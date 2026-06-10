//
//  ClienteDetailView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ClienteDetailView: View {
    @ObservedObject var cliente: Cliente
    
    // Control de presentación del formulario de edición
    @State private var mostrarEdicion: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Perfil Cabecera
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(cliente.nombres ?? "") \(cliente.apellidos ?? "")")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Badge de Estado
                        Text(cliente.estado ? "Activo" : "Inactivo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(cliente.estado ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                            .foregroundColor(cliente.estado ? .green : .gray)
                            .clipShape(Capsule())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Detalles de Identificación y Contacto
                VStack(alignment: .leading, spacing: 16) {
                    DetalleFila(icon: "doc.text.fill", title: "DNI", value: cliente.dni ?? "N/A")
                    Divider()
                    DetalleFila(icon: "phone.fill", title: "Teléfono", value: cliente.telefono ?? "N/A")
                    Divider()
                    DetalleFila(icon: "envelope.fill", title: "Correo Electrónico", value: cliente.correo ?? "N/A")
                    Divider()
                    DetalleFila(icon: "mappin.and.ellipse", title: "Dirección", value: cliente.direccion ?? "N/A")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detalle de Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    mostrarEdicion = true
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $mostrarEdicion) {
            ClienteFormView(cliente: cliente)
        }
    }
}

// Fila reutilizable para visualización de detalles
struct DetalleFila: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

// Preview
struct ClienteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let model = Cliente(context: context)
        model.dni = "88888888"
        model.nombres = "Fabrizio"
        model.apellidos = "Luna Cordova"
        model.telefono = "+51 999 888 777"
        model.correo = "fabrizio.luna@tecsup.edu.pe"
        model.direccion = "Av. El Sol 345, Lima"
        model.estado = true
        
        return NavigationStack {
            ClienteDetailView(cliente: model)
        }
    }
}
