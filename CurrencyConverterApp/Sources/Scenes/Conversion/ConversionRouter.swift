import UIKit

protocol ConversionRoutingLogic {
    func routeToCurrenciesList(for selection: Conversion.CurrencySelection)
}

protocol ConversionDataPassing {
    var dataStore: ConversionDataStore? { get }
}

class ConversionRouter: ConversionRoutingLogic, ConversionDataPassing {
    
    weak var viewController: ConversionViewController?
    var dataStore: ConversionDataStore?
    
    func routeToCurrenciesList(for selection: Conversion.CurrencySelection) {
        dataStore?.selectedCurrencyType = selection
        
        let listVC = CurrenciesListViewController()
        
        listVC.onCurrencySelected = { [weak viewController, dataStore] currency in
            if dataStore?.selectedCurrencyType == .from {
                viewController?.updateFromCurrency(currency)
            } else {
                viewController?.updateToCurrency(currency)
            }
        }
        
        viewController?.navigationController?.pushViewController(listVC, animated: true)
    }
}
