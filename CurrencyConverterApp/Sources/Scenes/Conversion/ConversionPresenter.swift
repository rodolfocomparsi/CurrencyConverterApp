import Foundation

protocol ConversionPresentationLogic {
    func presentFetchedRates(response: Conversion.FetchRates.Response)
    func presentConversion(response: Conversion.PerformConversion.Response)
}

class ConversionPresenter: ConversionPresentationLogic {
    
    weak var viewController: ConversionDisplayLogic?
    
    func presentFetchedRates(response: Conversion.FetchRates.Response) {
        let viewModel = Conversion.FetchRates.ViewModel(
            errorMessage: response.error?.localizedDescription
        )
        viewController?.displayRates(viewModel: viewModel)
    }
    
    func presentConversion(response: Conversion.PerformConversion.Response) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let formatted = response.convertedAmount.map { formatter.string(from: NSNumber(value: $0)) ?? "0,00" } ?? "0,00"

        let viewModel = Conversion.PerformConversion.ViewModel(
            convertedText: formatted,
            errorMessage: response.error?.localizedDescription
        )
        
        viewController?.displayConversion(viewModel: viewModel)
    }
}
