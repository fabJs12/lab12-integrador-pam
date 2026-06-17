import SwiftUI
import CoreData

struct VentaListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Venta.fechaVenta, ascending: false)],
        animation: .default
    ) private var ventas: FetchedResults<Venta>

    @State private var activarFiltroFecha: Bool = false
    @State private var fechaInicio: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var fechaFin: Date = Date()

    @State private var filtroMonto: FiltroMonto = .todos

    @State private var mostrarFormularioCreacion: Bool = false

    enum FiltroMonto: String, CaseIterable, Identifiable {
        case todos = "Todos los montos"
        case masDe50 = "Más de S/. 50"
        case masDe100 = "Más de S/. 100"
        case masDe500 = "Más de S/. 500"

        var id: String { self.rawValue }

        var valorMinimo: Double {
            switch self {
            case .todos: return 0.0
            case .masDe50: return 50.0
            case .masDe100: return 100.0
            case .masDe500: return 500.0
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter
    }

    var ventasFiltradas: [Venta] {
        ventas.filter { v in

            if activarFiltroFecha {
                guard let fecha = v.fechaVenta else { return false }

                let startOfDay = Calendar.current.startOfDay(for: fechaInicio)
                let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: fechaFin) ?? fechaFin
                if fecha < startOfDay || fecha > endOfDay {
                    return false
                }
            }

            if v.total < filtroMonto.valorMinimo {
                return false
            }

            return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 12) {

                HStack {
                    Text("Filtrar por Total:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Monto", selection: $filtroMonto) {
                        ForEach(FiltroMonto.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                Divider()

                Toggle(isOn: $activarFiltroFecha.animation()) {
                    Label("Filtrar por Rango de Fechas", systemImage: "calendar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .tint(.blue)

                if activarFiltroFecha {
                    HStack {
                        DatePicker("Desde", selection: $fechaInicio, displayedComponents: .date)
                            .labelsHidden()
                        Spacer()
                        Text("hasta")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        DatePicker("Hasta", selection: $fechaFin, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)

            if ventasFiltradas.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No se registraron ventas en este rango")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(ventasFiltradas) { v in
                        NavigationLink(destination: VentaDetailView(venta: v)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    if let fecha = v.fechaVenta {
                                        Text(dateFormatter.string(from: fecha))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Fecha Desconocida")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    Text(String(format: "S/. %.2f", v.total))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }

                                HStack(spacing: 16) {
                                    Text("Cant: \(v.cantidad)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("P.U: S/. \(String(format: "%.2f", v.precio))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("Subtotal: S/. \(String(format: "%.2f", v.subtotal))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("IGV: S/. \(String(format: "%.2f", v.igv))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: eliminarVentas)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Ventas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarFormularioCreacion = true
                }) {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $mostrarFormularioCreacion) {
            VentaFormView()
        }
    }

    private func eliminarVentas(at offsets: IndexSet) {
        for index in offsets {
            let venta = ventasFiltradas[index]
            do {
                try CoreDataManager.shared.deleteVenta(venta: venta)
            } catch {
                print("Error al eliminar venta: \(error.localizedDescription)")
            }
        }
    }
}

struct VentaListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VentaListView()
        }
    }
}
