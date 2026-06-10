//
//  ProductoListView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ProductoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest ordenando por 'nombre' de manera ascendente
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Producto.nombre, ascending: true)],
        animation: .default
    ) private var productos: FetchedResults<Producto>
    
    // Estados para filtros
    @State private var textoBusqueda: String = ""
    @State private var categoriaSeleccionada: String = "Todos"
    @State private var filtroStock: FiltroStock = .todos
    
    // Control de hojas (Sheets)
    @State private var mostrarFormularioCreacion: Bool = false
    
    enum FiltroStock: String, CaseIterable, Identifiable {
        case todos = "Todos"
        case stockBajo = "Bajo Stock (< 5)"
        case conStock = "Con Stock (> 0)"
        case sinStock = "Sin Stock (0)"
        
        var id: String { self.rawValue }
    }
    
    let categorias = ["Todos", "Electrónicos", "Ropa", "Hogar", "Alimentos", "Otros"]
    
    // Filtrado interactivo en memoria para máxima fluidez y consistencia
    var productosFiltrados: [Producto] {
        productos.filter { prod in
            // Filtro por Nombre (Buscador)
            let coincideNombre = textoBusqueda.isEmpty || (prod.nombre ?? "").localizedCaseInsensitiveContains(textoBusqueda)
            
            // Filtro por Categoría
            let coincideCategoria = categoriaSeleccionada == "Todos" || prod.categoria == categoriaSeleccionada
            
            // Filtro por Stock
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
            // Filtros Picker superiores
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Selector de Categoría
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
                    
                    // Selector de Filtro de Stock
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
            
            // Lista de Productos
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
                                // Indicador visual de stock
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
    
    // Función auxiliar para determinar el color según el stock
    private func colorDeStock(_ stock: Int64) -> Color {
        if stock == 0 {
            return .red
        } else if stock < 5 {
            return .orange
        } else {
            return .green
        }
    }
    
    // Función onDelete para eliminar registros en Core Data
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
