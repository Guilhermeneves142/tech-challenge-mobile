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

---

## Pré-requisitos

Instale e confira os itens abaixo **antes** de clonar/rodar o app.

### 1. Flutter SDK

- Flutter **3.44+** (Dart **3.12+**), canal `stable`
- [Instalação oficial](https://docs.flutter.dev/get-started/install)

```bash
flutter --version
flutter doctor
```

Resolva os avisos do `flutter doctor` para a plataforma que for usar (Android e/ou iOS).

### 2. Dependências de plataforma

| Plataforma | O que instalar |
| --- | --- |
| **Android** | [Android Studio](https://developer.android.com/studio) (ou só o SDK), JDK **17**, emulador ou dispositivo físico com USB debugging |
| **iOS** (somente macOS) | Xcode (última estável), CocoaPods (`sudo gem install cocoapods`), simulador ou iPhone |

Aceite as licenças do Android SDK:

```bash
flutter doctor --android-licenses
```

### 3. Ferramentas de linha de comando

| Ferramenta | Para quê | Instalação |
| --- | --- | --- |
| **Node.js** (LTS) | Rodar o Firebase CLI | [nodejs.org](https://nodejs.org/) |
| **Firebase CLI** | Deploy de regras e índices | `npm install -g firebase-tools` |
| **FlutterFire CLI** | Gerar credenciais do app | `dart pub global activate flutterfire_cli` |

Garanta que o `bin` do Dart pub global esteja no `PATH` (o `flutterfire` precisa ser encontrado):

```bash
# Linux/macOS — adicione ao ~/.bashrc ou ~/.zshrc se necessário
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### 4. Conta Firebase

- Conta Google + acesso ao [Firebase Console](https://console.firebase.google.com/)
- Permissão para criar (ou usar) um projeto com **Authentication**, **Cloud Firestore** e **Storage**

---

## Como rodar localmente

### Passo 1 — Clonar e instalar pacotes Dart

```bash
git clone <url-do-repositorio>
cd tech-challenge-mobile

flutter pub get
```

### Passo 2 — Configurar o Firebase

As credenciais **não** vão para o Git (estão no `.gitignore`). Cada pessoa gera as próprias com o FlutterFire.

#### 2.1 Criar / preparar o projeto no Console

1. Abra o [Firebase Console](https://console.firebase.google.com/) e crie um projeto (ou use um existente).
2. Habilite os produtos:
   - **Authentication** → método **E-mail/senha**
   - **Cloud Firestore** → criar banco (modo produção ou teste; as regras do repositório restringem o acesso)
   - **Storage** → criar bucket padrão
3. Anote o **Project ID** (ex.: `finance-app-plus`).

> O `applicationId` Android do app é `com.financeapp.finance_app_mobile`. Ao registrar o app Android no Console, use esse package name.

#### 2.2 Gerar arquivos de configuração

No diretório raiz do projeto:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

No fluxo interativo:

1. Selecione o projeto Firebase.
2. Selecione as plataformas **Android** e **iOS** (e outras se precisar).
3. Confirme o package/bundle id quando pedido.

Isso gera (ou sobrescreve):

| Arquivo | Plataforma |
| --- | --- |
| `lib/firebase_options.dart` | Dart (obrigatório — usado em `main.dart`) |
| `android/app/google-services.json` | Android |
| `ios/Runner/GoogleService-Info.plist` | iOS |

> Há um `lib/firebase_options.dart` placeholder no workspace local. Ele **precisa** ser substituído pelo gerado pelo `flutterfire configure` — sem isso o app não conecta ao seu projeto Firebase.

#### 2.3 Publicar regras e índices

A listagem de transações usa **índices compostos**. Sem o deploy, consultas com filtro combinado falham com `failed-precondition`.

```bash
firebase login          # se ainda não estiver logado
firebase use <project-id>
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Arquivos versionados no repositório:

- [`firestore.rules`](firestore.rules) — acesso por `userId` / uid
- [`firestore.indexes.json`](firestore.indexes.json) — índices da listagem/filtros/totais
- [`storage.rules`](storage.rules) — recibos em `receipts/{userId}/...`
- [`firebase.json`](firebase.json) — aponta regras e índices para o CLI

### Passo 3 — (Opcional) CocoaPods no iOS

Só no macOS, após o `flutterfire configure`:

```bash
cd ios
pod install
cd ..
```

### Passo 4 — Executar o app

Liste dispositivos/emuladores e rode:

```bash
flutter devices
flutter run
```

Ou escolha a plataforma:

```bash
flutter run -d android
flutter run -d ios        # macOS + Xcode
```

Na primeira execução, crie uma conta pela tela de **Cadastro** (e-mail/senha) ou faça login se já existir usuário no Firebase Auth do projeto.

### Checklist rápido

- [ ] `flutter doctor` ok para Android e/ou iOS
- [ ] `flutter pub get` sem erros
- [ ] `flutterfire configure` gerou `firebase_options.dart` + arquivos nativos
- [ ] Auth (e-mail/senha), Firestore e Storage ativos no Console
- [ ] `firebase deploy --only firestore:rules,firestore:indexes,storage` concluído
- [ ] Emulador/dispositivo disponível em `flutter devices`

---

## Estrutura de pastas

```
lib/
├── main.dart                  # entrypoint (Firebase.initializeApp)
├── app.dart                   # FinanceApp: Provider + ShadApp.router
├── firebase_options.dart      # gerado pelo FlutterFire (não versionar)
├── core/
│   ├── router/                # go_router (AppRouter)
│   ├── theme/                 # design system: tokens + tema
│   ├── utils/                 # formatters: moeda/data pt-BR, parse, busca
│   └── widgets/               # AppScaffold e telas auxiliares
└── features/
    ├── splash/                # splash inicial
    ├── auth/                  # login, cadastro, AuthProvider (estado global)
    ├── dashboard/             # home, gráficos, widgets configuráveis
    └── transactions/          # listagem, filtros, formulário + recibos
        ├── data/              # repository Firestore + ReceiptStorageService
        ├── models/
        ├── presentation/
        └── providers/
```

---

## Transações

Tela em [`lib/features/transactions`](lib/features/transactions), com filtros, cards de
resumo e scroll infinito sobre a coleção `transactions` do Cloud Firestore. O
formulário permite anexar recibo via `image_picker`; o upload vai para o
Firebase Storage (`receipts/{userId}/{transactionId}.ext`).

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
| Recibos | `ReceiptStorageService` + `image_picker` no formulário; URL salva em `receiptUrl` |

> **Limite da busca:** o Firestore não tem full-text search. A busca é por **prefixo**
> ("supermerc" acha "Supermercado Pão"), não por trecho no meio da frase — isso exigiria
> um indexador externo (Algolia/Typesense), fora do escopo da fase.

---

## Design system

As cores, tipografia, raio e spacing espelham os tokens de `@vandrei/finance-ui`
(fonte da verdade dos apps web), em [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart)
e [`lib/core/theme/app_theme.dart`](lib/core/theme/app_theme.dart). Os componentes vêm do
pacote `shadcn_ui`, cujos tokens semânticos (background, foreground, primary, muted,
accent, destructive…) mapeiam 1:1 com os do design system.

---

## Validação

```bash
flutter analyze
flutter test
```

---

## Problemas comuns

| Sintoma | Causa provável | O que fazer |
| --- | --- | --- |
| Falha ao iniciar / Firebase | `firebase_options.dart` placeholder ou ausente | Rodar `flutterfire configure` |
| `failed-precondition` na listagem | Índices compostos não publicados | `firebase deploy --only firestore:indexes` |
| Login/cadastro não funciona | Auth e-mail/senha desabilitado | Ativar no Firebase Console → Authentication |
| Upload de recibo falha | Storage sem regras / bucket | Deploy de `storage.rules` e bucket criado |
| Plugin Android / Gradle | SDK ou JDK incompatível | JDK 17 + `flutter doctor` limpo |
| `flutterfire: command not found` | Pub global fora do PATH | Exportar `$HOME/.pub-cache/bin` no shell |
