# Blueprint Arsitektur Aplikasi Kasir (POS) Modern

**Setara Majoo / Mekari POS — Berbasis Flutter Web (PWA), Database Gratis & Hosting Vercel**

Dokumen ini merupakan panduan teknis (*System Design & Blueprint*) untuk membangun aplikasi kasir *cloud* multi-platform yang dapat diakses dengan mulus di iPhone, iPad/Tablet Android, maupun Desktop melalui browser (dan dapat di-install layaknya aplikasi native menggunakan PWA).

---

## 1. Rekomendasi Tech Stack (100% Free Tier Friendly)

Untuk menyaingi kecepatan dan fitur aplikasi seperti Majoo atau Mekari POS tanpa biaya infrastruktur di awal, berikut adalah kombinasi teknologi terbaik:

| Komponen | Teknologi Pilihan | Alasan Pemilihan & Kuota Gratis |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter Web (PWA)** | Satu kode untuk tampilan *Mobile* (iPhone), *Tablet* (iPad/Tab), dan *Desktop*. Mendukung instalasi ke *Home Screen* iOS/Android. |
| **UI & Animasi Modern** | **`flutter_animate` + Material 3** | Animasi mikro yang halus (60fps), transisi *shared-axis*, dan efek *shimmer* tanpa mengorbankan kecepatan kasir. |
| **Visualisasi Grafik** | **`fl_chart`** | Library grafik interaktif di Flutter untuk membuat *Pie Chart*, *Donut Chart*, dan *Bar Chart* (Modal vs Keuntungan) dengan animasi *touch-tooltip*. |
| **State Management** | **Flutter Riverpod** | Sangat stabil untuk mengelola *state* keranjang belanja (*cart*), filter rentang waktu laporan, dan kalkulasi laba *real-time*. |
| **Database & Auth** | **Supabase (PostgreSQL)** | **Database Gratis Terbaik:** 500 MB PostgreSQL murni, *Google OAuth* bawaan gratis, *Unlimited API requests*, dan *Realtime Subscription*. |
| **Offline Storage (Cache)** | **Drift (SQLite Web) / Hive** | Menyimpan katalog produk dan antrean transaksi sementara di *IndexedDB* browser jika internet kasir tiba-tiba terputus. |
| **Hosting Web** | **Vercel (Free / Hobby Plan)** | CDN global super cepat, SSL (HTTPS) otomatis (wajib untuk Google Login & akses kamera di iPhone), serta integrasi CI/CD GitLab/GitHub. |
| **Cetak Struk & Export** | `flutter_thermal_printer` + `pdf` + `excel` | Cetak struk via Bluetooth/AirPrint serta unduh laporan bulanan ke PDF dan Excel (.xlsx). |

---

## 2. Sistem Desain Modern, Animasi Terkini & UX Kasir yang Simple

Kasir membutuhkan kecepatan tinggi (tidak boleh terhambat animasi yang lambat), namun pemilik usaha (*Owner*) menyukai tampilan visual yang mewah dan modern. Prinsip desain yang digunakan adalah **"Fast Micro-Interactions & Clean Bento Grid"**:

### A. Palet Warna & Gaya Visual (Modern SaaS)
* **Surface & Background:** Menggunakan *Soft Slate Grey* (`#F8FAFC`) dengan kartu putih bersih (`#FFFFFF`) dan *border* tipis (`#E2E8F0`) agar mata kasir tidak cepat lelah.
* **Primary Accent:** *Electric Indigo* (`#4F46E5`) atau *Emerald Teal* (`#0D9488`) untuk tombol aksi utama.
* **Semantic Financial Colors:**
  * **Keuntungan Bersih (Profit):** *Vibrant Emerald* (`#10B981`)
  * **Harga Modal (HPP/COGS):** *Amber Orange* (`#F59E0B`)
  * **Omzet Kotor (Revenue):** *Royal Blue* (`#3B82F6`)

