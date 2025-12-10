String formatRupiah(String angkaRaw) {
  if (angkaRaw == null || angkaRaw.trim().isEmpty) return '';
  final cleaned = angkaRaw.replaceAll(RegExp(r'[^0-9\-]'), '');
  if (cleaned.isEmpty) return '';
  final n = int.tryParse(cleaned) ?? 0;
  final s = n.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    buffer.write(s[i]);
    if (pos > 1 && pos % 3 == 1) buffer.write('.');
  }
  final prefix = n < 0 ? '-' : '';
  return 'Rp $prefix${buffer.toString()}';
}
