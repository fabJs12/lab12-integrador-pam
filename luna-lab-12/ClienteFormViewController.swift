import UIKit
import CoreData

class ClienteFormViewController: UIViewController, UITextFieldDelegate {

    var cliente: Cliente?

    // UI Controls
    private var txtDni: UITextField!
    private var txtNombres: UITextField!
    private var txtApellidos: UITextField!
    private var txtTelefono: UITextField!
    private var txtCorreo: UITextField!
    private var txtDireccion: UITextField!
    private var swEstado: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadDataIfEditing()
    }

    private func configureUI() {
        title = cliente == nil ? "Nuevo Cliente" : "Editar Cliente"
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
        stackView.spacing = 14
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Fields
        txtDni = createTextField(placeholder: "DNI (8 dígitos)", keyboardType: .numberPad)
        txtNombres = createTextField(placeholder: "Nombres")
        txtApellidos = createTextField(placeholder: "Apellidos")
        txtTelefono = createTextField(placeholder: "Teléfono", keyboardType: .phonePad)
        txtCorreo = createTextField(placeholder: "Correo Electrónico", keyboardType: .emailAddress)
        txtDireccion = createTextField(placeholder: "Dirección")

        // Estado Row
        let estadoContainer = UIView()
        estadoContainer.backgroundColor = .systemBackground
        estadoContainer.layer.cornerRadius = 10
        estadoContainer.translatesAutoresizingMaskIntoConstraints = false

        let estadoLabel = UILabel()
        estadoLabel.text = "Cliente Activo"
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

        // Add elements to Stack
        stackView.addArrangedSubview(createLabel(text: "IDENTIFICACIÓN"))
        stackView.addArrangedSubview(txtDni)
        stackView.addArrangedSubview(createLabel(text: "NOMBRES Y APELLIDOS"))
        stackView.addArrangedSubview(txtNombres)
        stackView.addArrangedSubview(txtApellidos)
        stackView.addArrangedSubview(createLabel(text: "DATOS DE CONTACTO"))
        stackView.addArrangedSubview(txtTelefono)
        stackView.addArrangedSubview(txtCorreo)
        stackView.addArrangedSubview(txtDireccion)
        stackView.addArrangedSubview(createLabel(text: "ESTADO"))
        stackView.addArrangedSubview(estadoContainer)

        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
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
        tf.autocapitalizationType = (keyboardType == .emailAddress) ? .none : .sentences
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return tf
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }

    private func loadDataIfEditing() {
        if let clie = cliente {
            txtDni.text = clie.dni
            txtNombres.text = clie.nombres
            txtApellidos.text = clie.apellidos
            txtTelefono.text = clie.telefono
            txtCorreo.text = clie.correo
            txtDireccion.text = clie.direccion
            swEstado.isOn = clie.estado

            // DNI cannot be changed once created
            txtDni.isEnabled = false
            txtDni.backgroundColor = .systemGray5
        }
    }

    @objc private func cancelarTapped() {
        dismissOrPop()
    }

    @objc private func guardarTapped() {
        let dni = txtDni.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nombres = txtNombres.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let apellidos = txtApellidos.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let telefono = txtTelefono.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let correo = txtCorreo.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let direccion = txtDireccion.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let estado = swEstado.isOn

        guard !dni.isEmpty else {
            showErrorAlert("El DNI es obligatorio.")
            return
        }
        guard dni.count == 8, dni.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            showErrorAlert("El DNI debe tener exactamente 8 dígitos numéricos.")
            return
        }
        guard !nombres.isEmpty else {
            showErrorAlert("El nombre es obligatorio.")
            return
        }
        guard !apellidos.isEmpty else {
            showErrorAlert("El apellido es obligatorio.")
            return
        }
        guard !telefono.isEmpty else {
            showErrorAlert("El teléfono es obligatorio.")
            return
        }
        guard !correo.isEmpty else {
            showErrorAlert("El correo electrónico es obligatorio.")
            return
        }
        guard correo.contains("@") && correo.contains(".") else {
            showErrorAlert("El formato de correo no es válido.")
            return
        }
        guard !direccion.isEmpty else {
            showErrorAlert("La dirección es obligatoria.")
            return
        }

        do {
            if let clieExistente = cliente {
                try CoreDataManager.shared.updateCliente(
                    cliente: clieExistente,
                    dni: dni,
                    nombres: nombres,
                    apellidos: apellidos,
                    telefono: telefono,
                    correo: correo,
                    direccion: direccion,
                    estado: estado
                )
            } else {
                let idUnico = UUID().uuidString
                _ = try CoreDataManager.shared.createCliente(
                    idCliente: idUnico,
                    dni: dni,
                    nombres: nombres,
                    apellidos: apellidos,
                    telefono: telefono,
                    correo: correo,
                    direccion: direccion,
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

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtDni {
            // Limit to 8 digits
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Only numbers
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return updatedText.count <= 8 && allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
