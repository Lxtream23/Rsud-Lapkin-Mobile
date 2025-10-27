import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../controllers/kontak_controller.dart';

class KontakPage extends StatefulWidget {
  const KontakPage({super.key});

  @override
  State<KontakPage> createState() => _KontakPageState();
}

class _KontakPageState extends State<KontakPage> {
  final _controller = KontakController();
  // Controller form
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _pesanController = TextEditingController();

  bool _pesanTerkirim = false;
  bool _isLoading = false;

  // Fungsi kirim pesan (dummy / simulasi)
  Future<void> _handleKirimPesan() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final pesan = _pesanController.text.trim();

    if (nama.isEmpty || email.isEmpty || pesan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom harus diisi."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _controller.sendContactMessage(
      nama: nama,
      email: email,
      pesan: pesan,
    );

    setState(() {
      _isLoading = false;
      _pesanTerkirim = success;
      if (success) {
        _namaController.clear();
        _emailController.clear();
        _pesanController.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Pesan berhasil dikirim!"
              : "Gagal mengirim pesan. Silakan coba lagi.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Kontak Kami',
          style: AppTextStyle.titleMedium.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Judul
                  Center(
                    child: Text(
                      'Informasi Kontak',
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Info kontak
                  _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value:
                        'Jl. Raya Raci – Bangil, Balungbendo, Masangan, Kec. Bangil, Pasuruan, Jawa Timur',
                  ),
                  _buildInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Telephone',
                    value: '+62 821-4231-6268',
                  ),
                  _buildInfoItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'magangrsudbangil@gmail.com',
                  ),
                  _buildInfoItem(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: 'https://rsudbangil.pasuruankab.go.id/',
                  ),
                  _buildInfoItem(
                    icon: Icons.access_time_outlined,
                    label: 'Jam Operasional',
                    value: 'Senin - Jumat. 08.00 – 16.00 WIB',
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Form kirim pesan
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField('Nama Lengkap', _namaController),
                          _buildTextField('Email', _emailController),
                          _buildTextField(
                            'Pesan',
                            _pesanController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 6),
                          _buildSendButton(),
                          if (_pesanTerkirim) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Pesan Anda telah terkirim. Terima kasih.',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🔹 Footer
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textDark, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleKirimPesan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'KIRIM PESAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
