import Foundation

protocol CurrenciesListBusinessLogic {
    func fetchCurrencies(request: CurrenciesList.FetchCurrencies.Request)
}

protocol CurrenciesListDataStore: AnyObject {
    var selectedCurrency: Currency? { get set }
}

class CurrenciesListInteractor: CurrenciesListBusinessLogic, CurrenciesListDataStore {
    
    var presenter: CurrenciesListPresentationLogic?
    var worker = CurrencyAPIWorker()
    
    var selectedCurrency: Currency?
    
    func fetchCurrencies(request: CurrenciesList.FetchCurrencies.Request) {
        worker.fetchSupportedCurrencies { result in
            switch result {
            case .success(let currencies):
                let response = CurrenciesList.FetchCurrencies.Response(
                    currencies: currencies,
                    error: nil
                )
                self.presenter?.presentCurrencies(response: response)
                
            case .failure(let error):
                let response = CurrenciesList.FetchCurrencies.Response(
                    currencies: [],
                    error: error
                )
                self.presenter?.presentCurrencies(response: response)
            }
        }
    }
}
