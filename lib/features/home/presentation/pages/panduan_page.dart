import 'package:flutter/material.dart';

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panduan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      // 🔹 Konten utama
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Panduan Penggunaan Aplikasi Sistem\nLaporan Kinerja',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Login ke Sistem',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Buka halaman utama aplikasi.\n'
                      '• Masukkan username (NIP) dan password yang telah terdaftar pada sistem.\n'
                      '• Jika belum memiliki akun, hubungi Administrator atau Tim IT RSUD Bangil untuk pendaftaran akun baru.\n'
                      '• Pastikan menjaga kerahasiaan akun Anda demi keamanan data pribadi dan kinerja.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '2. Mengelola Perjanjian Kinerja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Pilih menu “Perjanjian” pada halaman utama.\n'
                      '• Klik tombol “Tambah Perjanjian” untuk membuat perjanjian baru.\n'
                      '• Isi formulir perjanjian sesuai dengan data kinerja yang telah disepakati, seperti:\n'
                      '   - Nama dan Jabatan pihak pertama serta pihak kedua,\n'
                      '   - Judul dan deskripsi perjanjian,\n'
                      '   - Target dan indikator kinerja.\n'
                      '• Setelah semua data lengkap, tekan “Simpan” untuk menyimpan draft atau “Kirim” untuk mengajukan perjanjian.\n'
                      '• Anda dapat memantau status perjanjian (Menunggu, Disetujui, Ditolak) melalui halaman Daftar Form Perjanjian.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 16),

                    Text(
                      '3. Mengisi Laporan Kinerja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Akses menu “Laporan Kinerja” untuk melaporkan hasil capaian berdasarkan perjanjian yang telah disetujui.\n'
                      '• Pilih periode pelaporan (triwulan, semester, atau tahunan).\n'
                      '• Isi data capaian sesuai indikator kinerja.\n'
                      '• Klik “Simpan” untuk menyimpan data sementara atau “Kirim” untuk mengirim laporan ke atasan.\n'
                      '• Pastikan seluruh data capaian terisi dengan benar sebelum mengirim laporan.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '4. Mengubah Profil dan Tanda Tangan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Pilih menu “Profil Saya”.\n'
                      '• Anda dapat memperbarui data pribadi, jabatan, dan tanda tangan digital.\n'
                      '• Klik tombol “Simpan” untuk memperbarui informasi.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '5. Bantuan dan Dukungan Teknis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Jika mengalami kendala dalam penggunaan aplikasi:\n'
                      '• Hubungi Tim IT RSUD Bangil melalui menu “Kontak” di dalam aplikasi.\n'
                      '• Sertakan keterangan masalah dan tangkapan layar (jika perlu).\n'
                      '• Tim IT akan membantu menyelesaikan kendala teknis dengan cepat.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Catatan Keamanan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Selalu logout setelah selesai menggunakan aplikasi.\n'
                      '• Jangan membagikan kredensial (username & password) kepada pihak lain.\n'
                      '• Gunakan perangkat yang aman dan terpercaya untuk mengakses sistem.\n'
                      '• Laporkan segera kepada Tim IT jika mencurigai adanya aktivitas tidak sah pada akun Anda.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Footer
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
