import SwiftUI
import SwiftData

@main
struct VitasolApp: App {
    @StateObject private var gestorSesion         = GestorSesion()
    @StateObject private var gestorNotificaciones = GestorNotificaciones()
    @StateObject private var gestorUbicacion      = GestorUbicacion()
    @StateObject private var gestorSalud          = GestorSalud()
    @StateObject private var gestorTema           = GestorTema()
    @StateObject private var gestorClima          = GestorClima()

    /// Persiste el idioma elegido por el usuario (es / en)
    @AppStorage("idiomaApp") private var idiomaApp = "es"

    var body: some Scene {
        WindowGroup {
            VistaPrincipal()
                .environmentObject(gestorSesion)
                .environmentObject(gestorNotificaciones)
                .environmentObject(gestorUbicacion)
                .environmentObject(gestorSalud)
                .environmentObject(gestorTema)
                .environmentObject(gestorClima)
                .environment(\.locale, Locale(identifier: idiomaApp))
                .preferredColorScheme(gestorTema.esquema)
                .onOpenURL { url in
                    if url.host == "detener" {
                        gestorSesion.detener()
                    } else if url.host == "sesion" {
                        gestorSesion.navegarASesion = true
                    }
                }
        }
        .modelContainer(for: SesionSolar.self)
    }
}
