# Client App — Scope & Boundaries

**Generated:** 2026-05-17  
**Scope:** Kolabri-client-app (`/Kolabri-client-app/`)  
**Purpose:** Mendefinisikan batasan pengembangan Client App agar development lanjutan tidak keluar dari scope arsitektur sistem.

---

## 1. Peran dalam Sistem

Client App adalah **BFF (Backend-for-Frontend) + UI Layer**. Bukan backend murni, bukan pure frontend. Dua tanggung jawab utamanya:

1. **Laravel** — session management, CSRF protection, proxy ke Core API, server-side rendering via Inertia.js
2. **React** — rendering UI, state management sisi client, real-time via Socket.IO client

```
Browser  →  Laravel (BFF)  →  Core API
              ↑
         Session, CSRF,
         Auth token mgmt
```

Client App **tidak pernah memanggil AI Engine langsung**. Semua AI-related request harus lewat Core API.

---

## 2. Batasan Interface

### Yang Boleh Dipanggil Client App

| Target | Protokol | Keterangan |
|---|---|---|
| Core API | HTTP REST | Semua data operations |
| Core API | Socket.IO | Real-time group chat |

### Yang TIDAK Boleh Dipanggil Client App

| Target | Alasan |
|---|---|
| AI Engine langsung | AI Engine hanya menerima request dari Core API |
| Database langsung | Tidak ada akses langsung ke PostgreSQL, MongoDB, Qdrant, Redis |
| LLM API langsung | Semua LLM calls harus lewat AI Engine via Core API |

---

## 3. Batasan Tanggung Jawab

### Yang Menjadi Tanggung Jawab Client App

| Domain | Deskripsi |
|---|---|
| **Session Management** | Login state, token storage, logout |
| **CSRF Protection** | Laravel middleware CSRF |
| **Auth Proxy** | Terima login → simpan token → forward ke Core API |
| **Role-based UI** | Render halaman berbeda untuk admin, lecturer, student |
| **UI Rendering** | Semua tampilan: dashboard, chat, analytics, forms |
| **Real-time Chat Client** | Socket.IO client untuk group chat |
| **File Upload UI** | Upload dokumen ke knowledge base (via Core API) |
| **Form Validation** | Client-side validation sebelum kirim ke Core API |

### Yang BUKAN Tanggung Jawab Client App

| Domain | Pemilik yang Benar |
|---|---|
| Business logic | Core API (service layer) |
| Data persistence | Core API → PostgreSQL / MongoDB |
| Auth token generation / verification | Core API |
| AI computation | AI Engine |
| Analytics computation | AI Engine |
| Document processing | AI Engine |
| Rate limiting untuk API | Core API |
| Audit logging | Core API |

> **Prinsip utama:** Jika ada logic yang bisa dijalankan di Core API, jangan taruh di Client App. Controller Laravel harus tipis — terima request, validasi, proxy, return response.

---

## 4. Struktur yang Harus Dipertahankan

### Laravel Controllers (sebagai proxy layer)

Controller Laravel harus mengikuti pola ini:

```php
// BENAR — controller tipis
public function store(Request $request) {
    $validated = $request->validate([...]);
    $response = $this->coreApiService->post('/courses', $validated);
    return back()->with('success', ...);
}

// SALAH — business logic di controller
public function store(Request $request) {
    // 50+ baris logic, kalkulasi, transformasi data...
}
```

### React Pages — Struktur per Role

```
resources/js/pages/
├── admin/          # Admin: dashboard, users, courses, AI providers, audit logs
├── lecturer/       # Lecturer: course management, groups, analytics
├── student/        # Student: chat spaces, AI assistant, reflections, goals
└── auth/           # Login, register
```

Jangan campur halaman antar role. Setiap role punya layout dan navigation sendiri.

### React Components — Struktur per Concern

```
resources/js/components/
├── ui/             # Shadcn/ui base components (Button, Card, Dialog, dll)
├── layout/         # Header, Sidebar, navigation
├── chat/           # ChatMessage, ChatInput, MessageList
├── analytics/      # Charts, metrics displays
└── forms/          # Form components dengan validation
```

---

## 5. Batasan Teknologi

| Komponen | Pilihan Saat Ini | Jangan Diganti Ke |
|---|---|---|
| Backend BFF | **Laravel 12** | Express, Next.js, Nuxt |
| Frontend | **React 19** + Inertia.js | Vue, Svelte, Angular |
| UI Library | **Shadcn/ui** | Material UI, Ant Design |
| Real-time | **Socket.IO client** | WebSocket raw, SSE |
| Type safety | **TypeScript ~95%** | Jangan turunkan coverage |
| Testing E2E | **Playwright** | Cypress, Selenium |

---

## 6. Batasan Fitur

### In Scope — Boleh Dikembangkan

- Tambah halaman baru sesuai role yang sudah ada (admin/lecturer/student)
- Improve UI/UX komponen yang sudah ada
- Tambah form validation yang lebih kuat
- Improve real-time chat experience
- Tambah analytics visualization baru (chart, metric)
- Code splitting / lazy loading untuk halaman besar
- Tambah component test React

### Out of Scope — Jangan Masuk ke Client App

- Business logic yang seharusnya di Core API service layer
- Kalkulasi analytics (harus di AI Engine, bukan di React)
- Direct database access
- LLM API calls
- Menambah role baru tanpa koordinasi dengan Core API dan AI Engine
- Fitur yang membutuhkan akses ke Qdrant, Redis, atau MongoDB langsung

---

## 7. Issues Open yang Harus Diselesaikan

### High Priority

| # | Issue | Action |
|---|---|---|
| 1 | Fat controllers Laravel | Extract business logic ke service layer |
| 2 | Duplikasi proxy pattern ke Core API | Buat shared `CoreApiService` wrapper |
| 3 | `@ts-ignore` di area legacy | Ganti dengan typing yang benar |
| 4 | Error handling tidak seragam antar controller | Standarkan error response mapping |

### Medium Priority

| # | Issue | Action |
|---|---|---|
| 5 | Tidak ada component test React | Tambah Vitest + React Testing Library |
| 6 | Tidak ada lazy loading | Implementasi code splitting untuk halaman besar |
| 7 | Potensi bundle growth | Review asset/bundle strategy |

### Low Priority

| # | Issue | Action |
|---|---|---|
| 8 | Tidak ada visual regression testing | Evaluasi Playwright visual comparison |

---

## 8. Checklist Sebelum Menambah Fitur Baru

- [ ] Apakah fitur ini adalah UI/UX atau BFF concern? (bukan business logic)
- [ ] Apakah controller Laravel tetap tipis setelah fitur ini ditambahkan?
- [ ] Apakah fitur ini memanggil Core API (bukan AI Engine atau database langsung)?
- [ ] Apakah TypeScript coverage tidak turun di bawah 95%?
- [ ] Apakah ada test (unit/component/e2e) untuk fitur ini?
- [ ] Apakah fitur ini mengikuti struktur role-based yang sudah ada?

---

## Referensi

- [FULL_INSPECTION_2026_05_17.md](./FULL_INSPECTION_2026_05_17.md)
- [KOLABRI_OBSERVATIONS_ACTION_ITEMS.md](./KOLABRI_OBSERVATIONS_ACTION_ITEMS.md)
- [KOLABRI_SEVERITY_BASED_OBSERVATIONS.md](./KOLABRI_SEVERITY_BASED_OBSERVATIONS.md)
- [CORE_API_SCOPE_BOUNDARIES.md](./CORE_API_SCOPE_BOUNDARIES.md)
