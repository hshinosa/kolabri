#!/bin/bash
# Ingest all demo PDFs into Qdrant via AI Engine /api/ingest
# Run from project root: ./scripts/ingest-rag-materials.sh

set -e

AI_ENGINE_URL="${AI_ENGINE_URL:-http://localhost:8001}"
AI_ENGINE_SECRET="${AI_ENGINE_SECRET:-shared-secret-key}"
QDRANT_URL="${QDRANT_URL:-http://localhost:6333}"
PDF_DIR="Kolabri-client-app/storage/app/public/demo-materials"
CLIENT_DB_HOST="127.0.0.1"
CLIENT_DB_PORT="5432"
CLIENT_DB_NAME="kolabri-db"
CLIENT_DB_USER="postgres"
CLIENT_DB_PASS="${CLIENT_DB_PASS:-123hshi}"

echo "🔍 Fetching course-week-material mapping from MySQL..."

MAPPING=$(PGPASSWORD="$CLIENT_DB_PASS" psql -h "$CLIENT_DB_HOST" -p "$CLIENT_DB_PORT" -U "$CLIENT_DB_USER" -d "$CLIENT_DB_NAME" -t -A -F'|' -c "
SELECT
    cw.course_id,
    cw.week_index,
    cw.id as week_id,
    cm.id as material_id,
    cm.file_path
FROM course_weeks cw
JOIN course_week_materials cwm ON cwm.course_week_id = cw.id
JOIN course_materials cm ON cm.id = cwm.course_material_id
ORDER BY cw.course_id, cw.week_index, cm.id;
")

if [ -z "$MAPPING" ]; then
    echo "❌ No materials found in database. Run seed first."
    exit 1
fi

TOTAL=$(echo "$MAPPING" | wc -l | tr -d ' ')
echo "📚 Found $TOTAL materials to ingest"
echo "🤖 AI Engine: $AI_ENGINE_URL"
echo ""

SUCCESS=0
FAILED=0
SKIPPED=0

while IFS='|' read -r course_id week_index week_id material_id file_path; do
    filename=$(basename "$file_path")
    full_path="$PDF_DIR/$filename"

    if [ ! -f "$full_path" ]; then
        echo "⚠️  SKIP: $filename (file not found at $full_path)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    extra_metadata="{\"week_index\":$week_index,\"week_id\":\"$week_id\",\"course_material_id\":\"$material_id\"}"

    echo -n "📤 [$((SUCCESS + FAILED + SKIPPED + 1))/$TOTAL] $filename (course: ${course_id:0:8}..., week: $week_index) ... "

    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AI_ENGINE_URL/api/ingest" \
        -H "Authorization: Bearer $AI_ENGINE_SECRET" \
        -F "file=@$full_path" \
        -F "course_id=$course_id" \
        -F "file_id=$material_id" \
        -F "extra_metadata=$extra_metadata" 2>&1)

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
        echo "✅ ($HTTP_CODE)"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "❌ ($HTTP_CODE) $BODY"
        FAILED=$((FAILED + 1))
    fi

    sleep 0.5
done <<< "$MAPPING"

echo ""
echo "========================================="
echo "✅ Success: $SUCCESS"
echo "❌ Failed:  $FAILED"
echo "⚠️  Skipped: $SKIPPED"
echo "========================================="

echo ""
echo "⏳ Waiting 10s for background processing..."
sleep 10

echo "📊 Qdrant collection status:"
curl -s "$QDRANT_URL/collections" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for c in data.get('result', {}).get('collections', []):
    name = c['name']
    if name.startswith('course_'):
        print(f'  {name}')
" 2>/dev/null || echo "  (could not fetch Qdrant collections)"

echo ""
echo "Done! Test the AI chat to verify materials are accessible."
