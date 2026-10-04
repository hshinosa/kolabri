# RAG Ingest & Retrieve — Cara Membuat Dokumen yang Bisa Di-retrieve

Panduan praktis untuk mengisi basis pengetahuan (Qdrant) agar `@ai` di ruang diskusi bisa mengutip materi,
dan cara membuktikan retrieval-nya bekerja.

**Ringkas:** dokumen masuk lewat **materi kuliah** (upload dosen) atau endpoint internal `POST /api/ingest`.
Vektor disimpan per-kelas di collection `course_<course_id>`.

---

##1. Dari mana saja dokumen bisa masuk?

| Jalur | Endpoint | Dipakai oleh | Status |
|---|---|---|---|
| Upload materi (resmi) | `POST /lecturer/courses/{course}/materials` | UI dosen → tab Materials | ✅ berfungsi |
| Reindex materi lama | `POST /lecturer/courses/{course}/materials/{id}/reindex` | UI dosen → tombol reindex | ✅ berfungsi |
| Assign materi ke minggu | `POST /lecturer/courses/{course}/weeks/{week}/materials` | UI dosen → tab Minggu | ✅ berfungsi |
| Internal (Core API) | `POST /api/internal/knowledge-base/queue-course-material` | Client App (hook) | ✅ |
| AI Engine langsung | `POST /api/ingest` (multipart) | Core API | ✅ dipakai untuk diagnosis |

Tidak ada UI khusus "upload dokumen ke basis pengetahuan" — **materi kuliah adalah dokumen RAG**.
Materi yang belum di-assign ke minggu tetap bisa di-ingest (pool material).

---

##2. Alur resmi: upload materi → otomatis jadi vektor

1. Login dosen pemilik kelas, mis. `budi.santoso@univ.ac.id` / `password123`.
2. Buka **kela­s** → tab **Materials** → **Upload Materi**.
3. Pilih berkas (`.pdf`, `.docx`, `.pptx`, `.txt`, `.md`, `.zip`), isi judul, upload.
4. Sistem otomatis memanggil Core API → AI Engine → vektor masuk Qdrant.
5. Cek status di DB:

```sql
SELECT file_name, vector_status, error_message
FROM knowledge_bases
ORDER BY uploaded_at DESC LIMIT 5;
```

`vector_status` bernilai `pending` → `processing` → `ready` (berhasil) atau `failed`.

Bila `failed`, kolom `error_message` memuat sebabnya (lihat §6).

---

##3. Format dokumen yang menghasilkan retrieval bagus

Ukuran: 1 PDF ~3–25 KB di demo ini menghasilkan **2–3 chunk**; `MAX_CHUNK = 1200` karakter per chunk.

Struktur yang terbukti bekerja (dipakai `docs/sample-materials/`):

```markdown
MINGGU 1 — PENGENALAN DATA MINING
Mata kuliah: IF211 Data Mining
Tujuan bacaan: Memahami definisi, tujuan, dan kerangka kerja data mining.

1. Definisi dan Tujuan
Data mining adalah proses menemukan pola...

2. Kerangka Kerja CRISP-DM
1. Business Understanding ...
2. Data Understanding ...
3. Data Preparation ...
4. Modeling ...
5. Evaluation ...
6. Deployment ...

Untuk diskusi
- Mengapa preprocessing disebut langkah yang paling memakan waktu?
```

Praktik yang membantu retrievabilitas:

- **Judul eksplisit di baris pertama** — ikut tersimpan sebagai metadata `section`.
- **Istilah teknis persis** yang nanti dipakai di pertanyaan (`CRISP-DM`, `JWT`, `K-Means`).
- **Pisahkan antar-topik** dengan `---` atau heading; chunker memotong di batas itu.
- **Hindari tabel lebar / diagram berbasis gambar** — teks mudah, gambar butuh OCR (`perform_ocr=true`).
- Satu berkas = satu topik minggu. Jangan campur 3 minggu dalam 1 PDF.

