# Review akhir hostile dan risiko sidang TA

Dokumen ini ditulis dari sudut pandang dosen penguji yang kritis, teliti, dan cenderung mencari celah. Fokusnya bukan lagi memperbaiki implementasi, tetapi menilai apakah naskah TA tentang AI Engine Kolabri cukup aman dipertahankan di sidang.

Ruang lingkup dokumen ini hanya AI Engine. Jangan tarik pembelaan ke Core API atau Client App kecuali sekadar konteks sistem, karena naskah TA memang tidak sedang mengklaim kontribusi utama di sana.

## Ringkasan putusan

Secara umum, naskah sudah lebih defensible dibanding versi sebelumnya. Kontradiksi besar seperti SQL vs NoSQL, jumlah E2E, threshold silence, dan klaim circuit breaker sudah jauh lebih rapi. Masalah utamanya sekarang bukan lagi "tesis ini salah secara teknis", tetapi "apakah bukti penelitian cukup kuat untuk mendukung klaim yang ditulis".

Kalau saya menjadi penguji, titik tekan saya akan ada di empat hal:

1. Jarak antara metodologi di Bab 3 dan hasil aktual di Bab 4.
2. Klaim H1 yang terlalu kuat jika hanya dibuktikan dengan sedikit query real-data.
3. Penggunaan coverage dan jumlah test sebagai bukti kualitas ilmiah, padahal itu lebih tepat disebut bukti kualitas perangkat lunak.
4. Validasi Logic Listener yang masih tampak fungsional, belum benar-benar ilmiah karena tidak ada precision, recall, atau gold standard.

Tesis ini masih bisa dipertahankan, tetapi pembelaannya harus disiplin. Jangan membesar-besarkan kontribusi. Jangan bilang "terbukti secara umum". Katakan bahwa sistem berhasil diimplementasikan dan dievaluasi pada skenario yang dibatasi.

## Abstrak

### Risiko utama

Tinggi sampai sangat tinggi. Abstrak adalah tempat pertama penguji membentuk ekspektasi. Kalau abstrak terdengar terlalu besar, seluruh sidang akan bergerak untuk menjatuhkan klaim itu.

### Serangan yang mungkin muncul

Penguji kemungkinan akan membaca abstrak sebagai janji ilmiah. Kalau abstrak menyebut bahwa sistem meningkatkan akurasi, mengurangi halusinasi, atau menjamin grounding, penguji akan bertanya: "Di mana bukti kuantitatifnya? Berapa sampelnya? Apa baseline-nya?"

Masalah berikutnya adalah istilah "100% grounding" atau klaim sejenis. Angka seperti itu berbahaya. Dari sisi penguji, angka 100% memberi kesan pengujian besar, stabil, dan bebas kesalahan. Padahal hasil aktual lebih dekat ke evaluasi terbatas atas beberapa query yang dicek secara manual.

Abstrak juga rentan jika terlalu mengandalkan angka test dan coverage. Coverage 98% memang kuat untuk software engineering, tetapi tidak otomatis membuktikan bahwa jawaban RAG benar, relevan, dan bebas halusinasi dalam konteks produksi.

### Pertanyaan sidang yang harus diantisipasi

- "Anda menulis sistem ini meningkatkan grounding. Meningkat dibanding apa?"
- "Apa baseline yang digunakan untuk menyatakan peningkatan?"
- "Berapa jumlah query evaluasi real-data? Apakah cukup untuk klaim abstrak?"
- "Coverage tinggi itu menguji kode atau menguji kualitas jawaban AI?"
- "Apakah 100% di sini berarti tidak pernah salah, atau hanya pada sampel kecil yang diuji?"

### Cara bertahan

Jawaban aman: abstrak harus dibaca sebagai ringkasan hasil pada skenario evaluasi yang dibatasi, bukan klaim universal. Tekankan bahwa kontribusi utama adalah perancangan dan implementasi AI Engine berbasis RAG, hybrid retrieval, reasoning service, dan Logic Listener, lalu evaluasinya menunjukkan hasil positif pada dataset dan skenario uji yang digunakan.

