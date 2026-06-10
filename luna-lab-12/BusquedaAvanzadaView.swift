//
//  BusquedaAvanzadaView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct BusquedaAvanzadaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Cargar todas las entidades para filtrado interactivo en tiempo real
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Producto.nombre, ascending: true)])
    private var productos: FetchedResults<Producto>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Cliente.apellidos, ascending: true)])
    private var clientes: FetchedResults<Cliente>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Venta.fechaVenta, ascending: false)])
    private var ventas: FetchedResults<Venta>
    
    // Estados de filtrado
    @State private var precioMinStr: String = ""
    @State private var precioMaxStr: String = ""
    @State private var dniBusqueda: String = ""
    @State private var totalMinStr: String = ""
    
    // Computar Productos filtrados por precio
    var productosFiltrados: [Producto] {
        let minPrice = Double(precioMinStr) ?? 0.0
        let maxPrice = Double(precioMaxStr) ?? Double.greatestFiniteMagnitude
        
        return productos.filter { prod in
            let cumpleMin = prod.precio >= minPrice
            let cumpleMax = prod.precio <= (precioMaxStr.isEmpty ? Double.greatestFiniteMagnitude : maxPrice)
            return cumpleMin && cumpleMax
        }
    }
    
    // Computar Clientes filtrados por DNI
    var clientesFiltrados: [Cliente] {
        let query = dniBusqueda.trimmingCharacters(in: .whitespacesAndNewlines)
        return clientes.filter { clie in
            query.isEmpty || (clie.dni ?? "").localizedCaseInsensitiveContains(query)
        }
    }
    
    // Computar Ventas filtradas por monto total
    var ventasFiltradas: [Venta] {
        let totalMin = Double(totalMinStr) ?? 0.0
        return ventas.filter { vent in
            vent.total >= totalMin
        }
    }
    
    var body: some View {
        List {
            // Sección de Búsqueda de Productos
            Section(header: Text("Búsqueda de Productos por Precio")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)) {
                
                HStack(spacing: 12) {
                    TextField("Mínimo (S/.)", text: $precioMinStr)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("a")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Máximo (S/.)", text: $precioMaxStr)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical, 4)
                
                if productosFiltrados.isEmpty {
                    Text("No hay productos en este rango")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(productosFiltrados.prefix(5)) { prod in
                        HStack {
                            Text(prod.nombre ?? "Sin Nombre")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "S/. %.2f", prod.precio))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            // Sección de Búsqueda de Clientes
            Section(header: Text("Búsqueda de Clientes por DNI")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)) {
                
                TextField("Ingrese DNI exacto o parcial", text: $dniBusqueda)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: dniBusqueda) { newValue in
                        dniBusqueda = String(newValue.filter { $0.isNumber }.prefix(8))
                    }
                
                if clientesFiltrados.isEmpty {
                    Text("No se encontraron clientes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(clientesFiltrados.prefix(5)) { clie in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(clie.nombres ?? "") \(clie.apellidos ?? "")")
                                .font(.subheadline)
                            Text("DNI: \(clie.dni ?? "")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Sección de Búsqueda de Ventas
            Section(header: Text("Búsqueda de Ventas por Monto")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)) {
                
                TextField("Monto total mayor o igual a (S/.)", text: $totalMinStr)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if ventasFiltradas.isEmpty {
                    Text("No se encontraron ventas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(ventasFiltradas.prefix(5)) { vent in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cant: \(vent.cantidad) unidades")
                                    .font(.subheadline)
                                if let fecha = vent.fechaVenta {
                                    Text(fecha, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text(String(format: "S/. %.2f", vent.total))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Búsqueda Avanzada")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview
struct BusquedaAvanzadaView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BusquedaAvanzadaView()
        }
    }
}
