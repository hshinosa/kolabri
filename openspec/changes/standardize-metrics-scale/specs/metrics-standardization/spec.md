## ADDED Requirements

### Requirement: Semua metrik analytics SHALL menggunakan skala 0-100

API response untuk analytics SHALL mengembalikan semua metrik dalam skala 0-100.

#### Scenario: Lexical variety dikembalikan dalam skala 0-100
- **WHEN** client meminta analytics grup
- **THEN** `qualityBreakdown.lexical_variety` SHALL berupa nilai 0-100 (bukan 0-1)

#### Scenario: Hot percentage tetap dalam skala 0-100
- **WHEN** client meminta analytics grup
- **THEN** `qualityBreakdown.hot_percentage` SHALL berupa nilai 0-100

#### Scenario: Quality score tetap dalam skala 0-100
- **WHEN** client meminta analytics grup
- **THEN** `qualityScore` SHALL berupa nilai 0-100

### Requirement: Frontend SHALL menampilkan metrik tanpa konversi manual

Frontend SHALL menampilkan metrik langsung dari API tanpa perkalian/pembagian untuk display.

#### Scenario: Lexical variety ditampilkan sebagai persentase
- **WHEN** frontend menerima `lexical_variety: 50`
- **THEN** frontend SHALL menampilkan "50%" (bukan "0.5%" atau "5000%")

#### Scenario: Radar chart menggunakan skala 0-10
- **WHEN** frontend merender radar chart
- **THEN** semua metrik SHALL dinormalisasi ke 0-10 dengan formula `nilai / 10`
