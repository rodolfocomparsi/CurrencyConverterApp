import Foundation

enum Conversion {
    
    enum FetchRates {
        struct Request {}
        
        struct Response {
            let rates: ExchangeRates?
            let error: Error?
        }
        
        struct ViewModel {
            let errorMessage: String?
        }
    }
    
    enum PerformConversion {
        struct Request {
            let amount: Double
            let fromCurrency: Currency
            let toCurrency: Currency
        }
        
        struct Response {
            let convertedAmount: Double?
            let rates: ExchangeRates?
            let error: Error?
            let toCurrencyCode: String
        }
        
        struct ViewModel {
            let convertedText: String
            let errorMessage: String?
        }
    }
    
    enum CurrencySelection {
            case from
            case to
        }
}
