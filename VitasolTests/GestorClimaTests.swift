import Testing
import Foundation
@testable import Vitasol

// MARK: Tests de mapeos de GestorClima

@Suite("GestorClima — mapeos de clima y UV")
struct GestorClimaTests {

    @MainActor
    @Test("condicion retorna sinDatos cuando codigoClima es nil")
    func condicionSinDatos() {
        let gestor = GestorClima()
        #expect(gestor.condicion == Textos.Clima.sinDatos)
    }

    @MainActor
    @Test("condicion retorna despejado para código 0")
    func condicionDespejado() {
        let gestor = GestorClima()
        gestor.codigoClima = 0
        #expect(gestor.condicion == Textos.Clima.despejado)
    }

    @MainActor
    @Test("condicion retorna nublado para código no mapeado")
    func condicionDefault() {
        let gestor = GestorClima()
        gestor.codigoClima = 10
        #expect(gestor.condicion == Textos.Clima.nublado)
    }

    @MainActor
    @Test("etiquetaUV clasifica correctamente los rangos")
    func etiquetaUV() {
        let gestor = GestorClima()

        gestor.indiceUV = 1.5
        #expect(gestor.etiquetaUV == Textos.Clima.uvBajo)

        gestor.indiceUV = 4.0
        #expect(gestor.etiquetaUV == Textos.Clima.uvMedio)

        gestor.indiceUV = 7.0
        #expect(gestor.etiquetaUV == Textos.Clima.uvAlto)

        gestor.indiceUV = 9.0
        #expect(gestor.etiquetaUV == Textos.Clima.uvMuyAlto)
    }

    @MainActor
    @Test("etiquetaUV trunca (no redondea) — UV 2.9 es bajo")
    func etiquetaUVTruncamiento() {
        let gestor = GestorClima()
        gestor.indiceUV = 2.9
        #expect(gestor.etiquetaUV == Textos.Clima.uvBajo)
    }

    @MainActor
    @Test("esBuenDia requiere UV >= 3 y sin precipitación")
    func esBuenDia() {
        let gestor = GestorClima()

        // Sin datos
        #expect(!gestor.esBuenDia)

        // Despejado con UV alto = buen día
        gestor.indiceUV = 5.0
        gestor.codigoClima = 0
        #expect(gestor.esBuenDia)

        // UV bajo con despejado = mal día
        gestor.indiceUV = 1.0
        #expect(!gestor.esBuenDia)

        // UV alto con lluvia = mal día
        gestor.indiceUV = 5.0
        gestor.codigoClima = 61
        #expect(!gestor.esBuenDia)
    }

    @MainActor
    @Test("esBuenDia es false con UV >= 8 (muy alto)")
    func esBuenDiaUVMuyAlto() {
        let gestor = GestorClima()
        gestor.codigoClima = 0

        gestor.indiceUV = 8.0
        #expect(!gestor.esBuenDia)

        gestor.indiceUV = 10.0
        #expect(!gestor.esBuenDia)
    }

    @MainActor
    @Test("esBuenDia es true con UV 7.9 (justo bajo el límite)")
    func esBuenDiaUVLimite() {
        let gestor = GestorClima()
        gestor.codigoClima = 0

        gestor.indiceUV = 7.9
        #expect(gestor.esBuenDia)

        gestor.indiceUV = 3.0
        #expect(gestor.esBuenDia)

        gestor.indiceUV = 2.9
        #expect(!gestor.esBuenDia)
    }

    @MainActor
    @Test("iconoSistema retorna ícono correcto por código")
    func iconoSistema() {
        let gestor = GestorClima()

        gestor.codigoClima = nil
        #expect(gestor.iconoSistema == "cloud.fill")

        gestor.codigoClima = 0
        #expect(gestor.iconoSistema == "sun.max.fill")

        gestor.codigoClima = 95
        #expect(gestor.iconoSistema == "cloud.bolt.rain.fill")
    }
}
