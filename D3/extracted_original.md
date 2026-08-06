Capstone Project 
Final Report and Documentation


Web Chatbot Kolaboratif
(Kolabri)



Team Members:
Soraya Haidar Salma (1302223006) - System Analyst
Irham Baehaqi (1302220063) - Backend Developer (Chat & User Management)
Muhammad Hashfi Hadyan (1302220079) - Backend Developer (AI Integration & Analytics)
Mochammad Rizky Septian (1302220121) - Frontend Developer (Chat UI & Group Space)
Ahmad Fadli Akbar (1302220126) - Frontend Developer (Dashboard & Visualization)
Benedict Arvin Indra Puteprasa (1302223136) - QA Engineer




Program Studi Sarjana Rekayasa Perangkat Lunak
Fakultas Informatika
Universitas Telkom
2026
# Abstrak




[Berikan penjelasan singkat/abstraksi (up to 250 words) dari CP terkait dan solusi yang Anda tawarkan dalam menyelesaikan CP tsb. ]



Katakunci: [tuliskan kata kunci terkait CP yang akan dikerjakan]





# Background, Motivation, and Problem Definition

Background
Pembelajaran kolaboratif telah terbukti secara empiris memberikan dampak positif yang signifikan dalam ekosistem pendidikan tinggi, terutama dalam meningkatkan keterampilan berpikir kritis, kemampuan komunikasi, serta retensi pengetahuan mahasiswa. Meskipun manfaatnya sangat jelas, implementasi strategi ini di lingkungan akademik sering kali terhambat oleh tantangan sistemik yang mengurangi efektivitasnya. Hambatan ini tidak hanya bersifat pedagogis, tetapi juga menyentuh aspek teknis, sehingga menuntut adanya solusi terintegrasi yang mampu menjembatani teori pembelajaran dengan pemanfaatan teknologi cerdas.

Secara pedagogis, tantangan utama yang sering muncul adalah ketimpangan partisipasi (participation inequity) dalam diskusi kelompok. Fenomena seperti free-riding atau dominasi diskusi oleh segelintir anggota menyebabkan distribusi manfaat pembelajaran yang tidak merata di antara mahasiswa. Selain itu, diskusi sering kali melebar keluar dari topik (off-topic discussion), yang mengakibatkan inefisiensi waktu dan kegagalan dalam mencapai tujuan pembelajaran. Situasi ini diperburuk oleh keterbatasan kapasitas dosen dalam memantau dinamika multipel kelompok secara simultan, khususnya di kelas besar. Akibatnya, tanpa adanya dokumentasi dan ringkasan otomatis yang memadai, proses diskusi sering kali berlalu tanpa jejak rekam yang baik, menyulitkan proses refleksi maupun penilaian objektif.

Di sisi lain, kemajuan pesat Large Language Models (LLM) seperti Google Gemini membuka peluang baru untuk mengatasi hambatan tersebut melalui pengembangan agen pedagogis cerdas. Martha et al. (2023) telah membuktikan bahwa integrasi scaffolding adaptif dalam agen pedagogis dapat secara signifikan meningkatkan keterampilan Self-Regulated Learning (SRL) dan Co-Regulated Learning (CoRL). Potensi ini menawarkan jalan keluar bagi masalah monitoring dan fasilitasi diskusi, di mana AI dapat berperan sebagai fasilitator yang membantu menjaga fokus dan keseimbangan partisipasi dalam kelompok.

