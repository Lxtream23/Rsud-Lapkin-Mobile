import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileController extends ChangeNotifier {
  // Data user sementara (contoh hardcoded)
  UserModel _user = UserModel(
    nama: "Andi Saputra",
    idPegawai: "PG00123",
    nip: "1987654321",
    email: "andi@rsudbangil.go.id",
    jabatan: "Staff IT",
    pangkat: "III/a",
    divisi: "Teknologi Informasi",
  );

  bool _isEditing = false;

  UserModel get user => _user;
  bool get isEditing => _isEditing;

  void toggleEdit() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _isEditing = false;
    notifyListeners();
  }
}
