import 'package:intl/intl.dart';

String formatRupiah(int value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

String formatDate(DateTime date) {
  return DateFormat('d MMM yyyy', 'id_ID').format(date);
}