Namun, transisi menuju penerapan AI dalam pendidikan memerlukan penanganan tantangan teknis yang serius. Risiko utama yang dihadapi adalah "halusinasi" LLM, di mana model rentan menghasilkan informasi yang meyakinkan namun faktualnya keliru. Untuk memitigasi risiko ini, pendekatan Retrieval-Augmented Generation (RAG) menjadi krusial sebagaimana ditunjukkan oleh Lewis et al. (2021), karena mampu membatasi respons AI pada konteks dokumen yang valid. Lebih jauh lagi, pengembangan sistem ini menghadapi kompleksitas dalam Requirement Engineering, di mana metode Agile tradisional sering kali gagal menangani ketidakpastian spesifikasi sistem berbasis AI (Hoy & Xu, 2023). Oleh karena itu, diperlukan arsitektur sistem yang tidak hanya cerdas dan akurat, tetapi juga mampu menjamin integritas data melalui pembentukan log terstruktur yang kompatibel dengan standar Educational Process Mining untuk keperluan riset pedagogis yang valid.
Motivation
Proyek ini termotivasi oleh tiga kesenjangan (gaps) utama antara kebutuhan pedagogis dan solusi teknologi yang tersedia:
Gap Teoritis-Praktis: Teori regulasi belajar Zimmerman yang telah mapan secara teoretis (Forethought-Performance-Reflection) belum terimplementasi secara komprehensif dalam sistem chatbot edukasi. Sebagian besar chatbot yang ada hanya berfungsi sebagai question-answering system pasif, bukan sebagai fasilitator aktif yang mendukung seluruh siklus regulasi belajar.
Gap Teknologi: Sistem chatbot edukasi yang ada mayoritas tidak mengintegrasikan mekanisme RAG untuk mencegah halusinasi, tidak memiliki Logic Listener untuk deteksi dinamika kelompok secara real-time, dan tidak menghasilkan data log yang terstruktur untuk analisis pembelajaran.
Gap Infrastruktur Penelitian: Ketiadaan sistem yang menghasilkan data research-grade dengan struktur log yang mengikuti taksonomi standar (Gen-SRL) menyulitkan peneliti pendidikan untuk melakukan analisis kausal tentang efektivitas intervensi pembelajaran.
Problem Definition
Berdasarkan analisis latar belakang, proyek ini merumuskan permasalahan utama sebagai berikut:

Permasalahan Inti:
Bagaimana merancang dan mengimplementasikan sistem Web Chatbot Kolaboratif berbasis AI yang mampu:
Memfasilitasi tiga tingkat regulasi belajar (SRL, CoRL, SSRL) sesuai siklus Zimmerman
Mendeteksi dan mengintervensi dinamika kelompok yang tidak produktif (pasivitas, dominasi, off-topic) secara otomatis
Menjamin akurasi respons AI melalui RAG dan Guardrails
Menghasilkan data log terstruktur untuk keperluan monitoring dosen dan riset pedagogis

Sub-Permasalahan Spesifik per Role:
System Analyst (Soraya): Bagaimana menerjemahkan kebutuhan pedagogis abstrak (fase regulasi, deteksi off-topic) menjadi spesifikasi UML yang presisi dan implementable?
Backend AI (Hashfi): Bagaimana mengintegrasikan RAG dengan Guardrails berlapis untuk menjamin akurasi dan keamanan, serta merancang arsitektur asinkron yang scalable?
Backend Chat (Irham): Bagaimana membangun infrastruktur komunikasi real-time dengan latensi rendah yang mendukung transactional logging untuk integritas data?
Frontend Chat (Rizky): Bagaimana merancang antarmuka yang mendorong otonomi mahasiswa (SRL) dan memvisualisasikan intervensi SSRL secara intuitif?
Frontend Dashboard (Akbar): Bagaimana menyajikan data analitik kompleks (risiko kelompok, process mining) dalam visualisasi yang actionable bagi dosen?
QA (Arvin): Bagaimana memvalidasi fungsionalitas fitur cerdas (deteksi off-topic, scaffolding adaptif) dan integritas data log untuk riset?

# Team Members and Role

[Tuliskan identitas seluruh anggota kelompok serta perannya masing-masing. Berikan justifikasi setiap pembagian peran.]
# Related Works

[Tuliskan hasil karya atau projek yang terkait dengan TA Capstone yang akan Anda kerjakan.]
# Detailed Design and Specification

[Tuliskan secara detail mengenai desain dan spesifikasi kebutuhan yang Anda gunakan dalam menyelesaikan masalah TA Capstone yang akan Anda kerjakan.]
Detail spesifikasi (e.g., FR, NFR)
Detail Desain (system blueprint, e.g. structure and behavior, interface, etc)
# Development

[Tuliskan perkembangan yang terjadi selama menyelesaikan masalah TA Capstone yang Anda kerjakan.]
Lingkungan pengembangan (Hardware/Software yang dibutuhkan)
Proses pengembangan dan buktinya

# Evaluation Process, Result, and Analysis

[Tuliskan evaluasi dari proses, hasil, dan analisis yang Anda lakukan dalam menyelesaikan TA Capstone ini.]
Skenario evaluasi
Melakukan evaluasi
Hasil (temuan)
Analisis (menjawab pertanyaan mengapa)
# Challenges

[Tuliskan tantangan apa saja yang Anda hadapi selama menyelesaikan TA Capstone ini.]
# Conclusion

[Tuliskan kesimpulan dari penyelesaian TA Capstone yang Anda buat.]

# Annex (e.g. user manual)

[Lampiran.]



# Referensi

[Tuliskan daftar referensi yang digunakan dalam penulisan dokumen ini.]












