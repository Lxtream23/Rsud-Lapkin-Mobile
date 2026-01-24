import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/register_controller.dart';
import '../../../../core/widgets/ui_helpers/dialogs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _idPegawaiController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _pangkatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? selectedJabatan;

  @override
  void dispose() {
    _idPegawaiController.dispose();
    _namaLengkapController.dispose();
    _emailController.dispose();
    _nipController.dispose();
    _pangkatController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Memproses...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Responsif
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo dua di atas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo_pemda.png', height: 50),
                      const SizedBox(width: 12),
                      Image.asset('assets/images/logo2.png', height: 50),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  const Text(
                    "Daftar Akun",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subjudul
                  const Text(
                    "Isi data berikut untuk membuat\nakun pegawai baru.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 24),

                  // Input fields
                  CustomTextField(
                    controller: _idPegawaiController,
                    hintText: "ID Pegawai",
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _namaLengkapController,
                    hintText: "Nama Lengkap",
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _nipController, hintText: "NIP"),
                  const SizedBox(height: 12),

                  // Dropdown untuk Jabatan
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: DropdownButtonFormField<String>(
                      isExpanded:
                          true, // 🔹 Supaya teks dan ikon tidak terpotong
                      decoration: InputDecoration(
                        hintText: 'Pilih Jabatan',
                        hintStyle: const TextStyle(color: AppColors.textDark),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: selectedJabatan,
                      items: const [
                        DropdownMenuItem(
                          value: 'Direktur',
                          child: Text('Direktur'),
                        ),
                        DropdownMenuItem(
                          value: 'Wadir Umum dan Keuangan',
                          child: Text('Wadir Umum dan Keuangan'),
                        ),
                        DropdownMenuItem(
                          value: 'Wadir Pelayanan',
                          child: Text('Wadir Pelayanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabid Pelayanan',
                          child: Text('Kabid Pelayanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabid Pelayanan Keperawatan',
                          child: Text('Kabid Pelayanan Keperawatan'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabid Pelayanan Penunjang',
                          child: Text('Kabid Pelayanan Penunjang'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabag SDM dan Pengambangan',
                          child: Text('Kabag SDM dan Pengambangan'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabag Umum',
                          child: Text('Kabag Umum'),
                        ),
                        DropdownMenuItem(
                          value: 'Kabag Keuangan',
                          child: Text('Kabag Keuangan'),
                        ),
                        DropdownMenuItem(
                          value: 'Ketua Tim Kerja',
                          child: Text('Ketua Tim Kerja'),
                        ),
                        DropdownMenuItem(
                          value: 'Admin/Staf',
                          child: Text('Admin/Staf'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedJabatan = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _pangkatController,
                    hintText: "Pangkat",
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: "Konfirmasi Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final controller = context.read<RegisterController>();

                        // 🔐 Validasi password
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          await showShadcnDialogError(
                            context,
                            title: 'Password Tidak Cocok',
                            message:
                                'Konfirmasi password tidak sesuai. Silakan periksa kembali.',
                          );
                          return;
                        }

                        // 🔄 Tampilkan loading
                        showLoadingDialog(context);

                        final result = await controller.register(
                          idPegawai: _idPegawaiController.text,
                          namaLengkap: _namaLengkapController.text,
                          email: _emailController.text,
                          nip: _nipController.text,
                          jabatan: selectedJabatan!,
                          pangkat: _pangkatController.text,
                          password: _passwordController.text,
                        );

                        if (context.mounted)
                          Navigator.pop(context); // Tutup loading

                        // ✅ Jika berhasil
                        if (result == null ||
                            result.contains('Silakan cek email') ||
                            result.contains('berhasil')) {
                          await showShadcnDialogSuccess(
                            context,
                            title: 'Akun Berhasil Dibuat',
                            message:
                                'Silakan konfirmasi email Anda, lalu login untuk melanjutkan.',
                            onOk: () {
                              // Tutup dialog dulu
                              Navigator.of(context, rootNavigator: true).pop();

                              // 🔁 Lalu arahkan ke halaman login
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          );
                        } else {
                          // ❌ Jika gagal
                          await showShadcnDialogError(
                            context,
                            title: 'Pendaftaran Gagal',
                            message: result,
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "DAFTAR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link ke login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: const Text(
                          "Login di sini",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
