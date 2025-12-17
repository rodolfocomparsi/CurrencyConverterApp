import Foundation

struct Currency: Encodable, Decodable {
    let code: String
    let name: String
    
    var displayName: String {
        "\(code) - \(name)"
    }
}

struct ExchangeRates: Encodable, Decodable {
    let timestamp: Int
    let source: String
    let quotes: [String: Double]
}
