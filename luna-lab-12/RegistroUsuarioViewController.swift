import UIKit

class RegistroUsuarioViewController: UIViewController {

    @IBOutlet weak var txtNuevoUsuario: UITextField!
    @IBOutlet weak var txtNuevaContrasena: UITextField!
    @IBOutlet weak var txtNombreCompleto: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        txtNuevaContrasena.isSecureTextEntry = true
    }

    @IBAction func guardarTapped(_ sender: UIButton) {
        guard let usuario = txtNuevoUsuario.text, !usuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlerta(titulo: "Validación", mensaje: "El campo nuevo usuario es obligatorio.", esError: true)
            return
        }

        guard let contrasena = txtNuevaContrasena.text, !contrasena.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlerta(titulo: "Validación", mensaje: "El campo contraseña es obligatorio.", esError: true)
            return
        }

        guard let nombreCompleto = txtNombreCompleto.text, !nombreCompleto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlerta(titulo: "Validación", mensaje: "El campo nombre completo es obligatorio.", esError: true)
            return
        }

        do {

            _ = try CoreDataManager.shared.registrarUsuario(
                nombreUsuario: usuario,
                contrasena: contrasena,
                nombreCompleto: nombreCompleto
            )

            mostrarAlerta(titulo: "Éxito", mensaje: "El usuario ha sido registrado correctamente.", esError: false) { [weak self] in

                if let navigationController = self?.navigationController {
                    navigationController.popViewController(animated: true)
                } else {

                    self?.dismiss(animated: true, completion: nil)
                }
            }

        } catch {
            mostrarAlerta(titulo: "Error al Registrar", mensaje: error.localizedDescription, esError: true)
        }
    }

    private func mostrarAlerta(titulo: String, mensaje: String, esError: Bool, handler: (() -> Void)? = nil) {
        let alerta = UIAlertController(
            title: titulo,
            message: mensaje,
            preferredStyle: .alert
        )

        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
            handler?()
        }

        alerta.addAction(accionAceptar)
        present(alerta, animated: true, completion: nil)
    }
}
