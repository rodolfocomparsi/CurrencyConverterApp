import UIKit

protocol CurrenciesListRoutingLogic {
    func routeBackWithSelectedCurrency()
}

protocol CurrenciesListDataPassing {
    var dataStore: CurrenciesListDataStore? { get }
}

class CurrenciesListRouter: CurrenciesListRoutingLogic, CurrenciesListDataPassing {
    
    weak var viewController: CurrenciesListViewController?
    var dataStore: CurrenciesListDataStore?
    
    func configureCurrencySelectionCallback(_ callback: @escaping (Currency) -> Void) {
        viewController?.onCurrencySelected = { [weak dataStore] currency in
            dataStore?.selectedCurrency = currency
            callback(currency)
        }
    }
    
    func routeBackWithSelectedCurrency() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
