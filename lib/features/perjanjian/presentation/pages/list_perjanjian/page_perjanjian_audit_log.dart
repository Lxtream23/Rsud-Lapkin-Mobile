import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/../../../config/app_colors.dart';
import '/../../../config/app_text_style.dart';

class PagePerjanjianAuditLog extends StatelessWidget {
  final String perjanjianId;

  const PagePerjanjianAuditLog({super.key, required this.perjanjianId});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.textDark,
        elevation: 1,
        title: Text(
          'Riwayat Perubahan',
          style: AppTextStyle.bold16.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('perjanjian_audit_log')
            .select()
            .eq('perjanjian_id', perjanjianId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat'));
          }

          final data = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) =>
                Divider(color: isDark ? Colors.white12 : Colors.black12),
            itemBuilder: (_, i) {
              final log = data[i];
              final time = DateTime.parse(log['created_at']);

              return ListTile(
                leading: Icon(
                  _iconForAction(log['aksi']),
                  color: _colorForAction(log['aksi']),
                ),
                title: Text(
                  log['aksi'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(log['keterangan'] ?? '-'),
                trailing: Text(
                  _formatDate(time),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===================== HELPERS =====================

  String _formatDate(DateTime time) {
    return '${time.day.toString().padLeft(2, '0')} '
        '${_monthName(time.month)} ${time.year}\n'
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')} WIB';
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m - 1];
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'CREATE':
        return Icons.add_circle;
      case 'EDIT_REQUEST':
        return Icons.edit;
      case 'UPDATE':
        return Icons.save;
      case 'DOWNLOAD':
        return Icons.download;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.history;
    }
  }

  Color _colorForAction(String action) {
    switch (action) {
      case 'CREATE':
        return Colors.blue;
      case 'EDIT_REQUEST':
        return Colors.orange;
      case 'UPDATE':
        return Colors.green;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
