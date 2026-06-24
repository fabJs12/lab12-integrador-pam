import UIKit
import SwiftUI
import CoreData

class VentaDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var venta: Venta?

    private var tableView: UITableView!

    private var detallesArray: [DetalleVenta] {
        guard let set = venta?.detalles as? Set<DetalleVenta> else { return [] }
        return Array(set).sorted { ($0.producto?.nombre ?? "") < ($1.producto?.nombre ?? "") }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        title = "Comprobante"
        view.backgroundColor = .systemGroupedBackground

        // Header view representing a digital ticket header
        let ticketHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 130))
        ticketHeader.backgroundColor = .clear

        let iconImageView = UIImageView(image: UIImage(systemName: "doc.plaintext.fill"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        ticketHeader.addSubview(iconImageView)

        let titleLabel = UILabel()
        titleLabel.text = "Comprobante de Pago"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ticketHeader.addSubview(titleLabel)

        let subtitleBadge = UILabel()
        subtitleBadge.text = "BOLETA ELECTRÓNICA"
        subtitleBadge.font = .systemFont(ofSize: 11, weight: .bold)
        subtitleBadge.textColor = .systemBlue
        subtitleBadge.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        subtitleBadge.textAlignment = .center
        subtitleBadge.layer.cornerRadius = 6
        subtitleBadge.layer.masksToBounds = true
        subtitleBadge.translatesAutoresizingMaskIntoConstraints = false
        ticketHeader.addSubview(subtitleBadge)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: ticketHeader.topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: ticketHeader.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: ticketHeader.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: ticketHeader.trailingAnchor, constant: -16),

            subtitleBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleBadge.centerXAnchor.constraint(equalTo: ticketHeader.centerXAnchor),
            subtitleBadge.widthAnchor.constraint(equalToConstant: 160),
            subtitleBadge.heightAnchor.constraint(equalToConstant: 22)
        ])

        // Table View
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = ticketHeader
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3 // ID, Fecha, Cliente
        case 1: return detallesArray.count // Detalles de Venta
        case 2: return 3 // Subtotal, IGV, Total
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Detalles de la Transacción"
        case 1: return "Detalle de Conceptos"
        case 2: return "Resumen de Cobro"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        cell.selectionStyle = .none
        
        guard let venta = venta else { return cell }

        switch indexPath.section {
        case 0:
            // Info cabecera
            if indexPath.row == 0 {
                cell.textLabel?.text = "ID Venta"
                cell.detailTextLabel?.text = String(venta.idVenta?.suffix(8) ?? "N/A")
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Fecha y Hora"
                if let fecha = venta.fechaVenta {
                    cell.detailTextLabel?.text = dateFormatter.string(from: fecha)
                } else {
                    cell.detailTextLabel?.text = "N/A"
                }
            } else {
                cell.textLabel?.text = "Cliente"
                if let clie = venta.cliente {
                    cell.detailTextLabel?.text = "\(clie.nombres ?? "") \(clie.apellidos ?? "")"
                } else {
                    cell.detailTextLabel?.text = "General"
                }
            }
            cell.textLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.textColor = .label
            
        case 1:
            // DetalleVenta rows
            let item = detallesArray[indexPath.row]
            
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.producto?.nombre ?? "Producto desconocido")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Cant: \(item.cantidad) x S/. \(String(format: "%.2f", item.precioUnitario))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        let sub = Double(item.cantidad) * item.precioUnitario
                        Text(String(format: "S/. %.2f", sub))
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
            } else {
                cell.textLabel?.text = item.producto?.nombre
                let sub = Double(item.cantidad) * item.precioUnitario
                cell.detailTextLabel?.text = String(format: "%d x S/. %.2f = S/. %.2f", item.cantidad, item.precioUnitario, sub)
            }
            
        case 2:
            // Resumen de Cobro
            if indexPath.row == 0 {
                cell.textLabel?.text = "Subtotal"
                cell.detailTextLabel?.text = String(format: "S/. %.2f", venta.subtotal)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "IGV (18%)"
                cell.detailTextLabel?.text = String(format: "S/. %.2f", venta.igv)
            } else {
                cell.textLabel?.text = "TOTAL FINAL"
                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
                cell.textLabel?.textColor = .label
                cell.detailTextLabel?.text = String(format: "S/. %.2f", venta.total)
                cell.detailTextLabel?.font = .systemFont(ofSize: 18, weight: .bold)
                cell.detailTextLabel?.textColor = .systemBlue
            }
            
        default:
            break
        }
        
        return cell
    }
}
