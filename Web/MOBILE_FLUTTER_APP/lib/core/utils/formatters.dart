import 'package:intl/intl.dart';

String formatPercent(num? value, {String placeholder = '--'}) {
  if (value == null) return placeholder;
  return '${value.toStringAsFixed(0)}%';
}

String formatNumber(num? value, {int fractionDigits = 1, String placeholder = '--'}) {
  if (value == null) return placeholder;
  return value.toStringAsFixed(fractionDigits);
}

String formatTemperature(num? value) {
  if (value == null) return '--';
  return '${value.toStringAsFixed(1)} degC';
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(dateTime);
}
