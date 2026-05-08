# Manual Completo — Crypto App (Flutter/Dart)

## O que este app faz?

É um aplicativo de **criptografia e descriptografia** de texto. O usuário digita um texto, o app envia para uma API REST, e recebe de volta o texto criptografado (ou descriptografado).

---

## 1. Ponto de Entrada — `main.dart`

```dart
void main() {
  runApp(const App());
}
```

Todo app Flutter começa aqui. `runApp()` recebe o widget raiz e monta a árvore de widgets na tela.

---

## 2. Widget Raiz — `app.dart`

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(...), // tema escuro com cores douradas
      home: const CryptoPage(),
    );
  }
}
```

- `MaterialApp` configura o app inteiro (tema, navegação, título).
- O tema usa **Material 3** com esquema de cores escuro (fundo cinza-carvão, destaques em dourado).
- A tela inicial é `CryptoPage`.

---

## 3. Arquitetura — Clean Architecture

O projeto segue **Clean Architecture** dividida em 3 camadas:

```
lib/
├── core/           → Utilitários globais (rede, erros, constantes)
└── features/
    └── crypto/
        ├── data/           → Implementação concreta (API, models)
        ├── domain/         → Regras de negócio puras (entidades, contratos, use cases)
        └── presentation/   → UI e gerenciamento de estado (Cubit/Bloc)
```

A ideia central: **cada camada só conhece a camada acima dela**. A UI não sabe como a API funciona, e a lógica de negócio não sabe que Flutter existe.

---

## 4. Camada Core — Fundação do App

### 4.1 Constantes da API (`lib/core/constants/api_constants.dart`)

```dart
class ApiConstants {
  static const String baseUrl = 'https://hub-api.sistemavirtual.com.br/api';
  static const String encryptEndpoint = '/Crypto/encrypt';
  static const String decryptEndpoint = '/Crypto/decrypt';
  static const Duration timeout = Duration(seconds: 30);
}
```

Centraliza URLs e configurações. Se a API mudar, você altera só aqui.

### 4.2 Tratamento de Erros

O projeto usa **dois níveis** de erro:

**Exceptions** (camada data — erros técnicos em `lib/core/errors/exceptions.dart`):
- `ServerException` — servidor respondeu com erro HTTP
- `NetworkException` — sem internet ou timeout

**Failures** (camada domain — erros de negócio em `lib/core/errors/failures.dart`):
```dart
sealed class Failure {
  final String message;
}
```
- `ServerFailure` — erro do servidor com código HTTP
- `NoConnectionFailure` — sem internet
- `TimeoutFailure` — requisição demorou demais
- `UnknownFailure` — erro inesperado

A palavra-chave `sealed` garante que o compilador sabe todos os tipos possíveis — útil no `switch`.

### 4.3 Rede

**ConnectivityService** (`lib/core/network/connectivity_service.dart`) — verifica se tem internet antes de fazer requisição:
```dart
Future<bool> hasConnection() async {
  final results = await _connectivity.checkConnectivity();
  return results.any((result) => result != ConnectivityResult.none);
}
```

**DioClient** (`lib/core/network/dio_client.dart`) — cria uma instância do Dio (cliente HTTP) com configurações padrão (timeout, headers, base URL).

### 4.4 Utilitários

**ClipboardHelper** (`lib/core/utils/clipboard_helper.dart`) — copia texto para a área de transferência do dispositivo.

---

## 5. Camada Domain — Regras de Negócio

### 5.1 Entidade (`lib/features/crypto/domain/entities/crypto_result.dart`)

```dart
class CryptoResult {
  final String value; // o texto criptografado ou descriptografado
}
```

Entidade pura — não sabe nada sobre JSON, API, ou Flutter.

### 5.2 Contrato do Repositório (`lib/features/crypto/domain/repositories/crypto_repository.dart`)

```dart
abstract class CryptoRepository {
  Future<Either<Failure, CryptoResult>> encrypt(String text);
  Future<Either<Failure, CryptoResult>> decrypt(String bytes);
}
```

`Either<Failure, CryptoResult>` vem do pacote `dartz`. É um tipo funcional que representa:
- **Left** = erro (Failure)
- **Right** = sucesso (CryptoResult)

Isso elimina `try/catch` espalhado pelo código. Quem chama o método recebe um "ou deu certo, ou deu errado" de forma explícita.

### 5.3 Use Cases (`lib/features/crypto/domain/usecases/`)

```dart
class EncryptUseCase {
  final CryptoRepository _repository;

