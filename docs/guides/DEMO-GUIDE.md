# Kolabri - Demo Flow untuk Sidang

**Platform**: Collaborative Learning Platform dengan AI-Powered Discussion Analysis  
**Tech Stack**: Laravel (BFF) + Express/TypeScript (Core API) + React + PostgreSQL + MongoDB

---

## 🚀 Cara Menjalankan Project

### Prerequisites
- PostgreSQL running (port 5432)
- MongoDB running (port 27017)
- Redis running (port 6379)
- Qdrant running (port 6333) - untuk vector store
- Node.js v18+
- PHP 8.2+
- Python 3.13+

### Step 1: Start AI Engine (Python)
```bash
cd Kolabri-ai-engine
pip install -r requirements.txt
python3 main.py
# Running on http://localhost:8001
```

### Step 2: Start Core API (Backend)
```bash
cd Kolabri-core-api
npm install
npm run dev
# Running on http://localhost:3000
```

### Step 3: Start Laravel BFF (Frontend Server)
```bash
cd Kolabri-client-app
composer install
npm install
npm run build
php artisan serve
# Running on http://localhost:8000
```

### Step 4: Seed Database (Test Data)
```bash
cd Kolabri-core-api
npm run db:seed
```

**Test Credentials**:
- **Lecturer**: `lecturer@kolabri.edu` / `password123`
- **Student**: `student1@kolabri.edu` / `password123`
- **Admin**: `admin@kolabri.id` / `password`

---

## 📋 Demo Flow untuk Sidang (10 MENIT TOTAL)

### 1️⃣ Landing Page & Login (30 detik)

**URL**: http://localhost:8000

**Action**:
1. Buka landing page (tunjukkan sekilas)
2. Klik "Masuk"
3. Login sebagai **Lecturer** (`lecturer@kolabri.edu` / `password123`)

---

### 2️⃣ Lecturer Dashboard (1 menit)

**URL**: http://localhost:8000/dashboard

**Demo Points**:
- ✅ Overview statistics (courses, students, groups)
- ✅ Recent activity feed
- ✅ Charts (class distribution, quality trends)

**Action**:
1. Tunjukkan dashboard overview (quick scan)
2. Highlight statistics
3. Langsung ke course list

---

### 3️⃣ Course List & Detail (1 menit)

**URL**: http://localhost:8000/lecturer/courses

**Action**:
1. Show course list
2. Pilih "Pemrograman Web"
3. Quick show: course info, groups, join code

---

### 4️⃣ AI-Powered Analytics (3 menit) ⭐ **MAIN HIGHLIGHT**

**URL**: http://localhost:8000/lecturer/courses/{id}/analytics

**Demo Points**:
- ✅ **Discussion Quality Metrics**:
  - Lexical variety (vocabulary richness)
  - HOT percentage (Higher Order Thinking)
  - Message count trends
- ✅ **Group Comparison Radar Chart** ⭐
- ✅ **AI Interventions** (automated feedback)

**Action**:
1. **Tunjukkan Radar Chart** - compare quality antar groups
2. **Explain 3 metrics**:
   - Lexical Variety: kekayaan vocabulary
   - HOT %: higher-order thinking
   - Message Count: aktivitas
3. **Show AI Interventions** - automated feedback

---

### 5️⃣ Student Experience (2.5 menit)

**Logout dan Login sebagai Student**

**Action**:
1. Logout, login sebagai student (`student1@kolabri.edu` / `password123`)
2. **Course Detail** (NEW FEATURE - 30 detik):
   - Show Minggu (Groups) list
   - Show Sesi Diskusi per minggu
3. **Dashboard Analytics** (NEW FEATURE - 1 menit) ⭐:
   - Personal metrics (weeks active, sessions joined)
   - Radar chart (personal performance)
   - Participation trend
4. **Real-time Chat** (1 menit):
   - Join discussion
   - Send message
   - Show real-time quality score updating

---

### 6️⃣ Admin Panel (2 menit)

**Logout dan Login sebagai Admin**

**URL**: http://localhost:8000/admin/dashboard

**Demo Points**:
- ✅ **AI Settings** ⭐ (ONLY HERE):
  - Multi-provider support (OpenAI, Claude, Gemini, Groq)
  - Fallback configuration
  - Usage statistics
