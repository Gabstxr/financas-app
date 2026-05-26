abstract class AppStrings {
  // App
  static const String appName = 'FinançasApp';
  static const String appTagline = 'Controle suas finanças com inteligência';

  // Auth
  static const String login = 'Entrar';
  static const String register = 'Criar conta';
  static const String logout = 'Sair';
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar senha';
  static const String name = 'Nome completo';
  static const String forgotPassword = 'Esqueceu a senha?';
  static const String loginWithGoogle = 'Continuar com Google';
  static const String noAccount = 'Não tem uma conta? ';
  static const String hasAccount = 'Já tem uma conta? ';
  static const String signUp = 'Cadastre-se';
  static const String signIn = 'Entrar';

  // Navigation
  static const String dashboard = 'Início';
  static const String transactions = 'Transações';
  static const String reports = 'Relatórios';
  static const String planning = 'Planejamento';
  static const String settings = 'Configurações';

  // Transactions
  static const String income = 'Receita';
  static const String expense = 'Despesa';
  static const String transfer = 'Transferência';
  static const String addTransaction = 'Nova transação';
  static const String editTransaction = 'Editar transação';
  static const String description = 'Descrição';
  static const String amount = 'Valor';
  static const String category = 'Categoria';
  static const String account = 'Conta';
  static const String date = 'Data';
  static const String notes = 'Observações';

  // Accounts
  static const String accounts = 'Contas';
  static const String addAccount = 'Adicionar conta';
  static const String editAccount = 'Editar conta';
  static const String accountName = 'Nome da conta';
  static const String accountType = 'Tipo de conta';
  static const String initialBalance = 'Saldo inicial';
  static const String checking = 'Conta Corrente';
  static const String savings = 'Poupança';
  static const String cash = 'Dinheiro';
  static const String credit = 'Cartão de Crédito';
  static const String investment = 'Investimento';

  // Categories
  static const String categories = 'Categorias';
  static const String addCategory = 'Adicionar categoria';
  static const String editCategory = 'Editar categoria';
  static const String categoryName = 'Nome da categoria';

  // Dashboard
  static const String totalBalance = 'Saldo Total';
  static const String monthlyIncome = 'Receitas';
  static const String monthlyExpenses = 'Despesas';
  static const String recentTransactions = 'Últimas transações';
  static const String seeAll = 'Ver tudo';

  // Reports
  static const String monthlyReport = 'Relatório Mensal';
  static const String byCategory = 'Por Categoria';
  static const String incomeVsExpenses = 'Receitas x Despesas';

  // Errors
  static const String genericError = 'Ocorreu um erro. Tente novamente.';
  static const String networkError = 'Sem conexão com a internet.';
  static const String authError = 'E-mail ou senha incorretos.';
  static const String emailInUse = 'Este e-mail já está em uso.';
  static const String weakPassword = 'A senha deve ter no mínimo 6 caracteres.';
  static const String invalidEmail = 'E-mail inválido.';
  static const String requiredField = 'Campo obrigatório.';
  static const String passwordMismatch = 'As senhas não coincidem.';
  static const String invalidAmount = 'Informe um valor válido.';

  // Success
  static const String transactionAdded = 'Transação adicionada!';
  static const String transactionUpdated = 'Transação atualizada!';
  static const String transactionDeleted = 'Transação excluída!';
  static const String accountAdded = 'Conta adicionada!';
  static const String accountUpdated = 'Conta atualizada!';

  // Empty states
  static const String noTransactions = 'Nenhuma transação neste mês';
  static const String noTransactionsSubtitle = 'Toque em + para adicionar sua primeira transação';
  static const String noAccounts = 'Nenhuma conta cadastrada';
  static const String noCategories = 'Nenhuma categoria cadastrada';

  // Onboarding
  static const String welcomeTitle = 'Bem-vindo ao FinançasApp!';
  static const String welcomeSubtitle = 'Antes de começar, vamos configurar sua primeira conta.';
  static const String getStarted = 'Começar';
  static const String skip = 'Pular';
  static const String next = 'Próximo';
  static const String finish = 'Concluir';

  // Confirmation
  static const String delete = 'Excluir';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String save = 'Salvar';
  static const String deleteTransactionTitle = 'Excluir transação?';
  static const String deleteTransactionMessage = 'Esta ação não pode ser desfeita.';

  // Offline
  static const String offlineMode = 'Modo offline';
}
