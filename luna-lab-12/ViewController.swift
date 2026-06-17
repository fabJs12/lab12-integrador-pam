import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {

        txtContrasena.isSecureTextEntry = true
    }

    @IBAction func ingresarTapped(_ sender: UIButton) {
        guard let usuario = txtUsuario.text, !usuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlertaError(mensaje: "El campo usuario es obligatorio.")
            return
        }

        guard let contrasena = txtContrasena.text, !contrasena.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlertaError(mensaje: "El campo contraseña es obligatorio.")
            return
        }

        do {
            let esValido = try CoreDataManager.shared.validarUsuario(nombreUsuario: usuario, contrasena: contrasena)
            if esValido {
                performSegue(withIdentifier: "segueLoginToMenu", sender: self)
            } else {
                mostrarAlertaError(mensaje: "Usuario o contraseña incorrectos.")
            }
        } catch {
            mostrarAlertaError(mensaje: error.localizedDescription)
        }
    }

    @IBAction func registrarTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueLoginToRegister", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLoginToMenu" {

            print("Navegando al Menú Principal")
        } else if segue.identifier == "segueLoginToRegister" {

            print("Navegando al Registro de Usuario")
        }
    }

    private func mostrarAlertaError(mensaje: String) {
        let alerta = UIAlertController(
            title: "Error de Validación",
            message: mensaje,
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
}
