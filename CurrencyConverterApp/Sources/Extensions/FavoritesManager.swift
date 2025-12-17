import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "FavoriteCurrencies"
    
    private init() {
        _ = favoriteCodes
    }
    
    func isFavorite(_ code: String) -> Bool {
        favoriteCodes.contains(code)
    }
    
    func toggleFavorite(_ code: String) {
        var codes = favoriteCodes
        
        if let index = codes.firstIndex(of: code) {
            codes.remove(at: index)
        } else {
            codes.append(code)
        }
        
        favoriteCodes = codes
    }
    
    var favoriteCodes: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favoritesKey)
        }
    }
    
    func sortedCurrencies(_ allCurrencies: [Currency]) -> [Currency] {
        let favorites = allCurrencies.filter { favoriteCodes.contains($0.code) }
            .sorted {
                guard let i1 = favoriteCodes.firstIndex(of: $0.code),
                      let i2 = favoriteCodes.firstIndex(of: $1.code) else { return false }
                return i1 < i2
            }
        
        let others = allCurrencies.filter { !favoriteCodes.contains($0.code) }
            .sorted { $0.code < $1.code }
        
        return favorites + others
    }
}
