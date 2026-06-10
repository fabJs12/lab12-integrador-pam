//
//  VentaDetailView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct VentaDetailView: View {
    let venta: Venta
    
    // Formateador de fecha
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "es_PE")
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cabecera de Boleta / Recibo
                VStack(spacing: 12) {
                    Image(systemName: "doc.plaintext.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                    
                    Text("Comprobante de Pago")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("BOLETA ELECTRÓNICA")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                // Información de Transacción
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detalles de la Transacción")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    FilaInfo(label: "ID de Venta", value: venta.idVenta ?? "N/A")
                    FilaInfo(label: "Fecha y Hora", value: venta.fechaVenta != nil ? dateFormatter.string(from: venta.fechaVenta!) : "N/A")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Desglose de Productos
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detalle de Conceptos")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Producto Transaccionado")
                                .fontWeight(.medium)
                            Text("Cant: \(venta.cantidad)  x  P.U: S/. \(String(format: "%.2f", venta.precio))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Text(String(format: "S/. %.2f", Double(venta.cantidad) * venta.precio))
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Bloques Matemáticos de Cobro
                VStack(spacing: 12) {
                    FilaMonto(label: "Subtotal", value: venta.subtotal)
                    FilaMonto(label: "IGV (18%)", value: venta.igv)
                    
                    Divider()
                    
                    HStack {
                        Text("TOTAL FINAL")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "S/. %.2f", venta.total))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Comprobante")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Subcomponente fila informativa general
struct FilaInfo: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Subcomponente fila montos financieros
struct FilaMonto: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "S/. %.2f", value))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Preview
struct VentaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let model = Venta(context: context)
        model.idVenta = UUID().uuidString
        model.fechaVenta = Date()
        model.cantidad = 3
        model.precio = 85.00
        model.subtotal = 255.00
        model.igv = 45.90
        model.total = 300.90
        
        return NavigationStack {
            VentaDetailView(venta: model)
        }
    }
}
