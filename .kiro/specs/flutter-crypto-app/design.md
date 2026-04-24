# Design Document — Flutter Crypto App

## Overview

O **Crypto App** é um aplicativo Flutter para Android que expõe duas operações de criptografia/descriptografia via chamadas REST a uma API pública. O objetivo principal é demonstrar uma aplicação funcional e publicável na Google Play Store, com arquitetura limpa, gerenciamento de estado reativo, tratamento robusto de erros de rede e configuração completa de build release (assinatura, ofuscação, AAB).

### Decisões de alto nível

| Decisão | Escolha | Justificativa |
|---|---|---|
| Gerenciamento de estado | `flutter_bloc` (Cubit) | Leve, testável, sem boilerplate excessivo para um app de escopo pequeno |
| Cliente HTTP | `dio` | Suporte nativo a timeout, cancelamento de requisição e interceptors |
| Verificação de conectividade | `connectivity_plus` | Pacote oficial Flutter Community, mantido ativamente |
| Ícones adaptativos | `flutter_launcher_icons` | Ferramenta padrão do ecossistema Flutter para geração automatizada |
| Arquitetura | Clean Architecture em 3 camadas | Separação clara entre UI, lógica de negócio e acesso a dados |

---

## Architecture

O app segue uma **Clean Architecture simplificada** com três camadas:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  Widgets (Flutter UI) ←→ Cubit (State Management)   │
└──────────────────────┬──────────────────────────────┘
                       │ usa
┌──────────────────────▼──────────────────────────────┐
│                   Domain Layer                       │
│  Use Cases  ←→  Repository Interfaces  ←→  Entities │
└──────────────────────┬──────────────────────────────┘
                       │ implementa
┌──────────────────────▼──────────────────────────────┐
│                    Data Layer                        │
│  Repository Impl  ←→  Remote Data Source  ←→  Dio   │
└─────────────────────────────────────────────────────┘
```

### Fluxo de dados (exemplo: criptografar)

```
User digita texto
       │
       ▼
EncryptPage (Widget)
       │ chama método
       ▼
CryptoCubit.encrypt(text)
       │ chama use case
       ▼
EncryptUseCase.execute(text)
       │ chama repositório
       ▼
CryptoRepositoryImpl.encrypt(text)
       │ chama data source
       ▼
CryptoRemoteDataSource.encrypt(text)
       │ POST via Dio
       ▼
Encrypt_API → resposta
       │
       ▼ (caminho de volta)
CryptoResult (sucesso ou falha)
       │
       ▼
CryptoCubit emite novo CryptoState
       │
       ▼
BlocBuilder reconstrói EncryptPage
```

### Estrutura de diretórios

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, tema, rotas
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # URLs base, endpoints, timeout
│   ├── errors/
│   │   ├── failures.dart             # Sealed class de falhas
│   │   └── exceptions.dart           # Exceções customizadas
│   ├── network/
│   │   ├── dio_client.dart           # Instância configurada do Dio
│   │   └── connectivity_service.dart # Wrapper do connectivity_plus
│   └── utils/
│       └── clipboard_helper.dart     # Utilitário para copiar texto
├── features/
│   └── crypto/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── crypto_remote_data_source.dart
│       │   ├── models/
│       │   │   ├── encrypt_request_model.dart
│       │   │   ├── encrypt_response_model.dart
│       │   │   ├── decrypt_request_model.dart
│       │   │   └── decrypt_response_model.dart
│       │   └── repositories/
│       │       └── crypto_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── crypto_result.dart
│       │   ├── repositories/
│       │   │   └── crypto_repository.dart   # interface abstrata
│       │   └── usecases/
│       │       ├── encrypt_use_case.dart
│       │       └── decrypt_use_case.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── crypto_cubit.dart
│           │   └── crypto_state.dart
│           ├── pages/
│           │   └── crypto_page.dart         # TabBar com 2 abas
│           └── widgets/
│               ├── crypto_tab.dart          # Widget reutilizável por aba
│               ├── result_card.dart         # Exibe resultado + botão Copiar
│               └── error_banner.dart        # Exibe erros e botão Tentar Novamente
assets/
├── icons/
│   ├── icon_foreground.png   # Camada foreground do ícone adaptativo
│   └── icon_background.png   # Camada background do ícone adaptativo
android/
├── app/
│   ├── build.gradle          # signingConfig, R8, versionCode/Name
│   ├── proguard-rules.pro
│   └── src/main/AndroidManifest.xml
├── build.gradle
└── key.properties            # NÃO versionado (.gitignore)
```

