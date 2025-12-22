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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        //centerTitle: true,
        title: Text(
          'Riwayat Perubahan',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('perjanjian_audit_log')
            .select()
            .eq('perjanjian_id', perjanjianId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text('Belum ada riwayat'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final log = data[i];
              final time = DateTime.parse(log['created_at']);

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(log['aksi']),
                subtitle: Text(log['keterangan'] ?? '-'),
                trailing: Text(
                  '${time.day}/${time.month}/${time.year}\n${time.hour}:${time.minute.toString().padLeft(2, '0')}',
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
}
