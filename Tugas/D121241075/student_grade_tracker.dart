// =====================================================
// 1. Guided Practice — Student Grade Tracker
// =====================================================
// Menyimpan data mahasiswa (nama, nilai, kehadiran),
// lalu menentukan grade & status kelulusan tiap mahasiswa.

// --- VARIABLE & TIPE DATA ---
// Class Mahasiswa menampung 3 tipe data berbeda:
// String (nama), double (nilai), int (kehadiran)
class Mahasiswa {
  String nama;
  double nilai;
  int kehadiran; // dalam persen

  Mahasiswa(this.nama, this.nilai, this.kehadiran);
}

// --- FUNCTION ---
// Menentukan grade huruf berdasarkan nilai (mengembalikan String)
String tentukanGrade(double nilai) {
  // --- IF/ELSE ---
  if (nilai >= 85) {
    return 'A';
  } else if (nilai >= 75) {
    return 'B';
  } else if (nilai >= 65) {
    return 'C';
  } else if (nilai >= 50) {
    return 'D';
  } else {
    return 'E';
  }
}

// --- FUNCTION ---
// Menentukan status kelulusan (mengembalikan bool)
// --- OPERATOR ---
// >= (perbandingan) dan && (logika AND): lulus hanya jika
// nilai cukup DAN kehadiran cukup
bool tentukanKelulusan(double nilai, int kehadiran) {
  return nilai >= 60 && kehadiran >= 80;
}

void main() {
  // --- VARIABLE & TIPE DATA ---
  // List<Mahasiswa> menampung beberapa objek mahasiswa
  List<Mahasiswa> daftarMahasiswa = [
    Mahasiswa('Andi', 88, 90),
    Mahasiswa('Budi', 55, 70),
    Mahasiswa('Citra', 70, 85),
    Mahasiswa('Dewi', 92, 60),
  ];

  print('=== Student Grade Tracker ===\n');

  // --- LOOP ---
  // for-in digunakan untuk mengolah setiap mahasiswa dalam daftar
  for (var m in daftarMahasiswa) {
    String grade = tentukanGrade(m.nilai);
    bool lulus = tentukanKelulusan(m.nilai, m.kehadiran);

    print('Nama       : ${m.nama}');
    print('Nilai      : ${m.nilai}');
    print('Kehadiran  : ${m.kehadiran}%');
    print('Grade      : $grade');
    // --- OPERATOR ---
    // Ternary (? :) untuk memilih teks status secara ringkas
    print('Status     : ${lulus ? "Lulus" : "Tidak Lulus"}');
    print('------------------------------');
  }
}

/* CONTOH OUTPUT:
=== Student Grade Tracker ===

Nama       : Andi
Nilai      : 88.0
Kehadiran  : 90%
Grade      : A
Status     : Lulus
------------------------------
Nama       : Budi
Nilai      : 55.0
Kehadiran  : 70%
Grade      : D
Status     : Tidak Lulus
------------------------------
Nama       : Citra
Nilai      : 70.0
Kehadiran  : 85%
Grade      : C
Status     : Lulus
------------------------------
Nama       : Dewi
Nilai      : 92.0
Kehadiran  : 60%
Grade      : A
Status     : Tidak Lulus
------------------------------
*/