Jangan mempertahankan klaim absolut. Kalau ditanya soal 100%, jawab dengan hati-hati: "Angka itu berlaku untuk query evaluasi yang digunakan dalam penelitian ini, bukan jaminan performa untuk semua kemungkinan pertanyaan."

## Bab 1

### Risiko utama

Tinggi. Bab 1 menetapkan masalah, tujuan, batasan, dan hipotesis. Kalau rumusan di sini terlalu ambisius, Bab 4 akan terlihat kurang kuat meskipun implementasinya bagus.

### Serangan yang mungkin muncul

Penguji akan melihat apakah masalah yang diajukan benar-benar dijawab oleh hasil penelitian. Jika Bab 1 berbicara tentang halusinasi, grounding, explainability, dan reasoning, maka Bab 4 harus menunjukkan bukti yang sepadan. Kalau bukti hanya berupa test pass, coverage, dan beberapa contoh query, penguji bisa bilang: "Ini lebih seperti laporan pembangunan sistem, bukan pembuktian hipotesis penelitian."

Rumusan H1 juga masih menjadi titik rawan. Jika H1 terdengar seperti klaim peningkatan akurasi atau pengurangan halusinasi secara umum, penguji akan meminta baseline. Tanpa baseline non-RAG, baseline semantic-only, atau baseline tanpa Logic Listener, klaim peningkatan menjadi sulit dipertahankan.

Batasan masalah harus dijaga ketat. Karena fokusnya AI Engine, jangan memberi kesan bahwa penelitian ini mengevaluasi seluruh ekosistem Kolabri secara end-to-end dari sisi produk. Kalau penguji menemukan pembahasan yang melebar ke sistem lain, ia bisa menyerang scope creep.

### Pertanyaan sidang yang harus diantisipasi

- "Masalah utama penelitian ini apa: membangun sistem, mengukur akurasi RAG, atau membuktikan reasoning?"
- "Apa indikator keberhasilan H1?"
- "Mengapa tidak ada baseline yang jelas?"
- "Jika hanya AI Engine, mengapa ada pembahasan komponen lain?"
- "Apa bedanya tujuan penelitian ini dengan sekadar membuat backend AI?"

### Cara bertahan

Jaga narasi: penelitian ini adalah penelitian rekayasa perangkat lunak terapan untuk membangun dan mengevaluasi AI Engine. Jadi pembuktian utamanya bukan eksperimen statistik besar, melainkan kesesuaian arsitektur, implementasi modul, dan evaluasi fungsional pada skenario yang relevan.

Untuk H1, jangan jawab dengan nada mutlak. Jawaban yang lebih aman: "H1 dalam penelitian ini diuji melalui keterikatan jawaban terhadap dokumen sumber pada skenario query yang disiapkan. Saya tidak mengklaim generalisasi ke semua domain, tetapi menunjukkan bahwa desain RAG dan mekanisme validasi membantu menjaga jawaban tetap berbasis konteks."

## Bab 2

### Risiko utama

Sedang sampai tinggi. Bab 2 biasanya tidak paling mematikan, tetapi bisa dipakai penguji untuk membuktikan bahwa fondasi teori tidak nyambung dengan metode.

### Serangan yang mungkin muncul

Penguji akan mencari hubungan antara teori dan implementasi. Jika Bab 2 menjelaskan RAG, vector search, hybrid retrieval, Logic Listener, atau reasoning, tetapi Bab 3 dan Bab 4 tidak mengoperasionalkan konsep itu dengan metrik yang jelas, Bab 2 akan dianggap dekoratif.

