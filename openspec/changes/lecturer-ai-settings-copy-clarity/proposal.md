## Why

Pengaturan AI pada detail kelas sudah fungsional, tetapi istilah yang tampil masih terlalu teknis untuk dosen. Label seperti "Preset guardrail AI", "me-rewrite", dan "Level scaffolding AI" memaksa dosen memahami mekanisme internal, bukan keputusan pedagogis yang sedang mereka atur. Selain itu, level scaffolding tetap terlihat saat fitur scaffolding dimatikan, sehingga menampilkan kontrol yang tidak berdampak.

## What Changes

- Perjelas copy pengaturan AI di halaman detail kelas dosen dengan bahasa formal kampus.
- Ubah istilah guardrail dan scaffolding menjadi istilah yang berorientasi kebijakan pembelajaran.
- Tambahkan helper text agar dampak setiap toggle dapat dipahami tanpa pengetahuan teknis.
- Tampilkan pilihan tingkat pendampingan AI hanya saat scaffolding diaktifkan.

## Capabilities

### New Capabilities
- `lecturer-ai-settings-copy-clarity`: Dosen dapat memahami dan mengatur kebijakan respons AI dengan istilah formal kampus dan hierarki UI yang lebih jelas.

### Modified Capabilities
- `settings`: Memperjelas presentasi pengaturan AI tingkat kelas tanpa mengubah kontrak API atau perilaku backend.

## Impact

- `Kolabri-client-app`: update copy UI lecturer course detail dan conditional rendering untuk kontrol scaffolding.
- Tidak ada perubahan API.
- Tidak ada perubahan database.
- Tidak ada perubahan perilaku enforcement AI.
