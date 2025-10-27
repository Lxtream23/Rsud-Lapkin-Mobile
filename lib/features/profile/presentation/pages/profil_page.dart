import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _selectedImage; // untuk menyimpan file foto
  final ImagePicker _picker = ImagePicker();

  // Fungsi ambil gambar dari galeri atau kamera
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Profil Saya',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // FOTO PROFIL
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Text(
                            "FOTO\nPROFIL",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // FORM FIELD
                _buildTextField('Nama Pegawai'),
                _buildTextField('ID Pegawai'),
                _buildTextField('NIP'),
                _buildTextField('Email'),
                _buildTextField('Jabatan'),
                _buildTextField('Pangkat'),
                _buildTextField('Divisi'),

                const SizedBox(height: 10),

                // EDIT PROFIL BUTTON
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TTD AREA
                Container(
                  height: 100,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Klik untuk tanda tangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // UPLOAD FOTO TTD BUTTON
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upload Foto TTD (jpg/png)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      // FOOTER
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable field builder
  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyle.regular14.copyWith(color: AppColors.textDark),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
