import UIKit

protocol ConversionDisplayLogic: AnyObject {
    func displayRates(viewModel: Conversion.FetchRates.ViewModel)
    func displayConversion(viewModel: Conversion.PerformConversion.ViewModel)
}

class ConversionViewController: UIViewController, ConversionDisplayLogic {
    
    var interactor: ConversionBusinessLogic?
    var router: (ConversionRoutingLogic & ConversionDataPassing)?
    
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
            
            performConversionIfPossible()
    }
    
    private func setupUI() {
        title = "Conversor de Moedas"
        view.backgroundColor = .systemBackground
        
        let fromCard = createConversionCard(isFrom: true)
        let toCard = createConversionCard(isFrom: false)
        
        let swapButton = UIButton(type: .system)
        swapButton.setImage(UIImage(systemName: "arrow.up.arrow.down.circle.fill"), for: .normal)
        swapButton.tintColor = .white
        swapButton.backgroundColor = .systemBlue
        swapButton.layer.cornerRadius = 28
        swapButton.addTarget(self, action: #selector(swapCurrencies), for: .touchUpInside)
        
        let mainStack = UIStackView(arrangedSubviews: [fromCard, swapButton, toCard])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            swapButton.widthAnchor.constraint(equalToConstant: 56),
            swapButton.heightAnchor.constraint(equalToConstant: 56),
            
            fromCard.heightAnchor.constraint(equalToConstant: 100),
            toCard.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        setupKeyboardToolbar()
    }

    private func createConversionCard(isFrom: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemGray5
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let currencyButton = isFrom ? fromButton : toButton
        let valueView = isFrom ? amountTextField : resultLabel
        
        currencyButton.setTitle(isFrom ? fromCurrency.code : toCurrency.code, for: .normal)
        currencyButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        currencyButton.setTitleColor(.systemBlue, for: .normal)
        currencyButton.backgroundColor = .clear
        currencyButton.contentHorizontalAlignment = .left
        
        let stack = UIStackView(arrangedSubviews: [currencyButton, valueView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            
            currencyButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        if isFrom {
            amountTextField.placeholder = "Valor"
            amountTextField.font = .systemFont(ofSize: 30, weight: .semibold)
            amountTextField.textAlignment = .right
            amountTextField.keyboardType = .decimalPad
            amountTextField.textColor = .label
            amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        } else {
            resultLabel.font = .systemFont(ofSize: 30, weight: .semibold)
            resultLabel.textAlignment = .right
            resultLabel.textColor = .systemBlue
            resultLabel.text = "0.00"
        }
        
        currencyButton.addTarget(self, action: isFrom ? #selector(selectFromCurrency) : #selector(selectToCurrency), for: .touchUpInside)
        
        return card
    }

    @objc private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        fromButton.setTitle(fromCurrency.code, for: .normal)
        toButton.setTitle(toCurrency.code, for: .normal)
        
        if let fromCard = fromButton.superview?.superview,
           let toCard = toButton.superview?.superview {
            UIView.transition(with: fromCard, duration: 0.35, options: .transitionFlipFromLeft, animations: nil)
            UIView.transition(with: toCard, duration: 0.35, options: .transitionFlipFromRight, animations: nil)
        }
        
        performConversionIfPossible()
    }
    private func createCurrencyStack(currencyButton: UIButton, valueField: UIView, currency: Currency, isEditable: Bool) -> UIStackView {
        currencyButton.setTitle(currency.code, for: .normal)
        currencyButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        currencyButton.backgroundColor = .secondarySystemBackground
        currencyButton.layer.cornerRadius = 12
        
        if let textField = valueField as? UITextField, isEditable {
            textField.isEnabled = true
        } else if let label = valueField as? UILabel {
            label.text = "0.00"
        }
        
        valueField.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [currencyButton, valueField])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        
        currencyButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        valueField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return stack
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
    
    private func performConversionIfPossible() {
        let cleanedText = amountTextField.text?
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        
        guard let text = cleanedText, !text.isEmpty,
              let amount = Double(text), amount > 0 else {
            resultLabel.text = "0.00"
            return
        }
        
        let request = Conversion.PerformConversion.Request(
            amount: amount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency
        )
        interactor?.performConversion(request: request)
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "OK", style: .prominent, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexSpace, doneButton]
        
        amountTextField.inputAccessoryView = toolbar
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
    
    @objc private func doneButtonTapped() {
        amountTextField.resignFirstResponder()
        performConversionIfPossible()
    }
    
    @objc private func textFieldDidChange() {
        performConversionIfPossible()
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
    
    func updateFromCurrency(_ currency: Currency) {
        fromCurrency = currency
        fromButton.setTitle(currency.code, for: .normal)
        performConversionIfPossible()
    }

    func updateToCurrency(_ currency: Currency) {
        toCurrency = currency
        toButton.setTitle(currency.code, for: .normal)
        resultLabel.text = "0.00"
        performConversionIfPossible()
    }
}
