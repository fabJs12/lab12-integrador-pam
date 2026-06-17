import SwiftUI
import CoreData

struct MainMenuView: View {

    @Environment(\.managedObjectContext) private var viewContext

    var onLogout: (() -> Void)?

    var body: some View {
        NavigationStack {
            List {

                Section(header: Text("Módulos de Gestión")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)) {

                    NavigationLink(destination: ProductoListView()) {
                        Label {
                            Text("Productos")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "cart.fill")
                                .foregroundStyle(.blue)
                        }
                    }

                    NavigationLink(destination: ClienteListView()) {
                        Label {
                            Text("Clientes")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.teal)
                        }
                    }
                }

                Section(header: Text("Operaciones e Informes")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)) {

                    NavigationLink(destination: VentaListView()) {
                        Label {
                            Text("Registro de Ventas")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    NavigationLink(destination: UbicacionMapView()) {
                        Label {
                            Text("Ubicación y Mapa")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "map.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    NavigationLink(destination: ReportesView()) {
                        Label {
                            Text("Reportes")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundStyle(.purple)
                        }
                    }

                    NavigationLink(destination: BusquedaAvanzadaView()) {
                        Label {
                            Text("Búsqueda Avanzada")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }

                Section(header: Text("Ajustes")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)) {

                    NavigationLink(destination: ConfiguracionView()) {
                        Label {
                            Text("Configuración y Acerca de")
                                .font(.body)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button(action: {
                        print("Logout")
                        onLogout?()
                    }) {
                        HStack {
                            Spacer()
                            Label("Cerrar Sesión", systemImage: "power")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Menú Principal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Logout")
                        onLogout?()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
