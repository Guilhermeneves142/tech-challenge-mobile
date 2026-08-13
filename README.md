# FinanceApp Mobile

Aplicativo mobile de **gerenciamento financeiro** desenvolvido em **Flutter**, para o
**Tech Challenge — Fase 03** (POSTECH Front-End Engineering). É a versão mobile do
FinanceApp web (microfrontends Next.js) construído nas fases anteriores, reutilizando
o mesmo design system (`@vandrei/finance-ui`) por meio de tokens espelhados no tema.

## Stack

| Área | Escolha |
| --- | --- |
| Framework | Flutter (mobile: Android/iOS) |
| UI / Design System | [`shadcn_ui`](https://pub.dev/packages/shadcn_ui) + tokens do `finance-ui` (`lib/core/theme`) |
| Estado global | `provider` (exigência da fase) |
| Navegação | `go_router` |
| Backend / Cloud | Firebase (Auth, Cloud Firestore, Storage) |
| Gráficos | `fl_chart` |
| Upload de recibos | `image_picker` + Firebase Storage |
| Formatação (moeda/data) | `intl` |

## Requisitos da Fase 03 (escopo)

- **Dashboard**: gráficos e análises + animações nativas do Flutter.
- **Listagem de transações**: filtros avançados (data, categoria), scroll infinito/paginação, busca no Cloud Firestore por usuário autenticado.
- **Adicionar/editar transação**: validação avançada + upload de recibos no Firebase Storage.
- **Autenticação** e **estado global** via Firebase Auth + Provider.

## Pré-requisitos

- Flutter SDK **3.44+** (Dart 3.12+) — `flutter doctor`
- Android Studio / Xcode (emulador ou dispositivo físico)
- Conta Firebase + [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)

## Como rodar

```bash
flutter pub get
flutter run
```

## Configuração do Firebase

O app ainda **não** inclui as credenciais do Firebase (não versionadas). Para configurar:

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/) e habilite
   **Authentication** (e-mail/senha), **Cloud Firestore** e **Storage**.
2. Instale as CLIs e gere as opções da plataforma:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Isso gera `lib/firebase_options.dart` e adiciona `google-services.json` (Android) /
   `GoogleService-Info.plist` (iOS).
3. Publique as regras e os **índices compostos** que a listagem de transações usa:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase deploy --only firestore:rules,firestore:indexes
   ```
   Sem os índices de [`firestore.indexes.json`](firestore.indexes.json), as consultas
   com filtro combinado falham com `failed-precondition` (a tela mostra o aviso).

> `firebase_options.dart`, `google-services.json` e `GoogleService-Info.plist` estão no
> `.gitignore` — cada integrante gera os seus com `flutterfire configure`.

## Estrutura de pastas

```
lib/
├── main.dart                  # entrypoint (Firebase.initializeApp)
├── app.dart                   # FinanceApp: Provider + ShadApp.router
├── core/
│   ├── router/                # go_router (AppRouter)
│   ├── theme/                 # design system: tokens (app_colors) + tema (app_theme)
│   ├── utils/                 # formatters: moeda/data pt-BR, parse de valor, busca
│   └── widgets/               # AppScaffold (AppBar + Drawer)
└── features/
    ├── auth/                  # autenticação (AuthProvider — estado global)
    ├── dashboard/             # tela principal / gráficos
    └── transactions/          # listagem, filtros e add/editar transação
        ├── data/              # TransactionsRepository (Firestore)
        ├── models/            # TransactionModel + TransactionFilters
        ├── presentation/      # TransactionsScreen + widgets
        └── providers/         # TransactionsProvider (estado da tela)
```

## Transações

Tela em [`lib/features/transactions`](lib/features/transactions), com filtros, cards de
resumo e scroll infinito sobre a coleção `transactions` do Cloud Firestore.

### Documento

```jsonc
{
  "userId": "<uid do dono>",          // usado pelas regras e por toda consulta
  "description": "Supermercado Pão",
  "descriptionLower": "supermercado pao", // minúsculo e sem acento: campo da busca
  "category": "alimentacao",           // TransactionCategory
  "type": "despesa",                   // TransactionType: receita | despesa
  "amount": 452.10,                    // sempre positivo — o sinal vem do type
  "date": "<Timestamp>",
  "receiptUrl": "<Storage, opcional>"
}
```

### Como cada requisito é atendido

| Requisito | Implementação |
| --- | --- |
| Scroll infinito | `limit(10)` + `startAfterDocument(cursor)` a cada página (`TransactionsRepository.fetchPage`) |
| Busca no Firestore | Range `[termo, termo+U+F8FF)` sobre `descriptionLower`, com debounce de 400 ms |
| Filtros | Período (range em `date`) e tipo (igualdade em `type`), combináveis com a busca |
| Totais | Agregação server-side (`sum('amount')`) respeitando os filtros — não é a soma do que está na tela |
| Por usuário | Todo query filtra `userId`; as regras em `firestore.rules` garantem no servidor |

> **Limite da busca:** o Firestore não tem full-text search. A busca é por **prefixo**
> ("supermerc" acha "Supermercado Pão"), não por trecho no meio da frase — isso exigiria
> um indexador externo (Algolia/Typesense), fora do escopo da fase.

O upload de recibos (Firebase Storage) ainda não está no formulário; o campo
`receiptUrl` já existe no modelo e é preservado na edição.

## Design system

As cores, tipografia, raio e spacing espelham os tokens de `@vandrei/finance-ui`
(fonte da verdade dos apps web), em [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart)
e [`lib/core/theme/app_theme.dart`](lib/core/theme/app_theme.dart). Os componentes vêm do
pacote `shadcn_ui`, cujos tokens semânticos (background, foreground, primary, muted,
accent, destructive…) mapeiam 1:1 com os do design system.

## Validação

```bash
flutter analyze
flutter test
```
