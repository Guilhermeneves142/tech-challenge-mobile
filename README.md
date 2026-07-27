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
3. Descomente a inicialização em [`lib/main.dart`](lib/main.dart):
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

> `firebase_options.dart`, `google-services.json` e `GoogleService-Info.plist` estão no
> `.gitignore` — cada integrante gera os seus com `flutterfire configure`.

## Estrutura de pastas

```
lib/
├── main.dart                  # entrypoint (init Firebase futuramente)
├── app.dart                   # FinanceApp: MultiProvider + ShadApp.router
├── core/
│   ├── router/                # go_router (AppRouter)
│   └── theme/                 # design system: tokens (app_colors) + tema (app_theme)
└── features/
    ├── auth/                  # autenticação (AuthProvider — estado global)
    ├── dashboard/             # tela principal / gráficos
    └── transactions/          # listagem e add/editar transação
```

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
