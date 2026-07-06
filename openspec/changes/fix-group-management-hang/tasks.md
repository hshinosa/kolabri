## 1. Database Configuration

- [ ] 1.1 Update Kolabri-core-api/.env.production DATABASE_URL to include connection pool parameters: connection_limit=20&pool_timeout=20&connect_timeout=10
- [ ] 1.2 Document connection pool parameters in Kolabri-core-api/.env.example with explanation comments
- [ ] 1.3 Verify Core API can parse the updated DATABASE_URL without errors

## 2. HTTP Timeout Configuration

- [ ] 2.1 Update GroupController store() method to use apiRequest(timeout: 30, connectTimeout: 10)
- [ ] 2.2 Update GroupController addMembers() method to use apiRequest(timeout: 30, connectTimeout: 10)

## 3. Verification

- [ ] 3.1 Test group creation locally - verify completes successfully
- [ ] 3.2 Test member assignment locally - verify completes successfully
- [ ] 3.3 Deploy to VPS and test group operations in production
- [ ] 3.4 Verify no hangs - operations complete or fail within 30 seconds
