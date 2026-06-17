import SwiftUI

struct ConfiguracionView: View {

    @State private var notificacionesActivas: Bool = true
    @State private var modoOffline: Bool = false
    @State private var idiomaSeleccionado: String = "Español"

    let idiomas = ["Español", "Inglés"]

    var body: some View {
        Form {

            Section(header: Text("Configuración de la Aplicación")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)) {

                Toggle(isOn: $notificacionesActivas) {
                    Label {
                        Text("Notificaciones Push")
                    } icon: {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.red)
                    }
                }
                .tint(.blue)

                Toggle(isOn: $modoOffline) {
                    Label {
                        Text("Modo Desconectado (Offline)")
                    } icon: {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.orange)
                    }
                }
                .tint(.blue)

                Picker(selection: $idiomaSeleccionado, label:
                        Label {
                            Text("Idioma de la aplicación")
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                        }
                ) {
                    ForEach(idiomas, id: \.self) { idioma in
                        Text(idioma).tag(idioma)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(header: Text("Acerca de (Créditos)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)) {

                HStack {
                    Label {
                        Text("Nombre de la App")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "app.badge.fill")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("TecStore Manager")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label {
                        Text("Versión")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("1.0.0 (Production)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label {
                        Text("Institución")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "graduationcap.fill")
                            .foregroundColor(.purple)
                    }
                    Spacer()
                    Text("Tecsup")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label {
                        Text("Curso")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(.teal)
                    }
                    Spacer()
                    Text("Integrador iOS")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label {
                        Text("Desarrollador")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Text("Fabrizio Luna Cordova")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }

                HStack {
                    Label {
                        Text("Docente")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "person.badge.key.fill")
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Text("Juan León")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConfiguracionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConfiguracionView()
        }
    }
}
