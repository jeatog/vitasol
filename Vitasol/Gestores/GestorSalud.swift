import Combine
import HealthKit

@MainActor
final class GestorSalud: ObservableObject {
    @Published var autorizado: Bool = false

    private let store = HKHealthStore()
    private let tipo  = HKQuantityType(.timeInDaylight)

    init() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        autorizado = store.authorizationStatus(for: HKQuantityType(.timeInDaylight)) == .sharingAuthorized
    }

    func solicitarPermiso() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await store.requestAuthorization(toShare: [tipo], read: [])
            autorizado = store.authorizationStatus(for: tipo) == .sharingAuthorized
            return autorizado
        } catch {
            return false
        }
    }

    /// Registra en Apple Salud el tiempo de exposición al sol de una sesión.
    func registrar(duracionSegundos: Int, fin: Date = .now) {
        guard autorizado, duracionSegundos > 0 else { return }
        let cantidad = HKQuantity(unit: .second(), doubleValue: Double(duracionSegundos))
        let inicio   = fin.addingTimeInterval(-TimeInterval(duracionSegundos))
        let muestra  = HKQuantitySample(type: tipo, quantity: cantidad, start: inicio, end: fin)
        store.save(muestra) { exito, error in
            if let error { print("[GestorSalud] Error al guardar en HealthKit: \(error.localizedDescription)") }
        }
    }
}
