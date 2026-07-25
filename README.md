# Hollow Knight - PoC GNU Prolog

Proof of Concept untuk Task #1 Seleksi Laboratorium Intelegensi Buatan.

## Environment

- Windows
- GNU Prolog
- Git

## Struktur

```text
Task1_AI_18224061/
├── README.md
└── src/
    ├── main.pl
    ├── facts.pl
    ├── state.pl
    ├── commands.pl
    └── file_io.pl
```

## Cara Menjalankan

Buka PowerShell atau Command Prompt pada folder repository, lalu jalankan:

```powershell
cd src
gprolog --consult-file main.pl
```

Pada GNU Prolog, mulai permainan dengan:

```prolog
| ?- play.
```

Setiap command di dalam permainan harus diakhiri tanda titik.

Contoh:

```prolog
look.
take(segel_lurien).
move(greenpath).
attack.
saveGame('progress1.sav').
quit.
```

Untuk memuat file penyimpanan dari top-level GNU Prolog:

```prolog
| ?- loadGame('progress1.sav').
```

Kemudian lanjutkan loop permainan dengan:

```prolog
| ?- gameLoop.
```

## Command Utama

- `play/0`
- `start/0`
- `help/0`
- `status/0`
- `look/0`
- `inventory/0`
- `move/1`
- `take/1`
- `attack/0`
- `bench/0`
- `saveGame/1`
- `loadGame/1`
- `gameLoop/0`
- `quit/0`

## Konsep yang Digunakan

- Rekurens: pemeriksaan dan pencetakan list fragmen
- List: inventory pemain
- Cut: pemilihan aturan dan validasi command
- Fail: fail-driven loop serta penolakan aksi ilegal
- Loop: `gameLoop/0`
- File processing: `saveGame/1` dan `loadGame/1`