Bagian RAG bisa diserang jika terlalu menekankan akurasi, anti-halusinasi, atau grounding tanpa menjelaskan bahwa RAG hanya mengurangi risiko, bukan menghilangkan halusinasi. Secara akademik, RAG bukan garansi kebenaran. Ia menyediakan konteks. Model tetap bisa salah membaca, salah menyusun, atau mengabaikan konteks.

Logic Listener juga rawan. Kalau ditempatkan seolah-olah sebagai mekanisme validasi logis yang kuat, penguji bisa meminta definisi formal: aturan logikanya apa, bagaimana validasinya, apa ground truth-nya, dan bagaimana false positive/false negative diukur.

### Pertanyaan sidang yang harus diantisipasi

- "Teori mana yang benar-benar dipakai dalam rancangan sistem?"
- "Mengapa hybrid retrieval dipilih dibanding semantic retrieval saja?"
- "Apakah RAG menjamin jawaban bebas halusinasi?"
- "Apa dasar teoretis Logic Listener?"
- "Jika ada reasoning service, bagaimana kualitas reasoning-nya dievaluasi?"

### Cara bertahan

Hubungkan teori ke modul secara eksplisit saat menjawab. RAG dipakai untuk grounding jawaban. Hybrid retrieval dipakai karena pencarian semantik saja bisa melewatkan kecocokan istilah spesifik, sedangkan keyword search saja tidak cukup menangkap makna. Logic Listener dipakai sebagai lapisan pemeriksaan tambahan terhadap konsistensi dan keterikatan jawaban, bukan sebagai pembukti formal bahwa jawaban pasti benar.

Kalimat penting untuk sidang: "Saya tidak memposisikan RAG sebagai penghilang halusinasi secara absolut. Dalam penelitian ini, RAG digunakan untuk mengurangi risiko jawaban lepas konteks dengan menyediakan dokumen sumber yang relevan."

## Bab 3

### Risiko utama

Sangat tinggi. Ini bab paling mudah diserang. Penguji biasanya memeriksa apakah desain evaluasi cukup kuat untuk mendukung klaim hasil. Di sini ada jarak antara rencana ideal dan hasil yang benar-benar dilaporkan.

### Serangan yang mungkin muncul

Serangan paling keras: metodologi terlihat menjanjikan evaluasi yang lebih besar daripada yang akhirnya dilakukan. Jika Bab 3 menyebut skenario konkuren bertahap, evaluasi retrieval, atau target kualitas tertentu, Bab 4 harus menunjukkan data yang sesuai. Kalau tidak, penguji akan menyebutnya mismatch.

Bagian metrik juga rawan. Jika ada pembahasan precision, recall, relevansi retrieval, atau akurasi RAG, penguji akan menanyakan rumus, data uji, jumlah query, anotator, dan ground truth. Tanpa itu, metrik harus diposisikan sebagai rujukan literatur atau target desain, bukan hasil penelitian utama.

Pengujian load/performance juga bisa diserang. Jika target awal terdengar seperti 50+ pengguna dan <500ms, lalu hasil yang ada hanya backend-local atau skenario terbatas, penguji bisa menyebut targetnya diturunkan setelah hasil diketahui. Walaupun wording sudah dilembutkan, pertanyaan ini masih mungkin muncul.

### Pertanyaan sidang yang harus diantisipasi

- "Berapa jumlah query yang digunakan untuk evaluasi kualitas jawaban?"
- "Apakah ada ground truth? Siapa yang menentukan jawaban benar?"
- "Mengapa tidak menghitung precision dan recall?"
- "Bagaimana desain evaluasi membuktikan H1?"
- "Apakah pengujian performance dilakukan pada kondisi yang menyerupai produksi?"
- "Mengapa jumlah user atau query tidak sebesar yang dibayangkan di rancangan awal?"

### Cara bertahan

Jangan berpura-pura metodologinya lebih kuat dari yang ada. Lebih aman mengakui bahwa evaluasi kualitas jawaban bersifat terbatas dan difokuskan pada skenario representatif, sementara pengujian perangkat lunak dipakai untuk memastikan implementasi modul berjalan benar.

