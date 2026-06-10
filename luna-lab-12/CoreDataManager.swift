//
//  CoreDataManager.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import UIKit
import CoreData

/// Errores de validación de negocio para Core Data.
enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidPrice
    case invalidStock
    case invalidQuantity
    case insufficientStock(currentStock: Int64, requested: Int64)
    case invalidDNI
    case invalidEmail
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "El campo '\(fieldName)' no puede estar vacío."
        case .invalidPrice:
            return "El precio del producto debe ser estrictamente mayor a 0."
        case .invalidStock:
            return "El stock del producto debe ser mayor o igual a 0."
        case .invalidQuantity:
            return "La cantidad de la venta debe ser estrictamente mayor a 0."
        case .insufficientStock(let current, let requested):
            return "Stock insuficiente. Stock disponible: \(current), solicitado: \(requested)."
        case .invalidDNI:
            return "El DNI debe tener una longitud coherente (8 dígitos numéricos)."
        case .invalidEmail:
            return "El correo electrónico debe tener un formato válido (contener '@' y '.')."
        case .productNotFound:
            return "Producto no encontrado en el sistema."
        }
    }
}

/// Singleton centralizado para gestionar las operaciones CRUD de Core Data con validaciones de negocio.
class CoreDataManager {
    
    /// Instancia compartida del Singleton.
    static let shared = CoreDataManager()
    
    private init() {}
    
    /// 1. Contexto persistente global.
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// 2. Función básica de guardado.
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - CRUD: Usuario
    
    /// Crea un nuevo Usuario con validaciones.
    func createUsuario(idUsuario: String, nombreUsuario: String, password: String, nombreCompleto: String, estado: Bool) throws -> Usuario {
        // Validaciones de negocio
        guard !idUsuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idUsuario") }
        guard !nombreUsuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombreUsuario") }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("password") }
        guard !nombreCompleto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombreCompleto") }
        
        let usuario = Usuario(context: context)
        usuario.idUsuario = idUsuario
        usuario.nombreUsuario = nombreUsuario
        usuario.password = password
        usuario.nombreCompleto = nombreCompleto
        usuario.estado = estado
        
        try saveContext()
        return usuario
    }
    
