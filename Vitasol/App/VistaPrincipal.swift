import SwiftUI

struct VistaPrincipal: View {
    @Environment(GestorSesion.self) private var gestorSesion
    @State private var tabSeleccionada = 0
    @AppStorage("idiomaApp") private var idiomaApp = "es"

    var body: some View {
        TabView(selection: $tabSeleccionada) {
            Tab(Textos.Inicio.tabNombre, systemImage: "sun.max.fill", value: 0) {
                VistaInicio(tabSeleccionada: $tabSeleccionada)
            }
            Tab(Textos.Sesion.tabNombre, systemImage: "timer", value: 1) {
                VistaSesion()
            }
            Tab(Textos.Estadisticas.titulo, systemImage: "chart.bar.fill", value: 2) {
                VistaEstadisticas()
            }
            Tab(Textos.Aprender.titulo, systemImage: "book.fill", value: 3) {
                VistaAprender()
            }
            Tab(Textos.Ajustes.titulo, systemImage: "gearshape.fill", value: 4) {
                VistaAjustes()
            }
        }
        .tint(.ambar)
        .environment(\.locale, Locale(identifier: idiomaApp))
        .id(idiomaApp)
        .onChange(of: gestorSesion.navegarASesion) { _, navegar in
            if navegar {
                tabSeleccionada = 1
                gestorSesion.navegarASesion = false
            }
        }
    }
}