Jawaban yang defensible: "Penelitian ini tidak melakukan evaluasi statistik skala besar terhadap kualitas generatif. Evaluasi diarahkan pada validasi sistem AI Engine: retrieval berjalan, jawaban dapat dikaitkan ke sumber, Logic Listener bekerja pada skenario uji, dan endpoint memenuhi skenario fungsional yang dirancang."

Kalau ditanya precision/recall, jawab: "Precision dan recall saya posisikan sebagai metrik ideal dalam evaluasi IR/RAG, tetapi penelitian ini belum menghitungnya secara formal karena belum menggunakan dataset beranotasi besar. Itu menjadi batasan penelitian."

## Bab 4

### Risiko utama

Tinggi sampai sangat tinggi. Bab 4 memuat hasil. Penguji akan menanyakan apakah data di sini cukup untuk mendukung klaim di Bab 1 dan Bab 3.

### Serangan yang mungkin muncul

Jumlah test dan coverage akan terlihat impresif, tetapi penguji yang kritis akan memisahkan dua hal: validasi software dan validasi ilmiah. 2.209 test dan coverage 98,86% membuktikan bahwa banyak jalur kode diuji. Itu tidak sama dengan membuktikan jawaban AI akurat secara semantik.

Evaluasi real-data dengan 5 query adalah titik lemah paling jelas. Lima query bisa berguna sebagai smoke test atau demonstrasi representatif, tetapi terlalu kecil untuk klaim luas. Kalau Bab 4 menyebut hasil 100% pada 5 query, penguji bisa langsung menyerang ukuran sampel.

Logic Listener juga akan dipertanyakan. Test unit bisa membuktikan fungsi berjalan sesuai kasus buatan. Namun penguji bisa bertanya apakah Logic Listener benar-benar mendeteksi kesalahan reasoning pada data nyata. Tanpa confusion matrix atau evaluasi manual yang lebih luas, jawabannya harus dibatasi.

Performance juga rawan jika data diukur dalam lingkungan lokal. Latensi lokal tidak selalu sama dengan latensi produksi. Kalau target <500ms pernah muncul, pastikan pembelaannya jelas: angka itu untuk operasi backend tertentu, bukan keseluruhan respons LLM dari ujung ke ujung.

### Pertanyaan sidang yang harus diantisipasi

- "Apakah 2.209 test membuktikan model menjawab benar?"
- "Mengapa evaluasi real-data hanya 5 query?"
- "Apa kategori 5 query itu? Apakah mewakili variasi kasus pengguna?"
- "Bagaimana Anda tahu jawaban grounded selain inspeksi manual?"
- "Apakah Logic Listener diuji pada jawaban yang sengaja salah?"
- "Apakah latensi yang dilaporkan mencakup proses LLM penuh atau hanya backend?"

### Cara bertahan

Pisahkan dua jenis bukti:

- Bukti engineering: unit test, integration test, E2E test, coverage, health check, endpoint behavior.
- Bukti kualitas jawaban: query real-data, grounding terhadap sumber, contoh respons, dan evaluasi manual terbatas.

Kalimat aman: "Coverage tinggi saya gunakan sebagai bukti stabilitas implementasi AI Engine, bukan sebagai bukti tunggal kualitas jawaban generatif. Untuk kualitas jawaban, saya menggunakan evaluasi query real-data dan analisis keterikatan jawaban pada sumber, dengan ruang lingkup yang memang terbatas."

Kalau penguji menekan ukuran sampel, jangan melawan. Akui sebagai batasan. Lebih baik terlihat jujur daripada memaksakan statistik dari data kecil.

## Bab 5

### Risiko utama

Tinggi. Bab 5 sering menjadi tempat klaim dibesarkan lagi setelah hasil terbatas. Penguji akan membandingkan kesimpulan dengan bukti di Bab 4.

