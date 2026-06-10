//
//  ReportesView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

import SwiftUI
import CoreData

struct ReportesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Obtener todas las ventas, clientes y productos
    @FetchRequest(sortDescriptors: []) private var ventas: FetchedResults<Venta>
    @FetchRequest(sortDescriptors: []) private var clientes: FetchedResults<Cliente>
    @FetchRequest(sortDescriptors: []) private var productos: FetchedResults<Producto>
    
    // 1. CÁLCULO EN TIEMPO REAL: Ventas totales
    private var totalVentasCount: Int {
        ventas.count
    }
    
    // 2. CÁLCULO EN TIEMPO REAL: Monto total vendido
    private var totalMontoVendido: Double {
        ventas.reduce(0.0) { $0 + $1.total }
    }
    
    // 3. CÁLCULO EN TIEMPO REAL: Clientes registrados
    private var totalClientesCount: Int {
        clientes.count
    }
    
    // 4. CÁLCULO EN TIEMPO REAL: Producto con menor stock
    private var productoMenorStockInfo: (nombre: String, stock: Int64) {
        guard !productos.isEmpty else {
            return ("Ninguno", 0)
        }
        
        // Encontrar el producto con menor stock
        if let minProd = productos.min(by: { $0.stock < $1.stock }) {
            return (minProd.nombre ?? "Sin Nombre", minProd.stock)
        }
        
        return ("Ninguno", 0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cabecera del Dashboard
                VStack(spacing: 8) {
                    Text("Resumen Estadístico")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Indicadores de rendimiento clave basados en Core Data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
                
                // Tarjeta: Monto Vendido
                MetricCard(
                    title: "Monto Total Vendido",
                    value: String(format: "S/. %.2f", totalMontoVendido),
                    subtitle: "Ingresos brutos acumulados",
                    systemIcon: "dollarsign.circle.fill",
                    iconColor: .green
                )
                
                // Tarjeta: Ventas Totales
                MetricCard(
                    title: "Ventas Totales",
                    value: "\(totalVentasCount)",
                    subtitle: "Transacciones procesadas",
                    systemIcon: "chart.bar.fill",
                    iconColor: .blue
                )
                
                // Tarjeta: Clientes Registrados
                MetricCard(
                    title: "Clientes Registrados",
                    value: "\(totalClientesCount)",
                    subtitle: "Base de datos de clientes",
                    systemIcon: "person.3.fill",
                    iconColor: .purple
                )
                
                // Tarjeta: Alerta de Inventario (Menor Stock)
                let menorStock = productoMenorStockInfo
                MetricCard(
                    title: "Producto con Menor Stock",
                    value: menorStock.nombre,
                    subtitle: "Unidades disponibles: \(menorStock.stock)",
                    systemIcon: "exclamationmark.triangle.fill",
                    iconColor: menorStock.stock < 5 ? .red : .orange
                )
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reportes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - MetricCard Component

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemIcon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono destacado
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: systemIcon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            // Textos descriptivos
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Preview

struct ReportesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReportesView()
        }
    }
}
