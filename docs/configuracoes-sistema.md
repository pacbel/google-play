# Configurações do Sistema — Crypto App

Documento técnico detalhando todas as versões, SDKs, ferramentas de build e compatibilidade de dispositivos do projeto.

---

## 1. Versões Principais do Ecossistema

| Tecnologia | Versão | Papel |
|------------|--------|-------|
| **Flutter SDK** | 3.41.7 (stable) | Framework de UI multiplataforma |
| **Dart SDK** | 3.11.5 | Linguagem de programação |
| **Android Gradle Plugin (AGP)** | 8.11.1 | Compila e empacota o APK/AAB |
| **Gradle** | 8.14 | Sistema de build do Android |
| **Kotlin** | 2.2.20 | Linguagem nativa Android (MainActivity) |
| **Java Compatibility** | 17 | Versão do JVM para compilação |

---

## 2. Como Essas Versões se Relacionam

```
Flutter SDK 3.41.7
    ├── contém Dart SDK 3.11.5 (embutido)
    ├── gera o código Dart → compila para ARM/x86 nativo
    └── integra com o build system Android via:
            │
            ├── Gradle 8.14 (orquestra o build)
            │       └── usa Android Gradle Plugin 8.11.1
            │               └── compila código Kotlin 2.2.20
            │                       └── com JVM target Java 17
            │
            └── Flutter Gradle Plugin (dev.flutter.flutter-gradle-plugin)
                    └── conecta o engine Flutter ao APK final
```

**Resumo da cadeia:**
1. Você escreve Dart → Flutter compila para código nativo
2. O Gradle monta o APK Android, incluindo o engine Flutter + código Kotlin
3. O Kotlin é usado apenas para a `MainActivity` (ponto de entrada Android)
4. O Java 17 é o target de compilação do bytecode Kotlin/Java

---

## 3. Dart SDK — `^3.11.5`

**Definido em:** `pubspec.yaml` → `environment.sdk`

```yaml
environment:
  sdk: ^3.11.5
```

**Por que esta versão:**
- Suporta `sealed class` e `final class` (Dart 3.0+)
- Suporta pattern matching com desestruturação no `switch` (Dart 3.0+)
- Suporta records e class modifiers (Dart 3.0+)
- O `^` significa "3.11.5 ou superior, mas menor que 4.0.0"

**O que o Dart SDK faz:**
- Compila o código `.dart` para código de máquina nativo (AOT para release)
- Executa em modo JIT durante desenvolvimento (hot reload)
- Gerencia pacotes via `pub` (equivalente ao npm/pip)

---

## 4. Flutter SDK — 3.41.7

**Definido em:** `.metadata` e `.dart_tool/package_config.json`

**Canal:** stable

**O que o Flutter SDK faz:**
- Fornece o framework de widgets (Material, Cupertino)
- Fornece o engine de renderização (Skia/Impeller)
- Gerencia o build para cada plataforma (Android, iOS, Web, Desktop)
- Inclui o Dart SDK embutido

**Por que Flutter:**
- Um único código Dart → roda em Android, iOS, Web, Desktop
- Hot reload para desenvolvimento rápido
- Performance nativa (compila para ARM, não usa bridge como React Native)
- Material 3 nativo com `useMaterial3: true`

---

## 5. Android SDK — Configuração

**Definido em:** `android/app/build.gradle.kts`

| Configuração | Valor | Significado |
|-------------|-------|-------------|
| `compileSdk` | `flutter.compileSdkVersion` | SDK usado para compilar (definido pelo Flutter, atualmente API 35) |
| `minSdk` | `flutter.minSdkVersion` | Mínimo suportado (API 21 = Android 5.0 Lollipop) |
| `targetSdk` | `flutter.targetSdkVersion` | SDK alvo para comportamento (API 35 = Android 15) |
| `namespace` | `com.pacbel.cryptoapp` | Identificador único do app |

