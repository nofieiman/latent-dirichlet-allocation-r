
# 🧠 Analisis Topik LDA

Repositori ini berisi skrip R untuk melakukan *topic modeling* menggunakan **Latent Dirichlet Allocation (LDA)**. Sebagai contoh latihan, kita menggunakan teks lengkap disertasi Dr. Bahlil Lahadalia. Tujuannya adalah untuk mengidentifikasi tema-tema utama dan menghasilkan visualisasi yang membantu memahami struktur konten disertasi. Tentu saja, teks apapun bisa digunakan untuk analisis. File diperoleh dari media sosial yang viral beberapa waktu lalu: 
`https://www.dropbox.com/scl/fi/z2qwvgck3iszrpx75ikz7/Disertasi-Bahlil-Lahadalia-Sidang-Promosi_Final.pdf.`

---

## 📁 Struktur Proyek

- `lda.R`: Skrip utama untuk pra-pemrosesan, pemodelan, dan visualisasi.
- 📄 **Catatan**: File PDF disertasi harus diunduh secara manual dan path-nya diperbarui di dalam skrip.

---

## 📦 Ketergantungan

Skrip ini membutuhkan paket R berikut:

- `tidyverse`
- `tidytext`
- `tm`
- `topicmodels`
- `LDAvis`
- `pdftools`
- `wordcloud`
- `RColorBrewer`

Instalasi dapat dilakukan dengan:

```r
install.packages(c("tidyverse", "tidytext", "tm", "topicmodels", "LDAvis", "pdftools", "wordcloud", "RColorBrewer"))
```

---

## 🧾 Alur Kerja

### 1. **Ekstraksi & Pembersihan Teks**
- Mengambil teks dari file PDF dengan `pdftools::pdf_text()`
- Pembersihan teks: huruf kecil, menghapus tanda baca/angka, stop words, dsb.

### 2. **Tokenisasi & Matriks Dokumen-Term**
- Tokenisasi teks menjadi kata
- Membuat Document-Term Matrix (DTM) menggunakan `tidytext` dan `tm`

### 3. **Pemodelan Topik**
- Menerapkan LDA dengan jumlah topik tertentu (`k = 5`)
- Mengekstrak probabilitas kata terhadap topik (`beta`)

### 4. **Visualisasi**
- **Wordcloud** dari 100 kata terpenting
- **Diagram batang** 10 kata teratas per topik dengan `ggplot2`
- **Visualisasi interaktif** dengan LDAvis

---

## 📌 Petunjuk Penggunaan

1. **Unduh** file PDF disertasi dan perbarui path di dalam skrip:
```r
file_path <- "/path/to/Disertasi Bahlil Lahadalia - Sidang Promosi_Final.pdf"
```

2. **Jalankan** skrip di lingkungan R (misal: RStudio)

3. **Eksplorasi** hasil visualisasi yang dihasilkan

---

## 📊 Contoh Output

- `Wordcloud`: 100 kata paling dominan
- `Facet Bar Plot`: 10 kata teratas untuk setiap topik
- `LDAvis`: Visualisasi topik interaktif di browser

---

## 📚 Tujuan

Proyek ini dapat digunakan untuk:
- Memahami tema utama dalam dokumen akademik
- Latihan *text mining* dan *topic modeling* dengan R
- Eksplorasi wacana ekonomi dan politik Indonesia melalui LDA

---

## 🔖 Lisensi

Proyek ini ditujukan untuk keperluan akademik dan edukatif. Mohon cantumkan atribusi jika digunakan dalam penelitian atau publikasi.

---

## 🙋‍♂️ Penghargaan

Teks disertasi diambil dari domain publik sebagai bahan analisis.
