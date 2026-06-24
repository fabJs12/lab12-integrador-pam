import UIKit
import SwiftUI
import CoreData

class VentaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    
    // Filtering states
    private var allSales: [Venta] = []
    private var activarFiltroFecha: Bool = false
    private var fechaInicio: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    private var fechaFin: Date = Date()
    private var selectedAmountFilter: AmountFilter = .todos

    enum AmountFilter: String, CaseIterable {
        case todos = "Todos los montos"
        case masDe50 = "Más de S/. 50"
        case masDe100 = "Más de S/. 100"
        case masDe500 = "Más de S/. 500"

        var valorMinimo: Double {
            switch self {
            case .todos: return 0.0
            case .masDe50: return 50.0
            case .masDe100: return 100.0
            case .masDe500: return 500.0
            }
        }
    }

    private var filteredSales: [Venta] {
        return allSales.filter { v in
            if activarFiltroFecha {
                guard let fecha = v.fechaVenta else { return false }
                let startOfDay = Calendar.current.startOfDay(for: fechaInicio)
                let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: fechaFin) ?? fechaFin
                if fecha < startOfDay || fecha > endOfDay {
                    return false
                }
            }
            if v.total < selectedAmountFilter.valorMinimo {
                return false
            }
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func configureUI() {
        title = "Ventas"
        view.backgroundColor = .systemGroupedBackground

        // Setup Right Bar Button for "+"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(agregarTapped)
        )

        // Setup filter container view
        let filterContainer = UIView()
        filterContainer.backgroundColor = .systemBackground
        filterContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterContainer)

        // Total Amount Filter Button with UIMenu
        let amountButton = UIButton(type: .system)
        amountButton.setTitle("Monto: Todos los montos", for: .normal)
        amountButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        amountButton.semanticContentAttribute = .forceRightToLeft
        amountButton.backgroundColor = .systemGray6
        amountButton.layer.cornerRadius = 8
        amountButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        amountButton.translatesAutoresizingMaskIntoConstraints = false
        setupAmountMenu(button: amountButton)
        filterContainer.addSubview(amountButton)

        // Date filter Toggle
        let dateToggleLabel = UILabel()
        dateToggleLabel.text = "Filtrar por Fechas"
        dateToggleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateToggleLabel.translatesAutoresizingMaskIntoConstraints = false
        filterContainer.addSubview(dateToggleLabel)

        let dateToggle = UISwitch()
        dateToggle.isOn = activarFiltroFecha
        dateToggle.addTarget(self, action: #selector(dateToggleChanged(_:)), for: .valueChanged)
        dateToggle.translatesAutoresizingMaskIntoConstraints = false
        filterContainer.addSubview(dateToggle)

        // Date Pickers Stack
        let datePickersStack = UIStackView()
        datePickersStack.axis = .horizontal
        datePickersStack.distribution = .fillProportionally
        datePickersStack.spacing = 8
        datePickersStack.translatesAutoresizingMaskIntoConstraints = false
        datePickersStack.isHidden = !activarFiltroFecha
        filterContainer.addSubview(datePickersStack)

        let startPicker = UIDatePicker()
        startPicker.datePickerMode = .date
        startPicker.preferredDatePickerStyle = .compact
        startPicker.date = fechaInicio
        startPicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        
        let toLabel = UILabel()
        toLabel.text = "hasta"
        toLabel.font = .systemFont(ofSize: 12)
        toLabel.textColor = .secondaryLabel
        toLabel.textAlignment = .center
        
        let endPicker = UIDatePicker()
        endPicker.datePickerMode = .date
        endPicker.preferredDatePickerStyle = .compact
        endPicker.date = fechaFin
        endPicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)

        datePickersStack.addArrangedSubview(startPicker)
        datePickersStack.addArrangedSubview(toLabel)
        datePickersStack.addArrangedSubview(endPicker)

        // Table View
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VentaCell")
        view.addSubview(tableView)

        // Constraints
        NSLayoutConstraint.activate([
            filterContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            amountButton.topAnchor.constraint(equalTo: filterContainer.topAnchor, constant: 12),
            amountButton.leadingAnchor.constraint(equalTo: filterContainer.leadingAnchor, constant: 16),
            amountButton.trailingAnchor.constraint(equalTo: filterContainer.trailingAnchor, constant: -16),
            amountButton.heightAnchor.constraint(equalToConstant: 36),

            dateToggleLabel.topAnchor.constraint(equalTo: amountButton.bottomAnchor, constant: 12),
            dateToggleLabel.leadingAnchor.constraint(equalTo: filterContainer.leadingAnchor, constant: 16),
            dateToggleLabel.heightAnchor.constraint(equalToConstant: 31),

            dateToggle.centerYAnchor.constraint(equalTo: dateToggleLabel.centerYAnchor),
            dateToggle.trailingAnchor.constraint(equalTo: filterContainer.trailingAnchor, constant: -16),

            datePickersStack.topAnchor.constraint(equalTo: dateToggleLabel.bottomAnchor, constant: 8),
            datePickersStack.leadingAnchor.constraint(equalTo: filterContainer.leadingAnchor, constant: 16),
            datePickersStack.trailingAnchor.constraint(equalTo: filterContainer.trailingAnchor, constant: -16),
            datePickersStack.bottomAnchor.constraint(equalTo: filterContainer.bottomAnchor, constant: -12),
            datePickersStack.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: filterContainer.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Add a bottom anchor constraint if date filter is inactive to size the container
        let inactiveBottom = datePickersStack.topAnchor.constraint(equalTo: filterContainer.bottomAnchor)
        inactiveBottom.priority = .defaultLow
        inactiveBottom.isActive = !activarFiltroFecha
    }

    private func setupAmountMenu(button: UIButton) {
        let actions = AmountFilter.allCases.map { filter in
            UIAction(title: filter.rawValue, state: filter == selectedAmountFilter ? .on : .off) { [weak self] action in
                self?.selectedAmountFilter = filter
                button.setTitle("Monto: \(filter.rawValue)", for: .normal)
                self?.setupAmountMenu(button: button)
                self?.tableView.reloadData()
            }
        }
        button.menu = UIMenu(title: "Filtrar por Monto", children: actions)
        button.showsMenuAsPrimaryAction = true
    }

    @objc private func dateToggleChanged(_ dateSwitch: UISwitch) {
        activarFiltroFecha = dateSwitch.isOn
        
        // Animating layout changes in stack view
        UIView.animate(withDuration: 0.3) {
            self.view.subviews.first(where: { $0.subviews.contains(dateSwitch) })?.subviews.first(where: { $0 is UIStackView })?.isHidden = !dateSwitch.isOn
            self.view.layoutIfNeeded()
        }
        
        tableView.reloadData()
    }

    @objc private func startDateChanged(_ picker: UIDatePicker) {
        fechaInicio = picker.date
        tableView.reloadData()
    }

    @objc private func endDateChanged(_ picker: UIDatePicker) {
        fechaFin = picker.date
        tableView.reloadData()
    }

    private func fetchData() {
        do {
            allSales = try CoreDataManager.shared.fetchVentas()
            tableView.reloadData()
        } catch {
            print("Error fetching sales: \(error.localizedDescription)")
        }
    }

    @objc private func agregarTapped() {
        performSegue(withIdentifier: "segueListToNuevaVenta", sender: self)
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSales.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VentaCell", for: indexPath)
        let sale = filteredSales[indexPath.row]

        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                VentaCellView(venta: sale)
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            cell.textLabel?.text = "Venta \(sale.idVenta?.suffix(6) ?? "") - \(formatter.string(from: sale.fechaVenta ?? Date()))"
            cell.detailTextLabel?.text = String(format: "Total: S/. %.2f", sale.total)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sale = filteredSales[indexPath.row]
        performSegue(withIdentifier: "segueListToDetalleVenta", sender: sale)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sale = filteredSales[indexPath.row]
            do {
                try CoreDataManager.shared.deleteVenta(venta: sale)
                // Remove locally
                if let index = allSales.firstIndex(where: { $0.idVenta == sale.idVenta }) {
                    allSales.remove(at: index)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
                present(alert, animated: true)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListToDetalleVenta" {
            if let detailVC = segue.destination as? VentaDetailViewController,
               let selectedVenta = sender as? Venta {
                detailVC.venta = selectedVenta
            }
        }
    }
}

// MARK: - SwiftUI sale card
struct VentaCellView: View {
    @ObservedObject var venta: Venta

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let fecha = venta.fechaVenta {
                    Text(dateFormatter.string(from: fecha))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } else {
                    Text("Fecha Desconocida")
                        .font(.subheadline)
                }
                Spacer()
                Text(String(format: "S/. %.2f", venta.total))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            if let cliente = venta.cliente {
                Text("Cliente: \(cliente.nombres ?? "") \(cliente.apellidos ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                Text("Items: \(venta.detalles?.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Subtotal: S/. \(String(format: "%.2f", venta.subtotal))")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("IGV: S/. \(String(format: "%.2f", venta.igv))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
