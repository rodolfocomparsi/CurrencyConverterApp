import Foundation

enum APIWorkerError: Error {
    case invalidURL
    case noData
    case apiError(code: Int, info: String)
    case decodingError
}

class CurrencyAPIWorker {
    
    private let baseURL = "https://api.currencylayer.com"
    private let accessKey = APIKeys.currencyLayer
    
    func fetchSupportedCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list?access_key=\(accessKey)") else {
            completion(.failure(APIWorkerError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIWorkerError.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ListResponse.self, from: data)
                
                if let apiError = decoded.error {
                    completion(.failure(APIWorkerError.apiError(code: apiError.code, info: apiError.info)))
                    return
                }
                
                let currencies = decoded.currencies.map { Currency(code: $0.key, name: $0.value) }
                    .sorted(by: { $0.code < $1.code })
                
                completion(.success(currencies))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchLiveRates(completion: @escaping (Result<ExchangeRates, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/live?access_key=\(accessKey)") else {
            completion(.failure(APIWorkerError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIWorkerError.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(LiveResponse.self, from: data)
                
                if let apiError = decoded.error {
                    completion(.failure(APIWorkerError.apiError(code: apiError.code, info: apiError.info)))
                    return
                }
                
                let rates = ExchangeRates(timestamp: decoded.timestamp,
                                          source: decoded.source,
                                          quotes: decoded.quotes)
                
                completion(.success(rates))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
