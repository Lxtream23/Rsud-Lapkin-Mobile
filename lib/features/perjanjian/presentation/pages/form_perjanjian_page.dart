import 'package:flutter/material.dart';
// import 'package:auto_size_text/auto_size_text.dart';
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
  final TextEditingController namaPihakPertamaController =
      TextEditingController();

  final TextEditingController namaPihakKeduaController =
      TextEditingController();

  final TextEditingController jabatanPihakPertamaController =
      TextEditingController();

  final TextEditingController jabatanController = TextEditingController();
  final TextEditingController tugasController = TextEditingController();

  List<TextEditingController> fungsiControllers =
      []; // untuk fungsi a-seterusnya

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
    //fungsiControllers.add(TextEditingController()); // fungsi pertama (a)
    // Pastikan list tidak kosong
    if (fungsiControllers.isEmpty) {
      _addFungsiField();
    } else {
      _attachListener(0);
    }
  }

  @override
  void dispose() {
    namaPihakPertamaController.dispose();
    namaPihakKeduaController.dispose();
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
    result['namaPihakPertama'] = namaPihakPertamaController.text;
    result['namaPihakKedua'] = namaPihakKeduaController.text;

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

  // Dropdown jabatan
  Widget _dropdown(String? value, void Function(String?) onChanged) {
    final theme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      isDense: true, // <<< kecilkan tinggi
      decoration: InputDecoration(
        labelText: "Jabatan",
        labelStyle: TextStyle(fontSize: 14),
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        isDense: true, // <<< menambah efek tinggi lebih kecil
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12, // <<< kecilkan tinggi dropdown
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
        ),
      ),
      items: jabatanList
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // // Modern input field with label
  // final jabatanController = TextEditingController();
  // final tugasController = TextEditingController();
  // final fungsiAController = TextEditingController();
  // final fungsiBController = TextEditingController();
  // final fungsiCController = TextEditingController();
  // final fungsiDController = TextEditingController();
  // final fungsiEController = TextEditingController();

  Widget _buildModernInput({
    required String hint,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        isDense: true, // <<< membuat tinggi lebih kecil
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12, // <<< tinggi field
        ),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  // -------------------------------------

  // ============ Fungsi management ===========
  void _addFungsiField() {
    setState(() {
      fungsiControllers.add(TextEditingController());
      _attachListener(fungsiControllers.length - 1);
    });
  }

  void _removeFungsi(int index) {
    setState(() {
      fungsiControllers[index].dispose();
      fungsiControllers.removeAt(index);

      if (fungsiControllers.isEmpty) {
        _addFungsiField();
      }
    });
  }

  void _attachListener(int index) {
    fungsiControllers[index].addListener(() {
      final isLast = index == fungsiControllers.length - 1;
      final hasText = fungsiControllers[index].text.trim().isNotEmpty;

      // Jika mengetik di field terakhir → auto tambah
      if (isLast && hasText) {
        _addFungsiField();
      }

      setState(() {}); // refresh UI
    });
  }

  Widget _buildFungsiList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fungsiControllers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildModernInput(
                  hint: "Fungsi ${String.fromCharCode(97 + i)}...",
                  controller: fungsiControllers[i],
                ),
              ),

              const SizedBox(width: 8),

              // tombol delete
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFungsi(i),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // === BUTTON TAMBAH FUNGSI (model baru, kiri) ===
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addFungsiField,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Tambah Fungsi"),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

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
                    const SizedBox(height: 10),
                    const Text(
                      "PERJANJIAN KINERJA TAHUN 2025 WAKIL\nDIREKTUR PELAYANAN UOBK RSUD BANGIL\nKABUPATEN PASURUAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini : ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // === INPUT NAMA PIHAK PERTAMA ===
                    _buildModernInput(
                      hint: "BUDI SANTOSO",
                      controller: namaPihakPertamaController,
                    ),
                    const SizedBox(height: 8),

                    // === INPUT JABATAN PIHAK PERTAMA ===
                    _buildModernInput(
                      hint: "Administrasi Pengembangan",
                      controller: jabatanPihakPertamaController,
                    ),

                    const SizedBox(height: 8),
                    const Text("Selanjutnya disebut PIHAK PERTAMA."),
                    const SizedBox(height: 24),

                    // === INPUT NAMA PIHAK KEDUA ===
                    _buildModernInput(
                      hint: "Nama Lengkap",
                      controller: namaPihakKeduaController,
                    ),
                    const SizedBox(height: 8),

                    // === DROPDOWN JABATAN PIHAK KEDUA ===
                    _dropdown(
                      selectedJabatan,
                      (v) => setState(() => selectedJabatan = v),
                    ),
                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK KEDUA."),
                    const SizedBox(height: 24),

                    // === PARAGRAF PERJANJIAN KINERJA ===
                    const Text(
                      "Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan. Keberhasilan dan kegagalan pencapaian target kinerja tersebut menjadi tanggung jawab kami. ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 14),

                    // === PARAGRAF EVALUASI KINERJA ===
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    //
                    // === INPUT MODERN (Jabatan, Tugas, Fungsi) ===
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Jabatan & Tugas",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // JABATAN
                    _buildModernInput(
                      // label: "Jabatan",
                      hint: "Masukkan jabatan...",
                      controller: jabatanController,
                    ),

                    const SizedBox(height: 12),

                    // TUGAS
                    _buildModernInput(
                      // label: "Tugas",
                      hint: "Masukkan tugas...",
                      controller: tugasController,
                    ),

                    const SizedBox(height: 20),

                    // FUNGSI A – E
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Fungsi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // pemanggilan fungsi list
                    _buildFungsiList(),

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
