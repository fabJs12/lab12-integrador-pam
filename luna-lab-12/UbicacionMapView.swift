//
//  UbicacionMapView.swift
//  luna-lab-12
//
//  Created by Antigravity on 9/06/26.
//

/*
 * ==============================================================================
 * ¡IMPORTANTE! NOTA TÉCNICA DE CONFIGURACIÓN DE PERMISOS:
 * 
 * Para que esta pantalla funcione correctamente en simuladores y dispositivos reales
 * y no ocurran bloqueos o cierres inesperados (crashes), DEBES agregar la siguiente
 * clave de privacidad en el archivo Info.plist de Xcode:
 * 
 * Clave (Key): NSLocationWhenInUseUsageDescription
 * Tipo (Type): String
 * Valor (Value): "Esta aplicación requiere acceso al GPS para capturar y registrar tu ubicación y mostrarla en el mapa de entregas."
 * ==============================================================================
 */

import SwiftUI
import MapKit
import CoreLocation
import CoreData

// MARK: - LocationManager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.046374, longitude: -77.042793), // Coordenadas de Lima por defecto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermissionAndStart() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Delegado: Cambios de autorización GPS
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Delegado: Actualización de Coordenadas
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        DispatchQueue.main.async {
            self.location = latestLocation
            self.region = MKCoordinateRegion(
                center: latestLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error en el LocationManager: \(error.localizedDescription)")
    }
}

// MARK: - UbicacionMapView

struct UbicacionMapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest para cargar todas las ubicaciones previamente guardadas en Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ubicacion.fechaRegistro, ascending: false)],
        animation: .default
    ) private var ubicacionesGuardadas: FetchedResults<Ubicacion>
    
    @StateObject private var locationManager = LocationManager()
    
    // Estado de cámara y mapa de iOS 17+
    @State private var position: MapCameraPosition = .automatic
    
    // Campo de texto de Dirección de Referencia
    @State private var direccionReferencia: String = ""
    
    // Gestión de Alertas
    @State private var mensajeAlerta: String = ""
    @State private var mostrarAlertaExito: Bool = false
    @State private var mostrarAlertaError: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Mapa Principal (Usa sintaxis iOS 17+ con marcadores de Core Data)
            Map(position: $position) {
                // Pin dinámico de la ubicación GPS actual
                if let loc = locationManager.location {
                    Marker("Mi Ubicación Actual", systemImage: "person.circle.fill", coordinate: loc.coordinate)
                        .tint(.blue)
                }
                
                // Pines guardados desde Core Data
                ForEach(ubicacionesGuardadas) { guardada in
                    Marker(
                        guardada.direccionReferencia ?? "Ubicación Guardada",
                        coordinate: CLLocationCoordinate2D(latitude: guardada.latitud, longitude: guardada.longitud)
                    )
                    .tint(.red)
                }
            }
            .frame(height: 350)
            .cornerRadius(16)
            .padding()
            
            // Panel inferior de GPS e Inputs
            ScrollView {
                VStack(spacing: 16) {
                    // Visualización de Coordenadas Actuales
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coordenadas GPS Actuales")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        if let loc = locationManager.location {
                            HStack {
                                Label {
                                    Text(String(format: "Lat: %.6f", loc.coordinate.latitude))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                } icon: {
                                    Image(systemName: "safari")
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Label {
                                    Text(String(format: "Lon: %.6f", loc.coordinate.longitude))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                } icon: {
                                    Image(systemName: "safari")
                                        .foregroundColor(.blue)
                                }
                            }
                        } else {
                            HStack {
                                Image(systemName: "location.slash.fill")
                                    .foregroundColor(.gray)
                                Text("Buscando señal GPS...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Input de Dirección de Referencia
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dirección de Referencia")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        TextField("Ej: Av. Las Casuarinas 456, Surco", text: $direccionReferencia)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Botón para Obtener y Guardar Ubicación
                    Button(action: {
                        guardarUbicacionActual()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Obtener y Guardar Ubicación")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Ubicación y Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestLocationPermissionAndStart()
            actualizarPosicionCamara()
        }
        // Alerta de Éxito
        .alert("Guardado", isPresented: $mostrarAlertaExito) {
            Button("Aceptar", role: .cancel) {
                direccionReferencia = ""
            }
        } message: {
            Text(mensajeAlerta)
        }
        // Alerta de Error
        .alert("Error de Ubicación", isPresented: $mostrarAlertaError) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(mensajeAlerta)
        }
    }
    
    // Actualizar la posición de la cámara del mapa
    private func actualizarPosicionCamara() {
        if let currentLoc = locationManager.location {
            position = .region(MKCoordinateRegion(
                center: currentLoc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else if let ultimaGuardada = ubicacionesGuardadas.first {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: ultimaGuardada.latitud, longitude: ultimaGuardada.longitud),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    // Lógica para guardar las coordenadas y la dirección en Core Data
    private func guardarUbicacionActual() {
        // 1. Forzar una actualización de GPS para capturar las coordenadas
        locationManager.requestLocationPermissionAndStart()
        
        guard let loc = locationManager.location else {
            mensajeAlerta = "Aún no se ha capturado la ubicación GPS del dispositivo. Por favor, asegúrate de activar el GPS e inténtalo nuevamente."
            mostrarAlertaError = true
            return
        }
        
        let referenciaLimpia = direccionReferencia.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2. Validar que la dirección de referencia no esté vacía
        guard !referenciaLimpia.isEmpty else {
            mensajeAlerta = "El campo 'Dirección de Referencia' es obligatorio para guardar la ubicación."
            mostrarAlertaError = true
            return
        }
        
        do {
            // 3. Registrar la nueva ubicación en Core Data usando el singleton CoreDataManager
            let idUUID = UUID().uuidString
            _ = try CoreDataManager.shared.createUbicacion(
                idUbicacion: idUUID,
                latitud: loc.coordinate.latitude,
                longitud: loc.coordinate.longitude,
                direccionReferencia: referenciaLimpia,
                fechaRegistro: Date()
            )
            
            // 4. Actualizar la cámara del mapa centrándola en la nueva ubicación guardada
            actualizarPosicionCamara()
            
            // 5. Mostrar confirmación de éxito
            mensajeAlerta = "La ubicación en '\(referenciaLimpia)' ha sido registrada con éxito en el mapa."
            mostrarAlertaExito = true
            
        } catch {
            mensajeAlerta = error.localizedDescription
            mostrarAlertaError = true
        }
    }
}

struct UbicacionMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UbicacionMapView()
        }
    }
}
