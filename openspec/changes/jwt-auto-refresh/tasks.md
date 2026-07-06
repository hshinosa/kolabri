## 1. Laravel Backend - JwtAuthMiddleware Proactive Refresh

- [x] 1.1 Add `proactiveRefresh()` method to `JwtAuthMiddleware.php` that calls Core API `/api/auth/refresh` with refresh token from session
- [x] 1.2 Modify JWT expiry handling: if expired + refresh_token exists → proactively refresh before controller runs
- [x] 1.3 Keep session cleanup when no refresh token exists or refresh fails

## 2. Laravel Backend - Refresh Endpoint (for Socket.io)

- [x] 2.1 Add `GET /api/auth/refresh-token` route in `routes/web.php`
- [x] 2.2 Implement `refreshToken()` method in `AuthController.php` that calls Core API refresh and updates session
- [x] 2.3 Return new token in response for frontend consumption
- [x] 2.4 Handle error cases: no refresh token, refresh failed, session expired

## 3. Frontend - Socket.io Fixes

- [x] 3.1 Update `getAuthToken.ts` to handle 401 response by redirecting to login + add `refreshAuthToken()` for socket reconnect
- [x] 3.2 Fix reserved `error` event → `server_error` in socket.io handler
- [x] 3.3 Change transport order to `['polling']` to avoid WebSocket upgrade failure
- [x] 3.4 Add `connect_error` guard to prevent transport upgrade errors from overriding working polling connection
- [x] 3.5 Add explicit token refresh call in `useSocketRoom.ts` on auth error before reconnect
- [x] 3.6 Fix `MutableRefObject` → `RefObject` for React 19

## 4. Core API - Socket.io Fixes

- [x] 4.1 Rename all `socket.emit('error', ...)` → `socket.emit('server_error', ...)` (reserved event fix)
- [x] 4.2 Add Vite dev server origins to CORS allowed list
- [x] 4.3 Change default transport order to `['polling', 'websocket']`

## 5. Cleanup

- [x] 5.1 Remove unused `TokenRefreshMiddleware.php` and its registration in `bootstrap/app.php`
- [x] 5.2 Remove unused `clearCachedToken()` from `getAuthToken.ts`
- [x] 5.3 Revert all controllers to original `$this->apiRequest()->get/post/etc` pattern

## 6. Testing & Verification

- [x] 6.1 Test refresh endpoint: token refresh via explicit call (cURL)
- [x] 6.2 Test proactive refresh: JWT expired + refresh_token → auto-refresh in middleware
- [x] 6.3 Test socket reconnect: `room_joined` fires, send button enabled
- [x] 6.4 Test chat send: type message → click Kirim → message appears
- [x] 6.5 Test edge cases: expired refresh token, revoked token
