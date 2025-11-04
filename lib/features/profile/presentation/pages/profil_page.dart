import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  File? _selectedImage;
  File? _signatureImage;
  Uint8List? _drawnSignature;
  String? _fotoProfilUrl;
  String? _ttdUrl;
  bool _isEditing = false;
  bool _isLoading = true;

  Map<String, String> userData = {
    'Nama Pegawai': '',
    'ID Pegawai': '',
    'NIP': '',
    'Email': '',
    'Jabatan': '',
    'Pangkat': '',
  };

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

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    userData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value);
    });
    _loadUserProfile();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 🔹 Ambil data user login dari tabel `pegawai`
  Future<void> _loadUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      if (response != null) {
        setState(() {
          userData = {
            'Nama Pegawai': response['nama_lengkap'] ?? '',
            'ID Pegawai': response['id_pegawai'] ?? '',
            'NIP': response['nip'] ?? '',
            'Email': response['email'] ?? user.email ?? '',
            'Jabatan': response['jabatan'] ?? '',
            'Pangkat': response['pangkat'] ?? '',
          };
          _fotoProfilUrl = response['foto_profil'];
          _ttdUrl = response['ttd'];
          _isLoading = false;

          userData.forEach((key, value) {
            _controllers[key]?.text = value;
          });
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('⚠️ Gagal memuat profil: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Upload file ke Supabase Storage
  Future<String?> _uploadToStorage(File file, String bucket) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final path = '$bucket/${user.id}.png';
      await supabase.storage
          .from(bucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('⚠️ Upload ke storage gagal: $e');
      return null;
    }
  }

  /// 🔹 Ganti foto profil
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _selectedImage = file);

    final uploadedUrl = await _uploadToStorage(file, 'foto_profil');
    if (uploadedUrl != null) {
      final user = supabase.auth.currentUser;
      await supabase
          .from('profiles')
          .update({'foto_profil': uploadedUrl})
          .eq('email', user?.email ?? '');
      setState(() => _fotoProfilUrl = uploadedUrl);
    }
  }

  /// 🔹 Upload tanda tangan dari galeri
  Future<void> _pickSignaturePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _signatureImage = file);

    final uploadedUrl = await _uploadToStorage(file, 'ttd');
    if (uploadedUrl != null) {
      final user = supabase.auth.currentUser;
      await supabase
          .from('profiles')
          .update({'ttd': uploadedUrl})
          .eq('email', user?.email ?? '');
      setState(() => _ttdUrl = uploadedUrl);
    }
  }

  /// 🔹 Popup tanda tangan manual
  Future<void> _showSignaturePopup() async {
    _signatureController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Buat Tanda Tangan'),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: Signature(
            controller: _signatureController,
            backgroundColor: Colors.grey[200]!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _signatureController.clear,
            child: const Text('Hapus'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (_signatureController.isNotEmpty) {
                final data = await _signatureController.toPngBytes();
                if (data != null) {
                  final tempFile = File('${Directory.systemTemp.path}/ttd.png');
                  await tempFile.writeAsBytes(data);

                  final uploadedUrl = await _uploadToStorage(tempFile, 'ttd');
                  if (uploadedUrl != null) {
                    final user = supabase.auth.currentUser;
                    await supabase
                        .from('profiles')
                        .update({'ttd': uploadedUrl})
                        .eq('email', user?.email ?? '');

                    setState(() {
                      _drawnSignature = data;
                      _ttdUrl = uploadedUrl;
                      _signatureImage = null;
                    });
                  }
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 🔹 Simpan perubahan data ke database
  Future<void> _saveProfileChanges() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final updates = {
        'nama_lengkap': _controllers['Nama Pegawai']!.text,
        'id_pegawai': _controllers['ID Pegawai']!.text,
        'nip': _controllers['NIP']!.text,
        'jabatan': userData['Jabatan'],
        'pangkat': _controllers['Pangkat']!.text,
      };

      await supabase
          .from('profiles')
          .update(updates)
          .eq('email', user.email ?? '');
    } catch (e) {
      debugPrint('⚠️ Gagal menyimpan profil: $e');
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) _saveProfileChanges();
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_fotoProfilUrl != null
                                ? NetworkImage(_fotoProfilUrl!)
                                : null)
                            as ImageProvider?,
                  child: _selectedImage == null && _fotoProfilUrl == null
                      ? const Text(
                          "FOTO\nPROFIL",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // FORM
              _buildTextField('Nama Pegawai'),
              _buildTextField('ID Pegawai'),
              _buildTextField('NIP'),
              _buildTextField('Email', editable: false),
              _buildDropdownField('Jabatan'),
              _buildTextField('Pangkat'),

              const SizedBox(height: 16),

              // BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _toggleEdit,
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

              const SizedBox(height: 24),

              // TANDA TANGAN
              GestureDetector(
                onTap: _isEditing ? _showSignaturePopup : null,
                child: Container(
                  height: 120,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _drawnSignature != null
                        ? Image.memory(_drawnSignature!)
                        : _signatureImage != null
                        ? Image.file(_signatureImage!)
                        : (_ttdUrl != null
                              ? Image.network(_ttdUrl!)
                              : const Text(
                                  'Klik untuk tanda tangan',
                                  style: TextStyle(color: Colors.black54),
                                )),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_isEditing)
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _pickSignaturePhoto,
                    icon: const Icon(
                      Icons.upload,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Upload Foto TTD',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool editable = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: AppTextStyle.regular14)),
        Expanded(
          child: TextField(
            controller: _controllers[label],
            enabled: editable && _isEditing,
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

  Widget _buildDropdownField(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: AppTextStyle.regular14)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: userData[label]!.isNotEmpty ? userData[label] : null,
                hint: const Text('Pilih Jabatan'),
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
                    ? (value) => setState(() {
                        userData[label] = value!;
                      })
                    : null,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
