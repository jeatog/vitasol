import SwiftUI
import SwiftData

@main
struct VitasolApp: App {
    let contenedor: ModelContainer

    @State private var gestorSesion         = GestorSesion()
    @State private var gestorNotificaciones = GestorNotificaciones()
    @State private var gestorUbicacion      = GestorUbicacion()
    @State private var gestorSalud          = GestorSalud()
    @State private var gestorTema           = GestorTema()
    @State private var gestorClima          = GestorClima()

    /// Persiste el idioma elegido por el usuario (es / en)
    @AppStorage("idiomaApp") private var idiomaApp = "es"

    init() {
        do {
            contenedor = try ModelContainer(
                for: SesionSolar.self,
                migrationPlan: PlanMigracionSesion.self
            )
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            VistaPrincipal()
                .environment(gestorSesion)
                .environment(gestorNotificaciones)
                .environment(gestorUbicacion)
                .environment(gestorSalud)
                .environment(gestorTema)
                .environment(gestorClima)
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
        .modelContainer(contenedor)
    }
}
