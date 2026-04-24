# Implementation Plan: Flutter Crypto App

## Overview

Implementação incremental do Crypto App em Flutter seguindo Clean Architecture em três camadas (Data, Domain, Presentation). As tarefas constroem o projeto de baixo para cima: configuração do projeto → camada de dados → domínio → apresentação → configuração Android de release. Cada etapa integra o código produzido à etapa anterior, sem código órfão.

## Tasks

- [x] 1. Configurar projeto Flutter e dependências
  - Criar o projeto Flutter com `applicationId` `com.pacbel.cryptoapp` no `android/app/build.gradle` e `AndroidManifest.xml`
  - Adicionar ao `pubspec.yaml` as dependências: `flutter_bloc`, `dio`, `connectivity_plus`, `dartz`, `flutter_launcher_icons`
  - Adicionar ao `pubspec.yaml` as dev dependencies: `bloc_test`, `mocktail`, `glados` (ou `fast_check`)
  - Criar a estrutura de diretórios conforme o design: `lib/core/`, `lib/features/crypto/data/`, `lib/features/crypto/domain/`, `lib/features/crypto/presentation/`
  - **Nota:** o arquivo `logo.png` está disponível na raiz do projeto e será utilizado na task 12 para gerar todos os ícones e variações de tamanho exigidos pelo Android e pelo `flutter_launcher_icons`
  - _Requirements: 4.1, 4.3_

- [x] 2. Implementar camada core (constantes, erros e rede)
  - [x] 2.1 Criar `api_constants.dart` com `baseUrl`, endpoints de encrypt/decrypt e valor de timeout (30 s)
    - _Requirements: 1.3, 2.3, 7.2_

  - [x] 2.2 Criar `failures.dart` com a sealed class `Failure` e subclasses: `ServerFailure`, `NoConnectionFailure`, `TimeoutFailure`, `UnknownFailure`
    - _Requirements: 1.5, 2.5, 7.1, 7.2_

  - [x] 2.3 Criar `exceptions.dart` com `ServerException` e `NetworkException`
    - _Requirements: 1.5, 2.5_

  - [x] 2.4 Criar `dio_client.dart` com `DioClient.createDio()` configurando `BaseOptions` com `baseUrl`, `connectTimeout`, `receiveTimeout`, `sendTimeout` de 30 s e header `Content-Type: application/json`
    - _Requirements: 1.3, 2.3, 7.2_

  - [x] 2.5 Criar `connectivity_service.dart` com a interface abstrata `ConnectivityService` e a implementação `ConnectivityServiceImpl` usando `connectivity_plus`
    - _Requirements: 7.1_

  - [x] 2.6 Criar `clipboard_helper.dart` com função utilitária para copiar texto para a área de transferência
    - _Requirements: 3.4, 3.5_

- [x] 3. Implementar modelos de dados (camada Data)
  - [x] 3.1 Criar `encrypt_request_model.dart` com campo `text` e método `toJson()`
    - _Requirements: 1.3_

  - [x] 3.2 Criar `encrypt_response_model.dart` com campo `encryptedValue` e factory `fromJson()`
    - _Requirements: 1.4_

  - [x] 3.3 Criar `decrypt_request_model.dart` com campo `bytes` e método `toJson()`
    - _Requirements: 2.3_

  - [x] 3.4 Criar `decrypt_response_model.dart` com campo `decryptedText` e factory `fromJson()`
    - _Requirements: 2.4_

  - [ ]* 3.5 Escrever property test para serialização round-trip dos modelos de requisição
    - **Property 4: Serialização round-trip dos modelos de requisição**
    - Para qualquer string válida, `EncryptRequestModel(text).toJson()` deve preservar o valor de `text`; idem para `DecryptRequestModel`
    - **Validates: Requirements 1.3, 2.3**