### Serangan yang mungkin muncul

Kesimpulan berbahaya kalau memakai bahasa terlalu pasti: "berhasil meningkatkan", "terbukti mengurangi halusinasi", atau "sistem mampu menjamin grounding". Dengan bukti terbatas, kata-kata seperti itu bisa dianggap overclaim.

Bab 5 juga rawan jika menyimpulkan semua komponen bekerja baik tanpa membedakan tingkat validasinya. Ada komponen yang kuat secara test engineering, ada yang baru kuat secara demonstrasi. Keduanya tidak boleh disamakan.

Saran penelitian berikutnya harus jujur. Jika belum ada precision/recall, baseline, uji multi-anotator, atau dataset besar, tulis itu sebagai future work. Jangan menutup kelemahan seolah-olah semua sudah selesai.

### Pertanyaan sidang yang harus diantisipasi

- "Kesimpulan mana yang langsung didukung data?"
- "Apakah Anda menyimpulkan RAG mengurangi halusinasi atau hanya membantu grounding?"
- "Apa batasan terbesar penelitian ini?"
- "Kalau penelitian ini dilanjutkan, evaluasi apa yang paling perlu ditambahkan?"
- "Apa kontribusi ilmiah, bukan hanya kontribusi implementasi?"

### Cara bertahan

Kesimpulan harus dibaca sebagai kesimpulan terbatas. Sistem berhasil dibangun, diuji, dan menunjukkan hasil positif dalam skenario yang dirancang. Jangan klaim generalisasi luas.

Jawaban yang aman: "Kontribusi utama penelitian ini adalah rancangan dan implementasi AI Engine berbasis RAG dengan hybrid retrieval, reasoning service, dan Logic Listener, serta evaluasi engineering yang cukup kuat. Untuk validasi kualitas jawaban secara statistik, penelitian ini masih perlu dataset query yang lebih besar, baseline, dan anotasi ground truth."

## Risiko lintas bab

### 1. Bab 3 menjanjikan lebih banyak daripada Bab 4 berikan

Ini risiko terbesar. Kalau metodologi terdengar seperti eksperimen kuantitatif penuh, tetapi hasilnya berupa test engineering dan evaluasi kecil, penguji akan menyebut desain penelitian tidak konsisten.

Cara bertahan: tekankan bahwa desain penelitian adalah rekayasa sistem dengan evaluasi terbatas, bukan eksperimen NLP skala besar.

### 2. H1 masih bisa dibaca terlalu ambisius

Kalau H1 terdengar seperti "RAG meningkatkan akurasi sampai sekian persen", penguji akan meminta baseline. Kalau H1 dibaca sebagai "RAG membantu keterikatan jawaban pada dokumen sumber", naskah jauh lebih aman.

Cara bertahan: arahkan H1 ke grounding dan keterikatan sumber, bukan klaim akurasi universal.

### 3. Coverage bisa disalahgunakan sebagai bukti ilmiah

Coverage tinggi adalah nilai plus, tapi bukan bukti bahwa AI benar. Ini harus dijelaskan dengan tegas.

Cara bertahan: coverage = stabilitas implementasi; query evaluation = kualitas jawaban; dua-duanya berbeda.

### 4. Logic Listener belum divalidasi seperti classifier

Kalau Logic Listener dianggap classifier kesalahan reasoning, perlu precision/recall. Kalau diposisikan sebagai lapisan pemeriksaan heuristik/fungsional, posisinya lebih aman.

Cara bertahan: sebut Logic Listener sebagai mekanisme tambahan untuk memeriksa konsistensi dan sumber, bukan validator formal yang menjamin kebenaran.

### 5. Performance target harus dibatasi

Jika penguji bertanya tentang <500ms, jawab bahwa itu bukan waktu generasi LLM end-to-end untuk semua kondisi, melainkan pengukuran pada operasi backend/skenario tertentu.

