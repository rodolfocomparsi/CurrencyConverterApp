import Foundation

protocol CurrenciesListPresentationLogic {
    func presentCurrencies(response: CurrenciesList.FetchCurrencies.Response)
}

class CurrenciesListPresenter: CurrenciesListPresentationLogic {
    
    weak var viewController: CurrenciesListDisplayLogic?
    
    func presentCurrencies(response: CurrenciesList.FetchCurrencies.Response) {
        let displayed = response.currencies.map {
            CurrenciesList.FetchCurrencies.ViewModel.DisplayedCurrency(
                code: $0.code,
                name: $0.name,
                displayText: $0.displayName
            )
        }
        
        let errorMessage = response.error?.localizedDescription ??
                           (response.currencies.isEmpty ? "Nenhuma moeda encontrada." : nil)
        
        let viewModel = CurrenciesList.FetchCurrencies.ViewModel(
            displayedCurrencies: displayed,
            errorMessage: errorMessage
        )
        
        viewController?.displayCurrencies(viewModel: viewModel)
    }
}
