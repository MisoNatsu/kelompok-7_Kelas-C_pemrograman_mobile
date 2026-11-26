void main() {
  List<Map<String, dynamic>> cart = [
    {'nama': 'Kopi Susu', 'harga': 18000.0, 'jumlah': 2},
    {'nama': 'Roti Bakar', 'harga': 25000.0, 'jumlah': 1},
    {'nama': 'Nasi Goreng', 'harga': 30000.0, 'jumlah': 2},
  ];

  print('=== SIMPLE SHOPPING CART ===\n');
  print('Daftar Pembelian:');

  double subtotalKeseluruhan = 0;

  for (var item in cart) {
    double itemSubtotal = calculateItemSubtotal(item['harga'], item['jumlah']);
    subtotalKeseluruhan += itemSubtotal;

    print('- ${item['nama']} x${item['jumlah']} @ Rp${item['harga'].toStringAsFixed(0)} = Rp${itemSubtotal.toStringAsFixed(0)}');
  }
 
  processCheckout(subtotalKeseluruhan);
}

double calculateItemSubtotal(double harga, int jumlah) {
  return harga * jumlah;
}

void processCheckout(double subtotal) {
  double diskon = 0;

  if (subtotal >= 100000) {
    diskon = subtotal * 0.10;
  }

  double totalBayar = subtotal - diskon;

  print('\n-----------------------------');
  print('Subtotal    : Rp ${subtotal.toStringAsFixed(0)}');
  print('Diskon      : Rp ${diskon.toStringAsFixed(0)} ${diskon > 0 ? '(10%)' : '(0%)'}');
  print('Total Bayar : Rp ${totalBayar.toStringAsFixed(0)}');
  print('-----------------------------');
}