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

    @AppStorage("idiomaApp")          private var idiomaApp          = "es"
    @AppStorage("primerLanzamiento") private var primerLanzamiento = true
    @State private var mostrarSplash = true

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
            ZStack {
                Group {
                    if primerLanzamiento {
                        VistaBienvenida()
                    } else {
                        VistaPrincipal()
                    }
                }

                if mostrarSplash {
                    VistaSplash()
                        .ignoresSafeArea()
                        .task {
                            try? await Task.sleep(nanoseconds: 1_400_000_000)
                            withAnimation { mostrarSplash = false }
                        }
                }
            }
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
