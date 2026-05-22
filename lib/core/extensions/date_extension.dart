import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get toMonthYear => DateFormat('MMMM yyyy', 'pt_BR').format(this);
  String get toShortDate => DateFormat('dd/MM/yyyy', 'pt_BR').format(this);
  String get toLongDate => DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(this);
  String get toDayMonth => DateFormat('dd/MM', 'pt_BR').format(this);
  String get toWeekDay => DateFormat('EEEE', 'pt_BR').format(this);
  String get toMonthName => DateFormat('MMMM', 'pt_BR').format(this);
  String get toAbbreviatedMonth => DateFormat('MMM', 'pt_BR').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Retorna "Hoje", "Ontem" ou a data formatada
  String get toRelative {
    if (isToday) return 'Hoje';
    if (isYesterday) return 'Ontem';
    return toShortDate;
  }
}
