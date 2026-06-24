import UIKit
import SwiftUI
import CoreData

class ClienteDetailViewController: UIViewController {
    var cliente: Cliente?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }

    private func configureUI() {
        title = "Detalle de Cliente"
        view.backgroundColor = .systemBackground

        guard let clie = cliente else { return }

        // Setup Edit Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Editar",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )

        // Clear previous children
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Embed SwiftUI View
        let detailView = ClienteDetailContentView(cliente: clie)
        let hostingVC = UIHostingController(rootView: detailView)

        addChild(hostingVC)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingVC.view)

        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingVC.didMove(toParent: self)
    }

    @objc private func editTapped() {
        performSegue(withIdentifier: "segueDetailToClienteForm", sender: cliente)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailToClienteForm" {
            if let formVC = segue.destination as? ClienteFormViewController {
                formVC.cliente = sender as? Cliente
            }
        }
    }
}

// MARK: - SwiftUI Cliente Detail Content View
struct ClienteDetailContentView: View {
    @ObservedObject var cliente: Cliente

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(cliente.nombres ?? "") \(cliente.apellidos ?? "")")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(cliente.estado ? "Activo" : "Inactivo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(cliente.estado ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                            .foregroundColor(cliente.estado ? .green : .gray)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRowView(icon: "doc.text.fill", title: "DNI", value: cliente.dni ?? "N/A")
                    Divider()
                    DetailRowView(icon: "phone.fill", title: "Teléfono", value: cliente.telefono ?? "N/A")
                    Divider()
                    DetailRowView(icon: "envelope.fill", title: "Correo Electrónico", value: cliente.correo ?? "N/A")
                    Divider()
                    DetailRowView(icon: "mappin.and.ellipse", title: "Dirección", value: cliente.direccion ?? "N/A")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
