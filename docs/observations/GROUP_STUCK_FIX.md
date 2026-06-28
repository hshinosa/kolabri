# Fix: Group Management Stuck on VPS

## Problem
Creating groups and assigning students stuck/hang di VPS production, tidak di local.

## Root Cause Analysis

### 1. Prisma Connection Pool Exhaustion
**Default:** 10 connections untuk PostgreSQL
- Multiple concurrent requests → pool habis
- Request baru wait forever (no timeout)

### 2. No Query Timeout
Prisma tidak punya query timeout default:
- Query lambat/hang → tidak pernah timeout
- Laravel HTTP timeout (10s) triggered → tapi frontend stuck

### 3. Low HTTP Timeout
`GroupController` pakai default `apiRequest()` → **10s timeout**
- Database operation bisa lebih lama di production
- Network latency VPS lebih tinggi

## Fixes

### Fix 1: Increase Prisma Connection Pool + Add Timeout

**File:** `Kolabri-core-api/.env.production`

```bash
# Sebelum:
DATABASE_URL="postgresql://postgres:password@postgres:5432/kolabri-db?schema=public"

# Setelah:
DATABASE_URL="postgresql://postgres:password@postgres:5432/kolabri-db?schema=public&connection_limit=20&pool_timeout=20&connect_timeout=10"
```

Parameter explanation:
- `connection_limit=20` → Pool size naik dari 10 ke 20
- `pool_timeout=20` → Wait max 20s untuk available connection
- `connect_timeout=10` → Max 10s untuk establish connection

### Fix 2: Increase Laravel HTTP Timeout untuk Group Operations

**File:** `Kolabri-client-app/app/Http/Controllers/GroupController.php`

```php
// Line 107 - store() method
public function store(Request $request, string $course)
{
    // ... validation ...

    try {
        // BEFORE: $response = $this->apiRequest()->post(...)
        // AFTER:
        $response = $this->apiRequest(timeout: 30, connectTimeout: 10)
            ->post($this->apiUrl() . "/api/courses/{$course}/groups", [
                'name' => $validated['name'],
            ]);

        // ... rest ...
    }
}

// Line 184 - addMembers() method
public function addMembers(Request $request, string $course, string $group)
{
    // ... validation ...

    try {
        // BEFORE: $response = $this->apiRequest()->post(...)
        // AFTER:
        $response = $this->apiRequest(timeout: 30, connectTimeout: 10)
            ->post($this->apiUrl() . "/api/courses/{$course}/groups/{$group}/members", [
                'member_ids' => $validated['member_ids']
            ]);

        // ... rest ...
    }
}
```

### Fix 3: Add Loading State Feedback (Optional)

**File:** `Kolabri-client-app/resources/js/pages/lecturer/groups/index.tsx`

Frontend sudah pakai `createForm.processing` dan `assignForm.processing` dari Inertia, tapi bisa tambah explicit timeout handling:

```typescript
const handleCreateGroup = (event: FormEvent) => {
    event.preventDefault();
    createForm.post(lecturer.groups.store.url({ course: course.id }), {
        onSuccess: () => {
            setShowCreateModal(false);
            createForm.reset();
            toast.success('Grup berhasil dibuat!');
        },
        onError: (errors) => {
            console.error('Create group error:', errors);
            toast.error('Gagal membuat grup. Coba lagi.');
        },
    });
};
```

## Testing Steps

### Local Test
```bash
# 1. Update DATABASE_URL di .env
DATABASE_URL="postgresql://postgres:123hshi@localhost:5432/kolabri-db?schema=public&connection_limit=20&pool_timeout=20&connect_timeout=10"

# 2. Restart core-api
cd Kolabri-core-api
npm run dev

# 3. Test create group dari lecturer UI
```

### VPS Deploy
```bash
# 1. Update .env.production di VPS
ssh vpsgw
cd /opt/kolabri
nano Kolabri-core-api/.env.production
# Add pool params ke DATABASE_URL

# 2. Update GroupController.php
# (scp file atau edit langsung)

# 3. Rebuild + restart
docker compose -f docker-compose.production.yml down
docker compose -f docker-compose.production.yml up -d --build

# 4. Test dari browser
```

## Verification

### Check Logs
```bash
# Core-API logs
docker logs --tail 100 -f kolabri-core-api

# Client-app logs  
docker logs --tail 100 -f kolabri-client-app

# PostgreSQL connections
docker exec kolabri-postgres psql -U postgres -d kolabri-db -c "SELECT count(*) FROM pg_stat_activity WHERE datname='kolabri-db';"
```

### Monitor Performance
```bash
# Watch active connections
watch -n 1 'docker exec kolabri-postgres psql -U postgres -d kolabri-db -c "SELECT count(*), state FROM pg_stat_activity WHERE datname='\''kolabri-db'\'' GROUP BY state;"'
```

## Additional Monitoring (Optional)

### Add Request Logging in GroupController

```php
use Illuminate\Support\Facades\Log;

public function store(Request $request, string $course)
{
    $startTime = microtime(true);
    Log::info('GroupController: Creating group', ['course' => $course]);
    
    try {
        $response = $this->apiRequest(timeout: 30, connectTimeout: 10)
            ->post($this->apiUrl() . "/api/courses/{$course}/groups", [
                'name' => $validated['name'],
            ]);
        
        $duration = round((microtime(true) - $startTime) * 1000, 2);
        Log::info('GroupController: Group created', ['duration_ms' => $duration]);
        
        // ... rest ...
    } catch (\Exception $e) {
        $duration = round((microtime(true) - $startTime) * 1000, 2);
        Log::error('GroupController: Create group failed', [
            'duration_ms' => $duration,
            'error' => $e->getMessage()
        ]);
        throw $e;
    }
}
```

## Expected Results

After fixes:
- ✅ Group creation completes dalam 5-15s (tergantung load)
- ✅ Member assignment completes dalam 3-10s
- ✅ No stuck/hang state
- ✅ Clear error messages jika timeout
- ✅ Connection pool tidak exhausted

## Rollback Plan

Jika fix menyebabkan issue:

```bash
# 1. Revert DATABASE_URL
DATABASE_URL="postgresql://postgres:password@postgres:5432/kolabri-db?schema=public"

# 2. Revert GroupController timeout ke default (10s)
$response = $this->apiRequest()->post(...)

# 3. Restart containers
docker compose -f docker-compose.production.yml restart core-api client-app
```