- [x] 4. Implementar entidades e interfaces de domínio
  - [x] 4.1 Criar `crypto_result.dart` com a entidade `CryptoResult(String value)`
    - _Requirements: 1.4, 2.4_

  - [x] 4.2 Criar `crypto_repository.dart` com a interface abstrata `CryptoRepository` declarando `encrypt(String text)` e `decrypt(String bytes)` retornando `Future<Either<Failure, CryptoResult>>`
    - _Requirements: 1.3, 1.4, 1.5, 2.3, 2.4, 2.5_

- [x] 5. Implementar use cases
  - [x] 5.1 Criar `encrypt_use_case.dart` que delega para `CryptoRepository.encrypt(text)`
    - _Requirements: 1.3, 1.4, 1.5_

  - [x] 5.2 Criar `decrypt_use_case.dart` que delega para `CryptoRepository.decrypt(bytes)`
    - _Requirements: 2.3, 2.4, 2.5_

  - [ ]* 5.3 Escrever testes unitários para `EncryptUseCase` e `DecryptUseCase`
    - Verificar delegação correta ao repositório em cenários de sucesso e falha
    - _Requirements: 1.3, 1.4, 1.5, 2.3, 2.4, 2.5_

- [x] 6. Implementar `CryptoRemoteDataSource`
  - [x] 6.1 Criar `crypto_remote_data_source.dart` com a interface abstrata e a implementação que usa `Dio` para `POST` nos endpoints de encrypt e decrypt
    - Lançar `ServerException` para status HTTP ≠ 200
    - Lançar `NetworkException` para falhas de rede/timeout do Dio
    - _Requirements: 1.3, 1.4, 1.5, 2.3, 2.4, 2.5, 7.2_

  - [ ]* 6.2 Escrever testes unitários para `CryptoRemoteDataSource`
    - Mockar o Dio; verificar corpo da requisição, headers e mapeamento de resposta para sucesso e erro
    - _Requirements: 1.3, 1.4, 1.5, 2.3, 2.4, 2.5_

- [x] 7. Implementar `CryptoRepositoryImpl`
  - [x] 7.1 Criar `crypto_repository_impl.dart` implementando `CryptoRepository`
    - Verificar conectividade via `ConnectivityService` antes de cada chamada; retornar `NoConnectionFailure` se sem conexão
    - Mapear `NetworkException`/`DioException` para `TimeoutFailure` ou `NoConnectionFailure` conforme o tipo
    - Mapear `ServerException` para `ServerFailure` com o `statusCode`
    - Mapear qualquer outro erro para `UnknownFailure`
    - _Requirements: 1.5, 2.5, 7.1, 7.2_

  - [ ]* 7.2 Escrever testes unitários para `CryptoRepositoryImpl`
    - Mockar `CryptoRemoteDataSource` e `ConnectivityService`
    - Verificar mapeamento de cada tipo de exceção para o `Failure` correto
    - _Requirements: 1.5, 2.5, 7.1, 7.2_

  - [ ]* 7.3 Escrever property test para mapeamento de resposta HTTP ≠ 200 para `ServerFailure`
    - **Property 5: Mapeamento de resposta HTTP ≠ 200 para ServerFailure**
    - Para qualquer código de status diferente de 200, o repositório deve produzir `ServerFailure` com o código recebido, sem lançar exceção não tratada
    - **Validates: Requirements 1.5, 2.5**

- [x] 8. Checkpoint — Verificar camadas de dados e domínio
  - Garantir que todos os testes das camadas Data e Domain passam. Perguntar ao usuário se houver dúvidas antes de prosseguir.

