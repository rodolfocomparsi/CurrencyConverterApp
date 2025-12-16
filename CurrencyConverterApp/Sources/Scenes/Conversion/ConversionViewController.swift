import UIKit

protocol ConversionDisplayLogic: AnyObject {
    func displayRates(viewModel: Conversion.FetchRates.ViewModel)
    func displayConversion(viewModel: Conversion.PerformConversion.ViewModel)
}

class ConversionViewController: UIViewController, ConversionDisplayLogic {
    
    var interactor: ConversionBusinessLogic?
    var router: (ConversionRoutingLogic & ConversionDataPassing)?
    
    // UI Elements
    private let fromButton = UIButton(type: .system)
    private let toButton = UIButton(type: .system)
    private let amountTextField = UITextField()
    private let resultLabel = UILabel()
    private let convertButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var fromCurrency = Currency(code: "USD", name: "United States Dollar")
    private var toCurrency = Currency(code: "BRL", name: "Brazilian Real")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVIP()
        fetchLiveRates()
    }
    
    private func setupUI() {
        title = "Conversor de Moedas"
        view.backgroundColor = .systemBackground
        
        // Botões de moeda
        fromButton.setTitle("De: \(fromCurrency.code)", for: .normal)
        fromButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        fromButton.addTarget(self, action: #selector(selectFromCurrency), for: .touchUpInside)
        
        toButton.setTitle("Para: \(toCurrency.code)", for: .normal)
        toButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        toButton.addTarget(self, action: #selector(selectToCurrency), for: .touchUpInside)
        
        // Campo de valor
        amountTextField.placeholder = "Digite o valor"
        amountTextField.keyboardType = .decimalPad
        amountTextField.borderStyle = .roundedRect
        amountTextField.font = .systemFont(ofSize: 18)
        
        // Resultado
        resultLabel.text = "0.00 \(toCurrency.code)"
        resultLabel.font = .boldSystemFont(ofSize: 28)
        resultLabel.textAlignment = .center
        
        // Botão converter
        convertButton.setTitle("Converter", for: .normal)
        convertButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        convertButton.backgroundColor = .systemBlue
        convertButton.setTitleColor(.white, for: .normal)
        convertButton.layer.cornerRadius = 8
        convertButton.addTarget(self, action: #selector(performConversion), for: .touchUpInside)
        
        // Loading
        activityIndicator.hidesWhenStopped = true
        
        // Layout
        let stack = UIStackView(arrangedSubviews: [fromButton, toButton, amountTextField, convertButton, resultLabel, activityIndicator])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        amountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        convertButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupVIP() {
        let presenter = ConversionPresenter()
        let interactor = ConversionInteractor()
        let router = ConversionRouter()
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
        
        self.interactor = interactor
        self.router = router
    }
    
    private func fetchLiveRates() {
        activityIndicator.startAnimating()
        let request = Conversion.FetchRates.Request()
        interactor?.fetchLiveRates(request: request)
    }
    
    @objc private func selectFromCurrency() {
        router?.routeToCurrenciesList(for: .from)
    }

    @objc private func selectToCurrency() {
        router?.routeToCurrenciesList(for: .to)
    }
    
    @objc private func performConversion() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText), amount > 0 else {
            resultLabel.text = "Valor inválido"
            return
        }
        
        activityIndicator.startAnimating()
        let request = Conversion.PerformConversion.Request(
            amount: amount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency
        )
        interactor?.performConversion(request: request)
    }
    
    // MARK: - Display Logic
    func displayRates(viewModel: Conversion.FetchRates.ViewModel) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if let error = viewModel.errorMessage {
                let alert = UIAlertController(title: "Erro ao carregar taxas", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tentar Novamente", style: .default) { _ in self.fetchLiveRates() })
                self.present(alert, animated: true)
            }
        }
    }
    
    func displayConversion(viewModel: Conversion.PerformConversion.ViewModel) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if let error = viewModel.errorMessage {
                let alert = UIAlertController(title: "Erro na conversão", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                self.resultLabel.text = viewModel.convertedText
            }
        }
    }
    
    // Funções auxiliares para atualizar botões (chamadas pelo Router)
    func updateFromCurrency(_ currency: Currency) {
        fromCurrency = currency
        fromButton.setTitle("De: \(currency.code)", for: .normal)
    }
    
    func updateToCurrency(_ currency: Currency) {
        toCurrency = currency
        toButton.setTitle("Para: \(currency.code)", for: .normal)
        resultLabel.text = "0.00 \(currency.code)"
    }
}