**Por que esses valores:**
- `minSdk 21` (Android 5.0): Cobre ~99% dos dispositivos Android ativos no mundo
- `targetSdk 35`: Garante conformidade com as políticas mais recentes do Google Play
- `compileSdk 35`: Permite usar as APIs mais recentes durante o desenvolvimento

---

## 6. Compatibilidade de Dispositivos

### Android

| Android Version | API Level | Suportado? | Market Share (aprox.) |
|----------------|-----------|------------|----------------------|
| Android 5.0 Lollipop | 21 | ✅ Mínimo | ~0.5% |
| Android 6.0 Marshmallow | 23 | ✅ | ~1% |
| Android 7.0/7.1 Nougat | 24-25 | ✅ | ~2% |
| Android 8.0/8.1 Oreo | 26-27 | ✅ | ~5% |
| Android 9 Pie | 28 | ✅ | ~7% |
| Android 10 | 29 | ✅ | ~10% |
| Android 11 | 30 | ✅ | ~14% |
| Android 12/12L | 31-32 | ✅ | ~15% |
| Android 13 | 33 | ✅ | ~18% |
| Android 14 | 34 | ✅ | ~20% |
| Android 15 | 35 | ✅ Target | ~8% |

**Cobertura total estimada: ~99% dos dispositivos Android ativos.**

### iOS

O projeto tem a pasta `ios/` configurada, então também suporta iOS. A versão mínima é definida pelo Flutter (atualmente iOS 12+), cobrindo praticamente todos os iPhones em uso (iPhone 5s em diante).

### Outras Plataformas (configuradas mas não priorizadas)

O `.metadata` mostra que o projeto foi criado com suporte a:
- ✅ Android (principal)
- ✅ iOS
- ⚠️ Web (ícones desabilitados no launcher_icons)
- ⚠️ Linux, macOS, Windows (estrutura existe mas não é foco)

---

## 7. Gradle — 8.14

**Definido em:** `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

**O que faz:**
- É o sistema de build do Android (como Make/CMake para C++)
- Resolve dependências, compila código, gera o APK/AAB
- Executa tasks como `assembleRelease`, `assembleDebug`

**Por que 8.14:**
- Compatível com AGP 8.11.1
- Performance melhorada de build (cache, paralelismo)
- Suporte a Kotlin DSL (`.gradle.kts` ao invés de `.gradle`)

**Configuração de memória** (`gradle.properties`):
```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m
```
- 8GB de heap para o Gradle — necessário para projetos Flutter que compilam código nativo
- `android.useAndroidX=true` — usa as bibliotecas AndroidX modernas

---

## 8. Kotlin — 2.2.20

**Definido em:** `android/settings.gradle.kts`

```kotlin
id("org.jetbrains.kotlin.android") version "2.2.20" apply false
```

**O que faz no projeto:**
- Apenas a `MainActivity.kt` é escrita em Kotlin
- É o ponto de entrada nativo Android que inicializa o Flutter engine
- Plugins nativos Android também podem usar Kotlin

**Por que Kotlin e não Java:**
- Flutter gera projetos com Kotlin por padrão desde 2020
- Kotlin é a linguagem oficial recomendada pelo Google para Android
- Mais conciso e seguro (null safety nativo)

---

## 9. Android Gradle Plugin (AGP) — 8.11.1

**Definido em:** `android/settings.gradle.kts`

```kotlin
id("com.android.application") version "8.11.1" apply false
```

**O que faz:**
- Transforma código Kotlin/Java em bytecode DEX (Dalvik Executable)
- Empacota resources, assets, manifest no APK
- Aplica ProGuard/R8 para minificação e ofuscação

**Configuração de release** (`build.gradle.kts`):
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true      // R8 remove código não usado
        isShrinkResources = true    // Remove resources não usados
        proguardFiles(...)          // Regras de ofuscação
    }
}
```

---

## 10. Configuração de Assinatura (Release)

**Definido em:** `android/key.properties` + `android/app/upload-keystore.jks`

O app usa um keystore para assinar o APK de release (necessário para publicar na Play Store):
- `key.properties` — contém alias, senha e caminho do keystore
- `upload-keystore.jks` — arquivo de chave criptográfica

