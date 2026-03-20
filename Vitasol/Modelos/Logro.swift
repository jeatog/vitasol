import SwiftUI

struct Logro: Identifiable, Equatable {
    let id:           String
    let titulo:       LocalizedStringKey
    let descripcion:  LocalizedStringKey
    let icono:        String
    let colorIcono:   Color
    var desbloqueado: Bool = false

    // MARK: Catálogo
    static let catalogo: [Logro] = [
        // Primeros pasos
        Logro(id: "primer_rayo",
              titulo:      Textos.Logros.primerRayoTitulo,
              descripcion: Textos.Logros.primerRayoDesc,
              icono: "sun.max.fill", colorIcono: .ambar),

        // Constancia — rachas
        Logro(id: "racha_3",
              titulo:      Textos.Logros.racha3Titulo,
              descripcion: Textos.Logros.racha3Desc,
              icono: "flame.fill", colorIcono: .orange),
        Logro(id: "semana",
              titulo:      Textos.Logros.semanaTitulo,
              descripcion: Textos.Logros.semanaDesc,
              icono: "star.fill", colorIcono: .dorado),
        Logro(id: "racha_14",
              titulo:      Textos.Logros.racha14Titulo,
              descripcion: Textos.Logros.racha14Desc,
              icono: "bolt.fill", colorIcono: .ambar),
        Logro(id: "mes",
              titulo:      Textos.Logros.mesTitulo,
              descripcion: Textos.Logros.mesDesc,
              icono: "trophy.fill", colorIcono: .dorado),
        Logro(id: "racha_60",
              titulo:      Textos.Logros.racha60Titulo,
              descripcion: Textos.Logros.racha60Desc,
              icono: "crown.fill", colorIcono: .ambar),

        // Volumen
        Logro(id: "devoto",
              titulo:      Textos.Logros.devotoTitulo,
              descripcion: Textos.Logros.devotoDesc,
              icono: "sun.horizon.fill", colorIcono: .dorado),
        Logro(id: "centenario",
              titulo:      Textos.Logros.centenarioTitulo,
              descripcion: Textos.Logros.centenarioDesc,
              icono: "sparkles", colorIcono: .ambar),
        Logro(id: "diez_horas",
              titulo:      Textos.Logros.diezHorasTitulo,
              descripcion: Textos.Logros.diezHorasDesc,
              icono: "clock.badge.checkmark.fill", colorIcono: .salvia),

        // Horario
        Logro(id: "madrugador",
              titulo:      Textos.Logros.madrugadorTitulo,
              descripcion: Textos.Logros.madrugadorDesc,
              icono: "sunrise.fill", colorIcono: .dorado),
        Logro(id: "mediodia",
              titulo:      Textos.Logros.medioDiaTitulo,
              descripcion: Textos.Logros.medioDiaDesc,
              icono: "sun.max.trianglebadge.exclamationmark.fill", colorIcono: .orange),

        // Exploración
        Logro(id: "trotamundos",
              titulo:      Textos.Logros.trotamundosTitulo,
              descripcion: Textos.Logros.trotamundosDesc,
              icono: "map.fill", colorIcono: .salvia),
        Logro(id: "uv_extremo",
              titulo:      Textos.Logros.uvExtremoTitulo,
              descripcion: Textos.Logros.uvExtremoDesc,
              icono: "sun.max.trianglebadge.exclamationmark", colorIcono: .uvMuyAlto),

        // Fin de semana
        Logro(id: "fin_de_semana",
              titulo:      Textos.Logros.finDeSemanaTitulo,
              descripcion: Textos.Logros.finDeSemanaDesc,
              icono: "figure.walk", colorIcono: .salvia),
    ]

    // MARK: Evaluar logros contra el historial
    static func evaluar(sesiones: [SesionSolar]) -> [Logro] {
        let completadas    = sesiones.filter { $0.completada }
        let racha          = rachaActual(de: completadas)
        let totalSegundos  = completadas.reduce(0) { $0 + $1.duracionSegundos }
        let ubicaciones    = Set(completadas.compactMap { $0.ubicacion })
        let calendario     = Calendar.current

        return catalogo.map { logro in
            var l = logro
            switch logro.id {
            case "primer_rayo":    l.desbloqueado = completadas.count >= 1
            case "racha_3":        l.desbloqueado = racha >= 3
            case "semana":         l.desbloqueado = racha >= 7
            case "racha_14":       l.desbloqueado = racha >= 14
            case "mes":            l.desbloqueado = racha >= 30
            case "racha_60":       l.desbloqueado = racha >= 60
            case "devoto":         l.desbloqueado = completadas.count >= 8
            case "centenario":     l.desbloqueado = completadas.count >= 100
            case "diez_horas":     l.desbloqueado = totalSegundos >= 36000
            case "madrugador":
                l.desbloqueado = completadas.contains {
                    calendario.component(.hour, from: $0.fecha) < 9
                }
            case "mediodia":
                l.desbloqueado = completadas.contains {
                    let hora = calendario.component(.hour, from: $0.fecha)
                    return hora >= 12 && hora < 14
                }
            case "trotamundos":    l.desbloqueado = ubicaciones.count >= 3
            case "uv_extremo":
                l.desbloqueado = completadas.contains { $0.indiceUV >= 8 }
            case "fin_de_semana":
                l.desbloqueado = tieneFinDeSemanaConsecutivo(completadas)
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
                guard let anterior = calendario.date(byAdding: .day, value: -1, to: diaAComprobar) else { break }
                diaAComprobar = anterior
            } else if dia < diaAComprobar {
                break
            }
        }
        return racha
    }

    // MARK: Fin de semana consecutivo (sábado + domingo)
    private static func tieneFinDeSemanaConsecutivo(_ sesiones: [SesionSolar]) -> Bool {
        let calendario = Calendar.current
        let diasCompletados = Set(sesiones.map { calendario.startOfDay(for: $0.fecha) })

        for dia in diasCompletados {
            let diaSemana = calendario.component(.weekday, from: dia)
            if diaSemana == 7, // sábado
               let domingo = calendario.date(byAdding: .day, value: 1, to: dia),
               diasCompletados.contains(calendario.startOfDay(for: domingo)) {
                return true
            }
        }
        return false
    }

    // Equatable manual por LocalizedStringKey
    static func == (lhs: Logro, rhs: Logro) -> Bool {
        lhs.id == rhs.id && lhs.desbloqueado == rhs.desbloqueado
    }
}
