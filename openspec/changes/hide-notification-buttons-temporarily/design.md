## Context
Saat ini tombol bell notifikasi dipakai sebagai affordance UI terpisah dari halaman pengaturan preferensi notifikasi. Permintaan hanya untuk menyembunyikan tombol tersebut sementara.

## Decision
Tambahkan short-circuit render pada `NotificationsBell` agar komponen mengembalikan `null`.

## Rationale
- Diff paling kecil.
- Tidak perlu memburu semua callsite.
- Reversible saat fitur ingin diaktifkan lagi.
- Tidak mengubah kontrak data atau perilaku backend.

## Non-Goals
- Menghapus API notifikasi.
- Menghapus tab/panel preferensi notifikasi.
- Mengubah ikon/heading statis bertuliskan "Notifikasi" di settings.