Se o `key.properties` não existir, o build usa a chave de debug automaticamente (com aviso no log).

---

## 11. Permissões Android

**Definido em:** `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**Apenas uma permissão:** acesso à internet. Necessária porque o app faz chamadas HTTP à API de criptografia.

O `connectivity_plus` não precisa de permissão extra — ele usa APIs do sistema que já estão disponíveis.

---

## 12. Dependências e Suas Versões Resolvidas

### Produção

| Pacote | Versão Declarada | Versão Resolvida | Função |
|--------|-----------------|-----------------|--------|
| `flutter_bloc` | ^8.1.6 | 8.1.6 | Gerenciamento de estado (Cubit/Bloc) |
| `dio` | ^5.4.3 | 5.9.2 | Cliente HTTP com interceptors e timeout |
| `connectivity_plus` | ^6.0.3 | 6.1.5 | Detecta estado da conexão de rede |
| `dartz` | ^0.10.1 | 0.10.1 | Tipos funcionais (Either, Option) |
| `cupertino_icons` | ^1.0.8 | 1.0.9 | Ícones estilo iOS |
| `flutter_launcher_icons` | ^0.13.1 | 0.13.1 | Gera ícones adaptativos para Android/iOS |

### Desenvolvimento/Testes

| Pacote | Versão Declarada | Versão Resolvida | Função |
|--------|-----------------|-----------------|--------|
| `bloc_test` | ^9.1.7 | 9.1.7 | Framework de teste para Cubits |
| `mocktail` | ^1.0.4 | 1.0.5 | Criação de mocks sem code generation |
| `glados` | ^1.1.7 | 1.1.7 | Property-based testing |
| `flutter_lints` | ^4.0.0 | 4.0.0 | Regras de análise estática |

### Dependências Transitivas Importantes

| Pacote | Versão | Vem de | Função |
|--------|--------|--------|--------|
| `bloc` | 8.1.4 | flutter_bloc | Core do padrão Bloc |
| `provider` | 6.1.5+1 | flutter_bloc | InheritedWidget wrapper (BlocProvider usa internamente) |
| `nested` | 1.0.0 | provider | Otimiza widgets aninhados |
| `dio_web_adapter` | 2.1.2 | dio | Adaptador para rodar Dio na web |

---

## 13. Por Que Cada Dependência Foi Escolhida

### `flutter_bloc` — Gerenciamento de Estado
- **Alternativas:** Provider puro, Riverpod, GetX, MobX
- **Por que Bloc/Cubit:** Separação clara entre lógica e UI, testabilidade excelente, padrão da comunidade para Clean Architecture
- **Cubit vs Bloc:** Cubit é mais simples (não usa Events), ideal para operações diretas como encrypt/decrypt

### `dio` — HTTP Client
- **Alternativas:** http (pacote padrão), retrofit, chopper
- **Por que Dio:** Interceptors, timeout granular (connect/receive/send), cancelamento de requests, upload com progresso
- **Relação com o projeto:** Configurado com base URL e timeout de 30s via `DioClient`

### `connectivity_plus` — Verificação de Rede
- **Alternativas:** internet_connection_checker, data_connection_checker
- **Por que connectivity_plus:** Mantido pela comunidade Flutter (Plus Plugins), leve, multiplataforma
- **Relação com o projeto:** Verifica conexão ANTES de fazer a requisição HTTP (fail-fast)

### `dartz` — Programação Funcional
- **Alternativas:** fpdart, oxidized, result_type
- **Por que dartz:** Maduro, amplamente usado com Clean Architecture, tipo `Either` bem documentado
- **Relação com o projeto:** Todo retorno de repositório é `Either<Failure, CryptoResult>` — elimina try/catch na camada de apresentação

### `glados` — Property-Based Testing
- **Alternativas:** quickcheck (não existe em Dart), test_randomized
- **Por que glados:** Único PBT maduro para Dart, gera inputs aleatórios e encontra edge cases automaticamente
- **Relação com o projeto:** Testa propriedades como "encrypt nunca retorna string vazia para input válido"

---

## 14. Configuração do Ícone do App

**Definido em:** `pubspec.yaml` → `flutter_launcher_icons`

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#1E252B"          # Midnight Blue-Grey
  adaptive_icon_foreground: "assets/icons/icon_foreground.png"
```

