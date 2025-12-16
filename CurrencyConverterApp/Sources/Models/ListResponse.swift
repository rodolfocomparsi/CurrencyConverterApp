import Foundation

struct ListResponse: Decodable {
    let success: Bool
    let terms: String
    let privacy: String
    let currencies: [String: String]
    let error: APIError?
}

struct LiveResponse: Decodable {
    let success: Bool
    let terms: String
    let privacy: String
    let timestamp: Int
    let source: String
    let quotes: [String: Double]
    let error: APIError?
}

struct APIError: Decodable {
    let code: Int
    let info: String
}
