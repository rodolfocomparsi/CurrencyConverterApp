import UIKit

protocol CurrenciesListDisplayLogic: AnyObject {
    func displayCurrencies(viewModel: CurrenciesList.FetchCurrencies.ViewModel)
}

class CurrenciesListViewController: UIViewController, CurrenciesListDisplayLogic {
    
    var interactor: CurrenciesListBusinessLogic?
    var router: (CurrenciesListRoutingLogic & CurrenciesListDataPassing)?
    
    var displayedCurrencies: [CurrenciesList.FetchCurrencies.ViewModel.DisplayedCurrency] = []
    
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Closure para passar a moeda selecionada de volta (usaremos no router)
    var onCurrencySelected: ((Currency) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVIP()
        fetchCurrencies()
    }
    
    private func setupUI() {
        title = "Selecione uma Moeda"
        view.backgroundColor = .systemBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrencyCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupVIP() {
        let presenter = CurrenciesListPresenter()
        let interactor = CurrenciesListInteractor()
        let router = CurrenciesListRouter()
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
        
        self.interactor = interactor
        self.router = router
    }
    
    private func fetchCurrencies() {
        activityIndicator.startAnimating()
        let request = CurrenciesList.FetchCurrencies.Request()
        interactor?.fetchCurrencies(request: request)
    }
    
    // MARK: - Display Logic
    func displayCurrencies(viewModel: CurrenciesList.FetchCurrencies.ViewModel) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            if let errorMessage = viewModel.errorMessage {
                let alert = UIAlertController(title: "Erro", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tentar Novamente", style: .default) { _ in
                    self.fetchCurrencies()
                })
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            self.displayedCurrencies = viewModel.displayedCurrencies
            self.tableView.reloadData()
        }
    }
}

extension CurrenciesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        let displayed = displayedCurrencies[indexPath.row]
        cell.textLabel?.text = displayed.displayText
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let displayed = displayedCurrencies[indexPath.row]
        let selectedCurrency = Currency(code: displayed.code, name: displayed.name)
        
        // Notifica via closure (configuraremos no router)
        onCurrencySelected?(selectedCurrency)
        
        // Ou usa router se preferir navigation controller
        navigationController?.popViewController(animated: true)
    }
}
