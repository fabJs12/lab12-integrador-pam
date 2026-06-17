import SwiftUI
import CoreData

struct ProductoListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Producto.nombre, ascending: true)],
        animation: .default
    ) private var productos: FetchedResults<Producto>

    @State private var textoBusqueda: String = ""
    @State private var categoriaSeleccionada: String = "Todos"
    @State private var filtroStock: FiltroStock = .todos

    @State private var mostrarFormularioCreacion: Bool = false

    enum FiltroStock: String, CaseIterable, Identifiable {
        case todos = "Todos"
        case stockBajo = "Bajo Stock (< 5)"
        case conStock = "Con Stock (> 0)"
        case sinStock = "Sin Stock (0)"

        var id: String { self.rawValue }
    }

    let categorias = ["Todos", "Electrónicos", "Ropa", "Hogar", "Alimentos", "Otros"]

    var productosFiltrados: [Producto] {
        productos.filter { prod in

            let coincideNombre = textoBusqueda.isEmpty || (prod.nombre ?? "").localizedCaseInsensitiveContains(textoBusqueda)

            let coincideCategoria = categoriaSeleccionada == "Todos" || prod.categoria == categoriaSeleccionada

            let coincideStock: Bool
            switch filtroStock {
            case .todos:
                coincideStock = true
            case .stockBajo:
                coincideStock = prod.stock < 5
            case .conStock:
                coincideStock = prod.stock > 0
            case .sinStock:
                coincideStock = prod.stock == 0
            }

            return coincideNombre && coincideCategoria && coincideStock
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 8) {
                HStack(spacing: 12) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Categoría")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)

                        Picker("Categoría", selection: $categoriaSeleccionada) {
                            ForEach(categorias, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Inventario")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)

                        Picker("Stock", selection: $filtroStock) {
                            ForEach(FiltroStock.allCases) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))

            if productosFiltrados.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.dashed")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No se encontraron productos")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(productosFiltrados) { prod in
                        NavigationLink(destination: ProductoDetailView(producto: prod)) {
                            HStack(spacing: 16) {

                                Circle()
                                    .fill(colorDeStock(prod.stock))
                                    .frame(width: 12, height: 12)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(prod.nombre ?? "Sin Nombre")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    HStack(spacing: 8) {
                                        Text(prod.codigo ?? "N/A")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)

                                        Text("•")
                                            .foregroundColor(.secondary)

                                        Text(prod.categoria ?? "Otros")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(String(format: "S/. %.2f", prod.precio))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    Text("Stock: \(prod.stock)")
                                        .font(.caption2)
                                        .foregroundColor(prod.stock < 5 ? .red : .secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: eliminarProductos)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Productos")
        .searchable(text: $textoBusqueda, prompt: "Buscar producto por nombre")
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
            ProductoFormView()
        }
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

    private func eliminarProductos(at offsets: IndexSet) {
        for index in offsets {
            let producto = productosFiltrados[index]
            do {
                try CoreDataManager.shared.deleteProducto(producto: producto)
            } catch {
                print("Error al eliminar producto: \(error.localizedDescription)")
            }
        }
    }
}

struct ProductoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductoListView()
        }
    }
}
