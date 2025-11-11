import 'package:flutter/material.dart';

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
    'Kabag SDM dan Pengambangan',
    'Kabag Umum',
    'Kabag Keuangan',
    'Ketua Tim Kerja',
    'Admin/Staf',
  ];

  final List<List<TextEditingController>> tabel1 = List.generate(
    5,
    (_) => List.generate(6, (_) => TextEditingController()),
  );

  final List<List<TextEditingController>> tabel2 = List.generate(
    3,
    (_) => List.generate(6, (_) => TextEditingController()),
  );

  final List<List<TextEditingController>> tabel3 = List.generate(
    5,
    (_) => List.generate(4, (_) => TextEditingController()),
  );

  Widget buildTable(
    List<List<TextEditingController>> data,
    List<String> header,
  ) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
          children: header
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
        ),
        for (var row in data)
          TableRow(
            children: row
                .map(
                  (controller) => Padding(
                    padding: const EdgeInsets.all(4),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(4),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F4F3),
      appBar: AppBar(
        title: const Text(
          "Form Perjanjian",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // Bagian konten bisa discroll
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
                    const SizedBox(height: 16),

                    const Text(
                      "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini :",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    _input("BUDI SANTOSO"),
                    const SizedBox(height: 8),
                    _input("Administrasi Pengembangan"),

                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK PERTAMA."),
                    const SizedBox(height: 16),

                    _input("Nama Lengkap"),
                    const SizedBox(height: 8),
                    _dropdown(
                      selectedJabatan,
                      (v) => setState(() => selectedJabatan = v),
                    ),

                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK KEDUA."),
                    const SizedBox(height: 16),

                    const Text(
                      "Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini...",
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL TAHUN 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Text("Jabatan : "),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedJabatan,
                            items: jabatanList
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedJabatan = v),
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Row(children: [Text("Tugas :")]),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fungsi :"),
                        SizedBox(width: 6),
                        Text("a.\nb.\nc.\nd.\ne."),
                      ],
                    ),

                    const SizedBox(height: 24),
                    buildTable(tabel1, [
                      "NO",
                      "SASARAN",
                      "INDIKATOR KINERJA",
                      "TARGET",
                      "FORMULASI HITUNG",
                      "SUMBER DATA",
                    ]),
                    const SizedBox(height: 24),

                    buildTable(tabel2, [
                      "SASARAN",
                      "Indikator Kinerja",
                      "Target",
                      "I",
                      "II",
                      "III / IV",
                    ]),
                    const SizedBox(height: 24),

                    buildTable(tabel3, [
                      "NO",
                      "PROGRAM",
                      "ANGGARAN",
                      "KETERANGAN",
                    ]),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: 150,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Footer sendiri di bawah layar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _dropdown(String? value, void Function(String?) onChanged) {
    return SizedBox(
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
  }
}