### B. Animasi Terkini yang Tetap Simple (Durasi $\le 200\text{ ms}$)
1. **Spring Scale Tap pada Kartu Produk:** Saat kasir menekan menu (misal *Es Kopi Susu*), kartu produk mengecil sedikit ($0.95\times$) selama $100\text{ ms}$ lalu memantul kembali disertai *badge* angka kuantitas yang muncul dengan efek *pop-up*.
2. **Animated Counter (`AnimatedSwitcher` / Count-Up):** Saat item masuk keranjang atau saat *Owner* mengganti filter laporan (Hari Ini $\rightarrow$ Bulan Ini), angka Rupiah dan persentase keuntungan berputar naik secara halus, bukan sekadar berganti kaku.
3. **Interactive Pie Chart Sweep:** Saat membuka Dashboard, *Donut/Pie Chart* berputar membentuk lingkaran selama $400\text{ ms}$. Jika salah satu bagian (*slice*) diketuk di layar iPhone/iPad, bagian tersebut sedikit bergeser keluar (*explode effect*) menampilkan detail Rupiah dan persentasenya.
4. **Skeleton Shimmer Loading:** Menggantikan *loading spinner* berputar yang membosankan dengan efek bayangan bergerak (*shimmer*) berbentuk kartu produk dan grafik saat mengambil data dari Supabase.

---

## 3. Apakah Login dengan Google Perlu? (Arsitektur Hybrid Auth)

**Jawaban Singkat: SANGAT PERLU untuk Pemilik Usaha (Owner), namun dikombinasikan dengan Quick PIN (4–6 Digit) untuk Kasir.**

Mengapa demikian? Berikut perbandingan kebutuhan nyatanya di lapangan:

| Peran Pengguna | Metode Login Terbaik | Alasan UX & Keamanan |
| :--- | :--- | :--- |
| **Owner / Manajer Toko** | **Login dengan Google (OAuth)** | **1-Tap Sign In** di iPhone/iPad/Laptop tanpa perlu menghafal password baru, tidak perlu biaya kirim OTP SMS/Email, dan langsung terintegrasi gratis di **Supabase Auth**. |
| **Staf Kasir (Operasional)** | **Pilih Nama + PIN 4 Digit** | Di meja kasir, berganti shift antar staf harus selesai dalam **2 detik**. Setelah perangkat tablet di-login oleh *Owner* (via Google), kasir cukup menekan foto profilnya dan memasukkan PIN `1234` seperti membuka layar HP. |

**Alur Implementasi di Supabase + Vercel:**
1. Owner klik **"Masuk dengan Google"** $\rightarrow$ Otomatis membuat toko/cabang baru jika belum ada.
2. Di menu Pengaturan, Owner menambahkan daftar Kasir beserta kode PIN masing-masing.
3. Saat mode **Kiosk/Kasir** aktif di Tablet, layar terkunci menggunakan *PIN Pad* cepat sehingga kasir tidak bisa mengintip menu **Dashboard Keuntungan/Laporan Owner** tanpa PIN Owner.

---

## 4. Manajemen Produk: Harga Jual vs Harga Modal (HPP)

Agar sistem dapat menghitung **Keuntungan Bersih (Gross Profit)** dan **Margin (%)** secara otomatis di setiap transaksi, setiap produk memiliki input **Harga Jual** dan **Harga Modal / HPP (Harga Pokok Penjualan)**.

### Contoh Simulasi Input Produk: "Es Kopi Susu"
Saat Owner menambahkan produk di form Manajemen Menu, sistem menampilkan **Kalkulator Margin Otomatis** secara *real-time*:

| Field Input / Kalkulasi | Nilai Contoh | Keterangan Sistem |
| :--- | :--- | :--- |
| **Nama Produk** | Es Kopi Susu Aren | Kategori: *Signature Coffee* |
| **Harga Jual (Selling Price)** | **Rp 18.000** | Harga yang dibayar pelanggan di kasir. |
| **Harga Modal / HPP (Cost Price)** | **Rp 7.500** | Bisa diinput langsung (Rp 7.500) atau dari rincian bahan (*Espresso Rp 2.500 + Susu Rp 3.000 + Aren Rp 1.000 + Cup Rp 1.000*). |
| **Keuntungan per Cup (Otomatis)** | **Rp 10.500** | Dihitung otomatis: $\text{Rp } 18.000 - \text{Rp } 7.500$. |
| **Persentase Margin (Otomatis)** | **$58.33\%$** | Indikator warna **Hijau (Margin Sehat)** karena $> 40\%$. |
| **Persentase Modal (COGS %)** | **$41.67\%$** | Porsi modal terhadap harga jual. |

