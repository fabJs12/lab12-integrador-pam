//
//  ClienteListView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ClienteListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest ordenando por 'apellidos' de manera ascendente
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Cliente.apellidos, ascending: true)],
        animation: .default
    ) private var clientes: FetchedResults<Cliente>
    
    // Estados para filtros
    @State private var textoBusqueda: String = ""
    @State private var filtroEstado: FiltroEstado = .todos
    
    // Control de hojas (Sheets)
    @State private var mostrarFormularioCreacion: Bool = false
    @State private var clienteParaEditar: Cliente? = nil
    
    enum FiltroEstado: String, CaseIterable, Identifiable {
        case todos = "Todos"
        case activos = "Activos"
        case inactivos = "Inactivos"
        
        var id: String { self.rawValue }
    }
    
    // Filtrado interactivo en tiempo real en memoria
    var clientesFiltrados: [Cliente] {
        clientes.filter { clie in
            // Filtro por búsqueda (DNI, nombres o apellidos)
            let query = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines)
            let coincideBusqueda = query.isEmpty ||
                (clie.dni ?? "").localizedCaseInsensitiveContains(query) ||
                (clie.nombres ?? "").localizedCaseInsensitiveContains(query) ||
                (clie.apellidos ?? "").localizedCaseInsensitiveContains(query)
            
            // Filtro por Estado
            let coincideEstado: Bool
            switch filtroEstado {
            case .todos:
                coincideEstado = true
            case .activos:
                coincideEstado = clie.estado == true
            case .inactivos:
                coincideEstado = clie.estado == false
            }
            
            return coincideBusqueda && coincideEstado
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Picker Segmentado de Estado
            Picker("Estado", selection: $filtroEstado) {
                ForEach(FiltroEstado.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemBackground))
            
            // Lista de Clientes
            if clientesFiltrados.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No se encontraron clientes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(clientesFiltrados) { clie in
                        NavigationLink(destination: ClienteDetailView(cliente: clie)) {
                            HStack(spacing: 16) {
                                // Indicador de estado circular
                                Circle()
                                    .fill(clie.estado ? Color.green : Color.gray)
                                    .frame(width: 12, height: 12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(clie.nombres ?? "") \(clie.apellidos ?? "")")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 8) {
                                        Text("DNI: \(clie.dni ?? "N/A")")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        
                                        if let tel = clie.telefono, !tel.isEmpty {
                                            Text("•")
                                                .foregroundColor(.secondary)
                                            Text("Tel: \(tel)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: eliminarClientes)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Clientes")
        .searchable(text: $textoBusqueda, prompt: "Buscar por DNI, nombres o apellidos")
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
        // Sheet para Crear un nuevo cliente
        .sheet(isPresented: $mostrarFormularioCreacion) {
            ClienteFormView()
        }
    }
    
    // Función onDelete para eliminar registros en Core Data
    private func eliminarClientes(at offsets: IndexSet) {
        for index in offsets {
            let cliente = clientesFiltrados[index]
            do {
                try CoreDataManager.shared.deleteCliente(cliente: cliente)
            } catch {
                print("Error al eliminar cliente: \(error.localizedDescription)")
            }
        }
    }
}

struct ClienteListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClienteListView()
        }
    }
}
