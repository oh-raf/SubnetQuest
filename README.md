# SubnetQuest: Misi Kampus Jaringan

**Tagline:** *Bagi alamatnya, hubungkan kampusnya.*

Game edukasi *puzzle* dan simulasi jaringan komputer 2D *top-down* berbasis **Godot 4.3 (GL Compatibility)** yang mengajarkan konsep konversi biner-desimal, perhitungan *Network Address*, *Subnet Mask / Prefix*, *Broadcast Address*, *Fixed Length Subnet Mask* (FLSM), dan *Variable Length Subnet Mask* (VLSM) berlatar peta kampus Universitas Negeri Malang (UM).

## Cara Menjalankan Project
1. Buka **Godot Engine 4.3 (Stable)** atau versi lebih baru.
2. Klik **Import**, lalu pilih file `project.godot` di dalam folder `SubnetQuest/`.
3. Klik **Import & Edit**, lalu tekan **F5** (atau tombol *Run Project*).

## Kontrol Permainan
- **WASD / Tombol Panah**: Menggerakkan karakter Admin Jaringan mengelilingi peta kampus.
- **E / Enter / Spasi**: Berinteraksi dengan Gedung Kampus (membuka Panel Konfigurasi IP), berinteraksi dengan NPC rekan tim, dan melanjutkan dialog.
- **Mouse Klik**: Mengklik saklar pada *Bit Board* 8-bit, mengisi kolom `LineEdit` (*Network Address*, *Subnet Mask/Prefix*, *Broadcast Address*), menekan tombol *Nyalakan Koneksi*, *Hint Bertahap*, *Tabel Referensi*, atau memilih tombol pintas gedung di bagian bawah HUD.

## Anggota Tim Pengembang
| No | Nama Lengkap | NIM | Peran | Kontribusi Utama |
|---|---|---|---|---|
| 1 | **Muhammad Rafif Imtithal** | 240533608447 | Project + Level | Manajemen papan Kanban Trello, dokumentasi GDD, desain kurikulum level (`levels.json`), soal FLSM/VLSM, dan naskah pop-up tutorial. |
| 2 | **Ihsan Yusuf Adrian** | 240533615464 | Artist | Desain sprite karakter (`char_1..3.png`), portrait pixelate (`portrait_1..3.png`), tileset kampus (`campus_tileset.png`), ikon gedung (`bldg_*.png`), palet UI, dan aset audio. |
| 3 | **Muhammad Ashar Farhandika Putra Farial** | 240533615493 | Programmer | Arsitektur Godot 4.3, mesin kalkulator `SubnetCalc`, validasi per-field & cek overlap VLSM, Bit Board interaktif, dan integrasi sistem. |

## Daftar Kredit Aset
- Sprite Karakter, Portrait, Tileset & Gedung: Disiapkan oleh Ihsan Yusuf Adrian (`char_1..3.png`, `portrait_1..3.png`, `campus_tileset.png`, serta `bldg_server.png`, `bldg_fakultas.png`, `bldg_lab.png`, dan `bldg_kantor.png` dari tileset town kustom) / Aset terbuka bebas lisensi (Kenney.nl / OpenGameArt / Itch.io).
- Font UI: Pixelify Sans / Press Start 2P (`assets/ui/font.ttf`, OFL) dengan fallback otomatis ke font default Godot 4.3.
- Audio BGM & SFX: `bgm_menu.ogg`, `bgm_campus.ogg`, serta efek suara `sfx_click.wav`, `sfx_dialog.wav`, `sfx_connect.wav`, `sfx_error.wav`, `sfx_found.wav`, dan `sfx_win.wav`.