**Ícone Adaptativo Android (API 26+):**
- Background: cor sólida `#1E252B` (escuro)
- Foreground: imagem PNG com o logo
- O sistema Android recorta em círculo, quadrado arredondado, etc. conforme o launcher

**Densidades geradas:**
- `mdpi` (1x) — 48x48px
- `hdpi` (1.5x) — 72x72px
- `xhdpi` (2x) — 96x96px
- `xxhdpi` (3x) — 144x144px
- `xxxhdpi` (4x) — 192x192px

---

## 15. Estrutura de Build — Debug vs Release

| Aspecto | Debug | Release |
|---------|-------|---------|
| Compilação Dart | JIT (Just-In-Time) | AOT (Ahead-Of-Time) |
| Hot Reload | ✅ Sim | ❌ Não |
| Performance | Mais lenta | Otimizada |
| Tamanho do APK | Maior (~80MB) | Menor (~15-25MB) |
| Minificação (R8) | Desabilitada | Habilitada |
| Shrink Resources | Desabilitado | Habilitado |
| ProGuard | Não aplicado | Aplicado |
| Assinatura | Debug key | Release keystore |
| Banner "DEBUG" | Visível | Removido (`debugShowCheckedModeBanner: false`) |

---

## 16. Fluxo de Build Completo

```
flutter build apk --release
    │
    ├── 1. Dart AOT Compiler
    │       └── Compila lib/*.dart → código ARM nativo (libapp.so)
    │
    ├── 2. Flutter Engine
    │       └── Inclui libflutter.so (engine de renderização)
    │
    ├── 3. Gradle Build
    │       ├── Compila MainActivity.kt → DEX
    │       ├── Processa AndroidManifest.xml
    │       ├── Empacota assets/ (ícones)
    │       ├── Aplica R8 (minificação + ofuscação)
    │       └── Assina com keystore
    │
    └── 4. Output
            └── build/app/outputs/flutter-apk/app-release.apk
```

---

## 17. Resumo de Compatibilidade

| Plataforma | Suportado | Versão Mínima | Dispositivos Cobertos |
|-----------|-----------|---------------|----------------------|
| Android | ✅ Principal | API 21 (Android 5.0) | ~99% dos Android ativos |
| iOS | ✅ Configurado | iOS 12+ | iPhone 5s em diante |
| Web | ⚠️ Estrutura existe | Navegadores modernos | Chrome, Firefox, Safari, Edge |
| Windows | ⚠️ Estrutura existe | Windows 10+ | — |
| macOS | ⚠️ Estrutura existe | macOS 10.14+ | — |
| Linux | ⚠️ Estrutura existe | — | — |

---

## 18. Comandos Úteis

```bash
# Ver versão do Flutter e Dart instalados
flutter --version

# Ver dispositivos conectados
flutter devices

# Build debug APK
flutter build apk --debug

# Build release APK (assinado)
flutter build apk --release

# Build App Bundle para Play Store
flutter build appbundle --release

# Analisar tamanho do APK
flutter build apk --analyze-size

# Gerar ícones do app
dart run flutter_launcher_icons

# Rodar testes
flutter test

# Verificar problemas no projeto
flutter doctor
flutter analyze
```


---

## 19. Glossário de Termos Técnicos