  Future<Either<Failure, CryptoResult>> call(String text) {
    return _repository.encrypt(text);
  }
}
```

Cada Use Case faz **uma coisa só**. Aqui é só um repasse, mas em apps maiores teria validações, combinação de repositórios, etc.

---

## 6. Camada Data — Implementação Concreta

### 6.1 Models / DTOs (`lib/features/crypto/data/models/`)

Representam o JSON que vai/vem da API:

```dart
// Request: {"text": "Carlos"}
class EncryptRequestModel {
  Map<String, dynamic> toJson() => {'text': text};
}

// Response: {"bytes": "tsbZ4eHU"}
class EncryptResponseModel {
  factory EncryptResponseModel.fromJson(Map<String, dynamic> json) {
    return EncryptResponseModel(bytes: json['bytes'] as String);
  }
}
```

- `toJson()` converte Dart → JSON (para enviar à API)
- `fromJson()` converte JSON → Dart (para receber da API)

### 6.2 Data Source (`lib/features/crypto/data/datasources/crypto_remote_data_source.dart`)

```dart
class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final Dio _dio;

  Future<EncryptResponseModel> encrypt(EncryptRequestModel request) async {
    final response = await _dio.post(endpoint, data: request.toJson());
    return EncryptResponseModel.fromJson(response.data);
  }
}
```

Faz a chamada HTTP real. Se der erro, lança `ServerException` ou `NetworkException`.

### 6.3 Repository Implementation (`lib/features/crypto/data/repositories/crypto_repository_impl.dart`)

```dart
class CryptoRepositoryImpl implements CryptoRepository {
  Future<Either<Failure, CryptoResult>> encrypt(String text) async {
    // 1. Verifica internet
    if (!await _connectivityService.hasConnection()) {
      return const Left(NoConnectionFailure());
    }
    // 2. Tenta chamar a API
    try {
      final response = await _dataSource.encrypt(...);
      return Right(CryptoResult(response.bytes)); // sucesso!
    } on ServerException catch (e) {
      return Left(ServerFailure(...)); // erro do servidor
    } on NetworkException catch (e) {
      return Left(TimeoutFailure()); // timeout
    }
  }
}
```

Aqui é onde **Exceptions viram Failures**. A camada de apresentação nunca vê exceptions — só Failures com mensagens amigáveis.

---

## 7. Camada Presentation — UI e Estado

### 7.1 Estado (`lib/features/crypto/presentation/cubit/crypto_state.dart`)

```dart
sealed class CryptoState {}

class CryptoInitial extends CryptoState {}   // tela limpa
class CryptoLoading extends CryptoState {}   // carregando...
class CryptoSuccess extends CryptoState {    // resultado pronto
  final String result;
}
class CryptoFailure extends CryptoState {    // erro
  final String message;
  final bool canRetry;
}
```

Cada estado possível da tela é uma classe. O `sealed` garante que o compilador verifica se você tratou todos os casos.

### 7.2 Cubit (`lib/features/crypto/presentation/cubit/crypto_cubit.dart`)

```dart
class CryptoCubit extends Cubit<CryptoState> {
  Future<void> encrypt(String text) async {
    emit(const CryptoLoading());           // mostra loading
    final result = await _encryptUseCase(text);
    result.fold(
      (failure) => emit(CryptoFailure(...)), // erro
      (success) => emit(CryptoSuccess(...)), // sucesso
    );
  }
}
```

O Cubit é uma versão simplificada do Bloc. Ele:
1. Recebe uma ação (encrypt/decrypt)
2. Emite estados (loading → success ou failure)
3. A UI reage automaticamente a cada estado emitido

Funcionalidades extras:
- `retry()` — repete a última operação (útil quando dá erro de rede)
- `clear()` — reseta tudo para o estado inicial

### 7.3 Página Principal (`lib/features/crypto/presentation/pages/crypto_page.dart`)

Monta a estrutura com:
- `AppBar` com gradiente dourado e abas (Criptografar / Descriptografar)
- `TabBarView` com duas instâncias de `CryptoTab`
- Cada aba tem seu próprio `CryptoCubit` (estados independentes)

A montagem das dependências acontece aqui (manual, sem injeção de dependência):
```dart
CryptoCubit _buildCubit() {
  final dio = DioClient.createDio();
  final dataSource = CryptoRemoteDataSourceImpl(dio);
  final repository = CryptoRepositoryImpl(...);
  return CryptoCubit(
    encryptUseCase: EncryptUseCase(repository),
    decryptUseCase: DecryptUseCase(repository),
  );
}
```

### 7.4 Widget `CryptoTab` (`lib/features/crypto/presentation/widgets/crypto_tab.dart`)

É um `StatefulWidget` porque precisa de um `TextEditingController`. Contém:
- Campo de texto (input)
- Botão de ação (Criptografar/Descriptografar)
- Botão "Limpar"
- Exibe `ResultCard` quando sucesso ou `ErrorBanner` quando erro

Usa `BlocBuilder` para reagir ao estado:
```dart
BlocBuilder<CryptoCubit, CryptoState>(
  builder: (context, state) {
    if (state is CryptoSuccess) ResultCard(result: state.result);
    if (state is CryptoFailure) ErrorBanner(message: state.message);
  },
);
```

### 7.5 Widgets de Resultado

- **ResultCard** — mostra o resultado com borda verde, texto em fonte monospace dourada, e botão "Copiar" que usa `ClipboardHelper`
- **ErrorBanner** — mostra erro com borda vermelha e botão "Tentar Novamente"

---

## 8. Fluxo Completo (do clique ao resultado)

```
Usuário digita "Carlos" → clica "Criptografar"
    ↓
