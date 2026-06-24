import UIKit
import SwiftUI
import CoreData

class ProductoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    private var tableView: UITableView!
    private var searchController: UISearchController!
    
    // Filtering states
    private var selectedCategory: String = "Todos"
    private var selectedStockFilter: StockFilter = .todos
    private var searchText: String = ""

    private let categories = ["Todos", "Electrónicos", "Ropa", "Hogar", "Alimentos", "Otros"]
    
    enum StockFilter: String, CaseIterable {
        case todos = "Todos"
        case bajoStock = "Bajo Stock (< 5)"
        case conStock = "Con Stock (> 0)"
        case sinStock = "Sin Stock (0)"
    }

    private var allProducts: [Producto] = []
    
    // Selection mode callback
    var onProductSelected: ((Producto) -> Void)?

    var isSelectionMode: Bool {
        return onProductSelected != nil
    }

    private var filteredProducts: [Producto] {
        return allProducts.filter { prod in
            let coincideNombre = searchText.isEmpty || (prod.nombre ?? "").localizedCaseInsensitiveContains(searchText)
            let coincideCategoria = selectedCategory == "Todos" || prod.categoria == selectedCategory
            
            let coincideStock: Bool
            switch selectedStockFilter {
            case .todos:
                coincideStock = true
            case .bajoStock:
                coincideStock = prod.stock < 5
            case .conStock:
                coincideStock = prod.stock > 0
            case .sinStock:
                coincideStock = prod.stock == 0
            }
            
            return coincideNombre && coincideCategoria && coincideStock
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
        title = isSelectionMode ? "Seleccionar Producto" : "Productos"
        view.backgroundColor = .systemBackground

        // Setup Buttons and Filter Bar
        let filterStackView = UIStackView()
        filterStackView.axis = .horizontal
        filterStackView.distribution = .fillEqually
        filterStackView.spacing = 16
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterStackView)

        // Setup Category Button with UIMenu
        let categoryButton = UIButton(type: .system)
        categoryButton.setTitle("Categoría: Todos", for: .normal)
        categoryButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        categoryButton.semanticContentAttribute = .forceRightToLeft
        categoryButton.backgroundColor = .systemGray6
        categoryButton.layer.cornerRadius = 8
        categoryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        setupCategoryMenu(button: categoryButton)
        filterStackView.addArrangedSubview(categoryButton)

        // Setup Stock Button with UIMenu
        let stockButton = UIButton(type: .system)
        stockButton.setTitle("Stock: Todos", for: .normal)
        stockButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        stockButton.semanticContentAttribute = .forceRightToLeft
        stockButton.backgroundColor = .systemGray6
        stockButton.layer.cornerRadius = 8
        stockButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        setupStockMenu(button: stockButton)
        filterStackView.addArrangedSubview(stockButton)

        // Setup TableView
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductoCell")
        view.addSubview(tableView)

        // Constraints
        NSLayoutConstraint.activate([
            filterStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterStackView.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Add Product button if not in selection mode
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
        searchController.searchBar.placeholder = "Buscar producto por nombre"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupCategoryMenu(button: UIButton) {
        let actions = categories.map { cat in
            UIAction(title: cat, state: cat == selectedCategory ? .on : .off) { [weak self] action in
                self?.selectedCategory = cat
                button.setTitle("Cat: \(cat)", for: .normal)
                self?.setupCategoryMenu(button: button)
                self?.tableView.reloadData()
            }
        }
        button.menu = UIMenu(title: "Seleccionar Categoría", children: actions)
        button.showsMenuAsPrimaryAction = true
    }

    private func setupStockMenu(button: UIButton) {
        let actions = StockFilter.allCases.map { filter in
            UIAction(title: filter.rawValue, state: filter == selectedStockFilter ? .on : .off) { [weak self] action in
                self?.selectedStockFilter = filter
                button.setTitle("Stock: \(filter.rawValue)", for: .normal)
                self?.setupStockMenu(button: button)
                self?.tableView.reloadData()
            }
        }
        button.menu = UIMenu(title: "Filtrar por Inventario", children: actions)
        button.showsMenuAsPrimaryAction = true
    }

    private func fetchData() {
        do {
            allProducts = try CoreDataManager.shared.fetchProductos()
            tableView.reloadData()
        } catch {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }

    @objc private func agregarTapped() {
        performSegue(withIdentifier: "segueProductoToForm", sender: nil)
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath)
        let product = filteredProducts[indexPath.row]

        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                ProductoCellView(producto: product)
            }
        } else {
            cell.textLabel?.text = product.nombre
            cell.detailTextLabel?.text = String(format: "S/. %.2f - Stock: %d", product.precio, product.stock)
        }
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = filteredProducts[indexPath.row]

        if let selectionCallback = onProductSelected {
            selectionCallback(product)
        } else {
            performSegue(withIdentifier: "segueProductoToDetail", sender: product)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueProductoToDetail" {
            if let detailVC = segue.destination as? ProductoDetailViewController,
               let product = sender as? Producto {
                detailVC.producto = product
            }
        } else if segue.identifier == "segueProductoToForm" {
            if let formVC = segue.destination as? ProductoFormViewController {
                formVC.producto = sender as? Producto
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSelectionMode // disable deletion in selection mode
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = filteredProducts[indexPath.row]
            do {
                try CoreDataManager.shared.deleteProducto(producto: product)
                // Remove from local array
                if let index = allProducts.firstIndex(where: { $0.idProducto == product.idProducto }) {
                    allProducts.remove(at: index)
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
struct ProductoCellView: View {
    @ObservedObject var producto: Producto
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(colorDeStock(producto.stock))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(producto.nombre ?? "Sin Nombre")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(producto.codigo ?? "N/A")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(producto.categoria ?? "Otros")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "S/. %.2f", producto.precio))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Stock: \(producto.stock)")
                    .font(.caption2)
                    .foregroundColor(producto.stock < 5 ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorDeStock(_ stock: Int64) -> Color {
        if stock == 0 {
            return .red
        } else if stock < 5 {
            return .orange
        } else {
            return .green
        }
    }
}
