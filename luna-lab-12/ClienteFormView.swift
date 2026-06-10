//
//  ClienteFormView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ClienteFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Objeto Cliente opcional: si está presente, el formulario actúa en modo edición
    var cliente: Cliente?
    
    // Estados del Formulario
    @State private var dni: String = ""
    @State private var nombres: String = ""
    @State private var apellidos: String = ""
    @State private var telefono: String = ""
    @State private var correo: String = ""
    @State private var direccion: String = ""
    @State private var estado: Bool = true
    
    // Gestión de Alertas de Error
    @State private var mensajeError: String = ""
    @State private var mostrarAlertaError: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Identificación")) {
                    TextField("DNI (8 dígitos)", text: $dni)
                        .keyboardType(.numberPad)
                        .onChange(of: dni) { newValue in
                            // Limitar la entrada a solo números y máximo 8 caracteres
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 8 {
                                dni = String(filtered.prefix(8))
                            } else {
                                dni = filtered
                            }
                        }
                }
                
                Section(header: Text("Datos Personales")) {
                    TextField("Nombres", text: $nombres)
                    TextField("Apellidos", text: $apellidos)
                }
                
                Section(header: Text("Contacto y Ubicación")) {
                    TextField("Teléfono", text: $telefono)
                        .keyboardType(.phonePad)
                    
                    TextField("Correo Electrónico", text: $correo)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    TextField("Dirección", text: $direccion)
                }
                
                Section(header: Text("Estado")) {
                    Toggle("Cliente Activo", isOn: $estado)
                        .tint(.blue)
                }
            }
            .navigationTitle(cliente == nil ? "Nuevo Cliente" : "Editar Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarCliente()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(isPresented: $mostrarAlertaError) {
                Alert(
                    title: Text("Error de Validación"),
                    message: Text(mensajeError),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
            .onAppear {
                cargarDatosSiEsEdicion()
            }
        }
    }
    
    // Cargar datos del cliente si estamos en modo edición
    private func cargarDatosSiEsEdicion() {
        if let cliente = cliente {
            dni = cliente.dni ?? ""
            nombres = cliente.nombres ?? ""
            apellidos = cliente.apellidos ?? ""
            telefono = cliente.telefono ?? ""
            correo = cliente.correo ?? ""
            direccion = cliente.direccion ?? ""
            estado = cliente.estado
        }
    }
    
    // Guardar o Actualizar el cliente en Core Data
    private func guardarCliente() {
        let dniLimpio = dni.trimmingCharacters(in: .whitespacesAndNewlines)
        let nombresLimpios = nombres.trimmingCharacters(in: .whitespacesAndNewlines)
        let apellidosLimpios = apellidos.trimmingCharacters(in: .whitespacesAndNewlines)
        let correoLimpio = correo.trimmingCharacters(in: .whitespacesAndNewlines)
        let telefonoLimpio = telefono.trimmingCharacters(in: .whitespacesAndNewlines)
        let direccionLimpia = direccion.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Validar campos obligatorios no vacíos
        guard !dniLimpio.isEmpty else {
            mostrarError("El DNI es obligatorio.")
            return
        }
        
        guard !nombresLimpios.isEmpty else {
            mostrarError("El nombre es obligatorio.")
            return
        }
        
        guard !apellidosLimpios.isEmpty else {
            mostrarError("El apellido es obligatorio.")
            return
        }
        
        guard !correoLimpio.isEmpty else {
            mostrarError("El correo electrónico es obligatorio.")
            return
        }
        
        // 2. Validar longitud de DNI (debe tener exactamente 8 caracteres)
        guard dniLimpio.count == 8 else {
            mostrarError("El DNI debe tener exactamente 8 dígitos.")
            return
        }
        
        // 3. Validar formato básico de correo (contener @ y un punto)
        guard correoLimpio.contains("@") && correoLimpio.contains(".") else {
            mostrarError("El formato del correo electrónico no es válido.")
            return
        }
        
        do {
            if let clienteExistente = cliente {
                // Modo Edición: Actualizar entidad
                try CoreDataManager.shared.updateCliente(
                    cliente: clienteExistente,
                    dni: dniLimpio,
                    nombres: nombresLimpios,
                    apellidos: apellidosLimpios,
                    telefono: telefonoLimpio,
                    correo: correoLimpio,
                    direccion: direccionLimpia,
                    estado: estado
                )
            } else {
                // Modo Creación: Crear nueva entidad con un ID autogenerado
                let idUnico = UUID().uuidString
                _ = try CoreDataManager.shared.createCliente(
                    idCliente: idUnico,
                    dni: dniLimpio,
                    nombres: nombresLimpios,
                    apellidos: apellidosLimpios,
                    telefono: telefonoLimpio,
                    correo: correoLimpio,
                    direccion: direccionLimpia,
                    estado: estado
                )
            }
            
            // Cerrar formulario tras guardar exitosamente
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

struct ClienteFormView_Previews: PreviewProvider {
    static var previews: some View {
        ClienteFormView()
    }
}
