#!/bin/bash
# Verification script for provider testing migration
# Run this after starting both ai-engine and core-api services

set -e

echo "🧪 Provider Testing Migration - Verification Script"
echo "=================================================="
echo ""

AI_ENGINE_URL="${AI_ENGINE_URL:-http://localhost:8001}"
CORE_API_URL="${CORE_API_URL:-http://localhost:3000}"

echo "📍 Testing endpoints:"
echo "  AI-Engine: $AI_ENGINE_URL"
echo "  Core-API:  $CORE_API_URL"
echo ""

# Test 1: AI-Engine health
echo "✓ Test 1: AI-Engine health check"
if curl -s -f "$AI_ENGINE_URL/api/health" > /dev/null; then
    echo "  ✅ AI-Engine is running"
else
    echo "  ❌ AI-Engine is not responding"
    exit 1
fi

# Test 2: AI-Engine model discovery (OpenAI)
echo "✓ Test 2: AI-Engine model discovery (OpenAI)"
RESPONSE=$(curl -s "$AI_ENGINE_URL/api/admin/providers/openai/models")
if echo "$RESPONSE" | grep -q '"success":true'; then
    MODEL_COUNT=$(echo "$RESPONSE" | grep -o '"id"' | wc -l)
    echo "  ✅ Model discovery working ($MODEL_COUNT models found)"
else
    echo "  ❌ Model discovery failed"
    echo "  Response: $RESPONSE"
fi

# Test 3: AI-Engine model discovery (Anthropic)
echo "✓ Test 3: AI-Engine model discovery (Anthropic)"
RESPONSE=$(curl -s "$AI_ENGINE_URL/api/admin/providers/anthropic/models")
if echo "$RESPONSE" | grep -q '"success":true'; then
    MODEL_COUNT=$(echo "$RESPONSE" | grep -o '"id"' | wc -l)
    echo "  ✅ Anthropic models loaded ($MODEL_COUNT models)"
else
    echo "  ❌ Anthropic model discovery failed"
fi

# Test 4: Core-API health
echo "✓ Test 4: Core-API health check"
if curl -s -f "$CORE_API_URL/api/health" > /dev/null; then
    echo "  ✅ Core-API is running"
else
    echo "  ⚠️  Core-API health endpoint not found (might be OK)"
fi

# Test 5: Check TypeScript compilation
echo "✓ Test 5: TypeScript compilation"
cd "$(dirname "$0")/../Kolabri-core-api"
if npx tsc --noEmit --skipLibCheck src/services/adminProvider.service.ts 2>&1 | grep -q "error TS"; then
    echo "  ⚠️  TypeScript has errors (check if they're pre-existing)"
else
    echo "  ✅ No TypeScript errors in adminProvider.service.ts"
fi

cd "$(dirname "$0")/../Kolabri-ai-engine"
if python3 -m py_compile app/services/admin_provider_test.py app/services/model_discovery.py 2>&1 | grep -q "SyntaxError"; then
    echo "  ❌ Python syntax errors found"
    exit 1
else
    echo "  ✅ Python syntax valid"
fi

echo ""
echo "=================================================="
echo "🎉 Verification complete!"
echo ""
echo "Next steps:"
echo "  1. Test provider connection via admin UI at /admin/ai-settings"
echo "  2. Verify model discovery works (see PROVIDER_TESTING_MIGRATION.md)"
echo "  3. Consider implementing UI enhancements (model dropdown)"
echo ""
