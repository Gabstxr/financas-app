import 'package:intl/intl.dart';

extension CurrencyExtension on int {
  /// Converte centavos para reais formatados (ex: 15099 → "R$ 150,99")
  String get toBRL {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(this / 100);
  }

  /// Valor absoluto em reais como double
  double get toReais => this / 100;

  /// Formata sem o símbolo (ex: 15099 → "150,99")
  String get toReaisFormatted {
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    return formatter.format(this / 100);
  }
}

extension DoubleToInt on double {
  /// Converte reais para centavos (ex: 150.99 → 15099)
  int get toCents => (this * 100).round();
}

extension StringCurrencyExtension on String {
  /// Tenta parsear uma string de valor monetário para centavos
  int get parseToCents {
    final cleaned = replaceAll(RegExp(r'[R$\s.]'), '').replaceAll(',', '.');
    final value = double.tryParse(cleaned) ?? 0.0;
    return value.toCents;
  }
}
