import Foundation

class CacheManager {
    static var shared = CacheManager()
    
    private let currenciesKey = "CachedCurrencies"
    private let ratesKey = "CachedRates"
    private let ratesTimestampKey = "RatesTimestamp"
    private let cacheValidityHours = 1.0
    
    init() {}
    
    func saveCurrencies(_ currencies: [Currency]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(currencies) {
            UserDefaults.standard.set(encoded, forKey: currenciesKey)
        }
    }
    
    func loadCurrencies() -> [Currency]? {
        guard let data = UserDefaults.standard.data(forKey: currenciesKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Currency].self, from: data)
    }
    
    func saveRates(_ rates: ExchangeRates) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(rates) {
            UserDefaults.standard.set(encoded, forKey: ratesKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: ratesTimestampKey)
        }
    }
    
    func loadValidRates() -> ExchangeRates? {
        guard let timestamp = UserDefaults.standard.object(forKey: ratesTimestampKey) as? TimeInterval else { return nil }
        let age = Date().timeIntervalSince1970 - timestamp
        if age > cacheValidityHours * 3600 { return nil }
        
        guard let data = UserDefaults.standard.data(forKey: ratesKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(ExchangeRates.self, from: data)
    }
}
