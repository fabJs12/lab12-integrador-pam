//
//  RegistroUsuarioViewController.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import UIKit

class RegistroUsuarioViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var txtNuevoUsuario: UITextField!
    @IBOutlet weak var txtNuevaContrasena: UITextField!
    @IBOutlet weak var txtNombreCompleto: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Setup
    private func configureUI() {
        txtNuevaContrasena.isSecureTextEntry = true
    }

    // MARK: - Actions
    
    /// Acción del botón "Guardar" que valida los campos, registra al usuario en Core Data y retorna a la pantalla anterior.
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
            // Invoca a CoreDataManager para persistir el nuevo usuario en Core Data
            _ = try CoreDataManager.shared.registrarUsuario(
                nombreUsuario: usuario,
                contrasena: contrasena,
                nombreCompleto: nombreCompleto
            )
            
            // Muestra una alerta de éxito y luego cierra la pantalla
            mostrarAlerta(titulo: "Éxito", mensaje: "El usuario ha sido registrado correctamente.", esError: false) { [weak self] in
                // Regresa a la vista de login mediante pop si está en un navigation stack
                if let navigationController = self?.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    // Si se presentó de manera modal o si se prefiere regresar por Dismiss/Unwind
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            
        } catch {
            mostrarAlerta(titulo: "Error al Registrar", mensaje: error.localizedDescription, esError: true)
        }
    }
    
    // MARK: - Helpers
    
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
