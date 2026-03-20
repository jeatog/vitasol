import Testing
import Foundation
@testable import Vitasol

// MARK: Tests de propiedades calculadas de GestorSesion

@Suite("GestorSesion — propiedades calculadas")
struct GestorSesionTests {

    @MainActor
    @Test("Progreso es 0 al inicio")
    func progresoInicio() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 0
        gestor.segundosObjetivo = 600
        #expect(gestor.progreso == 0.0)
    }

    @MainActor
    @Test("Progreso es 0.5 a la mitad")
    func progresoMitad() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 300
        gestor.segundosObjetivo = 600
        #expect(gestor.progreso == 0.5)
    }

    @MainActor
    @Test("Progreso clampea a 1.0 si se excede")
    func progresoExcedido() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 700
        gestor.segundosObjetivo = 600
        #expect(gestor.progreso == 1.0)
    }

    @MainActor
    @Test("Progreso es 0 cuando objetivo es 0 (evita división por cero)")
    func progresoObjetivoCero() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 0
        gestor.segundosObjetivo = 0
        #expect(gestor.progreso == 0)
    }

    @MainActor
    @Test("Segundos restantes calcula correctamente")
    func segundosRestantes() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 200
        gestor.segundosObjetivo = 600
        #expect(gestor.segundosRestantes == 400)
    }

    @MainActor
    @Test("Segundos restantes clampea a 0 si se excede")
    func segundosRestantesExcedido() {
        let gestor = GestorSesion()
        gestor.segundosSesion = 700
        gestor.segundosObjetivo = 600
        #expect(gestor.segundosRestantes == 0)
    }

    @MainActor
    @Test("tiempoTexto formatea MM:SS correctamente")
    func tiempoTexto() {
        let gestor = GestorSesion()
        gestor.segundosObjetivo = 600

        gestor.segundosSesion = 0
        #expect(gestor.tiempoTexto == "10:00")

        gestor.segundosSesion = 535
        #expect(gestor.tiempoTexto == "01:05")

        gestor.segundosSesion = 600
        #expect(gestor.tiempoTexto == "00:00")
    }
}
