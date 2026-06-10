//
//  ProductoFormView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ProductoFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Objeto Producto opcional: si está presente, el formulario actúa en modo edición
    var producto: Producto?
    
    // Estados del Formulario
    @State private var codigo: String = ""
    @State private var nombre: String = ""
    @State private var categoria: String = "Electrónicos"
    @State private var precio: String = ""
    @State private var stock: Int = 0
    @State private var estado: Bool = true
    
    // Gestión de Errores y Alertas
    @State private var mensajeError: String = ""
    @State private var mostrarAlertaError: Bool = false
    
    let categorias = ["Electrónicos", "Ropa", "Hogar", "Alimentos", "Otros"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Básica")) {
                    TextField("Código del Producto", text: $codigo)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                    
                    TextField("Nombre del Producto", text: $nombre)
                }
                
                Section(header: Text("Clasificación")) {
                    Picker("Categoría", selection: $categoria) {
                        ForEach(categorias, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Inventario y Costos")) {
                    HStack {
                        Text("Precio ($)")
                        Spacer()
                        TextField("0.00", text: $precio)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    
                    Stepper("Stock disponible: \(stock)", value: $stock, in: 0...100000)
                }
                
                Section(header: Text("Estado")) {
                    Toggle("Activo / Habilitado", isOn: $estado)
                        .tint(.blue)
                }
            }
            .navigationTitle(producto == nil ? "Nuevo Producto" : "Editar Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarProducto()
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
    
    // Cargar los datos del producto si estamos en modo edición
    private func cargarDatosSiEsEdicion() {
        if let producto = producto {
            codigo = producto.codigo ?? ""
            nombre = producto.nombre ?? ""
            categoria = producto.categoria ?? "Electrónicos"
            precio = String(format: "%.2f", producto.precio)
            stock = Int(producto.stock)
            estado = producto.estado
        }
    }
    
    // Guardar o Actualizar el producto en Core Data
    private func guardarProducto() {
        // 1. Validaciones de campos obligatorios
        guard !codigo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarError("El código del producto es obligatorio.")
            return
        }
        
        guard !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarError("El nombre del producto es obligatorio.")
            return
        }
        
        // 2. Validación de Precio
        let precioLimpio = precio.replacingOccurrences(of: ",", with: ".")
        guard let precioDouble = Double(precioLimpio), precioDouble > 0 else {
            mostrarError("El precio debe ser un número estrictamente mayor a 0.")
            return
        }
        
        // 3. Validación de Stock
        guard stock >= 0 else {
            mostrarError("El stock debe ser un entero mayor o igual a 0.")
            return
        }
        
        do {
            if let productoExistente = producto {
                // Modo Edición: Actualizar entidad
                try CoreDataManager.shared.updateProducto(
                    producto: productoExistente,
                    codigo: codigo,
                    nombre: nombre,
                    categoria: categoria,
                    precio: precioDouble,
                    stock: Int64(stock),
                    estado: estado
                )
            } else {
                // Modo Creación: Crear nueva entidad
                let idUnico = UUID().uuidString
                _ = try CoreDataManager.shared.createProducto(
                    idProducto: idUnico,
                    codigo: codigo,
                    nombre: nombre,
                    categoria: categoria,
                    precio: precioDouble,
                    stock: Int64(stock),
                    fechaRegistro: Date(),
                    estado: estado
                )
            }
            
            // Cerrar el formulario tras guardar exitosamente
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

struct ProductoFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProductoFormView()
    }
}
