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
        let formatted = response.convertedAmount.map { String(format: "%.2f", $0) } ?? "0.00"
        let viewModel = Conversion.PerformConversion.ViewModel(
            convertedText: "\(formatted) \(response.rates?.source ?? "USD")",
            errorMessage: response.error?.localizedDescription
        )
        viewController?.displayConversion(viewModel: viewModel)
    }
}
