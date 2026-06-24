import UIKit
import CoreData

class ProductoFormViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var producto: Producto?

    // UI Controls
    private var txtCodigo: UITextField!
    private var txtNombre: UITextField!
    private var txtCategoria: UITextField!
    private var txtPrecio: UITextField!
    private var txtStock: UITextField!
    private var swEstado: UISwitch!
    
    private var categoryPicker: UIPickerView!
    private let categories = ["Electrónicos", "Ropa", "Hogar", "Alimentos", "Otros"]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadDataIfEditing()
    }

    private func configureUI() {
        title = producto == nil ? "Nuevo Producto" : "Editar Producto"
        view.backgroundColor = .systemGroupedBackground

        // Navigation Bar Buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancelar",
            style: .plain,
            target: self,
            action: #selector(cancelarTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Guardar",
            style: .done,
            target: self,
            action: #selector(guardarTapped)
        )

        // Main StackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Helper to create form fields
        txtCodigo = createTextField(placeholder: "Código (ej. P001)")
        txtNombre = createTextField(placeholder: "Nombre del Producto")
        
        // Category field with Picker Input View
        txtCategoria = createTextField(placeholder: "Categoría")
        categoryPicker = UIPickerView()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        txtCategoria.inputView = categoryPicker
        addDoneButtonToTextField(txtCategoria)

        txtPrecio = createTextField(placeholder: "Precio Unitario (S/.)", keyboardType: .decimalPad)
        txtStock = createTextField(placeholder: "Stock Inicial", keyboardType: .numberPad)

        // Estado Row
        let estadoContainer = UIView()
        estadoContainer.backgroundColor = .systemBackground
        estadoContainer.layer.cornerRadius = 10
        estadoContainer.translatesAutoresizingMaskIntoConstraints = false

        let estadoLabel = UILabel()
        estadoLabel.text = "Producto Activo"
        estadoLabel.font = .systemFont(ofSize: 16)
        estadoLabel.translatesAutoresizingMaskIntoConstraints = false
        estadoContainer.addSubview(estadoLabel)

        swEstado = UISwitch()
        swEstado.isOn = true
        swEstado.translatesAutoresizingMaskIntoConstraints = false
        estadoContainer.addSubview(swEstado)

        NSLayoutConstraint.activate([
            estadoContainer.heightAnchor.constraint(equalToConstant: 50),
            estadoLabel.centerYAnchor.constraint(equalTo: estadoContainer.centerYAnchor),
            estadoLabel.leadingAnchor.constraint(equalTo: estadoContainer.leadingAnchor, constant: 16),
            swEstado.centerYAnchor.constraint(equalTo: estadoContainer.centerYAnchor),
            swEstado.trailingAnchor.constraint(equalTo: estadoContainer.trailingAnchor, constant: -16)
        ])

        // Add to stack
        stackView.addArrangedSubview(createLabel(text: "IDENTIFICACIÓN"))
        stackView.addArrangedSubview(txtCodigo)
        stackView.addArrangedSubview(createLabel(text: "DETALLES DEL PRODUCTO"))
        stackView.addArrangedSubview(txtNombre)
        stackView.addArrangedSubview(txtCategoria)
        stackView.addArrangedSubview(createLabel(text: "PRECIO E INVENTARIO"))
        stackView.addArrangedSubview(txtPrecio)
        stackView.addArrangedSubview(txtStock)
        stackView.addArrangedSubview(createLabel(text: "ESTADO"))
        stackView.addArrangedSubview(estadoContainer)

        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.keyboardType = keyboardType
        tf.delegate = self
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }

    private func addDoneButtonToTextField(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(pickerDoneTapped))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }

    @objc private func pickerDoneTapped() {
        txtCategoria.resignFirstResponder()
    }

    private func loadDataIfEditing() {
        if let prod = producto {
            txtCodigo.text = prod.codigo
            txtNombre.text = prod.nombre
            txtCategoria.text = prod.categoria
            txtPrecio.text = String(format: "%.2f", prod.precio)
            txtStock.text = "\(prod.stock)"
            swEstado.isOn = prod.estado
            
            // Code field is not editable during update
            txtCodigo.isEnabled = false
            txtCodigo.backgroundColor = .systemGray5
            
            if let index = categories.firstIndex(of: prod.categoria ?? "") {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    @objc private func cancelarTapped() {
        dismissOrPop()
    }

    @objc private func guardarTapped() {
        let codigo = txtCodigo.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nombre = txtNombre.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let categoria = txtCategoria.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let precioStr = txtPrecio.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let stockStr = txtStock.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let estado = swEstado.isOn

        guard !codigo.isEmpty else {
            showErrorAlert("El código es obligatorio.")
            return
        }
        guard !nombre.isEmpty else {
            showErrorAlert("El nombre es obligatorio.")
            return
        }
        guard !categoria.isEmpty else {
            showErrorAlert("La categoría es obligatoria.")
            return
        }
        guard let precio = Double(precioStr), precio > 0 else {
            showErrorAlert("El precio debe ser un número estrictamente mayor a 0.")
            return
        }
        guard let stock = Int64(stockStr), stock >= 0 else {
            showErrorAlert("El stock debe ser un número entero mayor o igual a 0.")
            return
        }

        do {
            if let prodExistente = producto {
                try CoreDataManager.shared.updateProducto(
                    producto: prodExistente,
                    codigo: codigo,
                    nombre: nombre,
                    categoria: categoria,
                    precio: precio,
                    stock: stock,
                    estado: estado
                )
            } else {
                let idUnico = UUID().uuidString
                _ = try CoreDataManager.shared.createProducto(
                    idProducto: idUnico,
                    codigo: codigo,
                    nombre: nombre,
                    categoria: categoria,
                    precio: precio,
                    stock: stock,
                    estado: estado
                )
            }
            
            dismissOrPop()
        } catch {
            showErrorAlert(error.localizedDescription)
        }
    }

    private func dismissOrPop() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Validación", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtCategoria.text = categories[row]
    }
}