> **Catatan Penting Database:** Saat transaksi terjadi, sistem wajib menyimpan `unit_price` (Harga Jual saat itu) DAN `unit_cost` (Harga Modal saat itu) ke dalam tabel `order_items`. Dengan begitu, jika bulan depan harga susu naik dan Anda mengubah Harga Modal *Es Kopi Susu* menjadi Rp 8.500, **laporan keuntungan bulan lalu tidak ikut berubah/rusak** (*Historical Cost Accuracy*).

---

## 5. Dashboard Analitik: Pie Chart & Filter Waktu Dinamis

Di halaman **Dashboard Owner**, terdapat filter waktu *segmented button* yang interaktif:
`[ Hari Ini ]` `[ Minggu Ini ]` `[ Bulan Ini ]` `[ Tahun Ini ]` `[ Pilih Tanggal ]`

### A. Konfigurasi Interactive Donut / Pie Chart (`fl_chart`)
Terdapat 2 mode tampilan *Pie Chart* yang bisa diganti dengan *toggle switch*:

1. **Mode 1: Komposisi Omzet (Modal vs Keuntungan Bersih vs Pajak/Diskon)**
   * Menampilkan perbandingan visual seberapa besar uang yang kembali menjadi **Modal (HPP)** dan seberapa besar yang murni menjadi **Keuntungan (Laba Kotor)**.
   * *Contoh Visual Bulan Ini (Total Omzet Rp 45.000.000):*
     * 🟢 **Keuntungan Bersih:** Rp 26.500.000 ($58.9\%$)
     * 🟠 **Total Modal (HPP):** Rp 16.000.000 ($35.5\%$)
     * 🟣 **Diskon Promo:** Rp 2.500.000 ($5.6\%$)
   * Di bagian tengah lubang *Donut Chart* tertulis angka besar: **Laba Bersih: Rp 26,5 Jt** ($\uparrow 14.2\%$ dibanding bulan lalu).

2. **Mode 2: Kontribusi Keuntungan per Kategori Menu**
   * Menampilkan kategori mana yang menyumbang keuntungan terbesar (*Contoh: Kopi $55\%$, Non-Kopi $20\%$, Makanan/Snack $25\%$*).

### B. Kartu Ringkasan Eksekutif (4 KPI Cards di Atas Grafik)
Setiap kali filter waktu (*Hari Ini / Minggu Ini / Bulan Ini / Tahun Ini*) diubah, 4 kartu ini memperbarui angkanya dengan animasi:
1. **Total Omzet (Gross Sales):** Total uang masuk dari pelanggan.
2. **Total Modal Terpakai (Total COGS):** Akumulasi modal dari seluruh produk yang terjual.
3. **Total Keuntungan (Net Profit):** $\text{Omzet Bersih} - \text{Total Modal}$.
4. **Rata-rata Margin & Jumlah Transaksi:** Contoh: *Margin $58.9\%$ dari $1.420$ Cup terjual*.

---

## 6. Laporan Lengkap Mingguan & Bulanan: Produk Terlaris, Modal & Keuntungan

Halaman laporan dirancang selengkap mungkin untuk menjawab pertanyaan utama pemilik bisnis: *"Produk apa yang paling banyak laku, berapa modal yang keluar, dan produk mana yang paling banyak menghasilkan uang?"*

### A. Contoh Tabel Laporan Penjualan Produk (Filter: Bulan Ini)

Dilengkapi fitur **Sortir (Urutkan)** berdasarkan: *Terlaris (Qty)*, *Keuntungan Tertinggi (Rp)*, atau *Margin Tertinggi (%)*, serta tombol **Export PDF & Excel**.

