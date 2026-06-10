//
//  MenuViewController.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import UIKit
import SwiftUI

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ocultar barra de navegación de UIKit para usar el NavigationStack de SwiftUI
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restaurar la barra de navegación de UIKit al regresar
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Instanciar MainMenuView configurando el callback de logout y el contexto de Core Data
        var mainMenuView = MainMenuView()
        mainMenuView.onLogout = { [weak self] in
            // Lógica para cerrar sesión: regresar a la pantalla de Login
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        // Inyección del contexto de Core Data para soportar @FetchRequest en SwiftUI
        let context = CoreDataManager.shared.context
        let hostedView = mainMenuView.environment(\.managedObjectContext, context)
        
        // 2. Crear el UIHostingController pasando la vista de SwiftUI
        let hostingController = UIHostingController(rootView: hostedView)
        
        // 3. Añadir el HostingController como hijo (Compatibilidad con Mac y jerarquía de vistas UIKit)
        addChild(hostingController)
        
        // 4. Agregar la vista del hostingController al contenedor de UIKit
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        // 5. Aplicar NSLayoutConstraint para que ocupe todo el espacio del contenedor
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 6. Notificar el movimiento del view controller secundario al principal
        hostingController.didMove(toParent: self)
    }
}
