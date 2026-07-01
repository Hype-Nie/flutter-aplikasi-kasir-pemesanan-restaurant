String formatCurrency(String raw) {
  try {
    final amount = double.parse(raw);
    final whole = amount.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $whole';
  } catch (_) {
    return raw;
  }
}