| Peringkat | Nama Produk | Qty Terjual | Harga Modal / Unit | Harga Jual / Unit | Total Modal (HPP) | Total Omzet Penjualan | **Total Keuntungan (Laba)** | Margin (%) | Status Analitik |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **#1** 🏆 | **Es Kopi Susu Aren** | 850 Cup | Rp 7.500 | Rp 18.000 | Rp 6.375.000 | Rp 15.300.000 | **Rp 8.925.000** | $58.3\%$ | ⭐ *Star (Laris & Untung Besar)* |
| **#2** 🔥 | **Americano Dingin** | 420 Cup | Rp 3.500 | Rp 15.000 | Rp 1.470.000 | Rp 6.300.000 | **Rp 4.830.000** | $76.7\%$ | 💎 *High Margin (Modal Kecil)* |
| **#3** 📈 | **Matcha Latte Oat** | 310 Cup | Rp 12.000 | Rp 24.000 | Rp 3.720.000 | Rp 7.440.000 | **Rp 3.720.000** | $50.0\%$ | ✅ *Stabil* |
| **#4** 🍟 | **French Fries Large** | 290 Porsi | Rp 8.000 | Rp 20.000 | Rp 2.320.000 | Rp 5.800.000 | **Rp 3.480.000** | $60.0\%$ | ✅ *Pendamping Terbaik* |
| **#5** ⚠️ | **Croissant Butter** | 180 Pcs | Rp 14.000 | Rp 18.000 | Rp 2.520.000 | Rp 3.240.000 | **Rp 720.000** | $22.2\%$ | ⚠️ *Margin Tipis (Evaluasi HPP)* |
| **TOTAL** | **Semua Produk** | **2.050 Item** | - | - | **Rp 16.405.000** | **Rp 38.080.000** | **Rp 21.675.000** | **$56.9\%$** | **Laba Kotor Bulan Ini** |

### B. Fitur Insight Otomatis (Menu Engineering Matrix)
Di bagian bawah laporan mingguan/bulanan, sistem memberikan rekomendasi otomatis kepada Owner:
* 🌟 **Produk Bintang (High Volume, High Profit):** *Es Kopi Susu Aren* — Pertahankan kualitas dan jadikan menu utama di baris paling atas layar kasir.
* 💎 **Tambang Emas Tersembunyi (High Margin, Medium Volume):** *Americano Dingin* (Margin $76.7\%$) — Buat promo *bundling* dengan makanan ringan untuk meningkatkan jumlah penjualan.
* ⚠️ **Perlu Evaluasi Harga/Modal (Low Margin):** *Croissant Butter* (Modal terlalu tinggi dibanding harga jual) — Naikkan harga jual Rp 3.000 atau cari *supplier* bahan dengan harga lebih rendah.
* 💤 **Produk Kurang Laku (Dead Stock / Slow Moving):** Daftar produk yang terjual $< 5$ item dalam sebulan terakhir agar tidak membuang stok bahan baku.

---

## 7. Desain Responsif (Adaptive Layout: iPhone vs Tablet/iPad)

Aplikasi POS memiliki tata letak yang otomatis menyesuaikan ukuran layar (*Breakpoint Architecture*):

### A. Tampilan Layar Lebar: Tablet (iPad / Android Tab) & Desktop (`Lebar >= 768px`)
Menggunakan konsep **Split-Screen (2 atau 3 Kolom)** khas Mekari POS / Majoo:
* **Sidebar Kiri (Navigasi Ringkas):** Kasir, Pesanan Aktif (Open Bill), Dashboard Analitik, Laporan Laba/Rugi, Manajemen Produk & HPP, Pengaturan.
* **Area Tengah (65% Layar - Katalog Produk):**
  * Kolom pencarian cepat (*Search bar*) & tombol *Scan Barcode*.
  * Filter kategori horizontal dengan animasi *sliding indicator*.
  * *Grid* kartu produk yang menampilkan foto, nama, harga jual, dan indikator sisa stok.
* **Panel Kanan (35% Layar - Keranjang & Checkout Tetap):**
  * Pilihan Tipe Order (*Dine-In, Takeaway, Delivery*).
  * Daftar item yang dibeli (tombol `+`, `-`, catatan item, diskon).
  * Rincian kalkulasi & tombol **Simpan Bill** atau **Bayar Sekarang**.

### B. Tampilan Layar Kecil: iPhone / Smartphone (`Lebar < 768px`)
Menggunakan konsep **Single Column + Sticky Bottom Cart Bar**:
* **Mode Kasir di iPhone:** Fokus pada katalog menu dan *Floating Bottom Bar* (`🛒 4 Item | Rp 72.000 -> Bayar`) yang membuka *Modal Bottom Sheet* saat diketuk.
* **Mode Owner di iPhone:** Saat Owner membuka aplikasi di iPhone, tampilan *Pie Chart* dan kartu *Keuntungan vs Modal* tersusun rapi secara vertikal (*scrollable cards*) sehingga sangat nyaman dipantau dengan satu tangan.