Cara bertahan: jelaskan environment pengujian, jenis request yang diukur, dan batas interpretasinya.

## Pertanyaan paling berbahaya di sidang

1. "Apa bukti bahwa sistem ini benar-benar mengurangi halusinasi?"

Jawaban aman: sistem tidak diklaim menghilangkan halusinasi sepenuhnya. Bukti yang diberikan adalah jawaban pada skenario uji dapat dikaitkan ke dokumen sumber dan mekanisme retrieval menyediakan konteks yang relevan. Pengurangan halusinasi dibahas sebagai tujuan desain dan indikasi pada evaluasi terbatas, bukan klaim universal.

2. "Mengapa evaluasi kualitas jawaban hanya sedikit?"

Jawaban aman: karena fokus penelitian adalah pembangunan dan evaluasi AI Engine sebagai sistem. Evaluasi real-data digunakan sebagai validasi representatif. Untuk generalisasi kualitas jawaban, diperlukan dataset lebih besar dan anotasi ground truth, dan itu diakui sebagai batasan.

3. "Apa bedanya penelitian ini dengan membuat backend biasa?"

Jawaban aman: backend ini memuat pipeline AI khusus: ingestion dokumen, vector retrieval, hybrid search, RAG answer generation, reasoning service, dan Logic Listener. Kontribusinya ada pada integrasi modul-modul itu menjadi AI Engine yang dapat diuji dan digunakan dalam konteks Kolabri.

4. "Apakah test pass membuktikan hipotesis?"

Jawaban aman: tidak secara langsung. Test pass membuktikan implementasi berjalan sesuai desain. Hipotesis didukung oleh kombinasi implementasi, skenario retrieval, evaluasi query real-data, dan analisis grounding. Kekuatan buktinya terbatas, dan batasan itu perlu diakui.

5. "Kalau Anda mengulang penelitian ini, apa yang akan diperbaiki?"

Jawaban aman: menambah dataset query, membuat ground truth, membandingkan dengan baseline semantic-only dan non-RAG, menghitung precision/recall retrieval, serta melakukan evaluasi jawaban dengan lebih dari satu evaluator.

## Strategi menjawab saat ditekan penguji

Gunakan pola ini:

1. Akui batasan lebih dulu.
2. Jelaskan apa yang benar-benar dilakukan.
3. Kaitkan ke data di Bab 4.
4. Jangan memperluas klaim.
5. Tutup dengan future work yang masuk akal.

Contoh:

"Betul, Pak/Bu, evaluasi kualitas jawaban belum menggunakan dataset besar dengan anotasi ground truth. Dalam penelitian ini, fokus saya adalah membangun AI Engine dan memvalidasi bahwa pipeline RAG, retrieval, reasoning service, dan Logic Listener berjalan sesuai skenario. Untuk pembuktian akurasi secara statistik, penelitian berikutnya perlu baseline dan query set yang lebih besar."

Jawaban seperti itu jauh lebih aman daripada memaksa bahwa 5 query sudah cukup untuk membuktikan semua hal.

## Putusan akhir

Tesis ini layak dibawa ke sidang, tetapi bukan dengan gaya klaim besar. Kekuatan utamanya ada di implementasi AI Engine dan pengujian software yang rapi. Kelemahannya ada di validasi ilmiah kualitas jawaban yang masih terbatas.

Kalau presentasi dan jawaban sidang disiplin membedakan "sistem berhasil dibangun" dari "model terbukti selalu benar", naskah ini bisa dipertahankan. Kalau pembelaan terlalu percaya diri dan menyamakan coverage dengan akurasi AI, penguji punya banyak pintu untuk menyerang.

Posisi paling aman: ini adalah penelitian rekayasa AI Engine berbasis RAG dengan evaluasi engineering kuat dan evaluasi kualitas jawaban terbatas. Jangan lebih dari itu.
