## Context

Halaman Profile (`/student/profile`) saat ini menampilkan informasi dasar mahasiswa (nama, NIM, email). Peningkatan ini menambah personalisasi, umpan balik aktivitas, dan kontrol preferensi untuk meningkatkan sense of ownership.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **Storage**: Laravel Storage (S3 atau local) untuk avatar

## Goals / Non-Goals

**Goals:**
- Avatar mudah diunggah dan diperbarui dengan validasi yang jelas
- Statistik aktivitas memberikan gambaran belajar yang mudah dipahami
- Preferensi pengguna tersimpan konsisten dan diterapkan di seluruh aplikasi

**Non-Goals:**
- Tidak menambah fitur sosial publik tingkat lanjut (posting, follow)
- Tidak menambah marketplace tema profil
- Tidak menambah fitur edit informasi akademik (NIM, jurusan) — ini diatur admin

## Decisions

### 1. Upload avatar terkontrol
- Format yang diizinkan: JPEG, PNG, WebP
- Ukuran maksimal: 2MB
- Dimensi: minimal 100x100px, maksimal 2000x2000px
- Opsi crop ringan sebelum simpan (client-side)
- Resize otomatis ke beberapa ukuran (thumbnail, medium, large)
- Hapus avatar lama saat upload baru

### 2. Statistik aktivitas ringkas
- **Course aktif**: Jumlah mata kuliah yang sedang berjalan
- **Tugas selesai**: Jumlah tugas yang sudah dikumpulkan
- **Streak aktivitas**: Hari berturut-turut mengakses platform
- **Total refleksi**: Jumlah refleksi yang sudah ditulis
- **Waktu belajar**: Estimasi total waktu belajar (jika data tersedia)
- Data di-aggregate dari tabel yang sudah ada

### 3. Preferensi tersentralisasi
- **Notifikasi**:
  - Email notifications (on/off)
  - Push notifications (on/off)
  - Notifikasi tugas (on/off)
  - Notifikasi chat (on/off)
  - Notifikasi grup (on/off)
- **Bahasa**:
  - Bahasa Indonesia
  - English
- **Tampilan**:
  - Tema: Light, Dark, System
  - Ukuran font: Kecil, Normal, Besar
- Preferensi disimpan di tabel `user_preferences`
- Diterapkan saat login dan saat berubah

### 4. Avatar pipeline
- Upload ke temporary storage → crop/resize → simpan ke final storage
- Generate multiple sizes: 50x50 (thumbnail), 200x200 (medium), 500x500 (large)
- URL avatar menggunakan CDN (jika tersedia)
- Fallback ke inisial nama jika tidak ada avatar

### 5. Real-time stats
- Statistik di-fetch saat halaman dimuat
- Cache hasil aggregate untuk performa
- Update cache saat ada perubahan data terkait

## Component Architecture

```
student/profile/
├── index.tsx                    # Halaman profil
├── components/
│   ├── AvatarSection.tsx        # Section avatar dengan upload
│   │   ├── AvatarUpload.tsx     # Komponen upload dengan crop
│   │   └── AvatarDisplay.tsx    # Tampilan avatar dengan fallback
│   ├── InfoSection.tsx          # Informasi dasar (read-only)
│   ├── StatsSection.tsx         # Statistik aktivitas
│   │   └── StatCard.tsx         # Kartu statistik individual
│   └── PreferencesSection.tsx   # Pengaturan preferensi
│       ├── NotificationPrefs.tsx # Preferensi notifikasi
│       ├── LanguagePrefs.tsx     # Preferensi bahasa
│       └── ThemePrefs.tsx        # Preferensi tampilan
└── hooks/
    ├── useProfile.ts            # Hook untuk data profil
    └── usePreferences.ts        # Hook untuk preferensi
```

## API Contracts

### Get Profile
```
GET /api/student/profile
Response: {
  id, name, email, nim, avatar_url,
  stats: { active_courses, completed_tasks, streak, total_reflections, study_hours }
}
```

### Upload Avatar
```
POST /api/student/profile/avatar
Content-Type: multipart/form-data
Body: { avatar: File, crop_x, crop_y, crop_width, crop_height }
Response: { avatar_url: { thumbnail, medium, large } }
```

### Delete Avatar
```
DELETE /api/student/profile/avatar
Response: { success: true }
```

### Get Preferences
```
GET /api/student/profile/preferences
Response: {
  notifications: { email, push, tasks, chat, groups },
  language: "id"|"en",
  theme: "light"|"dark"|"system",
  font_size: "small"|"normal"|"large"
}
```

### Update Preferences
```
PATCH /api/student/profile/preferences
Body: { notifications?, language?, theme?, font_size? }
Response: { success: true, preferences: {...} }
```

## Data Model

```sql
-- Tambah kolom pada users (jika belum ada)
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500) NULL;
ALTER TABLE users ADD COLUMN avatar_thumbnail VARCHAR(500) NULL;

-- Tabel preferensi
CREATE TABLE user_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) UNIQUE,
    notifications_email BOOLEAN DEFAULT TRUE,
    notifications_push BOOLEAN DEFAULT TRUE,
    notifications_tasks BOOLEAN DEFAULT TRUE,
    notifications_chat BOOLEAN DEFAULT TRUE,
    notifications_groups BOOLEAN DEFAULT TRUE,
    language VARCHAR(10) DEFAULT 'id',
    theme VARCHAR(20) DEFAULT 'system',
    font_size VARCHAR(20) DEFAULT 'normal',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabel streak tracking
CREATE TABLE user_activity_streak (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    activity_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, activity_date)
);

-- Index untuk statistik
CREATE INDEX idx_activity_streak_user ON user_activity_streak(user_id, activity_date DESC);
```

## Risks / Mitigasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Berkas avatar tidak valid atau berbahaya | Security | Validasi MIME type + ukuran di client dan server, scan malware |
| Crop di client tidak akurat | UX buruk | Server-side resize sebagai fallback |
| Statistik tidak akurat | Kepercayaan turun | Validasi data, cache invalidation saat data berubah |
| Preferensi tidak diterapkan | Inkonsistensi | Apply preference saat login dan saat berubah |

## Rollout Plan

1. **Phase 1**: Upload avatar dengan validasi dan crop
2. **Phase 2**: Statistik aktivitas
3. **Phase 3**: Pengaturan preferensi

Setiap phase dilakukan validasi UX dan security review.