---

## 8. Skema Database PostgreSQL + View Analitik (Siap Pakai di Supabase)

Salin dan jalankan *script* SQL berikut di **SQL Editor Supabase** Anda. Skema ini sudah mendukung pencatatan Harga Modal (`cost_price`) historis dan dilengkapi *Query View* untuk Pie Chart serta Laporan Produk Terlaris:

```sql
-- 1. Tabel Kategori Produk
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabel Produk (Lengkap dengan Harga Jual & Harga Modal/HPP)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  sku VARCHAR(50) UNIQUE,
  name VARCHAR(150) NOT NULL,           -- Contoh: 'Es Kopi Susu Aren'
  price NUMERIC(12, 2) NOT NULL DEFAULT 0,      -- Harga Jual (Rp 18.000)
  cost_price NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Harga Modal / HPP (Rp 7.500)
  stock INT NOT NULL DEFAULT 0,
  track_stock BOOLEAN DEFAULT TRUE,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Tabel Profil Staf & PIN Kasir (Terhubung dengan Google Auth Owner)
CREATE TABLE staff_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(20) DEFAULT 'CASHIER', -- OWNER, MANAGER, CASHIER
  pin_code VARCHAR(6) NOT NULL,       -- PIN 4-6 digit untuk pindah shift cepat
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tabel Transaksi / Order (Header)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number VARCHAR(50) UNIQUE NOT NULL,
  cashier_name VARCHAR(100),
  order_type VARCHAR(30) DEFAULT 'DINE_IN',
  subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  tax_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  grand_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total_cost NUMERIC(12, 2) NOT NULL DEFAULT 0,   -- Total Modal pada transaksi ini
  total_profit NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Total Keuntungan Bersih transaksi ini
  payment_method VARCHAR(30), -- CASH, QRIS, DEBIT, TRANSFER
  status VARCHAR(20) DEFAULT 'COMPLETED', -- OPEN_BILL, COMPLETED, VOID
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Tabel Detail Item Transaksi (Menyimpan Modal & Laba per Item)
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR(150) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price NUMERIC(12, 2) NOT NULL, -- Harga Jual saat transaksi
  unit_cost NUMERIC(12, 2) NOT NULL,  -- Harga Modal (HPP) saat transaksi
  total_price NUMERIC(12, 2) NOT NULL, -- quantity * unit_price
  total_cost NUMERIC(12, 2) NOT NULL,  -- quantity * unit_cost
  item_profit NUMERIC(12, 2) NOT NULL, -- total_price - total_cost
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. RPC / Fungsi Analitik Produk Terlaris, Modal & Keuntungan per Rentang Tanggal
CREATE OR REPLACE FUNCTION get_product_sales_report(start_date TIMESTAMPTZ, end_date TIMESTAMPTZ)
RETURNS TABLE (
  product_id UUID,
  product_name VARCHAR,
  qty_sold BIGINT,
  unit_cost NUMERIC,
  unit_price NUMERIC,
  total_modal NUMERIC,
  total_omzet NUMERIC,
  total_keuntungan NUMERIC,
  margin_persen NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    oi.product_id,
    oi.product_name,
    SUM(oi.quantity)::BIGINT AS qty_sold,
    AVG(oi.unit_cost)::NUMERIC(12,2) AS unit_cost,
    AVG(oi.unit_price)::NUMERIC(12,2) AS unit_price,
    SUM(oi.total_cost)::NUMERIC(12,2) AS total_modal,
    SUM(oi.total_price)::NUMERIC(12,2) AS total_omzet,
    SUM(oi.item_profit)::NUMERIC(12,2) AS total_keuntungan,
    CASE 
      WHEN SUM(oi.total_price) > 0 
      THEN ROUND((SUM(oi.item_profit) / SUM(oi.total_price)) * 100, 2)
      ELSE 0 
    END AS margin_persen
  FROM order_items oi
  JOIN orders o ON o.id = oi.order_id
  WHERE o.status = 'COMPLETED'
    AND o.created_at BETWEEN start_date AND end_date
  GROUP BY oi.product_id, oi.product_name
  ORDER BY qty_sold DESC, total_keuntungan DESC;
END;
$$ LANGUAGE plpgsql;
```

---

