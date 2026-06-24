import UIKit
import SwiftUI

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Deselect any selected row in tableView
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func configureUI() {
        title = "Menú Principal"
        view.backgroundColor = .systemGroupedBackground

        // Add Logout button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        // Hide back button on menu
        navigationItem.hidesBackButton = true

        // Initialize TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func logoutTapped() {
        logout()
    }

    private func logout() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Productos, Clientes
        case 1: return 4 // Registro de Ventas, Ubicación y Mapa, Reportes, Búsqueda Avanzada
        case 2: return 1 // Configuración y Acerca de
        case 3: return 1 // Cerrar Sesión
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Módulos de Gestión"
        case 1: return "Operaciones e Informes"
        case 2: return "Ajustes"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuCell")
        cell.accessoryType = .disclosureIndicator

        var titleStr = ""
        var iconName = ""
        var iconColor: UIColor = .systemBlue

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            titleStr = "Productos"
            iconName = "cart.fill"
            iconColor = .systemBlue
        case (0, 1):
            titleStr = "Clientes"
            iconName = "person.2.fill"
            iconColor = .systemTeal
        case (1, 0):
            titleStr = "Registro de Ventas"
            iconName = "dollarsign.circle.fill"
            iconColor = .systemGreen
        case (1, 1):
            titleStr = "Ubicación y Mapa"
            iconName = "map.fill"
            iconColor = .systemOrange
        case (1, 2):
            titleStr = "Reportes"
            iconName = "chart.bar.xaxis"
            iconColor = .systemPurple
        case (1, 3):
            titleStr = "Búsqueda Avanzada"
            iconName = "magnifyingglass.circle.fill"
            iconColor = .systemBlue
        case (2, 0):
            titleStr = "Configuración y Acerca de"
            iconName = "gearshape.fill"
            iconColor = .systemGray
        case (3, 0):
            titleStr = "Cerrar Sesión"
            iconName = "power"
            iconColor = .systemRed
            cell.accessoryType = .none
        default:
            break
        }

        var content = cell.defaultContentConfiguration()
        content.text = titleStr
        content.image = UIImage(systemName: iconName)
        content.imageProperties.tintColor = iconColor
        
        if indexPath.section == 3 {
            content.textProperties.color = .systemRed
            content.textProperties.font = .systemFont(ofSize: 16, weight: .bold)
            content.textProperties.alignment = .center
        } else {
            content.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            performSegue(withIdentifier: "segueMenuToProductos", sender: self)
        case (0, 1):
            performSegue(withIdentifier: "segueMenuToClientes", sender: self)
        case (1, 0):
            performSegue(withIdentifier: "segueMenuToVentas", sender: self)
        case (1, 1):
            performSegue(withIdentifier: "segueMenuToMapa", sender: self)
        case (1, 2):
            performSegue(withIdentifier: "segueMenuToReportes", sender: self)
        case (1, 3):
            performSegue(withIdentifier: "segueMenuToBusqueda", sender: self)
        case (2, 0):
            performSegue(withIdentifier: "segueMenuToConfiguracion", sender: self)
        case (3, 0):
            logout()
        default:
            break
        }
    }
}
