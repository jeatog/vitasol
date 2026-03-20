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

    private func sesion(
        diasAtras: Int,
        completada: Bool = true,
        duracion: Int = 600,
        uv: Double = 4.0,
        ubicacion: String? = nil
    ) -> SesionSolar {
        let fecha = Calendar.current.date(byAdding: .day, value: -diasAtras, to: .now)!
        return SesionSolar(
            fecha: fecha,
            duracionSegundos: duracion,
            completada: completada,
            indiceUV: uv,
            ubicacion: ubicacion
        )
    }

    private func sesionConHora(_ hora: Int, completada: Bool = true) -> SesionSolar {
        var componentes = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        componentes.hour = hora
        componentes.minute = 30
        let fecha = Calendar.current.date(from: componentes) ?? .now
        return SesionSolar(fecha: fecha, duracionSegundos: 600, completada: completada)
    }

    private func logrosDesbloqueados(_ sesiones: [SesionSolar]) -> Set<String> {
        Set(Logro.evaluar(sesiones: sesiones).filter { $0.desbloqueado }.map { $0.id })
    }

    // MARK: Logros originales

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
        let sesiones = [0, 2, 4, 6, 8, 10, 12, 14].map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("primer_rayo"))
        #expect(ids.contains("devoto"))
        #expect(!ids.contains("racha_3"))
    }

    @Test("Racha de 7 desbloquea semana")
    func rachaSemana() {
        let sesiones = (0..<7).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("semana"))
    }

    // MARK: Logros de racha nuevos

    @Test("Racha de 14 desbloquea racha_14")
    func racha14() {
        let sesiones = (0..<14).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("racha_14"))
        #expect(!ids.contains("mes"))
    }

    @Test("Racha de 30 desbloquea mes")
    func rachaMes() {
        let sesiones = (0..<30).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("mes"))
        #expect(!ids.contains("racha_60"))
    }

    @Test("Racha de 60 desbloquea racha_60")
    func racha60() {
        let sesiones = (0..<60).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("racha_60"))
    }

    // MARK: Logros de volumen

    @Test("100 sesiones desbloquean centenario")
    func centenario() {
        let sesiones = (0..<100).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("centenario"))
    }

    @Test("99 sesiones no desbloquean centenario")
    func centenarioInsuficiente() {
        let sesiones = (0..<99).map { sesion(diasAtras: $0) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(!ids.contains("centenario"))
    }

    @Test("10 horas acumuladas desbloquean diez_horas")
    func diezHoras() {
        // 60 sesiones de 600s = 36000s = 10h
        let sesiones = (0..<60).map { sesion(diasAtras: $0, duracion: 600) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("diez_horas"))
    }

    @Test("Menos de 10 horas no desbloquea diez_horas")
    func diezHorasInsuficiente() {
        // 59 sesiones de 600s = 35400s < 36000s
        let sesiones = (0..<59).map { sesion(diasAtras: $0, duracion: 600) }
        let ids = logrosDesbloqueados(sesiones)
        #expect(!ids.contains("diez_horas"))
    }

    // MARK: Logros de horario

    @Test("Sesión antes de las 9 AM desbloquea madrugador")
    func madrugador() {
        let ids = logrosDesbloqueados([sesionConHora(8)])
        #expect(ids.contains("madrugador"))
    }

    @Test("Sesión a las 9 AM no desbloquea madrugador")
    func madrugadorLimite() {
        let ids = logrosDesbloqueados([sesionConHora(9)])
        #expect(!ids.contains("madrugador"))
    }

    @Test("Sesión entre 12 y 14 desbloquea mediodia")
    func mediodia() {
        let ids = logrosDesbloqueados([sesionConHora(12)])
        #expect(ids.contains("mediodia"))
    }

    @Test("Sesión a las 14 no desbloquea mediodia")
    func mediodiaLimite() {
        let ids = logrosDesbloqueados([sesionConHora(14)])
        #expect(!ids.contains("mediodia"))
    }

    // MARK: Logros de exploración

    @Test("3 ubicaciones distintas desbloquean trotamundos")
    func trotamundos() {
        let sesiones = [
            sesion(diasAtras: 0, ubicacion: "Ciudad A"),
            sesion(diasAtras: 1, ubicacion: "Ciudad B"),
            sesion(diasAtras: 2, ubicacion: "Ciudad C"),
        ]
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("trotamundos"))
    }

    @Test("2 ubicaciones no desbloquean trotamundos")
    func trotamundosInsuficiente() {
        let sesiones = [
            sesion(diasAtras: 0, ubicacion: "Ciudad A"),
            sesion(diasAtras: 1, ubicacion: "Ciudad B"),
        ]
        let ids = logrosDesbloqueados(sesiones)
        #expect(!ids.contains("trotamundos"))
    }

    @Test("UV >= 8 desbloquea uv_extremo")
    func uvExtremo() {
        let ids = logrosDesbloqueados([sesion(diasAtras: 0, uv: 8.0)])
        #expect(ids.contains("uv_extremo"))
    }

    @Test("UV < 8 no desbloquea uv_extremo")
    func uvExtremoInsuficiente() {
        let ids = logrosDesbloqueados([sesion(diasAtras: 0, uv: 7.9)])
        #expect(!ids.contains("uv_extremo"))
    }

    // MARK: Fin de semana

    @Test("Sábado y domingo consecutivos desbloquean fin_de_semana")
    func finDeSemana() {
        let calendario = Calendar.current
        // Buscar el sábado más reciente
        var fecha = Date.now
        while calendario.component(.weekday, from: fecha) != 7 {
            fecha = calendario.date(byAdding: .day, value: -1, to: fecha)!
        }
        let sabado = fecha
        let domingo = calendario.date(byAdding: .day, value: 1, to: sabado)!

        let sesiones = [
            SesionSolar(fecha: sabado, duracionSegundos: 600, completada: true),
            SesionSolar(fecha: domingo, duracionSegundos: 600, completada: true),
        ]
        let ids = logrosDesbloqueados(sesiones)
        #expect(ids.contains("fin_de_semana"))
    }

    @Test("Solo sábado no desbloquea fin_de_semana")
    func finDeSemanaSoloSabado() {
        let calendario = Calendar.current
        var fecha = Date.now
        while calendario.component(.weekday, from: fecha) != 7 {
            fecha = calendario.date(byAdding: .day, value: -1, to: fecha)!
        }
        let sesiones = [
            SesionSolar(fecha: fecha, duracionSegundos: 600, completada: true),
        ]
        let ids = logrosDesbloqueados(sesiones)
        #expect(!ids.contains("fin_de_semana"))
    }
}