- ✅ **User Management**
- ✅ **Audit Logs**

**Action**:
1. Login sebagai admin (`admin@kolabri.id` / `password`)
2. **Go to AI Settings** (1 menit):
   - Show provider list
   - Explain fallback mechanism
   - Show usage stats
3. Quick show user management & audit logs (30 detik)

---

## 🎯 Key Features untuk Highlight di Sidang

### 1. **AI-Powered Discussion Analysis** ⭐⭐⭐
- Real-time quality metrics
- Automated interventions
- Multi-dimensional analysis (lexical variety, HOT, engagement)

### 2. **Multi-Provider AI System** ⭐⭐ (Admin Only)
- Support 4+ AI providers
- Automatic fallback
- Cost optimization

### 3. **Real-time Collaboration** ⭐⭐
- WebSocket-based chat
- Live quality scoring
- Instant feedback

### 4. **Comprehensive Analytics** ⭐⭐
- Lecturer analytics (group comparison, trends)
- Student analytics (personal performance)
- Admin analytics (platform-wide)

---

## 📊 Technical Highlights untuk Sidang

### Architecture
- **BFF Pattern**: Laravel sebagai Backend-for-Frontend
- **Microservices**: Core API terpisah untuk scalability
- **Real-time**: WebSocket dengan Socket.IO
- **Database**: PostgreSQL (relational) + MongoDB (chat logs)

### Code Quality
- **AI Slop Score**: 3/100 (pristine) - exceptionally clean code
- **Type Safety**: Full TypeScript + PHP type hints
- **Error Handling**: Specific exception handling (no blanket catch-all)
- **Testing**: Unit tests + integration tests

### Performance
- **Caching**: Redis untuk session & cache
- **Optimization**: Database indexing, query optimization
- **Scalability**: Horizontal scaling ready

### Security
- **Authentication**: JWT-based with refresh tokens
- **Authorization**: Role-based access control
- **Input Validation**: Comprehensive validation
- **XSS Protection**: Sanitized inputs/outputs

---

## 🎬 Demo Script (10 MENIT)

**Intro (30 detik)**:
- "Kolabri adalah platform collaborative learning dengan AI-powered discussion analysis"
- "Saya akan demo 3 role: Lecturer, Student, dan Admin"

**Lecturer Flow (4.5 menit)**:
1. Login & Dashboard (1 min) - overview statistics
2. Course List & Detail (1 min) - quick navigation
3. **AI Analytics** ⭐ (2.5 min) - MAIN HIGHLIGHT
   - Radar chart comparison
   - Quality metrics explanation
   - AI interventions

**Student Flow (2.5 menit)**:
1. Login (10 detik)
2. **Course Detail** (NEW) (30 detik) - Minggu & Sesi
3. **Dashboard Analytics** (NEW) ⭐ (1 min) - personal metrics & radar
4. **Real-time Chat** (1 min) - live quality scoring

**Admin Flow (2 menit)**:
1. Login (10 detik)
2. **AI Settings** ⭐ (1 min) - multi-provider, fallback, usage stats
3. User Management & Audit Logs (30 detik) - quick show

**Wrap-up (1 menit)**:
- Technical highlights (architecture, code quality)
- Key features recap
- Q&A

---

## 🔧 Troubleshooting

### Server tidak jalan?
```bash
# Check ports
lsof -i :3000  # Core API
lsof -i :8000  # Laravel

# Restart
pkill -f "node.*3000"
pkill -f "php.*8000"
cd Kolabri-core-api && npm run dev &
cd Kolabri-client-app && php artisan serve &
```

### Database kosong?
```bash
cd Kolabri-core-api
npm run db:seed
```

### WebSocket error?
```bash
# Pastikan Core API running
curl http://localhost:3000/health
```

### Build error?
```bash
cd Kolabri-client-app
npm run build
php artisan cache:clear
```

---

## 📝 Notes untuk Sidang

1. **Prepare backup slides** - jika demo gagal
2. **Record demo video** - sebagai backup
3. **Test semua flow** sebelum sidang
4. **Prepare data** - pastikan ada discussion history untuk analytics
5. **Highlight AI features** - ini unique selling point
6. **Explain technical decisions** - kenapa BFF, kenapa multi-provider, dll

**Good luck! 🚀**
