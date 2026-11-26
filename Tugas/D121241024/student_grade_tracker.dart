void main() {
  List<Map<String, dynamic>> students = [
    {'nama': 'Raya', 'nilai': 85.5, 'kehadiran': 90},
    {'nama': 'Budi', 'nilai': 65.0, 'kehadiran': 80},
    {'nama': 'Siti', 'nilai': 75.0, 'kehadiran': 60},
    {'nama': 'Andi', 'nilai': 45.0, 'kehadiran': 50},
  ];

  print('=== STUDENT GRADE TRACKER ===\n');
  
  for (var student in students) {
    processStudentGrade(student);
  }
}

void processStudentGrade(Map<String, dynamic> student) {
  String nama = student['nama'];
  double nilai = student['nilai'];
  int kehadiran = student['kehadiran'];

  String grade;
  if (nilai >= 85) {
    grade = 'A';
  } else if (nilai >= 75) {
    grade = 'B';
  } else if (nilai >= 65) {
    grade = 'C';
  } else if (nilai >= 50) {
    grade = 'D';
  } else {
    grade = 'F';
  }

  bool isLulus = (nilai >= 70) && (kehadiran >= 75);
  String status = isLulus ? 'LULUS' : 'TIDAK LULUS';

  print('Nama      : $nama');
  print('Nilai     : $nilai');
  print('Kehadiran : $kehadiran%');
  print('Grade     : $grade');
  print('Status    : $status');
  print('-----------------------------');
}