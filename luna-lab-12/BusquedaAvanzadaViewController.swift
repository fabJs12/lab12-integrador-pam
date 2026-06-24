import UIKit
import SwiftUI
import CoreData

class BusquedaAvanzadaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private var tableView: UITableView!
    
    // Filter controls
    private var txtPrecioMin: UITextField!
    private var txtPrecioMax: UITextField!
    private var txtDni: UITextField!
    private var txtTotalMin: UITextField!

    // In-memory data
    private var allProducts: [Producto] = []
    private var allClients: [Cliente] = []
    private var allSales: [Venta] = []

    // Filter values
    private var precioMin: Double = 0.0
    private var precioMax: Double = Double.greatestFiniteMagnitude
    private var dniQuery: String = ""
    private var totalMin: Double = 0.0

    private var filteredProducts: [Producto] {
        return allProducts.filter { prod in
            let price = prod.precio
            let matchesMin = price >= precioMin
            let matchesMax = price <= precioMax
            return matchesMin && matchesMax
        }
    }

    private var filteredClients: [Cliente] {
        return allClients.filter { clie in
            dniQuery.isEmpty || (clie.dni ?? "").localizedCaseInsensitiveContains(dniQuery)
        }
    }

    private var filteredSales: [Venta] {
        return allSales.filter { vent in
            vent.total >= totalMin
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
    }

    private func configureUI() {
        title = "Búsqueda Avanzada"
        view.backgroundColor = .systemGroupedBackground

        // Setup filter header panel
        let filterHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        filterHeader.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        filterHeader.addSubview(stackView)

        // Prices row (Min & Max)
        let priceStack = UIStackView()
        priceStack.axis = .horizontal
        priceStack.spacing = 8
        priceStack.distribution = .fillEqually

        txtPrecioMin = createTextField(placeholder: "Precio Min (S/.)", keyboardType: .decimalPad)
        txtPrecioMax = createTextField(placeholder: "Precio Max (S/.)", keyboardType: .decimalPad)
        priceStack.addArrangedSubview(txtPrecioMin)
        priceStack.addArrangedSubview(txtPrecioMax)

        // Dni textfield
        txtDni = createTextField(placeholder: "Buscar Cliente por DNI", keyboardType: .numberPad)

        // Min Sales Total textfield
        txtTotalMin = createTextField(placeholder: "Ventas total mayor o igual a (S/.)", keyboardType: .decimalPad)

        stackView.addArrangedSubview(priceStack)
        stackView.addArrangedSubview(txtDni)
        stackView.addArrangedSubview(txtTotalMin)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: filterHeader.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: filterHeader.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: filterHeader.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: filterHeader.bottomAnchor, constant: -12)
        ])

        // Setup TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = filterHeader
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 8
        tf.keyboardType = keyboardType
        tf.delegate = self
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 36))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return tf
    }

    private func fetchData() {
        do {
            allProducts = try CoreDataManager.shared.fetchProductos()
            allClients = try CoreDataManager.shared.fetchClientes()
            allSales = try CoreDataManager.shared.fetchVentas()
            tableView.reloadData()
        } catch {
            print("Error pre-fetching search data: \(error.localizedDescription)")
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == txtPrecioMin {
            precioMin = Double(textField.text ?? "") ?? 0.0
        } else if textField == txtPrecioMax {
            let maxStr = textField.text ?? ""
            precioMax = maxStr.isEmpty ? Double.greatestFiniteMagnitude : (Double(maxStr) ?? Double.greatestFiniteMagnitude)
        } else if textField == txtDni {
            let filtered = (textField.text ?? "").filter { $0.isNumber }
            txtDni.text = String(filtered.prefix(8))
            dniQuery = txtDni.text ?? ""
        } else if textField == txtTotalMin {
            totalMin = Double(textField.text ?? "") ?? 0.0
        }
        
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return min(5, filteredProducts.count)
        case 1: return min(5, filteredClients.count)
        case 2: return min(5, filteredSales.count)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Productos Encontrados (Máx. 5)"
        case 1: return "Clientes Encontrados (Máx. 5)"
        case 2: return "Ventas Encontradas (Máx. 5)"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            let product = filteredProducts[indexPath.row]
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.nombre ?? "Sin Nombre")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text(product.categoria ?? "Otros")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "S/. %.2f", product.precio))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            } else {
                cell.textLabel?.text = product.nombre
                cell.detailTextLabel?.text = String(format: "S/. %.2f", product.precio)
            }
            
        case 1:
            let client = filteredClients[indexPath.row]
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(client.nombres ?? "") \(client.apellidos ?? "")")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text("DNI: \(client.dni ?? "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            } else {
                cell.textLabel?.text = "\(client.nombres ?? "") \(client.apellidos ?? "")"
                cell.detailTextLabel?.text = "DNI: \(client.dni ?? "")"
            }
            
        case 2:
            let sale = filteredSales[indexPath.row]
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Venta a: \(sale.cliente?.nombres ?? "General")")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text("Cant: \(sale.cantidad) unidades")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "S/. %.2f", sale.total))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                cell.textLabel?.text = "Venta: \(sale.idVenta?.suffix(6) ?? "")"
                cell.detailTextLabel?.text = String(format: "S/. %.2f", sale.total)
            }
            
        default:
            break
        }

        return cell
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
