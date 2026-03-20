import Testing
import Foundation
@testable import Vitasol

// MARK: Tests de SesionSolar

@Suite("SesionSolar — propiedades calculadas")
struct SesionSolarTests {

    @Test("duracionFormateada con solo segundos")
    func soloSegundos() {
        let sesion = SesionSolar(duracionSegundos: 45)
        #expect(sesion.duracionFormateada == "45s")
    }

    @Test("duracionFormateada con minutos y segundos")
    func minutosYSegundos() {
        let sesion = SesionSolar(duracionSegundos: 125)
        #expect(sesion.duracionFormateada == "2 min 5s")
    }

    @Test("duracionFormateada con minutos exactos")
    func minutosExactos() {
        let sesion = SesionSolar(duracionSegundos: 600)
        #expect(sesion.duracionFormateada == "10 min 0s")
    }

    @Test("duracionFormateada con 0 segundos")
    func ceroSegundos() {
        let sesion = SesionSolar(duracionSegundos: 0)
        #expect(sesion.duracionFormateada == "0s")
    }

    @Test("esHoy retorna true para sesión de hoy")
    func esHoyVerdadero() {
        let sesion = SesionSolar(fecha: .now)
        #expect(sesion.esHoy)
    }

    @Test("esHoy retorna false para sesión de ayer")
    func esHoyFalso() {
        let ayer = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let sesion = SesionSolar(fecha: ayer)
        #expect(!sesion.esHoy)
    }
}

// MARK: Tests de UVCategoria

@Suite("UVCategoria — rangos y filtros")
struct UVCategoriaTests {

    @Test("Rangos cubren todo el espectro sin huecos")
    func sinHuecos() {
        let valoresPrueba = [0.0, 1.0, 2.0, 2.5, 2.99, 3.0, 5.5, 5.99, 6.0, 7.5, 7.99, 8.0, 15.0, 20.0]
        for valor in valoresPrueba {
            let coincide = UVCategoria.allCases.contains { $0.contiene(valor) }
            #expect(coincide, "UV \(valor) debería pertenecer a alguna categoría")
        }
    }

    @Test("UV 2.5 pertenece a bajo")
    func uvDecimalBajo() {
        #expect(UVCategoria.bajo.contiene(2.5))
    }

    @Test("UV 5.5 pertenece a medio")
    func uvDecimalMedio() {
        #expect(UVCategoria.medio.contiene(5.5))
    }

    @Test("UV 7.5 pertenece a alto")
    func uvDecimalAlto() {
        #expect(UVCategoria.alto.contiene(7.5))
    }

    @Test("UV 10.0 pertenece a muyAlto")
    func uvMuyAlto() {
        #expect(UVCategoria.muyAlto.contiene(10.0))
    }
}
