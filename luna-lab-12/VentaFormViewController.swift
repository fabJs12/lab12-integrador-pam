import UIKit
import SwiftUI
import CoreData

class VentaFormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct CartItem {
        let producto: Producto
        var cantidad: Int64
        
        var subtotal: Double {
            return producto.precio * Double(cantidad)
        }
    }

    private var selectedCliente: Cliente?
    private var cartItems: [CartItem] = []

    // UI Elements
    private var clienteLabel: UILabel!
    private var selectClienteButton: UIButton!
    private var addProductButton: UIButton!
    private var tableView: UITableView!
    
    private var subtotalLabel: UILabel!
    private var igvLabel: UILabel!
    private var totalLabel: UILabel!
    
    private var saveButton: UIButton!

    private var subtotal: Double {
        return cartItems.reduce(0.0) { $0 + $1.subtotal }
    }
    
    private var igv: Double {
        return subtotal * 0.18
    }
    
    private var total: Double {
        return subtotal + igv
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        title = "Nueva Venta"
        view.backgroundColor = .systemGroupedBackground

        // Top Client Selector Container
        let topContainer = UIView()
        topContainer.backgroundColor = .systemBackground
        topContainer.layer.cornerRadius = 12
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topContainer)

        clienteLabel = UILabel()
        clienteLabel.text = "Cliente: Sin seleccionar"
        clienteLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        clienteLabel.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(clienteLabel)

        selectClienteButton = UIButton(type: .system)
        selectClienteButton.setTitle("Seleccionar Cliente", for: .normal)
        selectClienteButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        selectClienteButton.semanticContentAttribute = .forceLeftToRight
        selectClienteButton.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        selectClienteButton.layer.cornerRadius = 8
        selectClienteButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        selectClienteButton.addTarget(self, action: #selector(selectClienteTapped), for: .touchUpInside)
        selectClienteButton.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(selectClienteButton)

        // Add Product Button
        addProductButton = UIButton(type: .system)
        addProductButton.setTitle("Añadir Producto", for: .normal)
        addProductButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addProductButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        addProductButton.backgroundColor = .systemGreen
        addProductButton.tintColor = .white
        addProductButton.layer.cornerRadius = 10
        addProductButton.addTarget(self, action: #selector(addProductTapped), for: .touchUpInside)
        addProductButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addProductButton)

        // Cart Table View
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CartCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Bottom Summary Container
        let summaryContainer = UIView()
        summaryContainer.backgroundColor = .systemBackground
        summaryContainer.layer.cornerRadius = 16
        summaryContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryContainer)

        let summaryStack = UIStackView()
        summaryStack.axis = .vertical
        summaryStack.spacing = 8
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        summaryContainer.addSubview(summaryStack)

        subtotalLabel = UILabel()
        subtotalLabel.text = "Subtotal: S/. 0.00"
        subtotalLabel.font = .systemFont(ofSize: 14)
        subtotalLabel.textColor = .secondaryLabel
        summaryStack.addArrangedSubview(subtotalLabel)

        igvLabel = UILabel()
        igvLabel.text = "IGV (18%): S/. 0.00"
        igvLabel.font = .systemFont(ofSize: 14)
        igvLabel.textColor = .secondaryLabel
        summaryStack.addArrangedSubview(igvLabel)

        let divider = UIView()
        divider.backgroundColor = .systemGray5
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        summaryStack.addArrangedSubview(divider)

        totalLabel = UILabel()
        totalLabel.text = "Total General: S/. 0.00"
        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.textColor = .systemBlue
        summaryStack.addArrangedSubview(totalLabel)

        // Save Button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Registrar Venta", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 12
        saveButton.addTarget(self, action: #selector(registrarVentaTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topContainer.heightAnchor.constraint(equalToConstant: 80),

            clienteLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            clienteLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 16),
            clienteLabel.trailingAnchor.constraint(equalTo: selectClienteButton.leadingAnchor, constant: -12),

            selectClienteButton.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            selectClienteButton.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -16),

            addProductButton.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 12),
            addProductButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addProductButton.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: addProductButton.bottomAnchor, constant: 4),
            tableView.bottomAnchor.constraint(equalTo: summaryContainer.topAnchor, constant: -12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            summaryContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryContainer.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),

            summaryStack.topAnchor.constraint(equalTo: summaryContainer.topAnchor, constant: 16),
            summaryStack.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: -16),
            summaryStack.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor, constant: 16),
            summaryStack.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor, constant: -16),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateClientLabel() {
        if let clie = selectedCliente {
            clienteLabel.text = "\(clie.apellidos ?? ""), \(clie.nombres ?? "")"
        } else {
            clienteLabel.text = "Cliente: Sin seleccionar"
        }
    }

    private func updateSummaryLabels() {
        subtotalLabel.text = String(format: "Subtotal: S/. %.2f", subtotal)
        igvLabel.text = String(format: "IGV (18%%): S/. %.2f", igv)
        totalLabel.text = String(format: "Total General: S/. %.2f", total)
    }

    @objc private func selectClienteTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let clieListVC = storyboard.instantiateViewController(withIdentifier: "ClienteListVC") as? ClienteListViewController {
            clieListVC.onClienteSelected = { [weak self] cliente in
                self?.selectedCliente = cliente
                self?.updateClientLabel()
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(clieListVC, animated: true)
        }
    }

    @objc private func addProductTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let prodListVC = storyboard.instantiateViewController(withIdentifier: "ProductoListVC") as? ProductoListViewController {
            prodListVC.onProductSelected = { [weak self] producto in
                self?.promptForQuantity(for: producto)
            }
            navigationController?.pushViewController(prodListVC, animated: true)
        }
    }

    private func promptForQuantity(for producto: Producto) {
        let alert = UIAlertController(
            title: "Ingresar Cantidad",
            message: "Stock disponible: \(producto.stock)",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Añadir", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, let qty = Int64(text), qty > 0 else {
                self?.showErrorAlert("Cantidad inválida.")
                return
            }

            guard qty <= producto.stock else {
                self?.showErrorAlert("Stock insuficiente. Disponible: \(producto.stock)")
                return
            }

            self?.addOrUpdateProductInCart(producto: producto, cantidad: qty)
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func addOrUpdateProductInCart(producto: Producto, cantidad: Int64) {
        if let index = cartItems.firstIndex(where: { $0.producto.idProducto == producto.idProducto }) {
            // Validate that new cumulative qty is within stock limits
            let newQty = cartItems[index].cantidad + cantidad
            if newQty <= producto.stock {
                cartItems[index].cantidad = newQty
            } else {
                cartItems[index].cantidad = producto.stock
                showErrorAlert("Se limitó al stock máximo disponible: \(producto.stock)")
            }
        } else {
            cartItems.append(CartItem(producto: producto, cantidad: cantidad))
        }
        
        tableView.reloadData()
        updateSummaryLabels()
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Advertencia", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }

    @objc private func registrarVentaTapped() {
        guard let cliente = selectedCliente else {
            showErrorAlert("Debe seleccionar un cliente.")
            return
        }

        guard !cartItems.isEmpty else {
            showErrorAlert("El carrito de compras está vacío.")
            return
        }

        let idVenta = UUID().uuidString
        let fechaVenta = Date()

        let arrayProductos = cartItems.map { (productoId: $0.producto.idProducto ?? "", cantidad: $0.cantidad) }

        do {
            _ = try CoreDataManager.shared.createVenta(
                idVenta: idVenta,
                fechaVenta: fechaVenta,
                clienteId: cliente.idCliente ?? "",
                productosSeleccionados: arrayProductos
            )
            
            // Pop back to sales list
            navigationController?.popViewController(animated: true)
            
        } catch {
            let alert = UIAlertController(title: "Error al Guardar Venta", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath)
        let item = cartItems[indexPath.row]
        
        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.producto.nombre ?? "Sin Nombre")
                            .font(.headline)
                        Text("Cant: \(item.cantidad) x S/. \(String(format: "%.2f", item.producto.precio))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "S/. %.2f", item.subtotal))
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 4)
            }
        } else {
            cell.textLabel?.text = item.producto.nombre
            cell.detailTextLabel?.text = "Cant: \(item.cantidad) - Subtotal: S/. \(item.subtotal)"
        }
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cartItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateSummaryLabels()
        }
    }
}