    /// Obtiene todos los Usuarios de la base de datos.
    func fetchUsuarios() throws -> [Usuario] {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    /// Actualiza un Usuario existente con validaciones.
    func updateUsuario(usuario: Usuario, nombreUsuario: String, password: String, nombreCompleto: String, estado: Bool) throws {
        guard !nombreUsuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombreUsuario") }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("password") }
        guard !nombreCompleto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombreCompleto") }
        
        usuario.nombreUsuario = nombreUsuario
        usuario.password = password
        usuario.nombreCompleto = nombreCompleto
        usuario.estado = estado
        
        try saveContext()
    }
    
    /// Elimina un Usuario de la base de datos.
    func deleteUsuario(usuario: Usuario) throws {
        context.delete(usuario)
        try saveContext()
    }
    
    /// Registra un nuevo usuario con una estructura simplificada y estado activo por defecto.
    func registrarUsuario(nombreUsuario: String, contrasena: String, nombreCompleto: String) throws -> Usuario {
        let idUsuario = UUID().uuidString
        return try createUsuario(idUsuario: idUsuario, nombreUsuario: nombreUsuario, password: contrasena, nombreCompleto: nombreCompleto, estado: true)
    }
    
    /// Valida las credenciales de un usuario buscando en Core Data.
    func validarUsuario(nombreUsuario: String, contrasena: String) throws -> Bool {
        guard !nombreUsuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyField("usuario")
        }
        guard !contrasena.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyField("contraseña")
        }
        
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombreUsuario == %@ AND password == %@", nombreUsuario, contrasena)
        let usuarios = try context.fetch(fetchRequest)
        return !usuarios.isEmpty
    }
    
    // MARK: - CRUD: Producto
    
    /// Crea un nuevo Producto con validaciones de negocio.
    func createProducto(idProducto: String, codigo: String, nombre: String, categoria: String, precio: Double, stock: Int64, fechaRegistro: Date = Date(), estado: Bool) throws -> Producto {
        // Validaciones de negocio
        guard !idProducto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idProducto") }
        guard !codigo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("codigo") }
        guard !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombre") }
        guard !categoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("categoria") }
        guard precio > 0 else { throw ValidationError.invalidPrice }
        guard stock >= 0 else { throw ValidationError.invalidStock }
        
        let producto = Producto(context: context)
        producto.idProducto = idProducto
        producto.codigo = codigo
        producto.nombre = nombre
        producto.categoria = categoria
        producto.precio = precio
        producto.stock = stock
        producto.fechaRegistro = fechaRegistro
        producto.estado = estado
        
        try saveContext()
        return producto
    }
    
    /// Obtiene todos los Productos.
    func fetchProductos() throws -> [Producto] {
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    /// Actualiza un Producto existente.
    func updateProducto(producto: Producto, codigo: String, nombre: String, categoria: String, precio: Double, stock: Int64, estado: Bool) throws {
        guard !codigo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("codigo") }
        guard !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombre") }
        guard !categoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("categoria") }
        guard precio > 0 else { throw ValidationError.invalidPrice }
        guard stock >= 0 else { throw ValidationError.invalidStock }
        
        producto.codigo = codigo
        producto.nombre = nombre
        producto.categoria = categoria
        producto.precio = precio
        producto.stock = stock
        producto.estado = estado
        
        try saveContext()
    }
    
    /// Elimina un Producto.
    func deleteProducto(producto: Producto) throws {
        context.delete(producto)
        try saveContext()
    }
    
    // MARK: - CRUD: Cliente
    
    /// Crea un nuevo Cliente con validaciones de DNI y Correo electrónico.
    func createCliente(idCliente: String, dni: String, nombres: String, apellidos: String, telefono: String, correo: String, direccion: String, estado: Bool) throws -> Cliente {
        // Validaciones generales de campos vacíos
        guard !idCliente.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idCliente") }
        guard !nombres.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombres") }
        guard !apellidos.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("apellidos") }
        guard !telefono.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("telefono") }
        guard !direccion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("direccion") }
        
        // Validación del DNI (Longitud coherente de 8 dígitos numéricos)
        let trimmedDNI = dni.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDNI.count == 8, trimmedDNI.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            throw ValidationError.invalidDNI
        }
        
        // Validación básica de Correo
        let trimmedCorreo = correo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCorreo.contains("@") && trimmedCorreo.contains(".") else {
            throw ValidationError.invalidEmail
        }
        
        let cliente = Cliente(context: context)
        cliente.idCliente = idCliente
        cliente.dni = trimmedDNI
        cliente.nombres = nombres
        cliente.apellidos = apellidos
        cliente.telefono = telefono
        cliente.correo = trimmedCorreo
        cliente.direccion = direccion
        cliente.estado = estado
        
        try saveContext()
        return cliente
    }
    
    /// Obtiene todos los Clientes.
    func fetchClientes() throws -> [Cliente] {
        let fetchRequest: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    /// Actualiza un Cliente existente.
    func updateCliente(cliente: Cliente, dni: String, nombres: String, apellidos: String, telefono: String, correo: String, direccion: String, estado: Bool) throws {
        guard !nombres.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("nombres") }
        guard !apellidos.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("apellidos") }
        guard !telefono.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("telefono") }
        guard !direccion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("direccion") }
        
        let trimmedDNI = dni.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDNI.count == 8, trimmedDNI.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            throw ValidationError.invalidDNI
        }
        
        let trimmedCorreo = correo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCorreo.contains("@") && trimmedCorreo.contains(".") else {
            throw ValidationError.invalidEmail
        }
        
        cliente.dni = trimmedDNI
        cliente.nombres = nombres
        cliente.apellidos = apellidos
        cliente.telefono = telefono
        cliente.correo = trimmedCorreo
        cliente.direccion = direccion
        cliente.estado = estado
        
        try saveContext()
    }
    
    /// Elimina un Cliente.
    func deleteCliente(cliente: Cliente) throws {
        context.delete(cliente)
        try saveContext()
    }
    
    // MARK: - CRUD: Venta
    
    /// Crea una nueva Venta validando el stock disponible del Producto.
    func createVenta(idVenta: String, fechaVenta: Date = Date(), cantidad: Int64, precio: Double, subtotal: Double, igv: Double, total: Double, productoId: String) throws -> Venta {
        // Validaciones generales
        guard !idVenta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idVenta") }
        guard cantidad > 0 else { throw ValidationError.invalidQuantity }
        
        // Control de stock: buscar el producto por id
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idProducto == %@", productoId)
        
        guard let producto = try context.fetch(fetchRequest).first else {
            throw ValidationError.productNotFound
        }
        
        // Validar si hay stock disponible
        guard producto.stock >= cantidad else {
            throw ValidationError.insufficientStock(currentStock: producto.stock, requested: cantidad)
        }
        
        // Disminuir el stock en el Producto
        producto.stock -= cantidad
        
        let venta = Venta(context: context)
        venta.idVenta = idVenta
        venta.fechaVenta = fechaVenta
        venta.cantidad = cantidad
        venta.precio = precio
        venta.subtotal = subtotal
        venta.igv = igv
        venta.total = total
        
        try saveContext()
        return venta
    }
    
    /// Obtiene todas las Ventas.
    func fetchVentas() throws -> [Venta] {
        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    /// Actualiza una Venta existente.
    func updateVenta(venta: Venta, cantidad: Int64, precio: Double, subtotal: Double, igv: Double, total: Double) throws {
        guard cantidad > 0 else { throw ValidationError.invalidQuantity }
        
        venta.cantidad = cantidad
        venta.precio = precio
        venta.subtotal = subtotal
        venta.igv = igv
        venta.total = total
        
        try saveContext()
    }
    
    /// Elimina una Venta.
    func deleteVenta(venta: Venta) throws {
        context.delete(venta)
        try saveContext()
    }
    
    // MARK: - CRUD: Ubicacion
    
    /// Crea una nueva Ubicacion con validaciones.
    func createUbicacion(idUbicacion: String, latitud: Double, longitud: Double, direccionReferencia: String, fechaRegistro: Date = Date()) throws -> Ubicacion {
        // Validaciones
        guard !idUbicacion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idUbicacion") }
        guard !direccionReferencia.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("direccionReferencia") }
        
        let ubicacion = Ubicacion(context: context)
        ubicacion.idUbicacion = idUbicacion
        ubicacion.latitud = latitud
        ubicacion.longitud = longitud
        ubicacion.direccionReferencia = direccionReferencia
        ubicacion.fechaRegistro = fechaRegistro
        
        try saveContext()
        return ubicacion
    }
    
    /// Obtiene todas las Ubicaciones.
    func fetchUbicaciones() throws -> [Ubicacion] {
        let fetchRequest: NSFetchRequest<Ubicacion> = Ubicacion.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    /// Actualiza una Ubicacion existente.
    func updateUbicacion(ubicacion: Ubicacion, latitud: Double, longitud: Double, direccionReferencia: String) throws {
        guard !direccionReferencia.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("direccionReferencia") }
        
        ubicacion.latitud = latitud
        ubicacion.longitud = longitud
        ubicacion.direccionReferencia = direccionReferencia
        
        try saveContext()
    }
    
    /// Elimina una Ubicacion.
    func deleteUbicacion(ubicacion: Ubicacion) throws {
        context.delete(ubicacion)
        try saveContext()
    }
}
