import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../presentation/widgets/card_table1.dart';
import '../../presentation/widgets/card_table2.dart';
import '../../presentation/widgets/card_table3.dart';

class FormPerjanjianPage extends StatefulWidget {
  const FormPerjanjianPage({Key? key}) : super(key: key);

  @override
  State<FormPerjanjianPage> createState() => _FormPerjanjianPageState();
}

class _FormPerjanjianPageState extends State<FormPerjanjianPage> {
  final TextEditingController namaController = TextEditingController();
  String? selectedJabatan;

  final List<String> jabatanList = [
    'Direktur',
    'Wadir Umum dan Keuangan',
    'Wadir Pelayanan',
    'Kabid Pelayanan',
    'Kabid Pelayanan Keperawatan',
    'Kabid Pelayanan Penunjang',
    'Kabag SDM dan Pengembangan',
    'Kabag Umum',
    'Kabag Keuangan',
    'Ketua Tim Kerja',
    'Admin/Staf',
  ];

  // Keys untuk mengakses method/state widget tabel (dynamic-cast dipakai)
  final GlobalKey table1Key = GlobalKey();
  final GlobalKey table2Key = GlobalKey();
  final GlobalKey table3Key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    namaController.dispose();
    super.dispose();
  }

  /// Ambil data dari setiap tabel dengan memanggil method yang tersedia di state widget.
  /// Kita memakai `dynamic` casting karena state class pada file widget bersifat private.
  Map<String, dynamic> _collectAllData() {
    final result = <String, dynamic>{};

    try {
      final t1State = table1Key.currentState;
      if (t1State != null) {
        // widget Table1 harus expose method getRowsAsStrings() atau serupa
        result['table1'] = (t1State as dynamic).getRowsAsStrings();
      } else {
        result['table1'] = [];
      }
    } catch (e) {
      result['table1_error'] = e.toString();
    }

    try {
      final t2State = table2Key.currentState;
      if (t2State != null) {
        result['table2'] = (t2State as dynamic).getRowsAsStrings();
      } else {
        result['table2'] = [];
      }
    } catch (e) {
      result['table2_error'] = e.toString();
    }

    try {
      final t3State = table3Key.currentState;
      if (t3State != null) {
        result['table3'] = (t3State as dynamic).getRowsAsStrings();
      } else {
        result['table3'] = [];
      }
    } catch (e) {
      result['table3_error'] = e.toString();
    }

    // tambah data form lain
    result['nama'] = namaController.text;
    result['jabatan'] = selectedJabatan;

    return result;
  }

  void _onSavePressed() {
    final all = _collectAllData();
    // untuk demo: tampilkan di dialog; di implementasi nyata: kirim ke API / simpan lokal
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Collected data (preview)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(all.toString())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ----------------- UI helpers -----------------
  Widget _input(String hint) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _dropdown(String? value, void Function(String?) onChanged) => SizedBox(
    height: 46,
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      hint: const Text("Pilih Jabatan"),
      items: jabatanList
          .map((jab) => DropdownMenuItem(value: jab, child: Text(jab)))
          .toList(),
      onChanged: onChanged,
    ),
  );

  // ----------------- Main build -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Form Perjanjian',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "PERJANJIAN KINERJA TAHUN 2025 WAKIL\nDIREKTUR PELAYANAN UOBK RSUD BANGIL\nKABUPATEN PASURUAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini : ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    _input("BUDI SANTOSO"),
                    const SizedBox(height: 8),
                    _input("Administrasi Pengembangan"),
                    const SizedBox(height: 8),
                    const Text("Selanjutnya disebut PIHAK PERTAMA."),
                    const SizedBox(height: 24),
                    _input("Nama Lengkap"),
                    const SizedBox(height: 8),
                    _dropdown(
                      selectedJabatan,
                      (v) => setState(() => selectedJabatan = v),
                    ),
                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK KEDUA."),
                    const SizedBox(height: 24),
                    const Text(
                      "Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan. Keberhasilan dan kegagalan pencapaian target kinerja tersebut menjadi tanggung jawab kami. ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi. ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    // === "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL TAHUN 2025" ===
                    const SizedBox(height: 40),
                    const Text(
                      "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL TAHUN 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // === Card-based Table 1 ===
                    CardTable1Widget(key: table1Key),

                    const SizedBox(height: 12),

                    // === Card-based Table 2 ===
                    CardTable2Widget(key: table2Key),

                    const SizedBox(height: 12),

                    // === Card-based Table 3 ===
                    CardTable3Widget(key: table3Key),

                    const SizedBox(height: 18),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          _onSavePressed();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "SIMPAN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // footer
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
