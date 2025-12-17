import Foundation

enum CurrenciesList {
    
    // MARK: - Fetch Currencies
    enum FetchCurrencies {
        struct Request { }
        
        struct Response {
            let currencies: [Currency]?
            let error: Error?
        }
        
        struct ViewModel {
            let displayedCurrencies: [DisplayedCurrency]
            let errorMessage: String?
            
            struct DisplayedCurrency {
                let code: String
                let name: String
                let displayText: String
            }
        }
    }
    
    // MARK: - Toggle Favorite
    enum ToggleFavorite {
        struct Request {
            let currencyCode: String
        }
    }
}
