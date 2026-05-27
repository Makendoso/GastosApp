abstract final class CurrencyFormatter {
  static String format(double amount) {
    final prefix = amount < 0 ? '-' : '';
    final fixed = amount.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final decimal = parts.last;
    final buffer = StringBuffer();

    for (var index = 0; index < whole.length; index++) {
      final positionFromEnd = whole.length - index;
      buffer.write(whole[index]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return '$prefix\$${buffer.toString()}.$decimal';
  }
}