---

## Components and Interfaces

### 1. `DioClient` (core/network)

Responsável por criar e configurar a instância singleton do Dio.

```dart
class DioClient {
  static Dio createDio() {
    return Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }
}
```

**Decisão de design:** timeout de 30 s em todas as fases (connect, send, receive) conforme Requirement 7.2. O `DioException` com tipo `connectionTimeout` ou `receiveTimeout` é mapeado para `TimeoutFailure`.

---

### 2. `ConnectivityService` (core/network)

```dart
abstract class ConnectivityService {
  Future<bool> hasConnection();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  // Verifica ConnectivityResult != none
}
```

Verificação feita **antes** de cada chamada de API no repositório. Se não houver conexão, retorna `NoConnectionFailure` sem realizar a requisição HTTP.

---

### 3. `CryptoRemoteDataSource` (data/datasources)

```dart
abstract class CryptoRemoteDataSource {
  Future<EncryptResponseModel> encrypt(EncryptRequestModel request);
  Future<DecryptResponseModel> decrypt(DecryptRequestModel request);
}
```

Implementação lança `ServerException` para status HTTP ≠ 200 e `NetworkException` para falhas de rede/timeout do Dio.

---

### 4. `CryptoRepository` (domain/repositories)

```dart
abstract class CryptoRepository {
  Future<Either<Failure, CryptoResult>> encrypt(String text);
  Future<Either<Failure, CryptoResult>> decrypt(String bytes);
}
```

**Decisão de design:** uso do tipo `Either<Failure, T>` (padrão funcional) para forçar o tratamento explícito de erros na camada de apresentação, sem depender de exceções não capturadas. Implementado com o pacote `dartz` ou equivalente simples com sealed classes.

> **Alternativa considerada:** retornar `CryptoResult` com campo `error` nullable. Rejeitada porque permite ignorar erros acidentalmente.

---

### 5. `CryptoCubit` e `CryptoState` (presentation/cubit)

```dart
// Estados possíveis
sealed class CryptoState {
  const CryptoState();
}

class CryptoInitial extends CryptoState {}

class CryptoLoading extends CryptoState {}

class CryptoSuccess extends CryptoState {
  final String result;
  const CryptoSuccess(this.result);
}

class CryptoFailure extends CryptoState {
  final String message;
  final bool canRetry;
  const CryptoFailure({required this.message, required this.canRetry});
}
```

```dart
class CryptoCubit extends Cubit<CryptoState> {
  final EncryptUseCase _encryptUseCase;
  final DecryptUseCase _decryptUseCase;

  // Armazena última operação para "Tentar Novamente"
  _LastOperation? _lastOperation;

  Future<void> encrypt(String text);
  Future<void> decrypt(String bytes);
  Future<void> retry();
  void clear();
}
```

**Decisão de design:** um único `CryptoCubit` gerencia ambas as abas. Cada aba instancia seu próprio `BlocProvider` com uma instância separada do cubit para manter estados independentes.

---

### 6. `CryptoTab` (presentation/widgets)

Widget reutilizável que recebe:
- `label`: "Criptografar" ou "Descriptografar"
- `inputHint`: texto de placeholder
- `onSubmit`: callback com o texto digitado
- `onClear`: callback para limpar
- `onRetry`: callback para tentar novamente

Internamente usa `BlocBuilder<CryptoCubit, CryptoState>` para reagir aos estados.

---

## Data Models

### Requisição — Encrypt

```dart
class EncryptRequestModel {
  final String text;

  Map<String, dynamic> toJson() => {'text': text};
}
```

