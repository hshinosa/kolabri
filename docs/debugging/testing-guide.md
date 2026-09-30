# Kolabri Debugging & Testing Guide

Dokumentasi lengkap untuk testing dan debugging setiap layer di sistem Kolabri menggunakan curl dan script.

## 📋 Daftar Isi

1. [Overview Arsitektur](#overview-arsitektur)
2. [Layer 1: AI Engine (FastAPI)](#layer-1-ai-engine-fastapi)
3. [Layer 2: Core API (Express.js)](#layer-2-core-api-expressjs)
4. [Layer 3: Client App (Laravel)](#layer-3-client-app-laravel)
5. [End-to-End Testing](#end-to-end-testing)
6. [Common Debugging Scenarios](#common-debugging-scenarios)
7. [Troubleshooting](#troubleshooting)

---

## Overview Arsitektur

```
┌─────────────────┐
│  Client App     │  Laravel (PHP)
│  Port: 8000     │  Session + CSRF Auth
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│  Core API       │  Express.js (Node.js)
│  Port: 3000     │  JWT Auth
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│  AI Engine      │  FastAPI (Python)
│  Port: 8001     │  Bearer Token Auth
└─────────────────┘
```

### Environment Variables Penting

```bash
# AI Engine
CORE_API_SECRET=kolabri-prod-core-secret-2026-06-16-abcdef1234567890
OPENAI_API_KEY=sk-ama
OPENAI_BASE_URL=http://43.228.214.145:8317/v1
OPENAI_MODEL=deepseek-v4-flash

# Core API
AI_ENGINE_URL=http://ai-engine:8001
JWT_SECRET=your-jwt-secret
CORE_API_SECRET=kolabri-prod-core-secret-2026-06-16-abcdef1234567890

# Client App
API_BASE_URL=http://core-api:3000
AI_ENGINE_URL=http://ai-engine:8001
```

---

## Layer 1: AI Engine (FastAPI)

### Health Check

```bash
# Dari host (jika port 8001 exposed)
curl -s http://localhost:8001/api/health | jq

# Dari dalam container lain (via Docker network)
docker exec kolabri-core-api-1 curl -s http://ai-engine:8001/api/health | jq
```

**Expected Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-06-18T02:30:00Z",
  "services": {
    "openai": true,
    "mongodb": true,
    "qdrant": true
  }
}
```

### List All Routes

```bash
# Get OpenAPI schema
curl -s http://localhost:8001/openapi.json | jq '.paths | keys'

# Filter specific routes
curl -s http://localhost:8001/openapi.json | jq '.paths | keys | .[] | select(contains("chat"))'
```

### Test AI Chat (Personal Stream)

```bash
# Set environment variables
export CORE_API_SECRET="kolabri-prod-core-secret-2026-06-16-abcdef1234567890"

# Test streaming endpoint
curl -X POST http://localhost:8001/api/chat/personal/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CORE_API_SECRET" \
  -d '{
    "message": "Apa itu algoritma?",
    "history": [],
    "course_ids": []
  }'
```

**Expected Response (SSE format):**
```
data: {"content": "Algoritma adalah..."}
data: {"content": " langkah-langkah..."}
data: [DONE]
```

### Test AI Chat (Non-Streaming) — DIHAPUS

Endpoint `POST /api/chat/personal` dan `POST /api/chat` sudah dihapus:
inference chat kini streaming-only. Endpoint lama mengembalikan **404**;
gunakan endpoint stream di atas.

### Test OpenAI Provider Directly

```bash
# Test models endpoint
curl -s http://43.228.214.145:8317/v1/models \
  -H "Authorization: Bearer sk-ama" | jq

# Test chat completion
curl -X POST http://43.228.214.145:8317/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-ama" \
  -d '{
    "model": "deepseek-v4-flash",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }' | jq
```

### Debug Script: AI Engine Full Test

```bash
#!/bin/bash
# Save as: test-ai-engine.sh

echo "=== AI Engine Debug Test ==="
echo ""

# 1. Health check
echo "1. Health Check:"
curl -s http://localhost:8001/api/health | jq '.status'
echo ""

# 2. List routes
echo "2. Available Routes:"
curl -s http://localhost:8001/openapi.json | jq -r '.paths | keys[]' | grep -E "(chat|health)" | head -10
echo ""

# 3. Test streaming
echo "3. Test Streaming Chat:"
curl -s -X POST http://localhost:8001/api/chat/personal/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CORE_API_SECRET" \
  -d '{"message": "Hello", "history": [], "course_ids": []}' | head -20
echo ""

# 4. Test OpenAI provider
echo "4. Test OpenAI Provider:"
curl -s http://43.228.214.145:8317/v1/models \
  -H "Authorization: Bearer sk-ama" | jq '.data | length'
echo ""

echo "=== Test Complete ==="
```

---

## Layer 2: Core API (Express.js)

### Health Check

```bash
# Public health endpoint
curl -s http://localhost:3000/health | jq
curl -s http://localhost:3000/api/health | jq
```

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-06-18T02:30:00Z",
  "services": {
    "postgres": "up",
    "mongodb": "up"
  }
}
```

### Authentication - Get JWT Token

```bash
# Login as student
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "andi.pratama@student.ac.id",
    "password": "password123"
  }' | jq

# Save token to variable
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "andi.pratama@student.ac.id", "password": "password123"}' \
  | jq -r '.token')

echo "Token: $TOKEN"
```

### Test AI Chat Endpoints

```bash
# List all chats
curl -s http://localhost:3000/api/ai-chats \
  -H "Authorization: Bearer $TOKEN" | jq

# Create new chat
CHAT_RESPONSE=$(curl -s -X POST http://localhost:3000/api/ai-chats \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Test Chat"}')

CHAT_ID=$(echo $CHAT_RESPONSE | jq -r '.data.id')
echo "Chat ID: $CHAT_ID"

# Send message (non-streaming)
curl -X POST http://localhost:3000/api/ai-chats/$CHAT_ID/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": "Apa itu machine learning?"}' | jq

# Send message (streaming)
curl -X POST http://localhost:3000/api/ai-chats/$CHAT_ID/messages/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": "Jelaskan tentang neural network"}'
```

### Test Course Endpoints

```bash
# List courses (lecturer)
curl -s http://localhost:3000/api/courses \
  -H "Authorization: Bearer $TOKEN" | jq '.data | length'

# Get course details
curl -s http://localhost:3000/api/courses/IF201 \
  -H "Authorization: Bearer $TOKEN" | jq

# List enrolled courses (student)
curl -s http://localhost:3000/api/courses/enrolled \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Test AI Provider Management

```bash
# List AI providers
curl -s http://localhost:3000/api/ai-providers \
  -H "Authorization: Bearer $TOKEN" | jq

# Test provider connection
curl -X POST http://localhost:3000/api/ai-providers/test \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"providerId": "openai"}' | jq
```

### Debug Script: Core API Full Test

```bash
#!/bin/bash
# Save as: test-core-api.sh

echo "=== Core API Debug Test ==="
echo ""

# 1. Health check
echo "1. Health Check:"
curl -s http://localhost:3000/health | jq '.status'
echo ""

# 2. Login
echo "2. Authentication:"
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "andi.pratama@student.ac.id", "password": "password123"}' \
  | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Login failed"
  exit 1
fi
echo "✅ Login successful"
echo ""

# 3. List courses
echo "3. List Courses:"
curl -s http://localhost:3000/api/courses/enrolled \
  -H "Authorization: Bearer $TOKEN" | jq '.data | length'
echo ""

# 4. Create AI chat
echo "4. Create AI Chat:"
CHAT_ID=$(curl -s -X POST http://localhost:3000/api/ai-chats \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Debug Test"}' | jq -r '.data.id')

if [ -z "$CHAT_ID" ] || [ "$CHAT_ID" = "null" ]; then
  echo "❌ Create chat failed"
  exit 1
fi
echo "✅ Chat created: $CHAT_ID"
echo ""

# 5. Send message
echo "5. Send Message (Streaming):"
curl -s -X POST http://localhost:3000/api/ai-chats/$CHAT_ID/messages/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": "Hello"}' | head -10
echo ""

echo "=== Test Complete ==="
```

---

## Layer 3: Client App (Laravel)

### Health Check

```bash
# Check if Laravel is responding
curl -s http://localhost:8000 | grep -o "<title>.*</title>"
```

### Authentication with CSRF

```bash
# Step 1: Get CSRF token and session cookie
CSRF_RESPONSE=$(curl -s -c /tmp/cookies.txt http://localhost:8000/login)
CSRF_TOKEN=$(echo "$CSRF_RESPONSE" | grep -o 'csrf-token.*content="[^"]*"' | cut -d'"' -f2)

echo "CSRF Token: $CSRF_TOKEN"

# Step 2: Login with CSRF
curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt \
  -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-CSRF-TOKEN: $CSRF_TOKEN" \
  -d '{
    "email": "andi.pratama@student.ac.id",
    "password": "password123"
  }' | jq
```

### Test AI Chat (with Session Auth)

```bash
# After login, access AI chat
curl -s -b /tmp/cookies.txt http://localhost:8000/student/ai-chat \
  -H "Accept: application/json" | jq

# Create new chat
CHAT_RESPONSE=$(curl -s -b /tmp/cookies.txt \
  -X POST http://localhost:8000/student/ai-chat \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"title": "Test Chat"}')

echo "$CHAT_RESPONSE" | jq

# Send streaming message
curl -s -b /tmp/cookies.txt \
  -X POST http://localhost:8000/student/ai-chat/{chat-id}/messages/stream \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"content": "Apa itu algoritma?"}'
```

### Test Course Pages

```bash
# Get course list
curl -s -b /tmp/cookies.txt http://localhost:8000/student/courses \
  -H "Accept: application/json" | jq '.props.courses'

# Get course detail
curl -s -b /tmp/cookies.txt http://localhost:8000/student/courses/IF201 \
  -H "Accept: application/json" | jq '.props.course'
```

### Debug Script: Client App Full Test

```bash
#!/bin/bash
# Save as: test-client-app.sh

echo "=== Client App Debug Test ==="
echo ""

# 1. Get CSRF token
echo "1. Get CSRF Token:"
CSRF_TOKEN=$(curl -s -c /tmp/cookies.txt http://localhost:8000/login | \
  grep -o 'csrf-token.*content="[^"]*"' | cut -d'"' -f2)

if [ -z "$CSRF_TOKEN" ]; then
  echo "❌ Failed to get CSRF token"
  exit 1
fi
echo "✅ CSRF Token obtained"
echo ""

# 2. Login
echo "2. Login:"
LOGIN_RESPONSE=$(curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt \
  -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-CSRF-TOKEN: $CSRF_TOKEN" \
  -d '{"email": "andi.pratama@student.ac.id", "password": "password123"}')

if echo "$LOGIN_RESPONSE" | grep -q "Redirecting"; then
  echo "✅ Login successful"
else
  echo "❌ Login failed:"
  echo "$LOGIN_RESPONSE" | jq
  exit 1
fi
echo ""

# 3. Access AI Chat
echo "3. Access AI Chat:"
CHAT_RESPONSE=$(curl -s -b /tmp/cookies.txt \
  http://localhost:8000/student/ai-chat \
  -H "Accept: application/json")

if echo "$CHAT_RESPONSE" | grep -q "props"; then
  echo "✅ AI Chat page loaded"
else
  echo "❌ Failed to load AI Chat"
  exit 1
fi
echo ""

# 4. List courses
echo "4. List Courses:"
curl -s -b /tmp/cookies.txt http://localhost:8000/student/courses \
  -H "Accept: application/json" | jq -r '.props.courses | length'
echo ""

echo "=== Test Complete ==="
```

---

## End-to-End Testing

### Full Stack AI Chat Test

```bash
#!/bin/bash
# Save as: test-e2e-ai-chat.sh

set -e

echo "=== End-to-End AI Chat Test ==="
echo ""

# Layer 1: AI Engine
echo "Layer 1: AI Engine"
echo "-------------------"
AI_HEALTH=$(curl -s http://localhost:8001/api/health | jq -r '.status')
echo "Status: $AI_HEALTH"

AI_CHAT=$(curl -s -X POST http://localhost:8001/api/chat/personal/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CORE_API_SECRET" \
  -d '{"message": "Test", "history": [], "course_ids": []}' | head -1)

if [ -n "$AI_CHAT" ]; then
  echo "✅ AI Engine responding"
else
  echo "❌ AI Engine failed"
  exit 1
fi
echo ""

# Layer 2: Core API
echo "Layer 2: Core API"
echo "-----------------"
CORE_HEALTH=$(curl -s http://localhost:3000/health | jq -r '.status')
echo "Status: $CORE_HEALTH"

TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "andi.pratama@student.ac.id", "password": "password123"}' \
  | jq -r '.token')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
  echo "✅ Core API authentication working"
else
  echo "❌ Core API authentication failed"
  exit 1
fi
echo ""

# Layer 3: Client App
echo "Layer 3: Client App"
echo "-------------------"
CSRF_TOKEN=$(curl -s -c /tmp/cookies.txt http://localhost:8000/login | \
  grep -o 'csrf-token.*content="[^"]*"' | cut -d'"' -f2)

if [ -n "$CSRF_TOKEN" ]; then
  echo "✅ Client App CSRF working"
else
  echo "❌ Client App CSRF failed"
  exit 1
fi
echo ""

echo "=== All Layers Healthy ==="
```

---

## Common Debugging Scenarios

### Scenario 1: AI Chat Not Responding

```bash
# Step 1: Check AI Engine health
curl -s http://localhost:8001/api/health | jq

# Step 2: Check if port 8001 is blocked by another service
sudo lsof -i :8001
# or
sudo netstat -tlnp | grep 8001

# Step 3: Test AI Engine directly from Core API container
docker exec kolabri-core-api-1 curl -s http://ai-engine:8001/api/health | jq

# Step 4: Check Core API logs
docker logs kolabri-core-api-1 --tail 50

# Step 5: Test streaming endpoint
curl -X POST http://localhost:8001/api/chat/personal/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CORE_API_SECRET" \
  -d '{"message": "Test", "history": [], "course_ids": []}'
```

### Scenario 2: Authentication Issues

```bash
# Check if user exists in database
docker exec kolabri-postgres-1 psql -U postgres -d kolabri-db \
  -c "SELECT id, email, role FROM users WHERE email = 'andi.pratama@student.ac.id';"

# Test JWT token manually
TOKEN="your-jwt-token-here"
curl -s http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq

# Check JWT secret
docker exec kolabri-core-api-1 printenv JWT_SECRET
```

### Scenario 3: Database Connection Issues

```bash
# Test PostgreSQL connection
docker exec kolabri-postgres-1 psql -U postgres -d kolabri-db -c "SELECT 1;"

# Test from Core API container
docker exec kolabri-core-api-1 curl -s http://localhost:3000/health | jq '.services.postgres'

# Check database logs
docker logs kolabri-postgres-1 --tail 50
```

### Scenario 4: Streaming Not Working in Browser

```bash
# Check if gizigo service is blocking port 8001
sudo lsof -i :8001

# Stop gizigo if running
sudo systemctl stop gizigo
# or
sudo kill $(pgrep -f "gizigo")

# Restart AI Engine container
cd /opt/kolabri && docker compose restart ai-engine

# Verify port is free
sudo lsof -i :8001
```

### Scenario 5: CORS Issues

```bash
# Test CORS headers
curl -I -X OPTIONS http://localhost:3000/api/health \
  -H "Origin: http://localhost:8000" \
  -H "Access-Control-Request-Method: GET"

# Check CORS config
docker exec kolabri-core-api-1 printenv CLIENT_URL
```

---

## Troubleshooting

### Container Won't Start

```bash
# Check container status
docker ps -a | grep kolabri

# View logs
docker logs kolabri-ai-engine-1 --tail 100

# Check resource usage
docker stats

# Restart all services
cd /opt/kolabri && docker compose restart
```

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :8001
sudo netstat -tlnp | grep 8001

# Kill process
sudo kill -9 <PID>

# Or stop service
sudo systemctl stop <service-name>
```

### Permission Denied

```bash
# Fix Docker socket permissions
sudo usermod -aG docker $USER
newgrp docker

# Fix file permissions
docker exec kolabri-client-app-1 chown -R www-data:www-data /var/www/html/storage
```

### Database Migration Issues

```bash
# Run migrations
docker exec kolabri-client-app-1 php artisan migrate --force

# Check migration status
docker exec kolabri-client-app-1 php artisan migrate:status

# Rollback last migration
docker exec kolabri-client-app-1 php artisan migrate:rollback --force
```

### Clear Cache

```bash
# Laravel cache
docker exec kolabri-client-app-1 php artisan cache:clear
docker exec kolabri-client-app-1 php artisan config:clear
docker exec kolabri-client-app-1 php artisan route:clear

# Redis cache
docker exec kolabri-redis-1 redis-cli FLUSHALL

# Browser cache
# Clear browser cache or use incognito mode
```

---

## Quick Reference

### Service URLs

| Service | Internal URL | External URL |
|---------|--------------|--------------|
| AI Engine | `http://ai-engine:8001` | `http://localhost:8001` |
| Core API | `http://core-api:3000` | `http://localhost:3000` |
| Client App | N/A | `http://localhost:8000` |
| PostgreSQL | `postgres:5432` | `localhost:5432` |
| Redis | `redis:6379` | `localhost:6379` |
| MongoDB | `mongodb:27017` | `localhost:27017` |

### Authentication Methods

| Service | Method | Header |
|---------|--------|--------|
| AI Engine | Bearer Token | `Authorization: Bearer $CORE_API_SECRET` |
| Core API | JWT | `Authorization: Bearer $TOKEN` |
| Client App | Session + CSRF | Cookie + `X-CSRF-TOKEN` |

### Common Test Accounts

```bash
# Student
email: andi.pratama@student.ac.id
password: password123

# Lecturer
email: budi.santoso@univ.ac.id
password: password123

# Admin
email: admin@kolabri.edu
password: password123
```

---

## Scripts Repository

Semua script di atas bisa disimpan di `scripts/debug/`:

```bash
scripts/debug/
├── test-ai-engine.sh
├── test-core-api.sh
├── test-client-app.sh
├── test-e2e-ai-chat.sh
└── README.md
```

### Usage

```bash
# Make scripts executable
chmod +x scripts/debug/*.sh

# Run individual tests
./scripts/debug/test-ai-engine.sh
./scripts/debug/test-core-api.sh
./scripts/debug/test-client-app.sh

# Run full E2E test
./scripts/debug/test-e2e-ai-chat.sh
```

---

## Last Updated

**Date:** 2026-06-18  
**Author:** AI Assistant  
**Status:** ✅ Complete and Tested
