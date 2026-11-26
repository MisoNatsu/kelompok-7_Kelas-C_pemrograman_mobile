// =====================================================
// 2. Independent Practice — Simple Shopping Cart
// =====================================================
// Menyimpan beberapa produk (nama, harga, jumlah),
// menghitung subtotal, diskon, dan total pembayaran.

// --- VARIABLE & TIPE DATA ---
// Class Produk menampung String (nama), double (harga), int (jumlah)
class Produk {
  String nama;
  double harga;
  int jumlah;

  Produk(this.nama, this.harga, this.jumlah);
}

// --- FUNCTION ---
// --- OPERATOR ---
// * (perkalian) untuk menghitung subtotal 1 produk
double hitungSubtotal(Produk p) {
  return p.harga * p.jumlah;
}

// --- FUNCTION ---
// Menentukan besar diskon berdasarkan total belanja
double hitungDiskon(double totalBelanja) {
  // --- IF/ELSE ---
  // Diskon bertingkat: makin besar belanja, makin besar persentase diskon
  if (totalBelanja >= 500000) {
    return totalBelanja * 0.15;
  } else if (totalBelanja >= 200000) {
    return totalBelanja * 0.10;
  } else if (totalBelanja >= 100000) {
    return totalBelanja * 0.05;
  } else {
    return 0;
  }
}

void main() {
  // --- VARIABLE & TIPE DATA ---
  List<Produk> keranjang = [
    Produk('Kaos', 75000, 3),
    Produk('Celana', 150000, 2),
    Produk('Topi', 50000, 1),
  ];

  double totalBelanja = 0;

  print('=== Simple Shopping Cart ===\n');
  print('Daftar Produk:');

  // --- LOOP ---
  // for-in mengolah setiap produk, mengakumulasi total belanja
  for (var p in keranjang) {
    double subtotal = hitungSubtotal(p);
    // --- OPERATOR ---
    // += (penjumlahan sekaligus penugasan) untuk akumulasi total
    totalBelanja += subtotal;
    print('${p.nama.padRight(10)} x${p.jumlah}  @Rp${p.harga.toStringAsFixed(0).padLeft(8)}  = Rp${subtotal.toStringAsFixed(0)}');
  }

  double diskon = hitungDiskon(totalBelanja);
  // --- OPERATOR ---
  // - (pengurangan) untuk mendapatkan total akhir yang harus dibayar
  double totalBayar = totalBelanja - diskon;

  print('\n------------------------------');
  print('Subtotal      : Rp${totalBelanja.toStringAsFixed(0)}');
  print('Diskon        : Rp${diskon.toStringAsFixed(0)}');
  print('Total Bayar   : Rp${totalBayar.toStringAsFixed(0)}');

  // --- IF/ELSE ---
  if (diskon > 0) {
    print('\nSelamat! Anda mendapatkan diskon.');
  } else {
    print('\nBelum memenuhi syarat diskon.');
  }
}

/* CONTOH OUTPUT:
=== Simple Shopping Cart ===

Daftar Produk:
Kaos       x3  @Rp   75000  = Rp225000
Celana     x2  @Rp  150000  = Rp300000
Topi       x1  @Rp   50000  = Rp50000

------------------------------
Subtotal      : Rp575000
Diskon        : Rp86250
Total Bayar   : Rp488750

Selamat! Anda mendapatkan diskon.
*/