Regenerate contoh PDF:

```bash
cd docs/sample-materials && python3 generate_pdfs.py
```

---

##4. Membuktikan retrieval bekerja

###4a. Retrieval murni (tanpa LLM) — paling cepat

```bash
ssh sumo1 'docker exec kolabri-ai-engine-1 python3 -c "
import asyncio
from app.services.vector_store import get_vector_store
async def main():
    vs = get_vector_store(); await vs.initialize()
    res = await vs.search(
        query=\"tahapan CRISP-DM dalam data mining\",
        collection_name=\"course_<COURSE_ID>\",
        n_results=3,
    )
    for r in res:
        print(r[\"score\"], r[\"metadata\"].get(\"file_id\"), (r[\"content\"] or \"\")[:150])
asyncio.run(main())
"'
```

Hasil nyata (terverifikasi 2026-10-04):

```
score=0.707 src=7fa3df0d-...  apakah model/jawaban memenuhi tujuan bisnis? 6. Deployment ? operasionalisasi ...
score=0.704 src=7fa3df0d-...  MINGGU 1 ? PENGENALAN DATA MINING Mata kuliah: IF211 Data Mining Tujuan bacaan: ...
```

###4b. End-to-end lewat `@ai` di ruang diskusi

Chat room → tulis `@ai <pertanyaan>` → jawaban streaming + panel **DIKUTIP DALAM DISKUSI** terisi.

⚠️ **Ketergantungan LLM:** bila provider kena rate limit (HTTP 429 → `LLMDegradedError`), endpoint
`POST /api/ask` mengembalikan `{"answer":"Maaf, saya tidak bisa menemukan jawaban...","error":"Internal error"}`
**meski retrieval berhasil**. Untuk memisahkan "RAG rusak" vs "LLM down", selalu cek log engine:

```bash
ssh sumo1 'docker logs --tail 100 kolabri-ai-engine-1 | grep -E "rag_search_started|reranking_completed|llm_request|LLMDegradedError"'
```

Urutan sukses: `rag_search_started` → `reranking_completed (original_count=N)` → `llm_request`.
Kalau `reranking_completed` muncul dengan `original_count>0`, **retrieval sehat**.

###4c. Cek langsung isi Qdrant

```bash
ssh sumo1 'curl -s http://127.0.0.1:16333/collections | python3 -m json.tool'
ssh sumo1 'curl -s http://127.0.0.1:16333/collections/course_<COURSE_ID> \
  | python3 -c "import sys,json;print(json.load(sys.stdin)[\"result\"][\"points_count\"])"'
```

---

##5. Endpoint manual (untuk diagnosis)

`POST /api/ingest` butuh header `Authorization: Bearer <CORE_API_SECRET>` (bukan `X-Internal-Secret`).

```bash
# dari dalam container ai-engine
docker cp file.pdf kolabri-ai-engine-1:/tmp/file.pdf
docker exec kolabri-ai-engine-1 python3 - <<'PY'
import urllib.request, uuid
SEC = "<CORE_API_SECRET>"          # lihat env kolabri-core-api-1
CID = "<course_id>"
body = b""
b = "----probe" + uuid.uuid4().hex
def part(name, value):
    return f"--{b}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n{value}\r\n".encode()
body += part("course_id", CID) + part("file_id", "probe-manual")
body += f"--{b}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"f.pdf\"\r\nContent-Type: application/pdf\r\n\r\n".encode()
body += open("/tmp/file.pdf", "rb").read() + b"\r\n" + f"--{b}--\r\n".encode()
req = urllib.request.Request("http://localhost:8001/api/ingest", data=body, headers={
    "Authorization": "Bearer " + SEC,
    "Content-Type": f"multipart/form-data; boundary={b}",
})
print(urllib.request.urlopen(req, timeout=300).read().decode())
PY
```

