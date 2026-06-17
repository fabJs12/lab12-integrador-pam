import SwiftUI
import CoreData

struct VentaFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Producto.nombre, ascending: true)],
        predicate: NSPredicate(format: "estado == true")
    ) private var productos: FetchedResults<Producto>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Cliente.apellidos, ascending: true)],
        predicate: NSPredicate(format: "estado == true")
    ) private var clientes: FetchedResults<Cliente>

    @State private var productoSeleccionadoId: String? = nil
    @State private var clienteSeleccionadoId: String? = nil
    @State private var cantidadTexto: String = "1"
    @State private var fechaVenta: Date = Date()

    @State private var mensajeError: String = ""
    @State private var mostrarAlertaError: Bool = false

    var productoSeleccionado: Producto? {
        productos.first { $0.idProducto == productoSeleccionadoId }
    }

    var clienteSeleccionado: Cliente? {
        clientes.first { $0.idCliente == clienteSeleccionadoId }
    }

    var cantidadEntera: Int {
        Int(cantidadTexto) ?? 0
    }

    var subtotal: Double {
        guard let prod = productoSeleccionado, cantidadEntera > 0 else { return 0.0 }
        return prod.precio * Double(cantidadEntera)
    }

    var igv: Double {
        return subtotal * 0.18
    }

    var total: Double {
        return subtotal + igv
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Selección de Entidades")) {
                    Picker("Cliente", selection: $clienteSeleccionadoId) {
                        Text("Seleccione un cliente").tag(String?.none)
                        ForEach(clientes, id: \.idCliente) { clie in
                            Text("\(clie.apellidos ?? ""), \(clie.nombres ?? "")").tag(clie.idCliente as String?)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Producto", selection: $productoSeleccionadoId) {
                        Text("Seleccione un producto").tag(String?.none)
                        ForEach(productos, id: \.idProducto) { prod in
                            Text("\(prod.nombre ?? "") (Stock: \(prod.stock))").tag(prod.idProducto as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if let prod = productoSeleccionado {
                    Section(header: Text("Detalle del Producto Seleccionado")) {
                        HStack {
                            Text("Código")
                            Spacer()
                            Text(prod.codigo ?? "N/A")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Precio Unitario")
                            Spacer()
                            Text(String(format: "S/. %.2f", prod.precio))
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("Stock Disponible")
                            Spacer()
                            Text("\(prod.stock)")
                                .foregroundColor(prod.stock < 5 ? .red : .primary)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Section(header: Text("Detalles de la Transacción")) {
                    DatePicker("Fecha", selection: $fechaVenta, displayedComponents: [.date, .hourAndMinute])

                    HStack {
                        Text("Cantidad")
                        Spacer()
                        TextField("Cantidad", text: $cantidadTexto)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onChange(of: cantidadTexto) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                cantidadTexto = filtered
                            }
                    }
                }

                Section(header: Text("Resumen de Cobro")) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(String(format: "S/. %.2f", subtotal))
                    }
                    HStack {
                        Text("IGV (18%)")
                        Spacer()
                        Text(String(format: "S/. %.2f", igv))
                    }
                    HStack {
                        Text("Total General")
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "S/. %.2f", total))
                            .font(.headline)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }

                Section {
                    Button(action: {
                        registrarVenta()
                    }) {
                        HStack {
                            Spacer()
                            Text("Registrar Venta")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Nueva Venta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $mostrarAlertaError) {
                Alert(
                    title: Text("Error al Registrar Venta"),
                    message: Text(mensajeError),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
            .onAppear {

                if productoSeleccionadoId == nil && !productos.isEmpty {
                    productoSeleccionadoId = productos.first?.idProducto
                }
                if clienteSeleccionadoId == nil && !clientes.isEmpty {
                    clienteSeleccionadoId = clientes.first?.idCliente
                }
            }
        }
    }

    private func registrarVenta() {

        guard let idProd = productoSeleccionadoId, let prod = productoSeleccionado else {
            mostrarError("Debe seleccionar un producto de la lista.")
            return
        }

        guard let _ = clienteSeleccionadoId else {
            mostrarError("Debe seleccionar un cliente de la lista.")
            return
        }

        guard cantidadEntera > 0 else {
            mostrarError("La cantidad debe ser mayor a 0.")
            return
        }

        guard prod.stock >= Int64(cantidadEntera) else {
            mostrarError("No permitir ventas si no hay stock suficiente")
            return
        }

        do {

            let idVentaUUID = UUID().uuidString
            _ = try CoreDataManager.shared.createVenta(
                idVenta: idVentaUUID,
                fechaVenta: fechaVenta,
                cantidad: Int64(cantidadEntera),
                precio: prod.precio,
                subtotal: subtotal,
                igv: igv,
                total: total,
                productoId: idProd
            )

            dismiss()

        } catch {
            mostrarError(error.localizedDescription)
        }
    }

    private func mostrarError(_ mensaje: String) {
        mensajeError = mensaje
        mostrarAlertaError = true
    }
}

struct VentaFormView_Previews: PreviewProvider {
    static var previews: some View {
        VentaFormView()
    }
}