| Termo | Definição |
|-------|-----------|
| **SDK (Software Development Kit)** | Conjunto de ferramentas, bibliotecas e documentação para desenvolver software para uma plataforma específica. Ex: Flutter SDK, Android SDK, Dart SDK. |
| **API (Application Programming Interface)** | Interface que permite a comunicação entre dois sistemas. Neste projeto, o app se comunica com uma API REST para criptografar/descriptografar texto. |
| **API Level** | Número inteiro que identifica a versão do framework Android. Cada versão do Android (5.0, 6.0, etc.) tem um API Level correspondente (21, 23, etc.). |
| **APK (Android Package Kit)** | Arquivo de instalação de apps Android. Contém o código compilado, recursos e manifesto. |
| **AAB (Android App Bundle)** | Formato de publicação para a Play Store. O Google gera APKs otimizados para cada dispositivo a partir do AAB. |
| **AOT (Ahead-Of-Time Compilation)** | Compilação feita antes da execução. O código Dart é convertido em código de máquina nativo durante o build. Usado em release para máxima performance. |
| **JIT (Just-In-Time Compilation)** | Compilação feita durante a execução. Permite hot reload no modo debug, mas é mais lento que AOT. |
| **Hot Reload** | Funcionalidade do Flutter que injeta código alterado no app em execução sem perder o estado. Só funciona em modo debug (JIT). |
| **Gradle** | Sistema de automação de build usado em projetos Android. Gerencia dependências, compila código e gera o APK/AAB. |
| **AGP (Android Gradle Plugin)** | Plugin do Gradle específico para Android. Adiciona tasks como `assembleRelease`, gerencia SDK versions e aplica ProGuard/R8. |
| **Kotlin** | Linguagem de programação moderna para JVM, oficial do Android. Neste projeto, usada apenas na MainActivity (ponto de entrada nativo). |
| **JVM (Java Virtual Machine)** | Máquina virtual que executa bytecode Java/Kotlin. O Gradle e o compilador Kotlin rodam na JVM. |
| **JVM Target** | Versão do bytecode Java gerado pelo compilador Kotlin. Java 17 neste projeto. |
| **Namespace** | Identificador único do app no sistema Android (ex: `com.pacbel.cryptoapp`). Usado para evitar conflitos entre apps. |
| **compileSdk** | Versão do Android SDK usada para compilar o código. Define quais APIs estão disponíveis durante o desenvolvimento. |
| **minSdk** | Versão mínima do Android que o app suporta. Dispositivos com versão inferior não podem instalar o app. |
| **targetSdk** | Versão do Android para a qual o app foi otimizado. O sistema aplica comportamentos de compatibilidade baseado neste valor. |
| **NDK (Native Development Kit)** | Kit para compilar código C/C++ para Android. O Flutter usa internamente para o engine de renderização. |
| **DEX (Dalvik Executable)** | Formato de bytecode executado pela máquina virtual Android (ART). Código Kotlin/Java é convertido para DEX. |
| **R8** | Compilador/otimizador que substitui o ProGuard. Remove código não usado (tree shaking), ofusca nomes e otimiza bytecode. |
| **ProGuard** | Ferramenta de ofuscação e minificação de código Java/Kotlin. R8 é seu sucessor moderno. |
| **Tree Shaking** | Processo de remover código que nunca é chamado/usado. Reduz o tamanho do APK final. |
| **Shrink Resources** | Remove recursos (imagens, strings, layouts) que não são referenciados no código. Complementa o tree shaking. |
| **Keystore** | Arquivo criptográfico (.jks) que contém a chave privada para assinar o APK. Necessário para publicar na Play Store. |
| **Assinatura Digital** | Processo de assinar o APK com uma chave privada. Garante que o app não foi adulterado e identifica o desenvolvedor. |
| **AndroidX** | Conjunto moderno de bibliotecas de suporte do Android. Substitui as antigas "Support Libraries". |
| **Material 3 (Material You)** | Sistema de design do Google com temas dinâmicos, cores adaptativas e componentes modernos. |
| **Dart** | Linguagem de programação criada pelo Google, usada pelo Flutter. Suporta compilação AOT e JIT, null safety e tipagem forte. |
| **Flutter** | Framework de UI do Google para criar apps multiplataforma (Android, iOS, Web, Desktop) a partir de um único código Dart. |
| **Widget** | Elemento básico de UI no Flutter. Tudo é widget: botões, textos, layouts, páginas inteiras. |
| **StatelessWidget** | Widget sem estado interno mutável. Recebe dados via construtor e nunca muda sozinho. |
| **StatefulWidget** | Widget com estado interno que pode mudar ao longo do tempo (ex: campo de texto, animações). |
| **Cubit** | Versão simplificada do Bloc. Gerencia estado emitindo novos estados via `emit()` quando uma função é chamada. |
| **Bloc (Business Logic Component)** | Padrão de gerenciamento de estado que separa eventos (input) de estados (output) usando streams. |
| **Either<L, R>** | Tipo funcional que representa dois resultados possíveis: Left (erro) ou Right (sucesso). Vem do pacote `dartz`. |
| **sealed class** | Classe que restringe quais subtipos podem existir. O compilador sabe todos os casos possíveis, permitindo `switch` exaustivo. |
| **Clean Architecture** | Padrão arquitetural que separa o código em camadas (data, domain, presentation) com dependências apontando para dentro. |
| **Use Case** | Classe que encapsula uma única regra de negócio. Conecta a camada de apresentação ao repositório. |
| **Repository Pattern** | Padrão que abstrai a origem dos dados. A camada domain define o contrato (interface), a camada data implementa. |
| **Data Source** | Classe responsável por buscar dados de uma fonte específica (API remota, banco local, cache). |
| **DTO (Data Transfer Object)** | Objeto usado para transportar dados entre camadas. Os Models (`EncryptRequestModel`, etc.) são DTOs. |
| **Dependency Injection** | Padrão onde as dependências de uma classe são fornecidas externamente (via construtor), facilitando testes e desacoplamento. |
| **HTTP (HyperText Transfer Protocol)** | Protocolo de comunicação entre cliente e servidor na web. O app usa HTTP POST para enviar dados à API. |
| **REST (Representational State Transfer)** | Estilo arquitetural para APIs web. Usa verbos HTTP (GET, POST, PUT, DELETE) e retorna dados em JSON. |
| **JSON (JavaScript Object Notation)** | Formato leve de troca de dados. Ex: `{"text": "Carlos"}`. Usado na comunicação com a API. |
| **Timeout** | Tempo máximo de espera por uma resposta. Se excedido, a operação é cancelada. Configurado em 30 segundos neste projeto. |
| **Interceptor** | Middleware que intercepta requisições/respostas HTTP. Usado para adicionar headers, logs ou tratar erros globalmente. |
| **Null Safety** | Sistema de tipos que distingue valores que podem ser nulos (`String?`) dos que não podem (`String`). Previne erros de null pointer. |
| **Property-Based Testing (PBT)** | Técnica de teste que gera inputs aleatórios e verifica se propriedades/invariantes são mantidas, ao invés de testar casos específicos. |
| **Mock** | Objeto falso que simula o comportamento de uma dependência real durante testes. Criado com `mocktail` neste projeto. |
| **Ícone Adaptativo** | Formato de ícone Android (API 26+) com duas camadas (foreground + background) que o sistema recorta em diferentes formas. |
| **Densidade de Tela (DPI)** | Quantidade de pixels por polegada. Android tem categorias: mdpi (1x), hdpi (1.5x), xhdpi (2x), xxhdpi (3x), xxxhdpi (4x). |
| **Pub** | Gerenciador de pacotes do Dart. Equivalente ao npm (Node.js) ou pip (Python). Resolve dependências declaradas no `pubspec.yaml`. |
| **Dependência Transitiva** | Pacote que não é declarado diretamente no seu `pubspec.yaml`, mas é puxado por outra dependência. Ex: `provider` vem via `flutter_bloc`. |
| **Channel (Flutter)** | Canal de atualização do Flutter: `stable` (produção), `beta` (pré-release), `master` (desenvolvimento). Este projeto usa `stable`. |
| **Engine Flutter** | Componente C++ que renderiza a UI, gerencia input e executa o código Dart. Distribuído como `libflutter.so` no APK. |
| **Skia / Impeller** | Engines de renderização gráfica. Skia é o legado, Impeller é o novo (mais rápido em iOS/Android). Flutter escolhe automaticamente. |
