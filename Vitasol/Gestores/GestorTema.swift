import Observation
import SwiftUI

// MARK: Gestor de tema día/noche
// Evalúa la hora cada 60 s y activa el modo noche entre las 19:00 y las 06:30,
// los mismos límites que VistaSesion usa para bloquear sesiones nocturnas.

@Observable
@MainActor
final class GestorTema {

    private(set) var esDeNoche: Bool = false

    private var timer: Timer?

    init() {
        actualizar()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.actualizar() }
        }
    }

    /// ColorScheme que debe aplicarse en la raíz de la app.
    var esquema: ColorScheme { esDeNoche ? .dark : .light }

    /// Determina si es de noche para una hora dada en minutos desde medianoche.
    /// Noche: antes de las 6:30 (390 min) o desde las 19:00 (1140 min).
    static func calcularEsDeNoche(minutosDia: Int) -> Bool {
        minutosDia < 390 || minutosDia >= 1140
    }

    private func actualizar() {
        let componentes = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let minutosDia  = (componentes.hour ?? 0) * 60 + (componentes.minute ?? 0)
        let nuevo       = Self.calcularEsDeNoche(minutosDia: minutosDia)
        guard nuevo != esDeNoche else { return }
        withAnimation(.easeInOut(duration: 1.5)) {
            esDeNoche = nuevo
        }
    }
}
