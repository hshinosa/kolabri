# Fix: Inertia Navigation Requires Manual Refresh

## Symptom

- Clicking buttons/links to another page does not visibly navigate.
- Creating a session keeps the modal open.
- Repeated clicks create multiple sessions, then they appear after refresh.
- Entering a class requires browser refresh before the page updates.

## Root Cause

Laravel generated HTTP URLs while the site was loaded over HTTPS.

Browser blocked Inertia SPA requests as mixed content:

```text
Mixed Content: The page at 'https://kolabri.web.id/login' was loaded over HTTPS,
but requested an insecure XMLHttpRequest endpoint 'http://kolabri.web.id/...'
```

So the backend action succeeded, but the Inertia response/XHR was blocked by the browser. UI state stayed stale until manual refresh.

The deployed `client-app` container had wrong runtime env from `docker-compose.yml`:

```yaml
APP_ENV: local
APP_DEBUG: "true"
APP_URL: http://localhost:8000
```

`APP_ENV=local` also disabled `TrustProxies` in `app/Http/Middleware/TrustProxies.php`, so Laravel did not trust `X-Forwarded-Proto: https` from nginx/Cloudflare.

## Fix

Patch `/opt/kolabri/docker-compose.yml` under `client-app.environment`:

```yaml
APP_ENV: production
APP_DEBUG: "false"
APP_URL: https://kolabri.web.id
```

Then recreate client app and clear Laravel cache:

```bash
cd /opt/kolabri
docker compose up -d --no-deps --force-recreate client-app
sleep 8
docker exec kolabri-client-app-1 php artisan optimize:clear
```

## Verification

Check runtime env:

```bash
docker exec kolabri-client-app-1 printenv | grep -E 'APP_ENV|APP_DEBUG|APP_URL'
```

Expected:

```text
APP_ENV=production
APP_DEBUG=false
APP_URL=https://kolabri.web.id
```

Check generated asset URLs are HTTPS:

```bash
curl -sS https://kolabri.web.id/login \
  | grep -Eo 'https?://kolabri.web.id[^" ]+' \
  | head -10
```

Expected: all URLs start with `https://kolabri.web.id`, not `http://`.

Browser verification:

1. Login as demo student.
2. Open a course.
3. Create one discussion session.
4. Modal should close or redirect immediately.
5. New session should appear without refresh.
6. Click session/class link. Page should change without manual refresh.
7. DevTools Console should have no mixed-content errors.

## If Bug Returns

Run these checks first:

```bash
ssh vpsgw
cd /opt/kolabri

docker exec kolabri-client-app-1 printenv | grep -E 'APP_ENV|APP_DEBUG|APP_URL'
curl -sS https://kolabri.web.id/login | grep -Eo 'https?://kolabri.web.id[^" ]+' | head -10
docker logs --tail 80 kolabri-client-app-1
```

Likely bad state:

```text
APP_URL=http://localhost:8000
```

or browser console:

```text
Mixed Content ... insecure XMLHttpRequest endpoint 'http://kolabri.web.id/...'
```

Fix with same `docker-compose.yml` env patch + `docker compose up -d --no-deps --force-recreate client-app`.

## Related Files

- `/opt/kolabri/docker-compose.yml`
- `Kolabri-client-app/app/Http/Middleware/TrustProxies.php`
- `Kolabri-client-app/resources/js/app.tsx`
- `Kolabri-client-app/resources/js/pages/student/courses/show.tsx`
