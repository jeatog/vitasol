import ActivityKit
import Foundation

struct SesionSolarActividad: ActivityAttributes {

    // Estado dinámico (actualizable durante la actividad)
    struct ContentState: Codable, Hashable {
        var progreso: Double   // 0.0 – 1.0  (para el arco del DI)
        var fechaFin: Date     // cuándo termina la sesión
    }

    // Atributos estáticos
    var duracionSegundos: Int
    var idioma: String
}
