import Testing
import Foundation
@testable import Vitasol

// MARK: Tests de Logro.rachaActual(de:)

@Suite("Racha actual")
struct RachaActualTests {

    private func sesion(diasAtras: Int, completada: Bool = true) -> SesionSolar {
        let fecha = Calendar.current.date(byAdding: .day, value: -diasAtras, to: .now)!
        return SesionSolar(fecha: fecha, duracionSegundos: 600, completada: completada)
    }

    @Test("Sin sesiones retorna racha 0")
    func sinSesiones() {
        #expect(Logro.rachaActual(de: []) == 0)
    }

    @Test("Solo sesión de hoy retorna racha 1")
    func soloHoy() {
        let sesiones = [sesion(diasAtras: 0)]
        #expect(Logro.rachaActual(de: sesiones) == 1)
    }

    @Test("Tres días consecutivos retorna racha 3")
    func tresDiasConsecutivos() {
        let sesiones = [sesion(diasAtras: 0), sesion(diasAtras: 1), sesion(diasAtras: 2)]
        #expect(Logro.rachaActual(de: sesiones) == 3)
    }

    @Test("Hueco en la racha corta el conteo")
    func huecoEnRacha() {
        // Hoy y hace 2 días (falta ayer)
        let sesiones = [sesion(diasAtras: 0), sesion(diasAtras: 2)]
        #expect(Logro.rachaActual(de: sesiones) == 1)
    }

    @Test("Múltiples sesiones en un mismo día cuentan como 1")
    func multiplesSesionesUnDia() {
        let sesiones = [
            sesion(diasAtras: 0), sesion(diasAtras: 0), sesion(diasAtras: 0),
            sesion(diasAtras: 1)
        ]
        #expect(Logro.rachaActual(de: sesiones) == 2)
    }

    @Test("Sin sesión hoy retorna racha 0")
    func sinSesionHoy() {
        // Solo ayer y anteayer
        let sesiones = [sesion(diasAtras: 1), sesion(diasAtras: 2)]
        #expect(Logro.rachaActual(de: sesiones) == 0)
    }

    @Test("Racha de 30 días consecutivos")
    func racha30Dias() {
        let sesiones = (0..<30).map { sesion(diasAtras: $0) }
        #expect(Logro.rachaActual(de: sesiones) == 30)
    }

    @Test("Sesiones desordenadas no afectan el resultado")
    func sesionesDesordenadas() {
        let sesiones = [sesion(diasAtras: 2), sesion(diasAtras: 0), sesion(diasAtras: 1)]
        #expect(Logro.rachaActual(de: sesiones) == 3)
    }
}

// MARK: Tests de Logro.evaluar(sesiones:)

@Suite("Evaluación de logros")
struct EvaluarLogrosTests {

    private func sesion(diasAtras: Int, completada: Bool = true) -> SesionSolar {
        let fecha = Calendar.current.date(byAdding: .day, value: -diasAtras, to: .now)!
        return SesionSolar(fecha: fecha, duracionSegundos: 600, completada: completada)
    }

    private func logrosDesbloqueados(_ sesiones: [SesionSolar]) -> Set<String> {
        Set(Logro.evaluar(sesiones: sesiones).filter { $0.desbloqueado }.map { $0.id })
    }

    @Test("Sin sesiones ningún logro desbloqueado")
    func sinSesiones() {
        #expect(logrosDesbloqueados([]).isEmpty)
    }

    @Test("Una sesión completada desbloquea primer_rayo")
    func primerRayo() {
        let ids = logrosDesbloqueados([sesion(diasAtras: 0)])
        #expect(ids.contains("primer_rayo"))
        #expect(!ids.contains("racha_3"))
    }

    @Test("Sesión no completada no desbloquea nada")
    func sesionNoCompletada() {
        let ids = logrosDesbloqueados([sesion(diasAtras: 0, completada: false)])
        #expect(ids.isEmpty)
    }

    @Test("8 sesiones sin racha desbloquean primer_rayo y devoto")
    func devotoSinRacha() {
        // 8 sesiones en días alternos (sin racha de 3)
        let sesiones = [0, 2, 4, 6, 8, 10, 12, 14].map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("primer_rayo"))
        #expect(ids.contains("devoto"))
        #expect(!ids.contains("racha_3"))
    }

    @Test("Racha de 7 desbloquea primer_rayo, racha_3 y semana")
    func rachaSemana() {
        let sesiones = (0..<7).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("primer_rayo"))
        #expect(ids.contains("racha_3"))
        #expect(ids.contains("semana"))
    }

    @Test("Racha de 30 desbloquea todos los logros")
    func rachaMes() {
        let sesiones = (0..<30).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids == Set(["primer_rayo", "racha_3", "semana", "devoto", "mes"]))
    }
}
