# Task1_AI_18224061 - Hollow Knight (GNU Prolog)



Repository ini berisi *Proof of Concept* permainan petualangan berbasis teks berbasis **GNU Prolog** yang terinspirasi dari dunia *Hollow Knight*. Proyek ini disusun untuk memenuhi **Task #1 Seleksi Laboratorium Intelegensi Buatan** oleh Riantama Putra (NIM: 18224061).

---

## 📖 Deskripsi Permainan

Pemain mengendalikan seorang **Vessel** yang terbangun di reruntuhan Hallownest. Tujuan utama permainan adalah menjelajahi area yang saling terhubung, mengumpulkan 3 fragmen segel (*Segel Lurien*, *Segel Herrah*, *Segel Monomon*), lalu membuka gerbang *Black Egg Temple* dan mengalahkan *The Hollow Knight* sebelum jumlah Mask (nyawa) atau batas giliran (*turns*) habis.

Seluruh interaksi dilakukan melalui masukan perintah (*command*) berbasis teks di terminal GNU Prolog.

---

## ⚙️ Penerapan Konsep Logika Komputasional

Implementasi permainan ini menerapkan 6 konsep utama logika komputasional:

* **Rekurens (Recursion)**: Digunakan pada pemrosesan struktur data linier, seperti pencetakan daftar fragmen secara rekursif pada `print_fragments/1` dan pengisian kembali fakta dinamis pada `assert_item_area_list/1`.


* **List**: Digunakan untuk mengelola inventori fragmen segel milik pemain (`inventory/1`) serta daftar area terhubung.


* **Cut (`!`)**: Memangkas pencarian (*backtracking*) untuk mengunci aturan predikat, seperti pada validasi masukan perintah `proses/1`, pencegahan pergerakan ilegal `move/1`, dan resolusi serangan `resolve_attack/3`.


* **Fail (`fail`)**: Digunakan dalam *fail-driven loop* untuk menyalin fakta statis ke fakta dinamis (`init_items/0`, `init_enemies/0`) serta membatalkan aksi yang tidak sah.


* **Loop**: Diimplementasikan dengan pola `repeat/fail` pada `game_loop/0` untuk menjalankan siklus giliran (*turn cycle*) hingga permainan selesai.


* **File Processing**: Pengolahan simpan dan muat data permainan eksternal melalui predikat `saveGame/1` dan `loadGame/1` dengan memanfaatkan operasi I/O Prolog (`open/3`, `writeq/2`, `read/2`, `close/1`).



---

## 📁 Struktur Berkas

* `main.pl`: Berkas utama penyambung dependensi dan pengelola loop permainan (`play/0`).


* `facts.pl`: Berkas fakta statis draf area, koneksi antar area, lokasi awal item, dan templat musuh.


* `state.pl`: Berkas basis data dinamis (`:- dynamic`), inisialisasi status awal, serta pengecekan kondisi menang/kalah.


* `commands.pl`: Berkas logika perintah pemain (`move/1`, `take/1`, `attack/0`, `bench/0`, `look/0`, `status/0`, `inventory/0`, `help/0`).


* `file_io.pl`: Berkas penanganan operasi simpan dan muat status permainan ke file eksternal.



---

## 🚀 Cara Menjalankan Permainan

### Prasyarat

Pastikan **GNU Prolog** (`gprolog`) telah terinstal pada sistem.

### Langkah Eksekusi

1. Buka terminal dan masuk ke direktori repositori ini.


2. Muat berkas utama ke dalam GNU Prolog:
```bash
gprolog --consult-file main.pl

```


3. Mulai permainan dengan mengeksekusi perintah berikut pada prompt Prolog:
```prolog
| ?- play.

```



---

## 🕹️ Daftar Command Utama

| Command | Deskripsi |
| --- | --- |
| `play.` | Memulai permainan dan menjalankan *loop* utama.

 |
| `help.` | Menampilkan daftar perintah yang tersedia.

 |
| `status.` | Menampilkan kondisi permainan (posisi, Mask, giliran, fase, dan jumlah segel).

 |
| `look.` | Menampilkan kondisi area saat ini, area terhubung, item, dan musuh.

 |
| `inventory.` | Menampilkan daftar fragmen segel yang dikumpulkan secara rekursif.

 |
| `move(Tujuan).` | Berpindah menuju area yang terhubung langsung.

 |
| `take(Item).` | Mengambil fragmen segel yang berada di area tempat pemain berada.

 |
| `attack.` | Menyerang musuh pada fase pertarungan.

 |
| `bench.` | Memulihkan Mask hingga batas maksimum (hanya dapat digunakan sekali).

 |
| `saveGame('nama_file.sav').` | Menyimpan kondisi permainan saat ini ke file.

 |
| `loadGame('nama_file.sav').` | Memuat kondisi permainan dari file (dijalankan di luar `play.`).

 |
| `quit.` | Mengakhiri sesi permainan.

 |

> **Catatan**: Setiap perintah pada GNU Prolog wajib diakhiri dengan tanda titik (`.`).