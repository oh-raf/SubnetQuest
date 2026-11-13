# Papan Kanban Kolaborasi Tim — SubnetQuest: Misi Kampus Jaringan

Kolom Standar Kanban: **Backlog** | **To Do** | **Doing** (Maks. 2 kartu/orang) | **Review** | **Done**

## Daftar Kartu Kanban & Penanggung Jawab (PIC)
| ID Kartu | Judul Kartu Tugas | Peran | Penanggung Jawab (PIC) | Area Repo | Kolom Awal |
|---|---|---|---|---|---|
| SQ-01 | Setup repositori Git, `.gitignore`, dan struktur direktori Godot 4.3 | Project + Level | Muhammad Rafif Imtithal | `/`, `/docs` | Done |
| SQ-02 | Penyusunan GDD & perancangan soal World 1, 3, 4 (FLSM), dan 5 (VLSM) di `data/levels.json` | Project + Level | Muhammad Rafif Imtithal | `/data` | Review |
| SQ-03 | Penulisan langkah penjelasan pop-up tutorial & hint bertahap tiap gedung | Project + Level | Muhammad Rafif Imtithal | `/data` | Review |
| SQ-04 | Pembuatan modul inti `SubnetCalc` (konversi biner, kalkulator subnet, cek overlap VLSM) | Programmer | Muhammad Ashar Farhandika Putra Farial | `/scripts/core` | Review |
| SQ-05 | Implementasi Autoload `GameState`, `AudioManager`, dan `DialogUI` | Programmer | Muhammad Ashar Farhandika Putra Farial | `/autoload` | Review |
| SQ-06 | Pembuatan `ConfigPanel` (3 `LineEdit` IP, Bit Board 8-bit, validasi per-field) & `TutorialPopup` | Programmer | Muhammad Ashar Farhandika Putra Farial | `/scripts/ui` | Doing |
| SQ-07 | Implementasi `CampusMap`, visualisasi kabel `Line2D` menyala hijau, `BuildingNode`, Player & NPC | Programmer | Muhammad Ashar Farhandika Putra Farial | `/scripts/world`, `/scenes` | Doing |
| SQ-08 | Pembuatan sprite sheet 3 karakter anggota (`char_1..3.png`) & portrait pixelate (`portrait_1..3.png`) | Artist | Ihsan Yusuf Adrian | `/assets/characters`, `/assets/portraits` | Review |
| SQ-09 | Pembuatan tileset peta kampus UM (`campus_tileset.png`) & visual gedung (`bldg_*.png`) | Artist | Ihsan Yusuf Adrian | `/assets/tilesets`, `/assets/buildings` | To Do |
| SQ-10 | Penyediaan font pixel (`font.ttf`), BGM (`bgm_menu`, `bgm_campus`), dan SFX (`connect`, `error`, `win`) | Artist | Ihsan Yusuf Adrian | `/assets/ui`, `/assets/audio` | To Do |
| SQ-11 | Playtest lintas anggota, verifikasi ganda kunci jawaban subnetting, dan perbaikan bug | Semua | Rafif, Ihsan, Ashar | Seluruh repo | Backlog |
| SQ-12 | Export `.exe` Windows Desktop dan perekaman video demo presentasi (15–20 menit) | Semua | Rafif, Ihsan, Ashar | `/export` | Backlog |

## Definition of Done (DoD)
1. Fitur atau aset berjalan sesuai deskripsi kartu dan telah diuji oleh minimal satu anggota tim lainnya.
2. Tidak terdapat *error* atau *crash* pada panel *Output/Debugger* Godot 4.3.
3. Kunci jawaban subnetting pada `levels.json` telah diverifikasi dua kali (perhitungan manual dan lewat modul `SubnetCalc`).
4. File ditempatkan pada area folder sesuai pembagian peran dan di-commit menggunakan format: `feat(...): ...`, `art(...): ...`, `level(...): ...`, atau `docs(...): ...`.
