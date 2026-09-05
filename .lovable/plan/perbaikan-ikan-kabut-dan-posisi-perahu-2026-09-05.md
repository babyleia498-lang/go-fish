# Perbaikan Ikan, Kabut, dan Posisi Perahu

## 1. Ikan tidak terlihat saat sedang ditarik (reeling)

Saat ini ikan yang tersangkut sudah ditampilkan sejak fase tarik-menarik, sehingga terlihat melayang di dalam air/dasar laut. Ikan hanya akan muncul pada saat tangkapan selesai dan terangkat ke permukaan. Berlaku untuk semua jenis ikan, termasuk ikan monster.

## 2. Semua ikan memakai file 3D

Seluruh ikan memakai file 3D yang sudah ada di proyek: ikan biasa (1), langka (1), epik (1), legendaris (2), mythic (3). Ikan monster (Ancient Leviathan) juga memakai file 3D mythic yang sudah ada, diperbesar sesuai ukurannya — bukan lagi bentuk buatan kode.

Bentuk ikan buatan kode dihapus seluruhnya:
- Ikan sementara yang muncul selagi file 3D dimuat.
- Ikan monster yang selama ini dibangun dari bentuk-bentuk dasar.

Selama file 3D belum selesai dimuat, tidak ada apa pun yang ditampilkan (kosong), bukan ikan pengganti.

## 3. Nilai kabut per cuaca

Disetel dengan satuan yang sama seperti sekarang (nilai dibagi 1000):

| Cuaca | Nilai kabut |
| --- | --- |
| Cerah | 0 |
| Berawan | 3 |
| Berkabut | 6 |
| Hujan | 3 |
| Badai | 5 |

## 4. Posisi perahu

Perahu dipindahkan ke ujung dermaga kayu dekat area utama (sekitar x 19, z 70), dengan arah haluan mengikuti arah dermaga sehingga terlihat tertambat rapi di ujungnya, dan pemain bisa naik dari dermaga.

## Catatan teknis

- `src/components/game/Angler.tsx`: tampilkan grup ikan hanya pada fase `caught` (hapus `phase === "reel"` dari kondisi visibilitas), sama untuk grup monster.
- `src/components/game/Fish.tsx`: hapus `FishFallback`, gunakan `<Suspense fallback={null}>`.
- `src/components/game/MonsterFish.tsx`: ganti isi dengan pemuat GLB (pakai `/models/fish_mythic_3.glb`, auto-center + auto-scale seperti `FishModel`), pertahankan nama ekspor `MonsterFishMesh` agar pemanggilnya tetap jalan; parameter `jawOpen` yang tidak relevan lagi dihapus dari pemakaian.
- `src/hooks/useWeather.ts`: `fogDensity` → cerah 0, berawan 0.003, berkabut 0.006, hujan 0.003, badai 0.005.
- Posisi awal perahu di `src/hooks/useBoat.ts` (`pos`) diubah ke ujung dermaga sekitar `(19.4, 0, 69.9)` dengan offset kecil ke arah air, plus sudut hadap menyesuaikan rotasi dermaga (≈1.4 rad); diverifikasi lewat tangkapan layar browser.
