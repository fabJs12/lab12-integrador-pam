import UIKit
import SwiftUI
import CoreData

class ReportesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!

    // Data fetched from Core Data
    private var totalVentasCount: Int = 0
    private var totalMontoVendido: Double = 0.0
    private var totalClientesCount: Int = 0
    private var productoMenorStockNombre: String = "Ninguno"
    private var productoMenorStockCantidad: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchReportData()
    }

    private func configureUI() {
        title = "Reportes"
        view.backgroundColor = .systemGroupedBackground

        // Table View
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MetricCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchReportData() {
        let context = CoreDataManager.shared.context
        
        do {
            // 1. Sales details
            let sales = try CoreDataManager.shared.fetchVentas()
            totalVentasCount = sales.count
            totalMontoVendido = sales.reduce(0.0) { $0 + $1.total }

            // 2. Customers details
            let customers = try CoreDataManager.shared.fetchClientes()
            totalClientesCount = customers.count

            // 3. Products stock details
            let products = try CoreDataManager.shared.fetchProductos()
            if !products.isEmpty, let minProd = products.min(by: { $0.stock < $1.stock }) {
                productoMenorStockNombre = minProd.nombre ?? "Sin Nombre"
                productoMenorStockCantidad = minProd.stock
            }
            
            tableView.reloadData()
        } catch {
            print("Error loading report metrics: \(error.localizedDescription)")
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath)
        cell.selectionStyle = .none

        var metricTitle = ""
        var metricValue = ""
        var metricSubtitle = ""
        var metricIcon = ""
        var metricColor: Color = .blue

        switch indexPath.row {
        case 0:
            metricTitle = "Monto Total Vendido"
            metricValue = String(format: "S/. %.2f", totalMontoVendido)
            metricSubtitle = "Ingresos brutos acumulados"
            metricIcon = "dollarsign.circle.fill"
            metricColor = .green
        case 1:
            metricTitle = "Ventas Totales"
            metricValue = "\(totalVentasCount)"
            metricSubtitle = "Transacciones procesadas"
            metricIcon = "chart.bar.fill"
            metricColor = .blue
        case 2:
            metricTitle = "Clientes Registrados"
            metricValue = "\(totalClientesCount)"
            metricSubtitle = "Base de datos de clientes"
            metricIcon = "person.3.fill"
            metricColor = .purple
        case 3:
            metricTitle = "Producto con Menor Stock"
            metricValue = productoMenorStockNombre
            metricSubtitle = "Unidades disponibles: \(productoMenorStockCantidad)"
            metricIcon = "exclamationmark.triangle.fill"
            metricColor = productoMenorStockCantidad < 5 ? .red : .orange
        default:
            break
        }

        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                ReporteMetricCellView(
                    title: metricTitle,
                    value: metricValue,
                    subtitle: metricSubtitle,
                    systemIcon: metricIcon,
                    iconColor: metricColor
                )
                .padding(.vertical, 4)
            }
        } else {
            cell.textLabel?.text = "\(metricTitle): \(metricValue)"
            cell.detailTextLabel?.text = metricSubtitle
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - SwiftUI Metric Card Component
struct ReporteMetricCellView: View {
    let title: String
    let value: String
    let subtitle: String
    let systemIcon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: systemIcon)
                    .font(.body)
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}
