import UIKit
import CoreData

enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidPrice
    case invalidStock
    case invalidQuantity
    case insufficientStock(currentStock: Int64, requested: Int64)
    case invalidDNI
    case invalidEmail
    case productNotFound
    case customerNotFound

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
        case .customerNotFound:
            return "Cliente no encontrado en el sistema."
        }
    }
}

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    func createUsuario(idUsuario: String, nombreUsuario: String, password: String, nombreCompleto: String, estado: Bool) throws -> Usuario {

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

    func fetchUsuarios() throws -> [Usuario] {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        return try context.fetch(fetchRequest)
    }

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

    func deleteUsuario(usuario: Usuario) throws {
        context.delete(usuario)
        try saveContext()
    }

    func registrarUsuario(nombreUsuario: String, contrasena: String, nombreCompleto: String) throws -> Usuario {
        let idUsuario = UUID().uuidString
        return try createUsuario(idUsuario: idUsuario, nombreUsuario: nombreUsuario, password: contrasena, nombreCompleto: nombreCompleto, estado: true)
    }

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

    func createProducto(idProducto: String, codigo: String, nombre: String, categoria: String, precio: Double, stock: Int64, fechaRegistro: Date = Date(), estado: Bool) throws -> Producto {

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

    func fetchProductos() throws -> [Producto] {
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        return try context.fetch(fetchRequest)
    }

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

    func deleteProducto(producto: Producto) throws {
        context.delete(producto)
        try saveContext()
    }

    func createCliente(idCliente: String, dni: String, nombres: String, apellidos: String, telefono: String, correo: String, direccion: String, estado: Bool) throws -> Cliente {

        guard !idCliente.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idCliente") }
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

    func fetchClientes() throws -> [Cliente] {
        let fetchRequest: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        return try context.fetch(fetchRequest)
    }

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

    func deleteCliente(cliente: Cliente) throws {
        context.delete(cliente)
        try saveContext()
    }

    func createVenta(idVenta: String, fechaVenta: Date, clienteId: String, productosSeleccionados: [(productoId: String, cantidad: Int64)]) throws -> Venta {
        guard !idVenta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("idVenta") }
        guard !productosSeleccionados.isEmpty else { throw ValidationError.emptyField("Carrito vacío") }

        let fetchCliente: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        fetchCliente.predicate = NSPredicate(format: "idCliente == %@", clienteId)
        guard let cliente = try context.fetch(fetchCliente).first else {
            throw ValidationError.customerNotFound
        }

        let venta = Venta(context: context)
        venta.idVenta = idVenta
        venta.fechaVenta = fechaVenta
        venta.cliente = cliente

        var totalSubtotal: Double = 0.0
        var totalCantidad: Int64 = 0

        for seleccion in productosSeleccionados {
            let fetchProducto: NSFetchRequest<Producto> = Producto.fetchRequest()
            fetchProducto.predicate = NSPredicate(format: "idProducto == %@", seleccion.productoId)
            
            guard let producto = try context.fetch(fetchProducto).first else {
                throw ValidationError.productNotFound
            }
            
            guard seleccion.cantidad > 0 else {
                throw ValidationError.invalidQuantity
            }
            
            guard producto.stock >= seleccion.cantidad else {
                throw ValidationError.insufficientStock(currentStock: producto.stock, requested: seleccion.cantidad)
            }
            
            // Disminuir stock
            producto.stock -= seleccion.cantidad
            
            // Crear DetalleVenta
            let detalle = DetalleVenta(context: context)
            detalle.idDetalle = UUID().uuidString
            detalle.cantidad = seleccion.cantidad
            detalle.precioUnitario = producto.precio
            detalle.producto = producto
            detalle.venta = venta
            
            totalSubtotal += producto.precio * Double(seleccion.cantidad)
            totalCantidad += seleccion.cantidad
        }

        venta.cantidad = totalCantidad
        venta.precio = 0.0 // no longer used as single product price, defaults to 0
        venta.subtotal = totalSubtotal
        venta.igv = totalSubtotal * 0.18
        venta.total = totalSubtotal + (totalSubtotal * 0.18)

        try saveContext()
        return venta
    }

    func fetchVentas() throws -> [Venta] {
        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    func updateVenta(venta: Venta, cantidad: Int64, precio: Double, subtotal: Double, igv: Double, total: Double) throws {
        guard cantidad > 0 else { throw ValidationError.invalidQuantity }

        venta.cantidad = cantidad
        venta.precio = precio
        venta.subtotal = subtotal
        venta.igv = igv
        venta.total = total

        try saveContext()
    }

    func deleteVenta(venta: Venta) throws {
        context.delete(venta)
        try saveContext()
    }

    func createUbicacion(idUbicacion: String, latitud: Double, longitud: Double, direccionReferencia: String, fechaRegistro: Date = Date()) throws -> Ubicacion {

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

    func fetchUbicaciones() throws -> [Ubicacion] {
        let fetchRequest: NSFetchRequest<Ubicacion> = Ubicacion.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    func updateUbicacion(ubicacion: Ubicacion, latitud: Double, longitud: Double, direccionReferencia: String) throws {
        guard !direccionReferencia.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ValidationError.emptyField("direccionReferencia") }

        ubicacion.latitud = latitud
        ubicacion.longitud = longitud
        ubicacion.direccionReferencia = direccionReferencia

        try saveContext()
    }

    func deleteUbicacion(ubicacion: Ubicacion) throws {
        context.delete(ubicacion)
        try saveContext()
    }
}
