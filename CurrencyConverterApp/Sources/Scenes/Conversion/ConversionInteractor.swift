import Foundation

protocol ConversionBusinessLogic {
    func fetchLiveRates(request: Conversion.FetchRates.Request)
    func performConversion(request: Conversion.PerformConversion.Request)
}

protocol ConversionDataStore {
    var liveRates: ExchangeRates? { get set }
    var selectedCurrencyType: Conversion.CurrencySelection? { get set }
}

class ConversionInteractor: ConversionBusinessLogic, ConversionDataStore {
    
    var presenter: ConversionPresentationLogic?
    var worker = CurrencyAPIWorker()
    
    var liveRates: ExchangeRates?
    var selectedCurrencyType: Conversion.CurrencySelection?
    
    func fetchLiveRates(request: Conversion.FetchRates.Request) {
        if let cachedRates = CacheManager.shared.loadValidRates() {
            liveRates = cachedRates
            let response = Conversion.FetchRates.Response(rates: cachedRates, error: nil)
            presenter?.presentFetchedRates(response: response)
        }
        
        worker.fetchLiveRates { result in
            switch result {
            case .success(let rates):
                CacheManager.shared.saveRates(rates)
                self.liveRates = rates
                let response = Conversion.FetchRates.Response(rates: rates, error: nil)
                self.presenter?.presentFetchedRates(response: response)
            case .failure(let error):
                if CacheManager.shared.loadValidRates() == nil {
                    let response = Conversion.FetchRates.Response(rates: nil, error: error)
                    self.presenter?.presentFetchedRates(response: response)
                }
            }
        }
    }
    
    func performConversion(request: Conversion.PerformConversion.Request) {
        guard let rates = liveRates else {
            let response = Conversion.PerformConversion.Response(convertedAmount: nil, rates: nil, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Taxas não carregadas"]), toCurrencyCode: request.toCurrency.code)
            presenter?.presentConversion(response: response)
            return
        }
        
        let fromCode = request.fromCurrency.code
        let toCode = request.toCurrency.code
        
        guard let usdFrom = rates.quotes["USD\(fromCode)"] ?? (fromCode == "USD" ? 1.0 : nil),
              let usdTo = rates.quotes["USD\(toCode)"] ?? (toCode == "USD" ? 1.0 : nil) else {
            let response = Conversion.PerformConversion.Response(convertedAmount: nil, rates: rates, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Moeda não suportada"]), toCurrencyCode: request.toCurrency.code)
            presenter?.presentConversion(response: response)
            return
        }
        
        let converted = request.amount / usdFrom * usdTo
        
        let response = Conversion.PerformConversion.Response(convertedAmount: converted, rates: rates, error: nil, toCurrencyCode: request.toCurrency.code)
        presenter?.presentConversion(response: response)
    }
}
