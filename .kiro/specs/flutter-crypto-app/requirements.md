# Requirements Document

## Introduction

Aplicativo Flutter destinado à publicação na Google Play Store, desenvolvido para validar uma conta de desenvolvedor Google Play. O app oferece uma interface simples para criptografar e descriptografar textos utilizando duas APIs públicas REST (sem autenticação). Além da funcionalidade principal, o projeto deve estar completamente configurado para publicação: ícones adaptativos, assinatura digital com Keystore, ofuscação de código via R8/ProGuard e geração de Android App Bundle (AAB) em modo release.

## Glossary

- **App**: O aplicativo Flutter denominado "Crypto App".
- **Encrypt_API**: Endpoint `POST https://hub-api.sistemavirtual.com.br/api/Crypto/encrypt` que recebe um texto e retorna o valor criptografado.
- **Decrypt_API**: Endpoint `POST https://hub-api.sistemavirtual.com.br/api/Crypto/decrypt` que recebe bytes criptografados e retorna o texto original.
- **Keystore**: Arquivo `.jks` contendo a chave privada usada para assinar digitalmente o APK/AAB.
- **key.properties**: Arquivo de configuração local (não versionado) que armazena as credenciais do Keystore.
- **AAB**: Android App Bundle — formato de distribuição exigido pela Google Play Store.
- **R8**: Ferramenta de minificação e ofuscação de código integrada ao build Android.
- **Adaptive Icon**: Ícone Android que se adapta a diferentes formatos de launcher conforme a versão do sistema operacional.
- **applicationId**: Identificador único do aplicativo no ecossistema Android/Google Play.
- **signingConfig**: Configuração de assinatura digital definida no `build.gradle`.
- **User**: Pessoa que utiliza o App para criptografar ou descriptografar textos.

---

## Requirements

### Requirement 1: Criptografar Texto

**User Story:** Como um User, quero digitar um texto e criptografá-lo, para que eu possa ver o resultado criptografado retornado pela API.

#### Acceptance Criteria

1. THE App SHALL exibir um campo de entrada de texto para o User digitar o conteúdo a ser criptografado.
2. THE App SHALL exibir um botão "Criptografar" para acionar a operação.
3. WHEN o User pressiona o botão "Criptografar" com o campo de entrada não vazio, THE App SHALL enviar uma requisição `POST` para a Encrypt_API com o corpo `{"text": "<valor_digitado>"}` e o cabeçalho `Content-Type: application/json`.
4. WHEN a Encrypt_API retorna resposta com status HTTP 200, THE App SHALL exibir o valor criptografado retornado na área de resultado.
5. IF a Encrypt_API retorna status HTTP diferente de 200, THEN THE App SHALL exibir uma mensagem de erro descritiva ao User.
6. IF o campo de entrada estiver vazio quando o User pressionar "Criptografar", THEN THE App SHALL exibir uma mensagem de validação informando que o campo é obrigatório.
7. WHILE a requisição à Encrypt_API estiver em andamento, THE App SHALL exibir um indicador de carregamento e desabilitar o botão "Criptografar".

---

### Requirement 2: Descriptografar Texto

**User Story:** Como um User, quero inserir bytes criptografados e descriptografá-los, para que eu possa recuperar o texto original.

#### Acceptance Criteria

1. THE App SHALL exibir um campo de entrada para o User inserir os bytes criptografados.
2. THE App SHALL exibir um botão "Descriptografar" para acionar a operação.
3. WHEN o User pressiona o botão "Descriptografar" com o campo de entrada não vazio, THE App SHALL enviar uma requisição `POST` para a Decrypt_API com o corpo `{"bytes": "<valor_digitado>"}` e o cabeçalho `Content-Type: application/json`.
4. WHEN a Decrypt_API retorna resposta com status HTTP 200, THE App SHALL exibir o texto descriptografado retornado na área de resultado.
5. IF a Decrypt_API retorna status HTTP diferente de 200, THEN THE App SHALL exibir uma mensagem de erro descritiva ao User.
6. IF o campo de entrada estiver vazio quando o User pressionar "Descriptografar", THEN THE App SHALL exibir uma mensagem de validação informando que o campo é obrigatório.
7. WHILE a requisição à Decrypt_API estiver em andamento, THE App SHALL exibir um indicador de carregamento e desabilitar o botão "Descriptografar".

---

### Requirement 3: Interface e Navegação

**User Story:** Como um User, quero navegar entre as funcionalidades de criptografia e descriptografia de forma intuitiva, para que eu possa usar o app sem dificuldades.

#### Acceptance Criteria

