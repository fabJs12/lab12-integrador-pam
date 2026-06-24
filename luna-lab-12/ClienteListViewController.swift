import UIKit
import SwiftUI
import CoreData

class ClienteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    private var tableView: UITableView!
    private var searchController: UISearchController!
    private var segmentedControl: UISegmentedControl!

    private var allClients: [Cliente] = []
    private var searchText: String = ""
    private var selectedStatusFilter: StatusFilter = .todos

    enum StatusFilter: Int {
        case todos = 0
        case activos = 1
        case inactivos = 2
    }

    // Selection mode callback
    var onClienteSelected: ((Cliente) -> Void)?

    var isSelectionMode: Bool {
        return onClienteSelected != nil
    }

    private var filteredClients: [Cliente] {
        return allClients.filter { clie in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let coincideBusqueda = query.isEmpty ||
                (clie.dni ?? "").localizedCaseInsensitiveContains(query) ||
                (clie.nombres ?? "").localizedCaseInsensitiveContains(query) ||
                (clie.apellidos ?? "").localizedCaseInsensitiveContains(query)

            let coincideEstado: Bool
            switch selectedStatusFilter {
            case .todos:
                coincideEstado = true
            case .activos:
                coincideEstado = clie.estado == true
            case .inactivos:
                coincideEstado = clie.estado == false
            }

            return coincideBusqueda && coincideEstado
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func configureUI() {
        title = isSelectionMode ? "Seleccionar Cliente" : "Clientes"
        view.backgroundColor = .systemBackground

        // Segmented Control
        segmentedControl = UISegmentedControl(items: ["Todos", "Activos", "Inactivos"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        // TableView
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ClienteCell")
        view.addSubview(tableView)

        // Constraints
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Add Cliente button if not in selection mode
        if !isSelectionMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(agregarTapped)
            )
        }

        // Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar por DNI, nombres o apellidos"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @objc private func filterChanged() {
        if let filter = StatusFilter(rawValue: segmentedControl.selectedSegmentIndex) {
            selectedStatusFilter = filter
            tableView.reloadData()
        }
    }

    private func fetchData() {
        do {
            allClients = try CoreDataManager.shared.fetchClientes()
            tableView.reloadData()
        } catch {
            print("Error fetching clients: \(error.localizedDescription)")
        }
    }

    @objc private func agregarTapped() {
        performSegue(withIdentifier: "segueClienteToForm", sender: nil)
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClienteCell", for: indexPath)
        let client = filteredClients[indexPath.row]

        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                ClienteCellView(cliente: client)
            }
        } else {
            cell.textLabel?.text = "\(client.nombres ?? "") \(client.apellidos ?? "")"
            cell.detailTextLabel?.text = "DNI: \(client.dni ?? "N/A")"
        }
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let client = filteredClients[indexPath.row]

        if let selectionCallback = onClienteSelected {
            selectionCallback(client)
        } else {
            performSegue(withIdentifier: "segueClienteToDetail", sender: client)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueClienteToDetail" {
            if let detailVC = segue.destination as? ClienteDetailViewController,
               let client = sender as? Cliente {
                detailVC.cliente = client
            }
        } else if segue.identifier == "segueClienteToForm" {
            if let formVC = segue.destination as? ClienteFormViewController {
                formVC.cliente = sender as? Cliente
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSelectionMode
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let client = filteredClients[indexPath.row]
            do {
                try CoreDataManager.shared.deleteCliente(cliente: client)
                // Remove from local array
                if let index = allClients.firstIndex(where: { $0.idCliente == client.idCliente }) {
                    allClients.remove(at: index)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - SwiftUI cell component
struct ClienteCellView: View {
    @ObservedObject var cliente: Cliente

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(cliente.estado ? Color.green : Color.gray)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(cliente.nombres ?? "") \(cliente.apellidos ?? "")")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text("DNI: \(cliente.dni ?? "N/A")")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    if let tel = cliente.telefono, !tel.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Tel: \(tel)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
