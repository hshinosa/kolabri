## Context

Halaman detail kelas dosen sudah menampilkan kontrol group policy, AI guardrails, dan AI scaffolding dalam satu form. Nilai yang disimpan (`strict|balanced|relaxed`, `auto|early|late`, dan toggle enabled flags) sudah benar dan dipakai backend. Masalahnya ada pada presentasi: istilah yang muncul masih teknis, dan dropdown scaffolding tetap tampil saat `ai_scaffolding_enabled=false` meskipun tidak berdampak.

## Goals / Non-Goals

**Goals:**
- Membuat label guardrail dan scaffolding lebih mudah dipahami dosen dengan bahasa formal kampus.
- Menjelaskan dampak toggle dengan helper text singkat.
- Menyelaraskan hierarki UI scaffolding: enable dulu, baru pilih level.
- Menjaga seluruh value backend, request shape, dan perilaku enforcement tetap sama.

**Non-Goals:**
- Mengubah preset/value backend (`strict`, `balanced`, `relaxed`, `auto`, `early`, `late`).
- Mengubah logika save, validasi server, atau perilaku AI engine.
- Mendesain ulang keseluruhan halaman detail kelas.

## Decisions

### Keep backend enums, localize only the visible labels
Label dropdown akan berubah ke Bahasa Indonesia formal, tetapi `value` option tetap mengikuti kontrak backend saat ini. Ini memberi perbaikan UX tanpa risiko perubahan integrasi.

### Add helper text under each policy toggle
Toggle guardrail rewrite, flag-only, dan scaffolding enabled akan diberi helper text dua-baris atau kurang agar dosen memahami dampak pengaturan dari sudut pandang kelas, bukan mekanisme AI.

### Gate scaffolding level behind the enabled toggle
Field `ai_scaffolding_level` akan dirender hanya ketika `ai_scaffolding_enabled` bernilai true. Saat disabled, nilai level sebelumnya tetap dipertahankan di state dan payload, tetapi tidak ditampilkan karena tidak berpengaruh. Pendekatan ini menghindari reset konfigurasi tersembunyi.

## UX Copy Decisions

### Guardrail section
- `Preset guardrail AI` → `Tingkat pembatasan AI`
- `Strict` → `Ketat`
- `Balanced` → `Seimbang`
- `Relaxed` → `Fleksibel`
- `Izinkan AI me-rewrite jawaban agar tetap aman` → `Izinkan AI menyesuaikan jawaban ke bentuk yang aman`
- helper text rewrite: `Apabila mahasiswa mengajukan permintaan yang tidak layak dijawab secara langsung, AI tetap memberikan bantuan dalam bentuk arahan belajar, langkah penyelesaian, atau ringkasan konsep.`
- `Tandai saja konten non-kritis tanpa blok penuh` → `Untuk pelanggaran ringan, tampilkan peringatan tanpa memblokir respons`
- helper text flag-only: `AI tetap dapat merespons, tetapi sistem akan menandai interaksi yang perlu dicermati sesuai kebijakan kelas.`

### Scaffolding section
- `Level scaffolding AI` → `Tingkat pendampingan AI`
- `Auto (berdasarkan semester)` → `Otomatis menyesuaikan`
- `Early (lebih terarah & bertahap)` → `Pendampingan tinggi (lebih terarah dan bertahap)`
- `Late (lebih mandiri & sumber)` → `Pendampingan ringan (lebih mandiri)`
- `Aktifkan adaptasi scaffolding berdasarkan level` → `Izinkan AI menyesuaikan tingkat pendampingan sesuai kebutuhan belajar`
- helper text enabled: `Saat diaktifkan, AI dapat menyesuaikan seberapa rinci arahan yang diberikan agar selaras dengan tingkat kemandirian belajar mahasiswa.`
- helper text disabled: `AI tidak menyesuaikan tingkat pendampingan secara khusus.`

## Risks / Trade-offs

- Menyembunyikan dropdown saat disabled membuat user tidak melihat nilai terakhir. Ini disengaja karena nilainya tidak aktif; state tetap dipertahankan agar saat diaktifkan kembali pilihan sebelumnya masih ada.
- Helper text menambah tinggi form sedikit, tetapi trade-off ini layak untuk mengurangi ambiguitas.

## Verification Plan

- Tambah/ubah targeted frontend test untuk memastikan copy baru tampil.
- Verifikasi conditional rendering: dropdown scaffolding tidak tampil saat toggle mati dan muncul saat toggle hidup.
- Jalankan type check frontend dan targeted unit test terkait perubahan.
