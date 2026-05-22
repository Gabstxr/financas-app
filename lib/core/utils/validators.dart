abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório.';
    if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Campo obrigatório.';
    if (value != password) return 'As senhas não coincidem.';
    return null;
  }

  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$field obrigatório.';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Informe o valor.';
    final cleaned = value.replaceAll(RegExp(r'[R$\s.]'), '').replaceAll(',', '.');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Valor inválido.';
    if (amount <= 0) return 'O valor deve ser maior que zero.';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    if (value.trim().length < 2) return 'Nome muito curto.';
    return null;
  }
}
