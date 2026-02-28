import SwiftUI

struct Logro: Identifiable, Equatable {
    let id:           String
    let titulo:       LocalizedStringKey
    let descripcion:  LocalizedStringKey
    let emoji:        String
    var desbloqueado: Bool = false

    // MARK: Catálogo
    // TODO: Ver si puedo hacer esto más dinámico o, cuando menos, meter más
    static let catalogo: [Logro] = [
        Logro(id: "primer_rayo",
              titulo:      Textos.Logros.primerRayoTitulo,
              descripcion: Textos.Logros.primerRayoDesc,
              emoji: "☀️"),
        Logro(id: "racha_3",
              titulo:      Textos.Logros.racha3Titulo,
              descripcion: Textos.Logros.racha3Desc,
              emoji: "🔥"),
        Logro(id: "semana",
              titulo:      Textos.Logros.semanaTitulo,
              descripcion: Textos.Logros.semanaDesc,
              emoji: "⭐️"),
        Logro(id: "devoto",
              titulo:      Textos.Logros.devotoTitulo,
              descripcion: Textos.Logros.devotoDesc,
              emoji: "🌤️"),
        Logro(id: "mes",
              titulo:      Textos.Logros.mesTitulo,
              descripcion: Textos.Logros.mesDesc,
              emoji: "🏆"),
    ]

    // MARK: Evaluar logros contra el historial
    static func evaluar(sesiones: [SesionSolar]) -> [Logro] {
        let completadas = sesiones.filter { $0.completada }
        let racha       = rachaActual(de: completadas)

        return catalogo.map { logro in
            var l = logro
            switch logro.id {
            case "primer_rayo": l.desbloqueado = completadas.count >= 1
            case "racha_3":     l.desbloqueado = racha >= 3
            case "semana":      l.desbloqueado = racha >= 7
            case "devoto":      l.desbloqueado = completadas.count >= 8
            case "mes":         l.desbloqueado = racha >= 30
            default: break
            }
            return l
        }
    }

    // MARK: Cálculo de racha
    static func rachaActual(de sesiones: [SesionSolar]) -> Int {
        let calendario = Calendar.current
        let diasUnicos = Set(sesiones.map { calendario.startOfDay(for: $0.fecha) })
            .sorted(by: >)

        var racha      = 0
        var diaAComprobar = calendario.startOfDay(for: .now)

        for dia in diasUnicos {
            if dia == diaAComprobar {
                racha += 1
                diaAComprobar = calendario.date(byAdding: .day, value: -1, to: diaAComprobar)!
            } else if dia < diaAComprobar {
                break
            }
        }
        return racha
    }

    // Equatable manual por LocalizedStringKey
    static func == (lhs: Logro, rhs: Logro) -> Bool {
        lhs.id == rhs.id && lhs.desbloqueado == rhs.desbloqueado
    }
}
