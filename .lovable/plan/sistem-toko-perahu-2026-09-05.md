# Sistem Toko Perahu

Captain Vex (dealer di pier timur) berhenti bilang "coming soon" dan mulai menjual perahu. Pemain baru tetap dapat perahu kayu gratis, lalu bisa naik kelas ke perahu yang lebih cepat.

## Daftar perahu

| Perahu | Harga | Kecepatan | Model 3D |
| --- | --- | --- | --- |
| Wooden Dinghy (gratis untuk pemain baru) | 0 | 100% | perahu kayu yang sudah ada |
| Minnow | 100.000 | 120% | ss_minnow_iii |
| Reef Runner | 250.000 | 150% | ss_minnow_iv |
| Bow Raider | 500.000 | 200% | 220 bow raider power boat |
| Sea Marshal | 1.000.000 | 250% | motor_boat_iii |
| Vex Yacht | 2.500.000 | 300% | yacht_ii |

Kecepatan 100% = perahu kayu sekarang; 300% adalah batas atas (Vex Yacht).

## Cara pakai perahu

- Tekan E di dekat perahu untuk naik. Setelah di atas kapal, karakter **bebas berjalan di dek** dan tetap bergerak bersama kapal saat kapal melaju.
- Memancing bisa dilakukan sambil berdiri di dek, sama seperti di boardwalk.
- Di area kemudi (helm) muncul petunjuk: tekan E untuk mengambil alih kemudi (W/S gas & mundur, A/D setir), tekan E lagi untuk lepas kemudi dan jalan lagi.
- Tekan E di tepi dek saat kapal berhenti untuk turun ke air/dermaga.
- Perahu yang tampil di dunia adalah perahu yang sedang dipakai; ganti perahu dari toko Captain Vex.

## Toko

Panel toko mengikuti gaya toko pancing/umpan: kartu per perahu dengan nama, kecepatan, harga, tombol Beli dan Pakai, plus saldo koin dan pesan kalau koin kurang.

## Catatan teknis

**Aset.** 5 file GLB (total ~100 MB, satu file 52 MB) diunduh dari repo GitHub yang diberikan, diunggah ke CDN aset Lovable, dan direferensikan lewat pointer `.asset.json`; binari tidak disimpan di repo. Model dimuat lazy (hanya perahu yang dipakai) dengan auto-center/auto-scale seperti `BoatModel` sekarang, ditambah target panjang lambung per perahu.

**Database (satu migrasi).**
- `boat_tiers`: `id`, `name`, `speed_percent`, `price_coins`, `sort_order` — read publik (anon + authenticated), mengikuti pola `rod_tiers`.
- `player_boats`: `wallet_address`, `boat_id`, `equipped`, `purchased_at`, PK gabungan + FK ke `profiles`/`boat_tiers`, RLS tanpa policy (akses hanya via fungsi security definer), GRANT untuk `service_role`.
- Fungsi: `get_player_boats(_wallet)`, `buy_boat(_wallet,_boat_id)`, `equip_boat(_wallet,_boat_id)` — salinan pola rod.
- `ensure_starter_gear` diperluas: insert `wooden_dinghy` equipped untuk wallet baru.
- Seed literal 6 baris `boat_tiers` sesuai tabel harga di atas.

**Kode.**
- `src/lib/boats.functions.ts` (server fn dengan verifikasi wallet proof), `src/hooks/useBoatStore.ts`, `src/components/game/BoatShop.tsx`, dan katalog model di `src/lib/boatModels.ts`.
- `NpcDialog` / `npcs.ts`: ganti `comingSoon` Captain Vex jadi `sellsBoats: true`.
- `src/hooks/useBoat.ts`: tambah `driving` (di kemudi) selain `riding` (di kapal), `deckOffset` posisi lokal karakter di dek, dan `speedFactor` dari perahu yang dipakai.
- `src/components/game/Boat.tsx`: MAX_SPEED/ACCEL dikali `speedFactor`; saat `riding` tapi tidak `driving`, gerak karakter diproses di ruang lokal kapal lalu dipetakan ke dunia (dibatasi kotak dek) sehingga karakter ikut bergerak dan bisa memancing.
- `src/components/game/Angler.tsx` dan `usePlayer.ts`: saat di atas kapal, tinggi lantai = dek kapal (bukan air), jadi karakter tidak dianggap berenang.
