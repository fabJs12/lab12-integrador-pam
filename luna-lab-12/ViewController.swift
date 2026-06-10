//
//  ViewController.swift
//  luna-lab-12
//
//  Created by piero on 9/06/26.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Setup
    private func configureUI() {
        // Configuraciones iniciales de interfaz
        txtContrasena.isSecureTextEntry = true
    }

    // MARK: - Actions
    
    /// Acción del botón "Ingresar" para validar credenciales y navegar al menú.
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
    
    /// Acción del botón "Registrar" que redirige a la pantalla de Registro de Usuarios.
    @IBAction func registrarTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueLoginToRegister", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLoginToMenu" {
            // Ejemplo de pase de información al controlador destino:
            // if let menuVC = segue.destination as? MenuViewController {
            //     menuVC.usuarioLogueado = txtUsuario.text
            // }
            print("Navegando al Menú Principal")
        } else if segue.identifier == "segueLoginToRegister" {
            // Si fuese necesario inyectar dependencias o delegados en el controlador de registro:
            // if let registroVC = segue.destination as? RegistroUsuarioViewController {
            //     registroVC.delegate = self
            // }
            print("Navegando al Registro de Usuario")
        }
    }
    
    // MARK: - Helpers
    
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
