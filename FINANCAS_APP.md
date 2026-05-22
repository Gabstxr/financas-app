# FinançasApp — Documentação Completa

> App de finanças pessoais para o mercado brasileiro, inspirado no Mobills.  
> Flutter + Firebase · Clean Architecture · BLoC · Design Dark + Roxo

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Stack Técnica](#2-stack-técnica)
3. [Arquitetura](#3-arquitetura)
4. [Estrutura de Pastas](#4-estrutura-de-pastas)
5. [Design System](#5-design-system)
6. [Banco de Dados Firebase](#6-banco-de-dados-firebase)
7. [Gerenciamento de Estado](#7-gerenciamento-de-estado)
8. [Injeção de Dependências](#8-injeção-de-dependências)
9. [Navegação](#9-navegação)
10. [Funcionalidades por Fase](#10-funcionalidades-por-fase)
11. [Roadmap Semanal](#11-roadmap-semanal)
12. [Bibliotecas](#12-bibliotecas)
13. [Boas Práticas](#13-boas-práticas)
14. [Git e GitHub](#14-git-e-github)
15. [Como Executar](#15-como-executar)
16. [Firebase — Setup](#16-firebase--setup)
17. [Dificuldades Técnicas](#17-dificuldades-técnicas)
18. [Open Finance (Fase 3)](#18-open-finance-fase-3)

---

## 1. Visão Geral

| Atributo | Valor |
|---|---|
| Nome | FinançasApp |
| Mercado | Brasil (PT-BR / BRL) |
| Plataformas | Android + iOS |
| Modelo | Gratuito |
| Status | MVP em desenvolvimento |
| Versão atual | 1.0.0 |

**O que o app faz:**
Controle completo de finanças pessoais — receitas, despesas, contas bancárias, categorias, relatórios visuais e suporte offline. Evolui em 3 fases até integração com o Open Finance Brasil.

---

## 2. Stack Técnica

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter 3.x (Dart 3.x) |
| Backend | Firebase (Auth + Firestore + Storage) |
| State Management | flutter_bloc (BLoC + Cubit) |
| DI | get_it |
| Navegação | go_router |
| Cache local | hive_flutter |
| Gráficos | fl_chart |
| Formatação | intl (pt_BR) |

---

## 3. Arquitetura

O projeto segue **Clean Architecture** com 3 camadas:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│   Pages · Widgets · BLoC/Cubit         │
│   Recebe eventos → emite estados        │
├─────────────────────────────────────────┤
│           DOMAIN LAYER                  │
│   Entities · Use Cases · Interfaces    │
│   Regras de negócio puras (sem Flutter) │
├─────────────────────────────────────────┤
│            DATA LAYER                   │
│   Models · DataSources · Repositories  │
│   Comunicação com Firebase/Hive         │
└─────────────────────────────────────────┘
```

**Fluxo de dados:**
```
UI Event → BLoC/Cubit → UseCase → Repository → DataSource → Firebase
                                                    ↓
UI State ←  BLoC/Cubit ← Either<Failure, Data> ←──┘
```

**Por que Clean Architecture?**
- Facilita testes unitários (cada camada é isolada)
- Permite trocar Firebase por outro backend sem alterar a lógica de negócio
- Escala com o crescimento do time e das funcionalidades

---

## 4. Estrutura de Pastas

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Paleta de cores
│   │   ├── app_sizes.dart         # Espaçamentos e tamanhos
│   │   └── app_strings.dart       # Textos da UI (PT-BR)
│   ├── errors/
│   │   ├── failures.dart          # Tipos de falha (domínio)
│   │   └── exceptions.dart        # Exceções da camada de dados
│   ├── extensions/
│   │   ├── currency_extension.dart  # int.toBRL, double.toCents
│   │   └── date_extension.dart    # DateTime.toMonthYear, etc.
│   ├── theme/
│   │   ├── app_theme.dart         # ThemeData completo dark + roxo
│   │   └── app_text_styles.dart   # Todos os estilos de texto
│   ├── utils/
│   │   ├── validators.dart        # Validadores de formulário
│   │   └── formatters.dart        # CurrencyInputFormatter
│   └── widgets/
│       ├── app_button.dart        # Botão reutilizável (variantes)
│       ├── app_card.dart          # Card com tap e borda
│       ├── app_text_field.dart    # Campo de texto customizado
│       └── loading_overlay.dart   # LoadingOverlay + EmptyState
│
├── features/
│   ├── auth/           # Autenticação (email + Google)
│   ├── accounts/       # Contas bancárias
│   ├── categories/     # Categorias de transações
│   ├── transactions/   # Transações (receita/despesa)
│   ├── dashboard/      # Tela principal
│   ├── reports/        # Relatórios e gráficos
│   ├── settings/       # Configurações
│   └── onboarding/     # Configuração inicial
│
├── injection/
│   └── injection_container.dart   # Setup get_it
├── router/
│   ├── app_router.dart           # GoRouter + redirect guards
│   └── main_scaffold.dart        # BottomNavigationBar + FAB
├── app.dart                      # MaterialApp.router + BlocProvider
└── main.dart                     # Inicialização Firebase + DI
```

Cada feature segue a estrutura:
```
feature/
├── data/
│   ├── datasources/   # Comunicação com Firebase
│   ├── models/        # Extends Entity, adds fromFirestore/toFirestore
│   └── repositories/  # Implementa interface do domínio
├── domain/
│   ├── entities/      # Objetos de negócio (Equatable)
│   ├── repositories/  # Interfaces abstratas
│   └── usecases/      # Um arquivo por caso de uso
└── presentation/
    ├── bloc/          # BLoC ou Cubit + Event + State
    ├── pages/         # Telas completas
    └── widgets/       # Widgets específicos da feature
```

---

## 5. Design System

### Paleta de Cores

| Token | Hex | Uso |
|---|---|---|
| `background` | `#0F0F1A` | Fundo principal |
| `surface` | `#1A1A2E` | Cards, modais |
| `card` | `#252542` | Componentes elevados |
| `primary` | `#7C3AED` | Ações principais, FAB |
| `primaryLight` | `#9F67E4` | Gradiente, links |
| `income` | `#10B981` | Receitas |
| `expense` | `#EF4444` | Despesas |
| `textPrimary` | `#E2E8F0` | Texto principal |
| `textSecondary` | `#94A3B8` | Texto secundário |
| `divider` | `#2D2D4E` | Separadores |

### Tipografia

Fonte: **Inter** (400 / 500 / 600 / 700)

| Estilo | Tamanho | Peso | Uso |
|---|---|---|---|
| `displayLarge` | 32sp | Bold | Títulos principais |
| `headlineMedium` | 20sp | SemiBold | AppBar |
| `titleLarge` | 16sp | SemiBold | Cards |
| `bodyMedium` | 14sp | Regular | Conteúdo |
| `amountLarge` | 36sp | Bold | Saldo principal |

### Componentes

- **AppButton** — variantes: primary, outline, ghost, danger
- **AppCard** — com ripple effect e borda sutil
- **AppTextField** — toggle de senha, label flutuante
- **EmptyState** — ícone + título + subtitle + action
- **LoadingOverlay** — overlay semi-transparente com spinner

---

## 6. Banco de Dados Firebase

### Modelo Firestore

```
/users/{uid}
  email, displayName, photoURL, onboardingDone, currency, createdAt

/users/{uid}/accounts/{accountId}
  name, type, balance*, initialBalance*, color, icon, isActive, createdAt

/users/{uid}/categories/{categoryId}
  name, type, icon, color, isDefault, createdAt

/users/{uid}/transactions/{transactionId}
  type, amount*, description, categoryId, accountId, date,
  isRecurring, notes, isDeleted, categoryName, categoryIcon,
  categoryColor, accountName, createdAt, updatedAt

/users/{uid}/budgets/{budgetId}           ← Fase 2
/users/{uid}/bills/{billId}               ← Fase 2
```

> ⚠️ **`*` = valores monetários em centavos (inteiros)**  
> R$ 150,99 → `15099` — Nunca use `double` para dinheiro.

### Regras de Segurança

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

### Índices Compostos Necessários

```
transactions: (date ASC, isDeleted ASC)
transactions: (date DESC, type ASC, isDeleted ASC)
```

---

## 7. Gerenciamento de Estado

**flutter_bloc v8** — padrão híbrido:

| Padrão | Quando usar | Exemplos |
|---|---|---|
| **Cubit** | Estado simples, sem eventos complexos | Dashboard, Reports |
| **BLoC** | Múltiplos eventos, transformações | Auth, Transactions, Accounts |

### Fluxo BLoC

```dart
// 1. UI dispara evento
context.read<TransactionsBloc>().add(TransactionsLoadRequested(...));

// 2. BLoC processa
Future<void> _onLoad(event, emit) async {
  emit(TransactionsLoading());
  final result = await getTransactionsByMonth(userId, year, month);
  result.fold(
    (failure) => emit(TransactionsError(failure.message)),
    (data)    => emit(TransactionsLoaded(data)),
  );
}

// 3. UI reage
BlocBuilder<TransactionsBloc, TransactionsState>(
  builder: (context, state) {
    if (state is TransactionsLoading) return LoadingWidget();
    if (state is TransactionsLoaded) return TransactionsList(state.transactions);
    return SizedBox();
  },
)
```

### Either<Failure, T>

Usando `dartz` para tratamento funcional de erros:

```dart
// Repository retorna Either
Future<Either<Failure, List<TransactionEntity>>> getTransactions(...);

// BLoC consome com fold
result.fold(
  (failure) => emit(Error(failure.message)),  // Left
  (data)    => emit(Loaded(data)),             // Right
);
```

---

## 8. Injeção de Dependências

`get_it` como service locator. Registrado em `injection/injection_container.dart`.

```dart
// Acesso em qualquer lugar
sl<TransactionsBloc>()
sl<AuthRepository>()

// BlocProvider com sl
BlocProvider(
  create: (_) => sl<DashboardCubit>()..load(userId),
  child: DashboardView(),
)
```

**Tipos de registro:**
- `registerLazySingleton` → criado na primeira chamada, reutilizado (datasources, repositories, usecases)
- `registerFactory` → nova instância a cada chamada (BLoCs, Cubits — evitar estado compartilhado)

---

## 9. Navegação

**go_router v14** com proteção de rotas e shell route para o BottomNav.

```
/                 SplashPage
/login            LoginPage
/register         RegisterPage
/onboarding       OnboardingPage
/dashboard        DashboardPage       ← ShellRoute (BottomNav)
/transactions     TransactionListPage ← ShellRoute
/reports          ReportsPage         ← ShellRoute
/settings         SettingsPage        ← ShellRoute
/add-transaction  AddTransactionPage
/transaction-detail TransactionDetailPage
/accounts         AccountsPage
/add-account      AddAccountPage
/categories       CategoriesPage
/add-category     AddCategoryPage
```

**Redirect automático:**
- Usuário não autenticado → `/login`
- Autenticado sem onboarding → `/onboarding`
- Autenticado com onboarding → `/dashboard`

---

## 10. Funcionalidades por Fase

### MVP (Semanas 1–8)

- [x] Autenticação (email/senha + Google Sign-In)
- [x] Splash + onboarding inicial
- [x] CRUD de contas (corrente, poupança, dinheiro)
- [x] Categorias padrão + categorias customizadas
- [x] Adicionar / editar / deletar transações (receita/despesa)
- [x] Dashboard: saldo, receitas, despesas, últimas transações
- [x] Navegar por mês
- [x] Tela de todas as transações
- [x] Relatório: pizza por categoria + resumo mensal
- [x] Configurações: perfil + logout
- [x] Suporte offline (Firestore persistence)

### Fase 2 (Semanas 9–18)

- [ ] Transferência entre contas
- [ ] Transações recorrentes
- [ ] Orçamentos por categoria + alertas
- [ ] Contas a pagar + lembretes (notifications)
- [ ] Foto de comprovante (Firebase Storage)
- [ ] Exportar relatório PDF
- [ ] Gráficos avançados (evolução de saldo)
- [ ] Cartão de crédito (fatura)

### Fase 3 (Semanas 19–26)

- [ ] Open Finance Brasil (API Banco Central + OAuth2 PKCE)
- [ ] Metas financeiras
- [ ] Investimentos (acompanhamento manual)
- [ ] Insights com IA (Claude/Gemini)
- [ ] Widget na tela inicial (Android Glance)
- [ ] Modo família (contas compartilhadas)

---

## 11. Roadmap Semanal

### Semana 1 — Fundação
- Setup Flutter + Firebase
- Estrutura de pastas Clean Architecture
- Tema dark + paleta roxa
- Widgets base (AppButton, AppCard, AppTextField)
- GoRouter + DI (get_it)

### Semana 2 — Autenticação
- Firebase Auth: email/senha + Google
- Splash → Login → Register → Onboarding
- AuthBloc com stream de estado de autenticação

### Semana 3 — Contas e Categorias
- CRUD completo de contas
- Seed de categorias padrão no onboarding
- CRUD de categorias customizadas

### Semana 4 — Transações
- Adicionar/editar/excluir receita e despesa
- Listagem por mês com paginação
- Soft delete com `isDeleted: true`

### Semana 5 — Dashboard
- Saldo total das contas
- Resumo mensal (receitas/despesas)
- Últimas 5 transações
- Navegação por mês

### Semana 6 — Relatórios
- Gráfico de pizza (fl_chart) por categoria
- Lista de categorias com percentual e barra de progresso
- Resumo mensal consolidado

### Semana 7 — Polimento
- Animações e transições
- Empty states ilustrados
- Pull-to-refresh
- Indicador offline

### Semana 8 — Release MVP
- App icon + splash screen branding
- Firebase Crashlytics + Analytics
- Revisão das Firestore Security Rules
- Build release Android (AAB) + iOS

---

## 12. Bibliotecas

### Produção

```yaml
# Firebase
firebase_core, firebase_auth, cloud_firestore,
firebase_analytics, firebase_crashlytics, google_sign_in

# State
flutter_bloc, equatable

# DI + Navigation
get_it, go_router

# Storage
hive_flutter

# UI
fl_chart, flutter_svg, shimmer, cached_network_image

# Utils
intl, connectivity_plus, dartz
```

### Desenvolvimento

```yaml
build_runner, freezed, json_serializable,
bloc_test, mocktail, fake_cloud_firestore
```

---

## 13. Boas Práticas

### Valores Monetários

```dart
// ✅ CORRETO — centavos como int
final amount = 15099;          // R$ 150,99
amount.toBRL                   // "R$ 150,99"
150.99.toCents                 // 15099

// ❌ ERRADO — nunca use double para dinheiro
final amount = 150.99;         // Problemas de arredondamento!
```

### Nomenclatura

```
Entidade:    UserEntity, TransactionEntity
Model:       UserModel, TransactionModel
Repository:  AuthRepository (interface), AuthRepositoryImpl (impl)
DataSource:  AuthRemoteDataSource (interface), AuthRemoteDataSourceImpl
UseCase:     SignInWithEmail, GetTransactionsByMonth
BLoC:        AuthBloc, TransactionsBloc
Cubit:       DashboardCubit, ReportsCubit
Event:       AuthSignInRequested, TransactionsLoadRequested
State:       AuthAuthenticated, TransactionsLoaded
Page:        LoginPage, DashboardPage
Widget:      BalanceCard, TransactionListItem
```

### Testes

```dart
// Teste de BLoC com bloc_test
blocTest<TransactionsBloc, TransactionsState>(
  'emite TransactionsLoaded ao carregar com sucesso',
  build: () => TransactionsBloc(
    getTransactionsByMonth: MockGetTransactionsByMonth(),
    ...
  ),
  act: (bloc) => bloc.add(TransactionsLoadRequested(
    userId: 'uid', year: 2026, month: 1,
  )),
  expect: () => [isA<TransactionsLoading>(), isA<TransactionsLoaded>()],
);

// Repositório com fake_cloud_firestore
final fakeFirestore = FakeFirebaseFirestore();
final dataSource = TransactionsRemoteDataSourceImpl(fakeFirestore);
```

---

## 14. Git e GitHub

### Estratégia de Branches

```
main        → produção estável (só merge via PR aprovado)
develop     → integração contínua
feature/*   → ex: feature/add-transaction, feature/budget
fix/*       → ex: fix/balance-calculation
hotfix/*    → correções urgentes em main
```

### Convenção de Commits (Gitmoji)

Formato obrigatório: `:emoji: tipo: descrição em PT-BR`

| Emoji code | Emoji | Tipo | Quando usar |
|---|---|---|---|
| `:tada:` | 🎉 | — | Commit inicial |
| `:sparkles:` | ✨ | feat | Nova funcionalidade |
| `:bug:` | 🐛 | fix | Correção de bug |
| `:books:` | 📚 | docs | Documentação |
| `:recycle:` | ♻️ | refactor | Refatoração de código |
| `:lipstick:` | 💄 | feat | Estilização / UI |
| `:zap:` | ⚡ | perf | Melhoria de performance |
| `:test_tube:` | 🧪 | test | Testes |
| `:bricks:` | 🧱 | ci | CI/CD, pipelines |
| `:boom:` | 💥 | fix | Correção de mudança que quebrou algo |
| `:broom:` | 🧹 | cleanup | Limpeza de código morto |
| `:wastebasket:` | 🗑️ | remove | Remoção de arquivos/código |

```bash
# Exemplos
git commit -m ":sparkles: feat: Página de cadastro de transação"
git commit -m ":bug: fix: Corrige cálculo de saldo com transferências"
git commit -m ":recycle: refactor: Extrai CurrencyFormatter para core/utils"
git commit -m ":test_tube: test: Testes do TransactionsBloc"
git commit -m ":books: docs: Atualiza README com instruções de setup"
git commit -m ":lipstick: feat: Padroniza espaçamentos no DashboardPage"
```

### Fluxo de Trabalho

```bash
# 1. Criar branch a partir de develop
git checkout develop
git pull
git checkout -b feature/reports-pie-chart

# 2. Commits atômicos durante o desenvolvimento
git add lib/features/reports/
git commit -m ":sparkles: feat: Gráfico de pizza em ReportsPage"

# 3. Push e PR para develop
git push origin feature/reports-pie-chart
# Abrir PR no GitHub: feature/reports-pie-chart → develop

# 4. Merge develop → main a cada release
```

### .gitignore Importante

```gitignore
# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart

# Flutter
.dart_tool/
build/
*.g.dart
*.freezed.dart

# IDE
.idea/
.vscode/settings.json
```

---

## 15. Como Executar

### Pré-requisitos

1. **Flutter SDK** ≥ 3.3.0 — [flutter.dev/get-started](https://flutter.dev/get-started)
2. **Android Studio** + Android SDK (para Android)
3. **Xcode** ≥ 14 (para iOS, somente macOS)
4. **Firebase CLI** — `npm install -g firebase-tools`
5. **FlutterFire CLI** — `dart pub global activate flutterfire_cli`

### Setup Inicial

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. Configurar Firebase (ver seção 16)

# 4. Executar
flutter run

# 5. Executar testes
flutter test

# 6. Analisar código
flutter analyze
```

### Adicionar a fonte Inter

Baixar de [fonts.google.com/specimen/Inter](https://fonts.google.com/specimen/Inter) e colocar em:
```
assets/fonts/Inter-Regular.ttf
assets/fonts/Inter-Medium.ttf
assets/fonts/Inter-SemiBold.ttf
assets/fonts/Inter-Bold.ttf
```

---

## 16. Firebase — Setup

### 1. Criar projeto no Firebase Console

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. "Adicionar projeto" → Nome: `financas-app`
3. Ativar **Google Analytics** (opcional)

### 2. Configurar FlutterFire

```bash
flutterfire configure --project=financas-app
```

Isso gera automaticamente `lib/firebase_options.dart`. Atualizar `main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 3. Habilitar Firebase Auth

Console → Authentication → Sign-in method:
- ✅ Email/senha
- ✅ Google

### 4. Criar banco Firestore

Console → Firestore Database → Criar banco → Modo de produção

### 5. Aplicar Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

### 6. Google Sign-In — Android

Adicionar SHA-1 no Firebase Console:
```bash
./gradlew signingReport
```

### 7. Habilitar persistência offline

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 17. Dificuldades Técnicas

| Desafio | Mitigação |
|---|---|
| **Saldo inconsistente offline** | Recalcular saldo ao reconectar; usar Firestore transactions para operações atômicas |
| **Arredondamento monetário** | Sempre usar centavos (int). Nunca double. |
| **Queries compostas no Firestore** | Criar índices compostos no console; queries filtram por `date` + `isDeleted` |
| **Performance com muitas transações** | Paginação com `limit(20)` + `startAfterDocument` |
| **Google Sign-In no Android** | Adicionar SHA-1 correto no Firebase Console |
| **Testes com Firestore** | Usar `fake_cloud_firestore` como mock |
| **Transações recorrentes (Fase 2)** | Gerar instâncias lazily no client ou via Cloud Functions |
| **Open Finance OAuth (Fase 3)** | Backend proxy (Cloud Functions) para tokens; `flutter_appauth` no client |

---

## 18. Open Finance (Fase 3)

### Visão Geral

O Open Finance Brasil é regulado pelo Banco Central. Permite que usuários autorizem o app a acessar dados bancários de terceiros.

### Arquitetura Planejada

```
App Flutter
  └─ flutter_appauth (OAuth2 PKCE)
       └─ Cloud Function (proxy backend)
            └─ API Open Finance Brasil
                 └─ Bancos participantes
```

### Passos de Implementação

1. **Registrar app** na plataforma do Banco Central
2. **Cloud Function** como proxy seguro para OAuth tokens
3. **flutter_appauth** para o fluxo de autenticação no app
4. **Interface preparada** — `OpenFinanceRepository` já definida no domínio
5. **Importação automática** de transações após autenticação

### Interface de Domínio (Preparada)

```dart
abstract class OpenFinanceRepository {
  Future<Either<Failure, List<BankAccount>>> getConnectedBanks(String userId);
  Future<Either<Failure, List<Transaction>>> importTransactions(
    String userId,
    String bankId,
    DateRange range,
  );
  Future<Either<Failure, void>> connectBank(String userId, String bankId);
  Future<Either<Failure, void>> disconnectBank(String userId, String bankId);
}
```

---

## Contato e Contribuição

Projeto desenvolvido como app pessoal de finanças para o mercado brasileiro.

- Issues e sugestões: GitHub Issues
- Commits seguem Conventional Commits
- PRs revisados antes do merge em `main`

---

*Documentação gerada em 22/05/2026 — FinançasApp v1.0.0 MVP*