- [x] 9. Implementar `CryptoCubit` e `CryptoState`
  - [x] 9.1 Criar `crypto_state.dart` com a sealed class `CryptoState` e subclasses: `CryptoInitial`, `CryptoLoading`, `CryptoSuccess(String result)`, `CryptoFailure({String message, bool canRetry})`
    - _Requirements: 1.7, 2.7, 7.1, 7.2, 7.3_

  - [x] 9.2 Criar `crypto_cubit.dart` com `CryptoCubit` contendo os métodos `encrypt(String text)`, `decrypt(String bytes)`, `retry()` e `clear()`
    - Validar entrada (vazio/somente espaços) antes de chamar o use case; emitir `CryptoFailure` com `canRetry = false` se inválido
    - Armazenar `_lastOperation` para suportar `retry()`
    - Emitir `CryptoLoading` antes da chamada e `CryptoSuccess` ou `CryptoFailure` após
    - _Requirements: 1.6, 1.7, 2.6, 2.7, 7.3, 7.4_

  - [ ]* 9.3 Escrever testes unitários para `CryptoCubit`
    - Verificar sequência de estados emitidos para sucesso, falha de rede, timeout e validação de entrada vazia
    - _Requirements: 1.6, 1.7, 2.6, 2.7, 7.1, 7.2, 7.3, 7.4_

  - [ ]* 9.4 Escrever property test para validação de entrada (Property 1)
    - **Property 1: Validação de entrada rejeita texto vazio ou somente espaços**
    - Para qualquer string composta inteiramente de espaços em branco (incluindo string vazia), `encrypt` e `decrypt` devem emitir `CryptoFailure` sem chamar o repositório
    - **Validates: Requirements 1.6, 2.6**

  - [ ]* 9.5 Escrever property test para mapeamento de falha de rede (Property 2)
    - **Property 2: Mapeamento de falha de rede para estado de erro com retry**
    - Para qualquer `Failure` retornado pelo repositório, o cubit deve transitar para `CryptoFailure` com `canRetry = true` e `retry()` deve reenviar os mesmos parâmetros
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**

  - [ ]* 9.6 Escrever property test para `clear()` (Property 3)
    - **Property 3: Limpar restaura estado inicial**
    - Para qualquer estado do cubit (sucesso, falha ou carregando), chamar `clear()` deve transitar para `CryptoInitial`
    - **Validates: Requirements 3.2, 3.3**

- [x] 10. Implementar widgets de apresentação
  - [x] 10.1 Criar `error_banner.dart` que exibe a mensagem de erro e, quando `canRetry = true`, o botão "Tentar Novamente" que chama `onRetry`
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 10.2 Criar `result_card.dart` que exibe o resultado e o botão "Copiar"; ao pressionar "Copiar", usa `ClipboardHelper` e exibe um `SnackBar` de confirmação
    - _Requirements: 3.4, 3.5_

  - [x] 10.3 Criar `crypto_tab.dart` como widget reutilizável com campo de entrada, botão de ação (Criptografar/Descriptografar), botão "Limpar" e `BlocBuilder<CryptoCubit, CryptoState>` para reagir aos estados
    - Desabilitar o botão de ação durante `CryptoLoading` e exibir `CircularProgressIndicator`
    - Exibir `ResultCard` em `CryptoSuccess`
    - Exibir `ErrorBanner` em `CryptoFailure`
    - _Requirements: 1.1, 1.2, 1.7, 2.1, 2.2, 2.7, 3.2, 3.3_

  - [x] 10.4 Criar `crypto_page.dart` com `TabBar` de duas abas ("Criptografar" e "Descriptografar"), cada aba com seu próprio `BlocProvider<CryptoCubit>` para manter estados independentes
    - _Requirements: 3.1_

  - [x] 10.5 Criar `app.dart` com `MaterialApp`, tema e rota inicial para `CryptoPage`
    - _Requirements: 3.1_

  - [x] 10.6 Atualizar `main.dart` para inicializar o app via `app.dart`
    - _Requirements: 3.1_

  - [ ]* 10.7 Escrever testes de widget para `CryptoTab`
    - Verificar que o botão fica desabilitado durante `CryptoLoading`
    - Verificar que o `SnackBar` de confirmação aparece ao copiar resultado
    - Verificar que o botão "Tentar Novamente" aparece em `CryptoFailure` com `canRetry = true`
    - _Requirements: 1.7, 2.7, 3.4, 3.5, 7.3_

