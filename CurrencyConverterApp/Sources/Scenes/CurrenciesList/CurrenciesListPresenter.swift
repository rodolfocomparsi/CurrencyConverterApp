import Foundation

protocol CurrenciesListPresentationLogic {
    func presentCurrencies(response: CurrenciesList.FetchCurrencies.Response)
}

class CurrenciesListPresenter: CurrenciesListPresentationLogic {
    
    weak var viewController: CurrenciesListDisplayLogic?
    
    func presentCurrencies(response: CurrenciesList.FetchCurrencies.Response) {
        if let error = response.error {
            let viewModel = CurrenciesList.FetchCurrencies.ViewModel(
                displayedCurrencies: [],
                errorMessage: error.localizedDescription
            )
            viewController?.displayCurrencies(viewModel: viewModel)
            return
        }
        
        guard let currencies = response.currencies else {
            let viewModel = CurrenciesList.FetchCurrencies.ViewModel(
                displayedCurrencies: [],
                errorMessage: "Nenhuma moeda carregada"
            )
            viewController?.displayCurrencies(viewModel: viewModel)
            return
        }
        
        let sorted = FavoritesManager.shared.sortedCurrencies(currencies)
        
        let displayed = sorted.map {
            CurrenciesList.FetchCurrencies.ViewModel.DisplayedCurrency(
                code: $0.code,
                name: $0.name,
                displayText: $0.displayName
            )
        }
        
        let viewModel = CurrenciesList.FetchCurrencies.ViewModel(
            displayedCurrencies: displayed,
            errorMessage: nil
        )
        
        viewController?.displayCurrencies(viewModel: viewModel)
    }
}
