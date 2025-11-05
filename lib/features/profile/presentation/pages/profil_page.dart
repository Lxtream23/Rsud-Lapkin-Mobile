import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import 'package:image/image.dart' as img;

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
  bool _isUploading = false;
  Uint8List? _selectedImageBytes;

  Uint8List removeWhiteBackground(Uint8List pngBytes) {
    img.Image? image = img.decodeImage(pngBytes);
    if (image == null) return pngBytes;

    const tolerance = 25;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y); // Pixel object

        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Jika mendekati warna putih → buat transparan
        if ((r - 255).abs() < tolerance &&
            (g - 255).abs() < tolerance &&
            (b - 255).abs() < tolerance) {
          image.setPixelRgba(x, y, r, g, b, 0); // alpha = 0
        }
      }
    }

    return Uint8List.fromList(
      img.encodePng(image),
    ); // simpan kembali sebagai PNG
  }

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

  /// 🔹 Hapus file lama di Supabase Storage sesuai user yg login
  Future<void> _deleteOldFiles(String bucket) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final folderPath = user.id; // folder sesuai policy
      final files = await supabase.storage.from(bucket).list(path: folderPath);

      for (final file in files) {
        await supabase.storage.from(bucket).remove([
          "$folderPath/${file.name}",
        ]);
      }

      debugPrint("🗑️ File lama di bucket '$bucket' sudah dihapus.");
    } catch (e) {
      debugPrint("⚠️ Gagal menghapus file lama: $e");
    }
  }

  /// 🔹 Upload file ke Supabase Storage
  Future<String?> _uploadToStorage(XFile file, String bucket) async {
    setState(() => _isUploading = true); // Start loading
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      // 🗑️ Hapus file lama dulu (pastikan function _deleteOldFiles sudah benar)
      await _deleteOldFiles(bucket);

      // 🎯 Nama & path file
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
      final filePath = "${user.id}/$fileName";

      // 🌐 WEB Upload
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await supabase.storage
            .from(bucket)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/png', // ✅ penting untuk web
              ),
            );
      }
      // 📱 ANDROID / iOS Upload
      else {
        final localFile = File(file.path);
        await supabase.storage
            .from(bucket)
            .upload(
              filePath,
              localFile,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/png', // ✅ jaga konsisten
              ),
            );
      }

      // 🔗 Ambil link public
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint("⚠️ Upload gagal: $e");
      return null;
    } finally {
      setState(() => _isUploading = false); // End loading
    }
  }

  /// 🔹 Ganti foto profil
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      // Baca gambar sebagai bytes
      final bytes = await pickedFile.readAsBytes();

      // Decode ke objek Image
      img.Image? original = img.decodeImage(bytes);
      if (original == null) return;

      // Crop menjadi persegi
      final cropSize = original.width < original.height
          ? original.width
          : original.height;
      final x = (original.width - cropSize) ~/ 2;
      final y = (original.height - cropSize) ~/ 2;
      img.Image cropped = img.copyCrop(
        original,
        x: x,
        y: y,
        width: cropSize,
        height: cropSize,
      );

      // Resize 300x300
      img.Image resized = img.copyResize(cropped, width: 300, height: 300);

      // Encode PNG
      final Uint8List pngBytes = Uint8List.fromList(img.encodePng(resized));

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 🗑️ Hapus foto lama
      await _deleteOldFiles('foto_profil');

      // Lokasi file baru
      final storagePath =
          'foto_profil/${user.id}/${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload
      await supabase.storage
          .from('foto_profil')
          .uploadBinary(
            storagePath,
            pngBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Ambil URL
      final uploadedUrl = supabase.storage
          .from('foto_profil')
          .getPublicUrl(storagePath);

      // Update database
      await supabase
          .from('profiles')
          .update({'foto_profil': uploadedUrl})
          .eq('email', user.email ?? '');

      // Update UI
      setState(() {
        _fotoProfilUrl = uploadedUrl;
        _selectedImageBytes = pngBytes;
        _selectedImage = null;
      });
    } catch (e) {
      debugPrint("⚠️ Gagal upload foto profil: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 🔹 Ambil foto dari kamera
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    if (!kIsWeb) {
      setState(() => _selectedImage = File(pickedFile.path));
    }

    final uploadedUrl = await _uploadToStorage(pickedFile, 'foto_profil');

    if (uploadedUrl != null) {
      await supabase
          .from('profiles')
          .update({'foto_profil': uploadedUrl})
          .eq('email', supabase.auth.currentUser?.email ?? '');

      setState(() => _fotoProfilUrl = uploadedUrl);
    }
  }

  /// 🔹 Menu pilih sumber gambar
  void _showImageSourceMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(); // yang sudah ada
                },
              ),
              if (!kIsWeb) // kamera hanya di Android/iOS
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Ambil dari Kamera"),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(); // kita bikin di bawah
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Upload tanda tangan dari galeri
  Future<void> _pickSignaturePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      // 📌 Baca file sebagai bytes
      final bytes = await pickedFile.readAsBytes();

      // 🎯 Hapus background putih → jadi transparan
      final transparentBytes = removeWhiteBackground(bytes);

      // ☁️ Upload ke Supabase
      final uploadedUrl = await _uploadBytesToStorage(transparentBytes, 'ttd');

      // 📝 Simpan URL ke database
      if (uploadedUrl != null) {
        await supabase
            .from('profiles')
            .update({'ttd': uploadedUrl})
            .eq('email', supabase.auth.currentUser?.email ?? '');

        setState(() {
          _ttdUrl = uploadedUrl;
          _drawnSignature = transparentBytes; // agar preview langsung muncul
          _signatureImage = null; // hilangkan preview lama
        });
      }
    } catch (e) {
      debugPrint("⚠️ Upload Foto TTD gagal: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 🔹 Popup tanda tangan manual
  Future<void> _showSignaturePopup() async {
    _signatureController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
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
              if (_signatureController.isEmpty) return;

              setState(() => _isUploading = true);

              try {
                final Uint8List? rawBytes = await _signatureController
                    .toPngBytes();
                if (rawBytes == null) return;

                // 🎯 Jadikan background putih → Transparan
                final Uint8List transparentBytes = removeWhiteBackground(
                  rawBytes,
                );

                final user = supabase.auth.currentUser;
                if (user == null) return;

                // ☁️ Upload ke Storage
                final uploadedUrl = await _uploadBytesToStorage(
                  transparentBytes,
                  'ttd',
                );

                if (uploadedUrl != null) {
                  await supabase
                      .from('profiles')
                      .update({'ttd': uploadedUrl})
                      .eq('email', user.email ?? '');

                  setState(() {
                    _drawnSignature = transparentBytes;
                    _ttdUrl = uploadedUrl;
                    _signatureImage = null;
                  });
                }
              } catch (e) {
                debugPrint("⚠️ Gagal simpan TTD manual: $e");
              } finally {
                setState(() => _isUploading = false);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSignature() async {
    try {
      setState(() => _isUploading = true);

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 🗑️ Hapus semua file ttd user di storage
      await _deleteOldFiles('ttd');

      // 🔄 Kosongkan kolom ttd di database
      await supabase
          .from('profiles')
          .update({'ttd': null})
          .eq('email', user.email ?? '');

      // 🧼 Reset UI
      setState(() {
        _drawnSignature = null;
        _signatureImage = null;
        _ttdUrl = null;
      });
    } catch (e) {
      debugPrint("⚠️ Gagal hapus TTD: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _confirmDeleteSignature() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus TTD"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus tanda tangan ini? Tindakan ini tidak dapat dibatalkan.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await _deleteSignature(); // Panggil fungsi hapus asli
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadBytesToStorage(Uint8List bytes, String bucket) async {
    try {
      setState(() => _isUploading = true);
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      await _deleteOldFiles(bucket);

      final filePath =
          "${user.id}/${DateTime.now().millisecondsSinceEpoch}.png";

      await supabase.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from(bucket).getPublicUrl(filePath);
    } catch (e) {
      debugPrint("⚠️ Upload gagal: $e");
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
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

    return Stack(
      children: [
        Scaffold(
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
                    onTap: _isEditing ? _showImageSourceMenu : null,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: _selectedImageBytes != null
                          ? MemoryImage(_selectedImageBytes!)
                          : _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (_fotoProfilUrl != null
                                ? NetworkImage(_fotoProfilUrl!)
                                : null),
                      child:
                          _selectedImageBytes == null &&
                              _selectedImage == null &&
                              _fotoProfilUrl == null
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
                  if (_ttdUrl != null && _isEditing)
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: _confirmDeleteSignature,
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Hapus TTD',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
        ),

        // ✅ Overlay Loading Full Screen
        AnimatedOpacity(
          opacity: _isUploading ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !_isUploading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildLoadingOverlay() {
  //   return AnimatedOpacity(
  //     opacity: _isUploading ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 300),
  //     child: Container(
  //       color: Colors.black54,
  //       child: const Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 70,
  //               height: 70,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 6,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               "Mengunggah...",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