1. THE App SHALL apresentar as funcionalidades de criptografia e descriptografia em abas ou seções distintas e claramente identificadas.
2. THE App SHALL exibir um botão "Limpar" em cada seção para que o User possa apagar o conteúdo dos campos de entrada e resultado.
3. WHEN o User pressiona o botão "Limpar", THE App SHALL apagar o conteúdo do campo de entrada e da área de resultado da seção correspondente.
4. THE App SHALL exibir um botão "Copiar" ao lado da área de resultado para que o User possa copiar o valor exibido para a área de transferência.
5. WHEN o User pressiona o botão "Copiar", THE App SHALL copiar o conteúdo da área de resultado para a área de transferência do dispositivo e exibir uma confirmação visual (ex.: snackbar).

---

### Requirement 4: Configuração de Identificadores e Assets

**User Story:** Como um desenvolvedor, quero configurar o applicationId e os ícones adaptativos do app, para que o app seja identificado corretamente na Google Play Store e exiba ícones adequados em todos os dispositivos Android.

#### Acceptance Criteria

1. THE App SHALL ter o `applicationId` configurado com um valor único no formato de domínio reverso (ex.: `com.pacbel.cryptoapp`).
2. THE App SHALL incluir ícones adaptativos Android configurados via `flutter_launcher_icons`, com camadas de foreground e background separadas.
3. THE App SHALL ter o `applicationId` definido de forma consistente nos arquivos `build.gradle` (app-level) e `AndroidManifest.xml`.
4. WHERE o dispositivo Android suportar ícones adaptativos (API 26+), THE App SHALL exibir o ícone adaptativo configurado.

---

### Requirement 5: Assinatura Digital (App Signing)

**User Story:** Como um desenvolvedor, quero assinar digitalmente o app com um Keystore, para que o app possa ser publicado na Google Play Store.

#### Acceptance Criteria

1. THE App SHALL ter um Keystore (arquivo `.jks`) gerado com algoritmo RSA de 2048 bits ou superior e validade mínima de 25 anos.
2. THE App SHALL ter um arquivo `key.properties` contendo as credenciais do Keystore (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`).
3. THE App SHALL ter o arquivo `key.properties` listado no `.gitignore` para que as credenciais não sejam versionadas.
4. THE App SHALL ter o `build.gradle` (app-level) configurado com um `signingConfig` de nome `release` que leia as credenciais a partir do arquivo `key.properties`.
5. WHEN o build é executado em modo release, THE App SHALL assinar o AAB/APK utilizando o `signingConfig` `release` configurado.

---

### Requirement 6: Otimização e Build Release

**User Story:** Como um desenvolvedor, quero gerar um Android App Bundle otimizado e ofuscado em modo release, para que o app atenda aos requisitos técnicos da Google Play Store.

#### Acceptance Criteria

1. THE App SHALL ter o R8/ProGuard habilitado no `build.gradle` para o build type `release`, com `minifyEnabled true` e `shrinkResources true`.
2. THE App SHALL incluir regras ProGuard (`proguard-rules.pro`) que preservem as classes necessárias para o funcionamento correto do app em modo release.
3. WHEN o comando de build release é executado (`flutter build appbundle --release`), THE App SHALL gerar um arquivo `.aab` válido no diretório `build/app/outputs/bundle/release/`.
4. THE App SHALL ter o `build.gradle` configurado com `versionCode` e `versionName` definidos explicitamente para o build release.
5. IF o processo de build release falhar por ausência do arquivo `key.properties` ou do Keystore, THEN o sistema de build SHALL exibir uma mensagem de erro descritiva indicando o arquivo ausente.

---

### Requirement 7: Conectividade e Tratamento de Erros de Rede

**User Story:** Como um User, quero ser informado quando não houver conexão com a internet ou quando a API estiver indisponível, para que eu entenda o motivo da falha e possa tentar novamente.

#### Acceptance Criteria

1. IF o dispositivo não possuir conexão com a internet quando o User acionar uma operação, THEN THE App SHALL exibir uma mensagem informando a ausência de conectividade.
2. IF a requisição à Encrypt_API ou Decrypt_API exceder 30 segundos sem resposta, THEN THE App SHALL cancelar a requisição e exibir uma mensagem de timeout ao User.
3. THE App SHALL exibir um botão "Tentar Novamente" após qualquer falha de rede, permitindo que o User reenvie a última requisição sem precisar redigitar o conteúdo.
4. WHEN o User pressiona "Tentar Novamente", THE App SHALL reenviar a requisição anterior com os mesmos parâmetros.
