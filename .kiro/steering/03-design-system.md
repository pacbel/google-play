---
inclusion: always
---

# Especificações de Design: Projeto Cripto (Pacbel)

Este documento define a identidade visual para o desenvolvimento do aplicativo Flutter, baseando-se no conceito de design "Premium Gold & Silver Minimalist".

## 1. Paleta de Cores (Hexadecimal)

### 1.1 Cores Primárias (Metais)
* **Gold Main:** `#D4AF37` (Ouro vibrante para elementos de destaque e botões principais).
* **Gold Light:** `#F1D592` (Destaques de brilho e gradientes).
* **Silver/Platinum:** `#C0C0C0` (Para elementos secundários e detalhes de contraste).

### 1.2 Cores de Interface (Background & Superfícies)
* **Deep Charcoal:** `#2C343C` (Fundo principal da aplicação - Dark Theme).
* **Midnight Blue-Grey:** `#1E252B` (Superfícies de cards e inputs para gerar profundidade).
* **Grid Slate:** `#3D4852` (Linhas de grade, divisores e bordas sutis).

### 1.3 Cores de Estado (Semânticas)
* **Success (Bullish):** `#00C853` (Para variações positivas de mercado).
* **Danger (Bearish):** `#FF3D00` (Para variações negativas ou alertas).

## 2. Tipografia e Estilo
* **Estética:** Moderna, geométrica e limpa (Sugestão: Fontes como *Montserrat* ou *Inter*).
* **Peso:** Uso de 'Semi-bold' para títulos e 'Regular' para dados numéricos.

## 3. Elementos Visuais e Efeitos
* **Gradientes:** Utilizar gradientes lineares suaves entre o `Gold Main` e o `Gold Light` para simular o efeito metálico do logo.
* **Sombras:** Aplicar sombras suaves (Drop Shadows) com opacidade baixa para simular o efeito de camadas sobrepostas visto no ícone.
* **Shapes:** Bordas arredondadas (Radius: 12px a 16px) para manter a suavidade do símbolo do infinito.

## 4. Diretrizes para Flutter (Material 3)
* **ColorScheme:** Implementar o `ThemeData` focado em tons escuros (Dark Mode por padrão).
* **Cards:** Devem utilizar a cor `Midnight Blue-Grey` com uma borda sutil em `Grid Slate`.
* **Ícones:** Sempre que possível, utilizar variações tonais do `Silver` para ícones inativos e `Gold` para ícones ativos/selecionados.