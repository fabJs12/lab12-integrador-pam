import SwiftUI
import CoreData

struct ProductoDetailView: View {
    @ObservedObject var producto: Producto

    @State private var mostrarEdicion: Bool = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(producto.categoria ?? "Sin Categoría")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(producto.estado ? "Activo" : "Inactivo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(producto.estado ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                            .foregroundColor(producto.estado ? .green : .gray)
                            .clipShape(Capsule())
                    }

                    Text(producto.nombre ?? "Producto sin Nombre")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Código: \(producto.codigo ?? "N/A")")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Precio Unitario", systemImage: "tag.fill")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "S/. %.2f", producto.precio))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    Divider()

                    HStack {
                        Label("Stock Disponible", systemImage: "shippingbox.fill")
                            .font(.headline)
                        Spacer()
                        Text("\(producto.stock)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(producto.stock < 5 ? .red : .primary)
                    }

                    if producto.stock < 5 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("¡Atención! Stock crítico (menor a 5 unidades).")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha de Registro")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    if let fecha = producto.fechaRegistro {
                        Text(dateFormatter.string(from: fecha))
                            .font(.body)
                    } else {
                        Text("Fecha no registrada")
                            .font(.body)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detalle del Producto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarEdicion = true
                }) {
                    Text("Editar")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $mostrarEdicion) {
            ProductoFormView(producto: producto)
        }
    }
}

struct ProductoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let model = Producto(context: context)
        model.codigo = "PRD-01"
        model.nombre = "Producto de Muestra"
        model.categoria = "Electrónicos"
        model.precio = 199.99
        model.stock = 4
        model.fechaRegistro = Date()
        model.estado = true

        return NavigationStack {
            ProductoDetailView(producto: model)
        }
    }
}
