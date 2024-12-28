import 'package:intl/intl.dart';

class DateFormatter {
  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(date);
  }
}