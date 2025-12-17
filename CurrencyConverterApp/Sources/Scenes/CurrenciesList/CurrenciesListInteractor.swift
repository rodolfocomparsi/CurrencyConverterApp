import Foundation

protocol CurrenciesListBusinessLogic {
    func fetchCurrencies(request: CurrenciesList.FetchCurrencies.Request)
    func toggleFavorite(request: CurrenciesList.ToggleFavorite.Request)
}

protocol CurrenciesListDataStore: AnyObject {
    var selectedCurrency: Currency? { get set }
    var allCurrencies: [Currency]? { get set }
}

class CurrenciesListInteractor: CurrenciesListBusinessLogic, CurrenciesListDataStore {
    
    var presenter: CurrenciesListPresentationLogic?
    var worker = CurrencyAPIWorker()
    
    var selectedCurrency: Currency?
    var allCurrencies: [Currency]?
    
    func fetchCurrencies(request: CurrenciesList.FetchCurrencies.Request) {
        if let cached = CacheManager.shared.loadCurrencies() {
            let response = CurrenciesList.FetchCurrencies.Response(currencies: cached, error: nil)
            presenter?.presentCurrencies(response: response)
        }
        
        worker.fetchSupportedCurrencies { result in
            switch result {
            case .success(let currencies):
                CacheManager.shared.saveCurrencies(currencies)
                let response = CurrenciesList.FetchCurrencies.Response(currencies: currencies, error: nil)
                self.presenter?.presentCurrencies(response: response)
            case .failure(let error):
                if CacheManager.shared.loadCurrencies() == nil {
                    let response = CurrenciesList.FetchCurrencies.Response(currencies: [], error: error)
                    self.presenter?.presentCurrencies(response: response)
                }
            }
        }
    }
    
    func toggleFavorite(request: CurrenciesList.ToggleFavorite.Request) {
        FavoritesManager.shared.toggleFavorite(request.currencyCode)
        
        guard let currencies = allCurrencies else { return }
        
        let response = CurrenciesList.FetchCurrencies.Response(
            currencies: currencies,
            error: nil
        )
        presenter?.presentCurrencies(response: response)
    }
}
