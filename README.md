# Currency Converter App

Aplicativo iOS de conversão de moedas.

Consumo da API **CurrencyLayer**

## Screenshots

| Tela de Conversão                          | Tela de Listagem de Moedas                     | Favoritos e Busca                              |
|--------------------------------------------|------------------------------------------------|------------------------------------------------|
| ![Conversão](Resources/Screenshots/conversion.png) | ![Listagem](Resources/Screenshots/list.png)    | ![Favoritos](Resources/Screenshots/favorites.png) |

## Funcionalidades Implementadas

**Obrigatórias**

- [x] Duas telas separadas (conversão + listagem)
- [x] Consumo das endpoints `/list` e `/live` 
- [x] Conversão para qualquer par de moedas
- [x] Tratamento completo de erros, loading states e fluxos de exceção

**Opcionais**
- [x] Ordenação da lista de moedas por nome ou código.
- [x] Realizar a persistência local da lista de moedas e taxas para permitir o uso do app no caso de falta de internet.
- [x] Adicionar a capacidade de favoritar uma moeda para que ela sempre apareça no topo da lista.
- [x] Desenvolver testes unitários e/ou funcionais.
- [x] Desenvolver o app seguindo a arquitetura VIP (Clean Swift).
- [x] UI/UX 

## Arquitetura

O aplicativo segue a arquitetura **VIP (Clean Swift)** para garantir separação clara de responsabilidades, testabilidade e manutenção:

- Ciclo: View → Interactor → Presenter → View
- Scenes: `ConversionScene` e `CurrenciesListScene`
- Workers para chamadas de rede
- Sem bibliotecas externas (apenas UIKit + URLSession)

## Como executar

1. Clone o repositório:

   git clone https://github.com/rodolfocomparsi/CurrencyConverterApp.git

Abra o projeto
Insira sua API Key da CurrencyLayer em Sources/Config/APIKeys.swift (arquivo ignorado no git)


## API Key
Crie o arquivo Sources/Config/APIKeys.swift:

Swiftstruct APIKeys {
    static let currencyLayer = "SUA_CHAVE_AQUI"
}






Rodolfo Comparsi 🚀
