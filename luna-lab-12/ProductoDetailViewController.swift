import UIKit
import SwiftUI
import CoreData

class ProductoDetailViewController: UIViewController {
    var producto: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }

    private func configureUI() {
        title = "Detalle de Producto"
        view.backgroundColor = .systemBackground

        guard let prod = producto else { return }

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
        let detailView = ProductoDetailContentView(producto: prod)
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
        performSegue(withIdentifier: "segueDetailToProductoForm", sender: producto)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailToProductoForm" {
            if let formVC = segue.destination as? ProductoFormViewController {
                formVC.producto = sender as? Producto
            }
        }
    }
}

// MARK: - SwiftUI Product Detail Content View
struct ProductoDetailContentView: View {
    @ObservedObject var producto: Producto

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Icon
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 90, height: 90)
                        Image(systemName: "cart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)

                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRowView(icon: "tag.fill", title: "Nombre del Producto", value: producto.nombre ?? "Sin Nombre")
                    Divider()
                    DetailRowView(icon: "barcode", title: "Código de Producto", value: producto.codigo ?? "N/A")
                    Divider()
                    DetailRowView(icon: "shippingbox.fill", title: "Categoría", value: producto.categoria ?? "Otros")
                    Divider()
                    DetailRowView(icon: "dollarsign.circle.fill", title: "Precio Unitario", value: String(format: "S/. %.2f", producto.precio))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                // Stock Card
                VStack(spacing: 12) {
                    Text("STOCK DISPONIBLE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text("\(producto.stock)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(colorDeStock(producto.stock))
                    
                    Text(stockStatusText(producto.stock))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(colorDeStock(producto.stock).opacity(0.15))
                        .foregroundColor(colorDeStock(producto.stock))
                        .cornerRadius(20)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func colorDeStock(_ stock: Int64) -> Color {
        if stock == 0 {
            return .red
        } else if stock < 5 {
            return .orange
        } else {
            return .green
        }
    }

    private func stockStatusText(_ stock: Int64) -> String {
        if stock == 0 {
            return "Agotado"
        } else if stock < 5 {
            return "Stock Crítico"
        } else {
            return "Stock Disponible"
        }
    }
}

struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}
