import UIKit
import SwiftUI

class ConfiguracionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!

    // Settings States
    private var notificacionesActivas = true
    private var updatesActivas = false
    private var faceIdActivo = true

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        title = "Configuración"
        view.backgroundColor = .systemGroupedBackground

        // Table View
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Switch actions
    @objc private func notificacionesChanged(_ sw: UISwitch) {
        notificacionesActivas = sw.isOn
    }

    @objc private func updatesChanged(_ sw: UISwitch) {
        updatesActivas = sw.isOn
    }

    @objc private func securityChanged(_ sw: UISwitch) {
        faceIdActivo = sw.isOn
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Notificaciones push, updates
        case 1: return 1 // Face ID
        case 2: return 1 // Acerca de (SwiftUI Card)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Notificaciones"
        case 1: return "Seguridad y Acceso"
        case 2: return "Acerca de la Aplicación"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingCell")
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            let sw = UISwitch()
            if indexPath.row == 0 {
                cell.textLabel?.text = "Notificaciones Push"
                sw.isOn = notificacionesActivas
                sw.addTarget(self, action: #selector(notificacionesChanged(_:)), for: .valueChanged)
            } else {
                cell.textLabel?.text = "Actualizaciones Automáticas"
                sw.isOn = updatesActivas
                sw.addTarget(self, action: #selector(updatesChanged(_:)), for: .valueChanged)
            }
            cell.accessoryView = sw
            cell.textLabel?.font = .systemFont(ofSize: 16)
            
        case 1:
            let sw = UISwitch()
            cell.textLabel?.text = "Usar Face ID / Touch ID"
            sw.isOn = faceIdActivo
            sw.addTarget(self, action: #selector(securityChanged(_:)), for: .valueChanged)
            cell.accessoryView = sw
            cell.textLabel?.font = .systemFont(ofSize: 16)
            
        case 2:
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    ConfigAboutCellView()
                }
            } else {
                cell.textLabel?.text = "Luna Lab 12 - v2.0.0"
            }
            
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 110
        }
        return 48
    }
}

// MARK: - SwiftUI Info cell
struct ConfigAboutCellView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "app.badge.fill")
                .font(.system(size: 36))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Luna Lab 12")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Versión 2.0.0 (UIKit Híbrido)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Desarrollado en Tecsup")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
