import SwiftData
import Foundation

@Model
final class SesionSolar {
    var id:               UUID
    var fecha:            Date
    var duracionSegundos: Int
    var completada:       Bool
    var indiceUV:         Double
    var temperatura:      Double
    var ubicacion:        String?

    init(
        fecha:            Date    = .now,
        duracionSegundos: Int     = 0,
        completada:       Bool    = false,
        indiceUV:         Double  = 0,
        temperatura:      Double  = 0,
        ubicacion:        String? = nil
    ) {
        self.id               = UUID()
        self.fecha            = fecha
        self.duracionSegundos = duracionSegundos
        self.completada       = completada
        self.indiceUV         = indiceUV
        self.temperatura      = temperatura
        self.ubicacion        = ubicacion
    }

    var duracionFormateada: String {
        let mins = duracionSegundos / 60
        let segs = duracionSegundos % 60
        return mins > 0 ? "\(mins) min \(segs)s" : "\(segs)s"
    }

    var esHoy: Bool {
        Calendar.current.isDateInToday(fecha)
    }
}