Ingest berjalan **di background** — respons `success:true` hanya berarti "dijadwalkan". Tunggu ~10–30 detik,
lalu cek `points_count` / `knowledge_bases.vector_status`.

Hapus vektor:

```bash
docker exec kolabri-ai-engine-1 python3 -c "
import asyncio
from app.services.vector_store import get_vector_store
async def main():
    vs = get_vector_store(); await vs.initialize()
    await vs.delete_documents(ids=['<file_id>'], collection_name='course_<COURSE_ID>')
asyncio.run(main())"
```

---

##6. Kalau `vector_status = failed` — diagnosa

| Gejala di `error_message` / log | Sebab | Perbaikan |
|---|---|---|
| `Source file not found on disk` | `file_path` di DB menunjuk lokasi yang tidak ada (mis. `/demo/kb/...`) | reindex; atau pastikan file ada di `/shared-storage` atau `/shared-storage-private` |
| `EACCES` / `Permission denied` / core-api tak bisa baca | Kepemilikan file: client-app jalan sebagai `www-data` (33), core-api sebagai `node` (uid 1000) | `sudo chmod -R 775` + `chown -R 33:33` pada `storage/app/private` |
| `Unable to create a directory at .../storage/app/private` | Folder `private` milik UID luar (1000), container tidak bisa menulis | idem di atas; cek dengan `namei -l` |
| `rate_limit_exceeded` / `429` | Provider LLM/embedding kena limit — **bukan** masalah ingest | tunggu, atau ganti provider aktif |

### Perbaikan permission standar (sumo1)

```bash
ssh sumo1 'sudo chown -R 33:33 /opt/kolabri/Kolabri-client-app/storage/app/private \
  && sudo find /opt/kolabri/Kolabri-client-app/storage/app/private -type d -exec chmod 775 {} \; \
  && sudo find /opt/kolabri/Kolabri-client-app/storage/app/private -type f -exec chmod 664 {} \;'
```

Verifikasi core-api bisa membaca berkasnya:

```bash
ssh sumo1 'docker exec kolabri-core-api-1 sh -lc "head -c 8 /shared-storage-private/materials/<course>/<file>"'
# harus tercetak: %PDF-1.4
```

---

##7. Arsitektur singkat

```
UI dosen (materials)
   └─ POST /lecturer/courses/{c}/materials
        └─ client-app simpan file → storage/app/private/materials/{course}/
        └─ CoreApiInternalClient → POST /api/internal/knowledge-base/queue-course-material
             └─ CourseMaterialKbService.upsertAndIngest()
                  └─ aiEngineService.ingestDocument() → multipart POST /api/ingest
                       └─ AI Engine: ekstrak teks → chunk (1200 char) → embed (voyage-3.5, 1024d)
                            └─ Qdrant collection course_<course_id>
                                 └─ retrieval: POST /api/ask → rerank → LLM
```

Client App **tidak** menyimpan basis pengetahuan sendiri; ia hanya BFF. Core API memegang tabel
`knowledge_bases` (status vektor), AI Engine memegang Qdrant.

---

##8. Temuan terkait (2026-10-04)

- **F5 — semua collection kosong.** Akar: file di `knowledge_bases.file_path` (`/demo/kb/...`) tidak ada
  di container, dan folder storage bermasalah permission. Setelah keduanya diperbaiki, ingest jalan.
- **Orphan vektor saat hapus materi.** `CourseMaterialKbService.softDeleteForCourseMaterial()` hanya
  melakukan soft-delete baris DB (`deletedAt` + `courseMaterialId → null`) dan **tidak** memanggil
  `aiEngineService.deleteDocument()`, sehingga vektor lama tetap di Qdrant. Jalur yang benar sudah ada di
  `knowledgeBase.service.ts:245` (`deleteFile`). Materi yang dihapus masih bisa muncul sebagai sitasi.
