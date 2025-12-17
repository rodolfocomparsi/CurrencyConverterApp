import XCTest
@testable import CurrencyConverterApp

final class CurrencyConverterAppTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    func testUSDConversionLogic() {
        let quotes = ["USDBRL": 5.6, "USDEUR": 0.92]
        
        func convert(amount: Double, from: String, to: String) -> Double? {
            let usdFrom = quotes["USD\(from)"] ?? (from == "USD" ? 1.0 : nil)
            let usdTo = quotes["USD\(to)"] ?? (to == "USD" ? 1.0 : nil)
            guard let fromRate = usdFrom, let toRate = usdTo else { return nil }
            return amount / fromRate * toRate
        }
        
        XCTAssertEqual(convert(amount: 560.0, from: "USD", to: "BRL")!, 3136.0, accuracy: 0.01)
        XCTAssertEqual(convert(amount: 100.0, from: "BRL", to: "EUR")!, 16.43, accuracy: 0.01)
    }

    func testConversionUnsupportedCurrency() {
        let quotes = ["USDBRL": 5.6]
        
        func convert(amount: Double, from: String, to: String) -> Double? {
            let usdFrom = quotes["USD\(from)"] ?? (from == "USD" ? 1.0 : nil)
            let usdTo = quotes["USD\(to)"] ?? (to == "USD" ? 1.0 : nil)
            guard let fromRate = usdFrom, let toRate = usdTo else { return nil }
            return amount / fromRate * toRate
        }
        
        XCTAssertNil(convert(amount: 100.0, from: "XYZ", to: "BRL"))
        XCTAssertNil(convert(amount: 100.0, from: "BRL", to: "ABC"))
    }

    func testFavoritesOrderingAndToggle() {
        let currencies = [
            Currency(code: "USD", name: "Dollar"),
            Currency(code: "BRL", name: "Real"),
            Currency(code: "EUR", name: "Euro"),
            Currency(code: "JPY", name: "Yen")
        ]
        
        FavoritesManager.shared.toggleFavorite("EUR")
        FavoritesManager.shared.toggleFavorite("BRL")
        
        let sorted1 = FavoritesManager.shared.sortedCurrencies(currencies)
        
        XCTAssertEqual(sorted1[0].code, "EUR")
        XCTAssertEqual(sorted1[1].code, "BRL")
        XCTAssertTrue(sorted1[2...].map { $0.code }.sorted() == ["JPY", "USD"])
        
        FavoritesManager.shared.toggleFavorite("BRL")
        let sorted2 = FavoritesManager.shared.sortedCurrencies(currencies)
        
        XCTAssertEqual(sorted2[0].code, "EUR")
        XCTAssertTrue(sorted2[1...].map { $0.code }.sorted() == ["BRL", "JPY", "USD"])
    }

    func testCurrencyCache() {
        let currencies = [
            Currency(code: "USD", name: "Dollar"),
            Currency(code: "BRL", name: "Real")
        ]
        
        CacheManager.shared.saveCurrencies(currencies)
        
        let loaded = CacheManager.shared.loadCurrencies()
        
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?[0].code, "USD")
        XCTAssertEqual(loaded?[1].code, "BRL")
    }

    func testRatesCacheValidity() {
        let rates = ExchangeRates(timestamp: 0, source: "USD", quotes: ["USDBRL": 5.6])
        CacheManager.shared.saveRates(rates)
        
        let loaded = CacheManager.shared.loadValidRates()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.quotes["USDBRL"], 5.6)
    }
}

