#!/usr/bin/env python3
"""
Generate professional UAT Word document for Kolabri (Mahasiswa)
"""

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.ns import qn
from docx.oxml import OxmlElement


def set_cell_border(cell, **kwargs):
    """Set cell border"""
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()

    for edge in ("start", "top", "end", "bottom", "insideH", "insideV"):
        edge_data = kwargs.get(edge)
        if edge_data:
            tag = "w:{}".format(edge)
            element = OxmlElement(tag)
            element.set(qn("w:val"), "single")
            element.set(qn("w:sz"), "4")
            element.set(qn("w:color"), "000000")
            tcPr.append(element)


def create_uat_document():
    doc = Document()

    # Set default font
    style = doc.styles["Normal"]
    font = style.font
    font.name = "Calibri"
    font.size = Pt(11)

    # Title
    title = doc.add_heading("User Acceptance Testing (UAT)", 0)
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER

    subtitle = doc.add_paragraph("Kolabri - Aplikasi Pembelajaran Kolaboratif")
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    subtitle.runs[0].font.size = Pt(14)
    subtitle.runs[0].font.bold = True

    target = doc.add_paragraph("Target User: Mahasiswa")
    target.alignment = WD_ALIGN_PARAGRAPH.CENTER
    target.runs[0].font.size = Pt(12)

    doc.add_paragraph()  # Spacing

    # Information section
    doc.add_heading("Informasi Testing", 1)
    info_table = doc.add_table(rows=5, cols=2)
    info_table.style = "Light Grid Accent 1"

    info_data = [
        ("Nama Sistem", "Kolabri"),
        ("Tanggal Testing", "____________"),
        ("Tester", "____________"),
        ("Versi", "____________"),
        ("Lingkungan", "Production / Staging"),
    ]

    for i, (label, value) in enumerate(info_data):
        info_table.rows[i].cells[0].text = label
        info_table.rows[i].cells[1].text = value
        info_table.rows[i].cells[0].paragraphs[0].runs[0].font.bold = True

    doc.add_paragraph()

    # Instructions
    doc.add_heading("Petunjuk Pengisian", 1)
    instructions = [
        'Centang (✓) pada kolom "Lolos" jika fitur berfungsi sesuai ekspektasi',
        'Centang (✗) pada kolom "Gagal" jika fitur tidak berfungsi',
        'Centang (-) pada kolom "N/A" jika fitur tidak diuji',
        'Tulis catatan pada kolom "Keterangan" jika diperlukan',
    ]
    for instruction in instructions:
        doc.add_paragraph(instruction, style="List Bullet")

    doc.add_page_break()

    # Test sections
    sections = [
        (
            "1. Autentikasi & Registrasi",
            [
                (
                    "1.1 Login",
                    [
                        (
                            "1.1.1",
                            "Login dengan email & password valid",
                            "1. Buka halaman login\n2. Masukkan email valid\n3. Masukkan password valid\n4. Klik tombol Login",
                            "User berhasil login dan diarahkan ke dashboard",
                        ),
                        (
                            "1.1.2",
                            "Login dengan email tidak valid",
                            "1. Buka halaman login\n2. Masukkan email tidak valid\n3. Masukkan password\n4. Klik tombol Login",
                            'Tampil pesan error "Email atau password salah"',
                        ),
                        (
                            "1.1.3",
                            "Login dengan password salah",
                            "1. Buka halaman login\n2. Masukkan email valid\n3. Masukkan password salah\n4. Klik tombol Login",
                            'Tampil pesan error "Email atau password salah"',
                        ),
                        (
                            "1.1.4",
                            "Login dengan Google",
                            '1. Buka halaman login\n2. Klik tombol "Login dengan Google"\n3. Pilih akun Google\n4. Berikan izin akses',
                            "User berhasil login dengan akun Google",
                        ),
                        (
                            "1.1.5",
                            "Rate limiting login",
                            "1. Coba login dengan password salah 5x berturut-turut",
                            'Akun terkunci sementara, tampil pesan "Terlalu banyak percobaan"',
                        ),
                    ],
                ),
                (
                    "1.2 Registrasi",
                    [
                        (
                            "1.2.1",
                            "Registrasi dengan data valid",
                            "1. Buka halaman registrasi\n2. Isi nama, email, password, konfirmasi password\n3. Klik Daftar",
                            "Akun berhasil dibuat, user diarahkan ke halaman verifikasi email",
                        ),
                        (
                            "1.2.2",
                            "Registrasi dengan email sudah terdaftar",
                            "1. Buka halaman registrasi\n2. Masukkan email yang sudah terdaftar\n3. Klik Daftar",
                            'Tampil pesan error "Email sudah terdaftar"',
                        ),
                        (
                            "1.2.3",
                            "Validasi password tidak cocok",
                            "1. Buka halaman registrasi\n2. Masukkan password dan konfirmasi yang berbeda\n3. Klik Daftar",
                            'Tampil pesan error "Password tidak cocok"',
                        ),
                    ],
                ),
                (
                    "1.3 Forgot Password",
                    [
                        (
                            "1.3.1",
                            "Request reset password",
                            '1. Klik "Lupa password"\n2. Masukkan email terdaftar\n3. Klik "Kirim Link Reset"',
                            "Email reset terkirim, tampil pesan konfirmasi",
                        ),
                        (
                            "1.3.2",
                            "Reset password dengan token valid",
                            '1. Buka link dari email\n2. Masukkan password baru\n3. Klik "Reset Password"',
                            "Password berhasil direset, user bisa login dengan password baru",
                        ),
                    ],
                ),
                (
                    "1.4 Logout",
                    [
                        (
                            "1.4.1",
                            "Logout dari sistem",
                            '1. Klik profil/avatar\n2. Klik "Logout"',
                            "User berhasil logout dan diarahkan ke halaman login",
                        ),
                    ],
                ),
            ],
        ),
        (
            "2. Dashboard",
            [
                (
                    "2.1 Dashboard Utama",
                    [
                        (
                            "2.1.1",
                            "Melihat dashboard",
                            "1. Login sebagai mahasiswa\n2. Akses halaman dashboard",
                            "Dashboard tampil dengan informasi: daftar kelas, aktivitas terbaru, notifikasi",
                        ),
                        (
                            "2.1.2",
                            "Navigasi ke kelas",
                            "1. Di dashboard, klik salah satu kelas",
                            "User diarahkan ke halaman detail kelas",
                        ),
                        (
                            "2.1.3",
                            "Melihat notifikasi",
                            "1. Klik ikon notifikasi di header",
                            "Dropdown notifikasi muncul dengan daftar notifikasi terbaru",
                        ),
                        (
                            "2.1.4",
                            "Menandai notifikasi sudah dibaca",
                            "1. Buka dropdown notifikasi\n2. Klik salah satu notifikasi",
                            "Notifikasi ditandai sebagai sudah dibaca",
                        ),
                    ],
                ),
            ],
        ),
        (
            "3. Courses (Kelas)",
            [
                (
                    "3.1 Daftar Kelas",
                    [
                        (
                            "3.1.1",
                            "Melihat daftar kelas yang diikuti",
                            "1. Navigasi ke /student/courses",
                            "Daftar kelas yang diikuti tampil",
                        ),
                        (
                            "3.1.2",
                            "Melihat detail kelas",
                            "1. Klik salah satu kelas dari daftar",
                            "Halaman detail kelas tampil dengan informasi: grup, sesi diskusi, materi",
                        ),
                    ],
                ),
                (
                    "3.2 Join Kelas",
                    [
                        (
                            "3.2.1",
                            "Join kelas dengan kode valid",
                            '1. Klik "Join Kelas"\n2. Masukkan kode kelas valid\n3. Klik "Join"',
                            "User berhasil bergabung dengan kelas",
                        ),
                        (
                            "3.2.2",
                            "Join kelas dengan kode tidak valid",
                            '1. Klik "Join Kelas"\n2. Masukkan kode kelas tidak valid\n3. Klik "Join"',
                            'Tampil pesan error "Kode kelas tidak valid"',
                        ),
                    ],
                ),
                (
                    "3.3 Course Weeks",
                    [
                        (
                            "3.3.1",
                            "Melihat daftar minggu",
                            "1. Di halaman detail kelas, navigasi ke tab Minggu",
                            "Daftar minggu perkuliahan tampil",
                        ),
                        (
                            "3.3.2",
                            "Melihat materi per minggu",
                            "1. Klik salah satu minggu",
                            "Daftar materi untuk minggu tersebut tampil",
                        ),
                    ],
                ),
            ],
        ),
        (
            "4. Groups (Kelompok)",
            [
                (
                    "4.1 Membuat Grup",
                    [
                        (
                            "4.1.1",
                            "Membuat grup baru",
                            '1. Di halaman detail kelas, klik "Buat Grup"\n2. Isi nama grup\n3. Klik "Buat"',
                            "Grup berhasil dibuat, user otomatis menjadi ketua",
                        ),
                        (
                            "4.1.2",
                            "Validasi nama grup kosong",
                            '1. Klik "Buat Grup"\n2. Kosongkan nama grup\n3. Klik "Buat"',
                            'Tampil pesan error "Nama grup wajib diisi"',
                        ),
                    ],
                ),
                (
                    "4.2 Join Grup",
                    [
                        (
                            "4.2.1",
                            "Join grup dengan kode undangan",
                            '1. Klik "Join Grup"\n2. Masukkan kode undangan valid\n3. Klik "Join"',
                            "User berhasil bergabung dengan grup",
                        ),
                        (
                            "4.2.2",
                            "Join grup dengan kode tidak valid",
                            '1. Klik "Join Grup"\n2. Masukkan kode tidak valid\n3. Klik "Join"',
                            'Tampil pesan error "Kode undangan tidak valid"',
                        ),
                    ],
                ),
                (
                    "4.3 Detail Grup",
                    [
                        (
                            "4.3.1",
                            "Melihat detail grup",
                            "1. Navigasi ke halaman grup",
                            "Detail grup tampil: nama, anggota, ketua, kode undangan",
                        ),
                        (
                            "4.3.2",
                            "Melihat daftar anggota",
                            "1. Di halaman grup, scroll ke bagian anggota",
                            "Daftar anggota grup tampil dengan nama dan role",
                        ),
                        (
                            "4.3.3",
                            "Copy kode undangan",
                            "1. Klik tombol copy di samping kode undangan",
                            "Kode undangan tersalin ke clipboard",
                        ),
                    ],
                ),
                (
                    "4.4 Manajemen Anggota (Ketua Grup)",
                    [
                        (
                            "4.4.1",
                            "Mengubah role anggota",
                            "1. Sebagai ketua, klik menu anggota\n2. Ubah role anggota",
                            "Role anggota berhasil diubah",
                        ),
                        (
                            "4.4.2",
                            "Mengeluarkan anggota (kick)",
                            '1. Sebagai ketua, klik menu anggota\n2. Klik "Keluarkan" pada anggota',
                            "Anggota berhasil dikeluarkan dari grup",
                        ),
                        (
                            "4.4.3",
                            "Mengundang anggota baru",
                            '1. Sebagai ketua, klik "Undang Anggota"\n2. Masukkan email anggota\n3. Klik "Undang"',
                            "Undangan terkirim ke email anggota",
                        ),
                    ],
                ),
                (
                    "4.5 Keluar dari Grup",
                    [
                        (
                            "4.5.1",
                            "Keluar dari grup (anggota biasa)",
                            '1. Klik "Keluar dari Grup"\n2. Konfirmasi',
                            "User berhasil keluar dari grup",
                        ),
                        (
                            "4.5.2",
                            "Ketua tidak bisa keluar",
                            '1. Sebagai ketua, cek tombol "Keluar dari Grup"',
                            "Tombol tidak tersedia atau ada peringatan harus menunjuk ketua baru",
                        ),
                    ],
                ),
                (
                    "4.6 Aktivitas Grup",
                    [
                        (
                            "4.6.1",
                            "Melihat aktivitas grup",
                            "1. Navigasi ke tab Aktivitas di halaman grup",
                            "Daftar aktivitas grup tampil (join, leave, create chat space, dll)",
                        ),
                    ],
                ),
            ],
        ),
        (
            "5. Chat Spaces (Ruang Diskusi)",
            [
                (
                    "5.1 Masuk ke Chat Room",
                    [
                        (
                            "5.1.1",
                            "Masuk ke chat room",
                            "1. Dari halaman kelas/grup, klik chat space",
                            "Chat room terbuka dengan daftar pesan",
                        ),
                        (
                            "5.1.2",
                            "Koneksi real-time",
                            "1. Masuk ke chat room\n2. Kirim pesan",
                            "Pesan langsung muncul di chat room (real-time)",
                        ),
                        (
                            "5.1.3",
                            "Connection banner",
                            "1. Masuk ke chat room\n2. Cek status koneksi",
                            "Banner koneksi tampil (connected/reconnecting/disconnected)",
                        ),
                    ],
                ),
                (
                    "5.2 Mengirim Pesan",
                    [
                        (
                            "5.2.1",
                            "Kirim pesan teks",
                            "1. Ketik pesan di input box\n2. Klik Send atau tekan Enter",
                            "Pesan terkirim dan muncul di chat",
                        ),
                        (
                            "5.2.2",
                            "Kirim pesan kosong",
                            "1. Klik Send tanpa mengetik apapun",
                            "Pesan tidak terkirim, input tetap kosong",
                        ),
                        (
                            "5.2.3",
                            "Upload file",
                            "1. Klik ikon attachment\n2. Pilih file\n3. Kirim",
                            "File berhasil diupload dan muncul di chat",
                        ),
                        (
                            "5.2.4",
                            "Upload file terlalu besar",
                            "1. Upload file > 10MB",
                            'Tampil pesan error "File terlalu besar"',
                        ),
                    ],
                ),
                (
                    "5.3 Edit & Hapus Pesan",
                    [
                        (
                            "5.3.1",
                            "Edit pesan sendiri",
                            '1. Klik menu pada pesan sendiri\n2. Pilih "Edit"\n3. Ubah teks\n4. Simpan',
                            'Pesan berhasil diedit, muncul label "(edited)"',
                        ),
                        (
                            "5.3.2",
                            "Hapus pesan sendiri",
                            '1. Klik menu pada pesan sendiri\n2. Pilih "Hapus"\n3. Konfirmasi',
                            "Pesan berhasil dihapus",
                        ),
                        (
                            "5.3.3",
                            "Tidak bisa edit pesan orang lain",
                            "1. Klik menu pada pesan orang lain",
                            'Opsi "Edit" tidak tersedia',
                        ),
                    ],
                ),
                (
                    "5.4 Pin Pesan",
                    [
                        (
                            "5.4.1",
                            "Pin pesan",
                            '1. Klik menu pada pesan\n2. Pilih "Pin"',
                            "Pesan di-pin dan muncul di bagian pinned messages",
                        ),
                        (
                            "5.4.2",
                            "Unpin pesan",
                            '1. Klik menu pada pesan yang sudah di-pin\n2. Pilih "Unpin"',
                            "Pesan di-unpin dan hilang dari pinned messages",
                        ),
                        (
                            "5.4.3",
                            "Melihat daftar pinned messages",
                            "1. Klik ikon pin di header chat",
                            "Daftar pesan yang di-pin tampil",
                        ),
                    ],
                ),
                (
                    "5.5 Search Pesan",
                    [
                        (
                            "5.5.1",
                            "Search pesan",
                            "1. Klik ikon search\n2. Ketik keyword\n3. Enter",
                            "Hasil search tampil dengan pesan yang mengandung keyword",
                        ),
                        (
                            "5.5.2",
                            "Search dengan keyword tidak ada",
                            "1. Search dengan keyword yang tidak ada di chat",
                            'Tampil pesan "Tidak ada hasil ditemukan"',
                        ),
                    ],
                ),
                (
                    "5.6 Tutup Sesi Diskusi",
                    [
                        (
                            "5.6.1",
                            "Tutup sesi diskusi",
                            '1. Klik "Tutup Sesi"\n2. Konfirmasi',
                            "Sesi ditutup, chat room menjadi read-only",
                        ),
                        (
                            "5.6.2",
                            "Lihat summary sesi",
                            '1. Setelah sesi ditutup, klik "Lihat Summary"',
                            "Summary sesi tampil dengan ringkasan diskusi",
                        ),
                    ],
                ),
            ],
        ),
        (
            "6. Pre-read (Materi Sebelum Sesi)",
            [
                (
                    "6.1 Melihat Pre-read",
                    [
                        (
                            "6.1.1",
                            "Akses pre-read",
                            "1. Dari halaman kelas, klik sesi yang memiliki pre-read",
                            "Halaman pre-read tampil dengan daftar materi",
                        ),
                        (
                            "6.1.2",
                            "Buka materi PDF",
                            "1. Klik materi PDF",
                            "PDF viewer terbuka dengan dokumen",
                        ),
                        (
                            "6.1.3",
                            "Buka materi video",
                            "1. Klik materi video",
                            "Video player terbuka",
                        ),
                    ],
                ),
                (
                    "6.2 Menyelesaikan Pre-read",
                    [
                        (
                            "6.2.1",
                            "Tandai pre-read selesai",
                            '1. Setelah melihat semua materi, klik "Selesai"',
                            "Pre-read ditandai selesai, user bisa lanjut ke sesi diskusi",
                        ),
                        (
                            "6.2.2",
                            "Pre-read belum selesai",
                            "1. Coba akses sesi diskusi tanpa menyelesaikan pre-read",
                            "User diarahkan kembali ke halaman pre-read",
                        ),
                    ],
                ),
            ],
        ),
        (
            "7. Goals (Tujuan Pembelajaran)",
            [
                (
                    "7.1 Membuat Goal",
                    [
                        (
                            "7.1.1",
                            "Membuat goal baru",
                            '1. Dari chat space, klik "Buat Tujuan"\n2. Isi tujuan pembelajaran\n3. Klik "Simpan"',
                            "Goal berhasil dibuat dan tersimpan",
                        ),
                        (
                            "7.1.2",
                            "Edit goal",
                            "1. Klik goal yang sudah dibuat\n2. Ubah teks\n3. Simpan",
                            "Goal berhasil diubah",
                        ),
                    ],
                ),
            ],
        ),
        (
            "8. Reflections (Refleksi)",
            [
                (
                    "8.1 Membuat Refleksi",
                    [
                        (
                            "8.1.1",
                            "Membuat refleksi baru",
                            '1. Navigasi ke /student/reflections\n2. Klik "Refleksi Baru"\n3. Isi judul dan konten\n4. Klik "Simpan"',
                            "Refleksi berhasil disimpan",
                        ),
                        (
                            "8.1.2",
                            "Refleksi dengan template",
                            '1. Klik "Refleksi Baru"\n2. Pilih template\n3. Isi sesuai template\n4. Simpan',
                            "Refleksi tersimpan dengan struktur template",
                        ),
                        (
                            "8.1.3",
                            "Tambah tag pada refleksi",
                            '1. Buat refleksi\n2. Tambah tag (misal: "belajar", "diskusi")\n3. Simpan',
                            "Tag tersimpan dan muncul di refleksi",
                        ),
                    ],
                ),
                (
                    "8.2 Melihat Daftar Refleksi",
                    [
                        (
                            "8.2.1",
                            "Melihat semua refleksi",
                            "1. Navigasi ke /student/reflections",
                            "Daftar semua refleksi tampil",
                        ),
                        (
                            "8.2.2",
                            "Filter refleksi berdasarkan tag",
                            "1. Klik tag di filter",
                            "Refleksi dengan tag tersebut tampil",
                        ),
                        (
                            "8.2.3",
                            "Search refleksi",
                            "1. Ketik keyword di search box",
                            "Refleksi yang mengandung keyword tampil",
                        ),
                    ],
                ),
                (
                    "8.3 Template Refleksi",
                    [
                        (
                            "8.4.1",
                            "Membuat template refleksi",
                            '1. Navigasi ke tab "Template"\n2. Klik "Template Baru"\n3. Isi nama dan pertanyaan\n4. Simpan',
                            "Template berhasil dibuat",
                        ),
                        (
                            "8.4.2",
                            "Edit template",
                            '1. Klik template yang ada\n2. Klik "Edit"\n3. Ubah pertanyaan\n4. Simpan',
                            "Template berhasil diubah",
                        ),
                        (
                            "8.4.3",
                            "Hapus template",
                            '1. Klik template\n2. Klik "Hapus"\n3. Konfirmasi',
                            "Template berhasil dihapus",
                        ),
                    ],
                ),
            ],
        ),
        (
            "9. AI Chat",
            [
                (
                    "9.1 Percakapan AI",
                    [
                        (
                            "9.1.1",
                            "Membuat chat baru",
                            '1. Navigasi ke /student/ai-chat\n2. Klik "Chat Baru"',
                            "Chat baru dibuat dan siap untuk percakapan",
                        ),
                        (
                            "9.1.2",
                            "Kirim pesan ke AI",
                            "1. Ketik pertanyaan di input box\n2. Klik Send",
                            "AI membalas dengan streaming response",
                        ),
                        (
                            "9.1.3",
                            "Streaming response",
                            "1. Kirim pesan ke AI\n2. Perhatikan response",
                            "Response muncul secara streaming (typewriter effect)",
                        ),
                        (
                            "9.1.4",
                            "Response dengan markdown",
                            "1. Tanya sesuatu yang butuh formatting (list, code, table)",
                            "Response AI ter-render dengan markdown yang benar",
                        ),
                    ],
                ),
                (
                    "9.2 Manajemen Chat",
                    [
                        (
                            "9.2.1",
                            "Lihat riwayat chat",
                            "1. Klik ikon menu/hamburger di AI chat",
                            "Sidebar riwayat chat muncul dengan daftar chat lama",
                        ),
                        (
                            "9.2.2",
                            "Buka chat lama",
                            "1. Klik salah satu chat di sidebar",
                            "Chat lama terbuka dengan riwayat percakapan",
                        ),
                        (
                            "9.2.3",
                            "Rename chat",
                            '1. Klik menu pada chat\n2. Pilih "Rename"\n3. Ubah nama\n4. Simpan',
                            "Nama chat berhasil diubah",
                        ),
                        (
                            "9.2.4",
                            "Hapus chat",
                            '1. Klik menu pada chat\n2. Pilih "Hapus"\n3. Konfirmasi',
                            "Chat berhasil dihapus",
                        ),
                    ],
                ),
                (
                    "9.3 Saved Materials (Materi Tersimpan)",
                    [
                        (
                            "9.3.1",
                            "Simpan materi dari AI response",
                            "1. AI memberikan response dengan sitasi materi\n2. Klik ikon bookmark pada sitasi",
                            "Materi tersimpan, ikon berubah menjadi filled",
                        ),
                        (
                            "9.3.2",
                            "Lihat daftar materi tersimpan",
                            "1. Klik ikon bookmark di header AI chat",
                            "Panel materi tersimpan terbuka dengan daftar materi",
                        ),
                        (
                            "9.3.3",
                            "Buka materi tersimpan",
                            "1. Di panel materi tersimpan, klik salah satu materi",
                            "Materi terbuka di tab baru",
                        ),
                        (
                            "9.3.4",
                            "Hapus materi tersimpan",
                            "1. Di panel materi tersimpan, klik ikon trash pada materi",
                            "Materi dihapus dari daftar tersimpan",
                        ),
                    ],
                ),
                (
                    "9.4 Search di AI Chat",
                    [
                        (
                            "9.4.1",
                            "Search percakapan AI",
                            "1. Klik ikon search di AI chat\n2. Ketik keyword\n3. Enter",
                            "Hasil search tampil dengan percakapan yang mengandung keyword",
                        ),
                    ],
                ),
            ],
        ),
        (
            "10. Profile (Profil)",
            [
                (
                    "10.1 Melihat Profil",
                    [
                        (
                            "10.1.1",
                            "Melihat profil",
                            "1. Navigasi ke /student/profile",
                            "Halaman profil tampil dengan informasi user",
                        ),
                        (
                            "10.1.2",
                            "Melihat statistik",
                            '1. Klik tab "Statistik" di profil',
                            "Statistik user tampil (jumlah refleksi, chat, dll)",
                        ),
                    ],
                ),
                (
                    "10.2 Edit Profil",
                    [
                        (
                            "10.2.1",
                            "Edit nama",
                            '1. Klik "Edit Profil"\n2. Ubah nama\n3. Simpan',
                            "Nama berhasil diubah",
                        ),
                        (
                            "10.2.2",
                            "Upload avatar",
                            "1. Klik avatar/foto profil\n2. Pilih file gambar\n3. Upload",
                            "Avatar berhasil diupload dan tampil",
                        ),
                        (
                            "10.2.3",
                            "Hapus avatar",
                            '1. Klik avatar\n2. Pilih "Hapus Avatar"',
                            "Avatar dihapus, kembali ke default",
                        ),
                    ],
                ),
                (
                    "10.3 Preferences",
                    [
                        (
                            "10.3.1",
                            "Ubah preferensi notifikasi",
                            "1. Navigasi ke preferensi\n2. Ubah setting notifikasi\n3. Simpan",
                            "Preferensi notifikasi berhasil diubah",
                        ),
                    ],
                ),
            ],
        ),
        (
            "11. Global Search",
            [
                (
                    "11.1 Pencarian Global",
                    [
                        (
                            "11.1.1",
                            "Search dari header",
                            "1. Klik ikon search di header\n2. Ketik keyword",
                            "Hasil search dari berbagai sumber (kelas, grup, refleksi, dll) tampil",
                        ),
                        (
                            "11.1.2",
                            "Filter hasil search",
                            "1. Setelah search, klik filter (kelas/grup/refleksi)",
                            "Hasil di-filter sesuai kategori",
                        ),
                    ],
                ),
            ],
        ),
    ]

    # Create test case tables for each section
    for section_title, subsections in sections:
        doc.add_heading(section_title, 1)

        for subsection_title, test_cases in subsections:
            doc.add_heading(subsection_title, 2)

            # Create table
            table = doc.add_table(rows=1, cols=7)
            table.style = "Light Grid Accent 1"

            # Header row
            header_cells = table.rows[0].cells
            headers = [
                "No",
                "Skenario",
                "Langkah",
                "Hasil yang Diharapkan",
                "Lolos",
                "Gagal",
                "Keterangan",
            ]
            for i, header in enumerate(headers):
                header_cells[i].text = header
                header_cells[i].paragraphs[0].runs[0].font.bold = True
                header_cells[i].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER

            # Set column widths
            widths = [
                Inches(0.5),
                Inches(1.5),
                Inches(2.0),
                Inches(2.0),
                Inches(0.5),
                Inches(0.5),
                Inches(1.0),
            ]
            for i, width in enumerate(widths):
                for cell in table.columns[i].cells:
                    cell.width = width

            # Add test cases
            for test_no, scenario, steps, expected in test_cases:
                row = table.add_row()
                row.cells[0].text = test_no
                row.cells[1].text = scenario
                row.cells[2].text = steps
                row.cells[3].text = expected
                row.cells[4].text = "☐"
                row.cells[5].text = "☐"
                row.cells[6].text = ""

                row.cells[0].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
                row.cells[4].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
                row.cells[5].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER

            doc.add_paragraph()  # Spacing

        doc.add_page_break()

    # Summary section
    doc.add_heading("Ringkasan Testing", 1)

    summary_table = doc.add_table(rows=1, cols=5)
    summary_table.style = "Light Grid Accent 1"

    summary_headers = ["Modul", "Total Test", "Lolos", "Gagal", "N/A"]
    for i, header in enumerate(summary_headers):
        summary_table.rows[0].cells[i].text = header
        summary_table.rows[0].cells[i].paragraphs[0].runs[0].font.bold = True
        summary_table.rows[0].cells[i].paragraphs[
            0
        ].alignment = WD_ALIGN_PARAGRAPH.CENTER

    summary_data = [
        ("1. Autentikasi & Registrasi", "11"),
        ("2. Dashboard", "4"),
        ("3. Courses", "6"),
        ("4. Groups", "12"),
        ("5. Chat Spaces", "15"),
        ("6. Pre-read", "5"),
        ("7. Goals", "2"),
        ("8. Reflections", "9"),
        ("9. AI Chat", "12"),
        ("10. Profile", "7"),
        ("11. Global Search", "2"),
    ]

    for module, count in summary_data:
        row = summary_table.add_row()
        row.cells[0].text = module
        row.cells[1].text = count
        row.cells[2].text = ""
        row.cells[3].text = ""
        row.cells[4].text = ""
        row.cells[1].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        row.cells[2].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        row.cells[3].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        row.cells[4].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER

    # Total row
    total_row = summary_table.add_row()
    total_row.cells[0].text = "TOTAL"
    total_row.cells[0].paragraphs[0].runs[0].font.bold = True
    total_row.cells[1].text = "84"
    total_row.cells[1].paragraphs[0].runs[0].font.bold = True
    for i in range(1, 5):
        total_row.cells[i].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER

    doc.add_paragraph()

    # Notes section
    doc.add_heading("Catatan & Rekomendasi", 1)
    doc.add_paragraph("_" * 80)
    doc.add_paragraph("_" * 80)
    doc.add_paragraph("_" * 80)

    doc.add_paragraph()

    # Signatures
    doc.add_heading("Tanda Tangan", 1)

    sig_table = doc.add_table(rows=4, cols=4)
    sig_table.style = "Light Grid Accent 1"

    sig_headers = ["", "Nama", "Tanggal", "Tanda Tangan"]
    for i, header in enumerate(sig_headers):
        sig_table.rows[0].cells[i].text = header
        sig_table.rows[0].cells[i].paragraphs[0].runs[0].font.bold = True

    sig_roles = ["Tester", "Developer", "Product Owner"]
    for i, role in enumerate(sig_roles, 1):
        sig_table.rows[i].cells[0].text = role
        sig_table.rows[i].cells[0].paragraphs[0].runs[0].font.bold = True

    # Save document
    output_path = "/Users/hshino/Kuliah/ProjectTA/docs/UAT_Mahasiswa_Kolabri.docx"
    doc.save(output_path)
    print(f"✓ UAT document saved to: {output_path}")


if __name__ == "__main__":
    create_uat_document()