### Resposta — Encrypt

A API retorna o valor criptografado. O campo exato da resposta será determinado na implementação após inspeção da resposta real da API. Modelo inicial:

```dart
class EncryptResponseModel {
  final String encryptedValue; // campo mapeado da resposta JSON

  factory EncryptResponseModel.fromJson(Map<String, dynamic> json);
}
```

### Requisição — Decrypt

```dart
class DecryptRequestModel {
  final String bytes;

  Map<String, dynamic> toJson() => {'bytes': bytes};
}
```

### Resposta — Decrypt

```dart
class DecryptResponseModel {
  final String decryptedText; // campo mapeado da resposta JSON

  factory DecryptResponseModel.fromJson(Map<String, dynamic> json);
}
```

### Entidade de domínio

```dart
class CryptoResult {
  final String value;
  const CryptoResult(this.value);
}
```

### Hierarquia de Failures

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure({required this.statusCode, required String message})
      : super(message);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure() : super('Sem conexão com a internet.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('A requisição excedeu o tempo limite de 30 segundos.');
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
```

---

## Configuração Android (Build & Release)

### applicationId e versionamento

```groovy
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "com.pacbel.cryptoapp"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### Assinatura digital (key.properties)

```properties
# android/key.properties  — NÃO versionar
storePassword=<senha_do_keystore>
keyPassword=<senha_da_chave>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

Se `key.properties` não existir, o Gradle lança erro descritivo em `validateSigningRelease` (Requirement 6.5).

### ProGuard rules

```proguard
# proguard-rules.pro
# Preserva modelos de dados usados na serialização JSON
-keep class com.pacbel.cryptoapp.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# Dart/Flutter runtime
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```

### Ícones adaptativos (flutter_launcher_icons)

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icons/icon_foreground.png"
  adaptive_icon_background: "assets/icons/icon_background.png"
  adaptive_icon_foreground: "assets/icons/icon_foreground.png"
  min_sdk_android: 21
```

Geração: `dart run flutter_launcher_icons`

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Validação de entrada rejeita texto vazio ou somente espaços

*Para qualquer* string composta inteiramente de espaços em branco (incluindo a string vazia), tentar submetê-la como entrada de criptografia ou descriptografia deve resultar em estado de erro de validação, sem que nenhuma requisição HTTP seja disparada e sem alterar o estado de resultado anterior.

**Validates: Requirements 1.6, 2.6**

---

### Property 2: Mapeamento de falha de rede para estado de erro com retry

*Para qualquer* falha de rede (sem conexão, timeout, erro de servidor), o cubit deve transitar para `CryptoFailure` com `canRetry = true`, preservando os parâmetros da última operação de forma que uma chamada subsequente a `retry()` reenvie exatamente os mesmos dados.

**Validates: Requirements 7.1, 7.2, 7.3, 7.4**

---

### Property 3: Limpar restaura estado inicial

*Para qualquer* estado do cubit (sucesso, falha ou carregando), chamar `clear()` deve transitar o cubit para `CryptoInitial`, independentemente do estado anterior.

**Validates: Requirements 3.2, 3.3**

---

### Property 4: Serialização round-trip dos modelos de requisição

*Para qualquer* string de texto válida, serializar um `EncryptRequestModel` para JSON e desserializar de volta deve produzir um objeto com o mesmo valor de `text`. O mesmo vale para `DecryptRequestModel` e o campo `bytes`.

**Validates: Requirements 1.3, 2.3**

---

### Property 5: Mapeamento de resposta HTTP ≠ 200 para ServerFailure

*Para qualquer* código de status HTTP diferente de 200 retornado pela API, o repositório deve produzir uma `ServerFailure` contendo o código de status recebido, sem lançar exceção não tratada.

**Validates: Requirements 1.5, 2.5**

---

## Error Handling

### Estratégia de tratamento de erros

```
Exceção Dio                    →  Failure
─────────────────────────────────────────────────────
DioExceptionType.connectionTimeout  →  TimeoutFailure
DioExceptionType.receiveTimeout     →  TimeoutFailure
DioExceptionType.sendTimeout        →  TimeoutFailure
DioExceptionType.connectionError    →  NoConnectionFailure
Response.statusCode != 200          →  ServerFailure(statusCode)
Qualquer outro erro                 →  UnknownFailure(message)
```

### Verificação de conectividade

Antes de cada chamada HTTP, `CryptoRepositoryImpl` consulta `ConnectivityService.hasConnection()`. Se retornar `false`, retorna imediatamente `NoConnectionFailure` sem instanciar a requisição Dio. Isso garante feedback imediato ao usuário mesmo quando o Dio ainda não detectou a ausência de rede.

### Mensagens de erro ao usuário

| Failure | Mensagem exibida |
|---|---|
| `NoConnectionFailure` | "Sem conexão com a internet. Verifique sua rede e tente novamente." |
| `TimeoutFailure` | "A requisição demorou mais de 30 segundos. Tente novamente." |
| `ServerFailure` | "Erro no servidor (código HTTP: {statusCode}). Tente novamente." |
| `UnknownFailure` | "Ocorreu um erro inesperado. Tente novamente." |

Todos os estados `CryptoFailure` expõem `canRetry = true`, exibindo o botão "Tentar Novamente" (Requirement 7.3).

### Validação de entrada

Realizada no `CryptoCubit` antes de chamar o use case:
- Texto vazio ou somente espaços → emite `CryptoFailure` com mensagem de validação e `canRetry = false` (não faz sentido tentar novamente sem alterar a entrada).

---

## Testing Strategy

### Abordagem dual

O projeto usa **testes unitários/de widget** para comportamentos específicos e **testes baseados em propriedades** para invariantes universais.

#### Biblioteca de property-based testing

**`fast_check`** (Dart) — alternativa: **`glados`**. Ambos disponíveis no pub.dev. Configuração mínima de **100 iterações** por propriedade.

> Justificativa: `glados` é mais maduro no ecossistema Dart e integra bem com `flutter_test`. `fast_check` oferece shrinking automático de contraexemplos.

#### Testes unitários (exemplo-based)

- `CryptoRemoteDataSource`: mock do Dio, verificar corpo da requisição, headers e mapeamento de resposta.
- `CryptoRepositoryImpl`: mock do data source e connectivity service, verificar mapeamento de exceções para Failures.
- `CryptoCubit`: verificar sequência de estados emitidos para cada operação.
- `EncryptUseCase` / `DecryptUseCase`: verificar delegação correta ao repositório.

#### Testes de widget

- `CryptoTab`: verificar que botão fica desabilitado durante `CryptoLoading`.
- `CryptoTab`: verificar que snackbar de confirmação aparece ao copiar resultado.
- `CryptoTab`: verificar que botão "Tentar Novamente" aparece em `CryptoFailure` com `canRetry = true`.

#### Testes baseados em propriedades

Cada propriedade do design é implementada como um único teste de propriedade:

```dart
// Exemplo — Property 1
test('Property 1: entrada inválida não dispara requisição HTTP', () {
  forAll(
    whitespaceStringArbitrary(), // gerador de strings com só espaços
    (input) {
      final cubit = CryptoCubit(...mockRepository...);
      cubit.encrypt(input);
      verifyNever(mockRepository.encrypt(any));
      expect(cubit.state, isA<CryptoFailure>());
    },
  );
});
// Feature: flutter-crypto-app, Property 1: entrada inválida não dispara requisição
```

#### Testes de integração (smoke)

- Verificar que o build release gera o arquivo `.aab` no caminho esperado.
- Verificar que `key.properties` ausente produz mensagem de erro descritiva no Gradle.

### Cobertura esperada

| Camada | Tipo de teste | Meta |
|---|---|---|
| Data (models, datasource) | Unitário + Property 4 | ≥ 90% |
| Domain (use cases, repository interface) | Unitário | ≥ 90% |
| Presentation (cubit, states) | Unitário + Property 2, 3 | ≥ 85% |
| Widgets | Widget test | Fluxos principais |
| Build/release | Smoke | Checklist manual |
