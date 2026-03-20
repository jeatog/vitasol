import Observation
import SwiftUI

// MARK: Gestor de tema día/noche
// Evalúa la hora cada 60 s y activa el modo noche entre las 19:00 y las 07:00,
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

    deinit {
        timer?.invalidate()
    }

    /// ColorScheme que debe aplicarse en la raíz de la app.
    var esquema: ColorScheme { esDeNoche ? .dark : .light }

    private func actualizar() {
        let hora  = Calendar.current.component(.hour, from: .now)
        let nuevo = hora < 7 || hora >= 19
        guard nuevo != esDeNoche else { return }
        withAnimation(.easeInOut(duration: 1.5)) {
            esDeNoche = nuevo
        }
    }
}
