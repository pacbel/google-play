---
inclusion: always
---

# Guia de Padrões de Comportamento e Resiliência

## 1. Tratamento de Erros (Error Handling)
* **Functional Error Handling:** Não utilizar `throw` para erros esperados. Utilizar a biblioteca `fpdart` com o tipo `Either<Failure, Success>`.
* **Failures:** Criar uma classe base `Failure` e especializações (ex: `ServerFailure`, `CacheFailure`, `NetworkFailure`).

## 2. Feedback ao Usuário (UI/UX)
* **Loading States:** Todo processo assíncrono deve exibir um shimmer effect ou um CircularProgressIndicator customizado na cor 'Gold Main'.
* **Toasts/Snackbars:** Implementar o pacote `cherry_toast` ou `asuka` para notificações globais.
    * *Sucesso:* Toast verde com ícone de check.
    * *Erro:* Toast vermelho com a mensagem amigável vinda do `Failure`.
* **Empty States:** Telas sem dados devem exibir uma ilustração minimalista e um botão de "Tentar Novamente".

## 3. Segurança e Performance
* **Sensitive Data:** Chaves de API e segredos nunca devem estar hardcoded. Usar `.env` (flutter_dotenv).
* **Imagens:** Utilizar `cached_network_image` para todas as imagens remotas.
* **Vibração (Haptic):** Feedback tátil suave em cliques de botões principais e confirmações de transação.

## 4. Validação de Formulários
* Validação em tempo real (autovalidateMode) para campos de e-mail e inputs financeiros, utilizando máscaras apropriadas.