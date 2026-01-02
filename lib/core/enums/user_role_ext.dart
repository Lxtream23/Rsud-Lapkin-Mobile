import 'user_role.dart';

extension UserRoleExt on UserRole {
  String get value {
    switch (this) {
      case UserRole.pimpinan:
        return 'pimpinan';
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
      default:
        return 'unknown';
    }
  }
}

extension UserRoleParser on String? {
  UserRole toUserRole() {
    switch (this) {
      case 'pimpinan':
        return UserRole.pimpinan;
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.unknown;
    }
  }
}