CryptoTab._submit() → CryptoCubit.encrypt("Carlos")
    ↓
Cubit emite CryptoLoading → UI mostra spinner
    ↓
EncryptUseCase.call("Carlos") → CryptoRepository.encrypt("Carlos")
    ↓
CryptoRepositoryImpl: verifica internet → chama DataSource
    ↓
DataSource: POST /Crypto/encrypt {"text": "Carlos"} → recebe {"bytes": "tsbZ4eHU"}
    ↓
Repository retorna Right(CryptoResult("tsbZ4eHU"))
    ↓
Cubit emite CryptoSuccess("tsbZ4eHU") → UI mostra ResultCard
```

---

## 9. Conceitos Dart Importantes Usados

| Conceito | Onde aparece | O que faz |
|----------|-------------|-----------|
| `sealed class` | States, Failures | Garante que todos os subtipos são conhecidos em compile-time |
| `final class` | States | Impede herança adicional |
| `const` constructors | Em quase tudo | Otimiza memória — objetos imutáveis reutilizáveis |
| `Either<L, R>` | Repository, Use Cases | Tratamento funcional de erros (sem throw/catch) |
| `part of` / `part` | Cubit + State | Divide um arquivo lógico em dois físicos |
| `abstract class` | Repository, DataSource | Define contratos (interfaces) |
| `factory` constructor | Models | Cria instância a partir de JSON |
| Pattern matching (`switch`) | `_mapFailureMessage` | Dart 3 — match por tipo com desestruturação |
| `StatelessWidget` | App, CryptoPage, ResultCard | Widget sem estado interno mutável |
| `StatefulWidget` | CryptoTab | Widget com estado interno (TextEditingController) |

---

## 10. Dependências do Projeto

| Pacote | Função |
|--------|--------|
| `flutter_bloc` | Gerenciamento de estado (Cubit) |
| `dio` | Cliente HTTP (requisições à API) |
| `connectivity_plus` | Verificar conexão com internet |
| `dartz` | Tipos funcionais (`Either`) |
| `flutter_launcher_icons` | Gerar ícones do app |

### Dev Dependencies (para testes)

| Pacote | Função |
|--------|--------|
| `bloc_test` | Testar Cubits/Blocs |
| `mocktail` | Criar mocks para testes |
| `glados` | Property-based testing |
| `flutter_lints` | Regras de lint/estilo |

---

## 11. Design Visual

O app segue o conceito **"Premium Gold & Silver Minimalist"**:

| Elemento | Cor | Hex |
|----------|-----|-----|
| Fundo principal | Deep Charcoal | `#2C343C` |
| Cards/Inputs | Midnight Blue-Grey | `#1E252B` |
| Bordas/Divisores | Grid Slate | `#3D4852` |
| Destaque principal | Gold Main | `#D4AF37` |
| Brilho/Gradiente | Gold Light | `#F1D592` |
| Texto secundário | Silver/Platinum | `#C0C0C0` |
| Sucesso | Green | `#00C853` |
| Erro | Red | `#FF3D00` |

---

## 12. Como Rodar o Projeto

```bash
# Instalar dependências
flutter pub get

# Rodar no dispositivo/emulador
flutter run

# Rodar testes
flutter test
```

---

## 13. Como Adicionar uma Nova Feature (seguindo a arquitetura)

1. Crie a pasta `lib/features/nova_feature/`
2. Dentro, crie as 3 camadas: `data/`, `domain/`, `presentation/`
3. Comece pelo `domain/` — defina a entidade e o contrato do repositório
4. Implemente o `data/` — models, datasource, repository
5. Crie o `presentation/` — cubit/state e widgets
6. Conecte tudo na página principal