- [x] 11. Checkpoint — Verificar camada de apresentação
  - Garantir que todos os testes de cubit e widget passam. Perguntar ao usuário se houver dúvidas antes de prosseguir.

- [x] 12. Configurar ícones adaptativos Android
  - **Fonte da logo:** o arquivo `logo.png` está disponível na raiz do projeto e deve ser usado como base para gerar todas as variações de ícones necessárias.
  - [x] 12.1 Copiar `logo.png` da raiz do projeto para `assets/icons/icon_foreground.png` (camada foreground do ícone adaptativo); criar também `assets/icons/icon_background.png` com uma cor sólida ou versão de fundo derivada da logo; declarar o diretório `assets/icons/` no `pubspec.yaml`
    - A `logo.png` da raiz deve ser usada como fonte principal — redimensionar e ajustar conforme necessário para cada variação
    - _Requirements: 4.2, 4.4_

  - [x] 12.2 Configurar a seção `flutter_launcher_icons` no `pubspec.yaml` apontando para os arquivos gerados a partir da `logo.png`: `image_path`, `adaptive_icon_background`, `adaptive_icon_foreground` e `min_sdk_android: 21`
    - _Requirements: 4.2, 4.4_

  - [x] 12.3 Executar `dart run flutter_launcher_icons` para gerar automaticamente todos os tamanhos e densidades de ícone exigidos (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) em `android/app/src/main/res/`, usando a `logo.png` como origem
    - _Requirements: 4.2, 4.4_

- [x] 13. Configurar build Android release (assinatura, R8 e AAB)
  - [x] 13.1 Gerar o Keystore `upload-keystore.jks` com RSA 2048 bits e validade mínima de 25 anos usando `keytool`
    - _Requirements: 5.1_

  - [x] 13.2 Criar `android/key.properties` com `storePassword`, `keyPassword`, `keyAlias` e `storeFile`; adicionar `key.properties` ao `.gitignore`
    - _Requirements: 5.2, 5.3_

  - [x] 13.3 Atualizar `android/app/build.gradle` para:
    - Ler `key.properties` e configurar `signingConfigs.release`
    - Habilitar `minifyEnabled true` e `shrinkResources true` no `buildTypes.release`
    - Referenciar `proguard-rules.pro`
    - Definir `versionCode 1` e `versionName "1.0.0"` explicitamente
    - _Requirements: 5.4, 5.5, 6.1, 6.4_

  - [x] 13.4 Criar/atualizar `android/app/proguard-rules.pro` com regras para preservar classes do app, Dio/OkHttp e Flutter runtime
    - _Requirements: 6.2_

  - [x] 13.5 Verificar que `android/app/build.gradle` exibe mensagem de erro descritiva quando `key.properties` está ausente (bloco condicional no Gradle)
    - _Requirements: 6.5_

- [-] 14. Gerar e validar o Android App Bundle release
  - Executar `flutter build appbundle --release` e verificar que o arquivo `.aab` é gerado em `build/app/outputs/bundle/release/`
  - _Requirements: 6.3_

- [~] 15. Checkpoint final — Garantir que todos os testes passam
  - Executar `flutter test` e confirmar que todos os testes unitários, de widget e de propriedade passam. Perguntar ao usuário se houver dúvidas antes de concluir.

## Notes

- Tarefas marcadas com `*` são opcionais e podem ser puladas para um MVP mais rápido
- Cada tarefa referencia os requisitos específicos para rastreabilidade
- Os checkpoints garantem validação incremental a cada fase
- Os property tests validam invariantes universais (Properties 1–5 do design)
- Os testes unitários validam exemplos específicos e casos de borda
- O `CryptoCubit` usa instâncias separadas por aba via `BlocProvider` para manter estados independentes
- O arquivo `key.properties` e o Keystore `.jks` **não devem ser versionados** no repositório
