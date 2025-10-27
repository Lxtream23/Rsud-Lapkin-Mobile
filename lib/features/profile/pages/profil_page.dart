import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_style.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;

  // Data user contoh (nanti bisa diambil dari backend)
  Map<String, String> userData = {
    'Nama Pegawai': 'Ahmad Fauzi',
    'ID Pegawai': 'PG00123',
    'NIP': '198706172019031002',
    'Email': 'ahmad.fauzi@rsudbangil.id',
    'Jabatan': 'Kabid Pelayanan',
    'Pangkat': 'III/b',
    'Divisi': 'Pelayanan Medis',
  };

  // Daftar pilihan jabatan (bisa kamu ubah sesuai kebutuhan)
  final List<String> jabatanList = [
    'Direktur',
    'Wadir Umum dan Keuangan',
    'Wadir Pelayanan',
    'Kabid Pelayanan',
    'Kabid Pelayanan Keperawatan',
    'Kabid Pelayanan Penunjang',
    'Kabag SDM dan Pengambangan',
    'Kabag Umum',
    'Kabag Keuangan',
    'Ketua Tim Kerja',
    'Admin/Staf',
  ];

  // Controller untuk field selain dropdown
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    userData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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

              // FORM FIELDS
              _buildTextField('Nama Pegawai'),
              _buildTextField('ID Pegawai'),
              _buildTextField('NIP'),
              _buildTextField('Email'),

              // 🔹 Dropdown Jabatan
              _buildDropdownField('Jabatan'),

              _buildTextField('Pangkat'),
              _buildTextField('Divisi'),

              const SizedBox(height: 10),

              // TOMBOL EDIT / SIMPAN
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        // Simpan data yang diedit
                        userData.forEach((key, _) {
                          if (key != 'Jabatan') {
                            userData[key] = _controllers[key]!.text;
                          }
                        });
                      }
                      _isEditing = !_isEditing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Simpan Profil' : 'Edit Profil',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TANDA TANGAN AREA
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

      // FOOTER
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }

  // 🔹 TextField builder
  Widget _buildTextField(String label) {
    final bool isEmail = label == 'Email';
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
              controller: _controllers[label],
              enabled: isEmail ? false : _isEditing,
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
              style: AppTextStyle.regular14,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dropdown field untuk Jabatan
  Widget _buildDropdownField(String label) {
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: userData[label],
                  isExpanded: true,
                  items: jabatanList
                      .map(
                        (jab) => DropdownMenuItem<String>(
                          value: jab,
                          child: Text(jab, style: AppTextStyle.regular14),
                        ),
                      )
                      .toList(),
                  onChanged: _isEditing
                      ? (value) {
                          setState(() {
                            userData[label] = value!;
                          });
                        }
                      : null, // nonaktif kalau bukan mode edit
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