## 9. Rumus Kalkulasi Kasir & Analitik Keuntungan

Di dalam *State Management* Flutter, gunakan rumus berikut untuk menghitung transaksi sekaligus metrik Pie Chart:

### A. Rumus per Item Produk (Contoh: Es Kopi Susu)
$$\text{Laba per Unit} = \text{Harga Jual} - \text{Harga Modal (HPP)}$$

$$\text{Margin Produk (\%)} = \left( \frac{\text{Harga Jual} - \text{Harga Modal}}{\text{Harga Jual}} \right) \times 100\%$$

$$\text{Markup Modal (\%)} = \left( \frac{\text{Harga Jual} - \text{Harga Modal}}{\text{Harga Modal}} \right) \times 100\%$$

### B. Rumus Agregasi Dashboard (Hari Ini / Minggu Ini / Bulan Ini / Tahun Ini)
$$\text{Total Omzet Bersih (Net Sales)} = \sum \text{Total Penjualan Item} - \text{Total Diskon Promo}$$

$$\text{Total Modal (COGS)} = \sum (\text{Harga Modal Item} \times \text{Kuantitas Terjual})$$

$$\text{Keuntungan Bersih (Gross Profit)} = \text{Total Omzet Bersih} - \text{Total Modal (COGS)}$$

---

## 10. Struktur Folder Project Flutter (`lib/`)

```text
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── supabase_config.dart         # Inisialisasi Supabase & Google OAuth
│   ├── theme/
│   │   ├── app_theme.dart               # Palet warna SaaS & tipografi Inter/Plus Jakarta Sans
│   │   └── micro_animations.dart        # Konfigurasi animasi cepat (150ms-300ms)
│   └── responsive/
│       └── responsive_layout.dart       # Detektor layar iPhone vs iPad/Desktop
├── features/
│   ├── auth/
│   │   ├── google_login_screen.dart     # Login Google untuk Owner
│   │   └── cashier_pin_lock.dart        # Lockscreen PIN 4 digit untuk Kasir
│   ├── pos_cashier/                     # Modul Utama Kasir
│   │   ├── models/
│   │   ├── providers/                   # CartNotifier (Hitung Omzet, Modal & Laba otomatis)
│   │   └── presentation/
│   │       ├── pos_screen.dart
│   │       └── widgets/
│   │           ├── animated_product_card.dart
│   │           ├── cart_panel.dart
│   │           └── payment_modal.dart
│   ├── menu_management/                 # Modul Input Produk (Harga Jual & Harga Modal/HPP)
│   │   └── product_form_dialog.dart     # Dilengkapi kalkulator margin otomatis
│   └── analytics_reports/               # Modul Dashboard Pie Chart & Laporan Terlaris
│       ├── dashboard_screen.dart
│       ├── widgets/
│       │   ├── profit_modal_pie_chart.dart  # Donut Chart (Hari/Minggu/Bulan/Tahun)
│       │   ├── period_filter_bar.dart       # Toggle Hari Ini, Minggu Ini, Bulan Ini, Tahun Ini
│       │   └── top_products_report_table.dart # Tabel Produk Terlaris, Modal & Keuntungan
└── shared/
    └── utils/
        └── currency_formatter.dart      # Format Rupiah (Rp 18.000)
```

---

## 11. Optimasi Khusus iPhone & iPad (Safari / iOS PWA) & Hosting Vercel

### A. Konfigurasi `web/index.html` untuk iPhone / iPad
Tambahkan meta tag berikut agar saat disimpan ke *Home Screen* iPhone/iPad berjalan *full-screen* tanpa bar browser:

```html
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="POS Kasir">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
```

### B. Deploy Cepat ke Vercel (`vercel.json`)
Letakkan file `vercel.json` di *root* project:

```json
{
  "buildCommand": "if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter config --enable-web && flutter/bin/flutter build web --release",
  "outputDirectory": "build/web",
  "framework": null,
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

> **Catatan Google Login di Vercel:** Setelah mendapatkan URL produksi dari Vercel (misal `https://kopi-pos.vercel.app`), daftarkan URL tersebut di **Supabase Dashboard $\rightarrow$ Authentication $\rightarrow$ URL Configuration (Site URL & Redirect URLs)** agar fitur *Login with Google* berjalan lancar di semua perangkat.