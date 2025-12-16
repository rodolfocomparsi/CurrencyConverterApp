import Foundation

struct Currency {
    let code: String
    let name: String
    
    var displayName: String {
        "\(code) - \(name)"
    }
}

struct ExchangeRates {
    let timestamp: Int
    let source: String
    let quotes: [String: Double]
}
