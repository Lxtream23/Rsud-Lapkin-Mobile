import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profileData => _profileData;
  String? get error => _error;

  /// Ambil data profil user yang sedang login
  Future<void> fetchProfile() async {
    _setLoading(true);
    _error = null;

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        _error = "Belum login.";
        _setLoading(false);
        return;
      }

      // 🔹 Ambil data dari tabel 'pegawai' berdasarkan email user login
      final response = await supabase
          .from('profiles')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      if (response != null) {
        _profileData = response;
      } else {
        _error = "Data profil tidak ditemukan di database.";
      }
    } catch (e) {
      _error = "Terjadi kesalahan: $e";
    }

    _setLoading(false);
  }

  /// Simpan perubahan data profil (jika kamu ingin user bisa edit profil)
  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    _setLoading(true);
    _error = null;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        _error = "Belum login.";
        _setLoading(false);
        return;
      }

      await supabase
          .from('profiles')
          .update(updatedData)
          .eq('email', user.email ?? '');

      _profileData = {...?_profileData, ...updatedData};
    } catch (e) {
      _error = "Gagal memperbarui profil: $e";
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearProfile() {
    _profileData = null;
    _error = null;
    notifyListeners();
  }
}
