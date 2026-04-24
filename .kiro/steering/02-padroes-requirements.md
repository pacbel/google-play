---
inclusion: always
---

# Especificações Técnicas e Arquitetura: App Cripto

## 1. Stack Tecnológica
* **Linguagem:** Dart
* **Framework:** Flutter (Stable Channel)
* **Gerenciamento de Estado:** Bloc ou Provider (definir conforme preferência, recomenda-se Bloc para Clean Arch).
* **Injeção de Dependência:** GetIt + Injectable.
* **Navegação:** AutoRoute ou GoRouter.
* **Persistência Local:** Hive ou Drift (SQLite).

## 2. Estrutura de Pastas (Clean Architecture)
O projeto deve ser dividido em camadas dentro de `lib/`:

* **data/**: Implementações de Repositórios, Models (Data Transfer Objects), Data Sources (Remote/Local) e Mappers.
* **domain/**: Entidades puras, Contratos de Repositórios (Interfaces) e Use Cases.
* **presentation/**: UI (Widgets, Pages) e Logic (Blocs/ChangeNotifiers).
* **core/**: Utilitários globais, temas, constantes de design e componentes compartilhados.

## 3. Padrões de Desenvolvimento
* **Imutabilidade:** Usar `freezed` e `json_serializable` para Models e States.
* **Networking:** Dio com interceptors para logs e tratamento de tokens.
* **Contratos:** Todo repositório deve ter uma classe abstrata no `domain` e sua implementação no `data`.