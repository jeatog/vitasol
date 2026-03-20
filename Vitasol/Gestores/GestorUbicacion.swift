import Combine
import CoreLocation
import MapKit

@MainActor
final class GestorUbicacion: NSObject, ObservableObject {
    @Published var nombreUbicacion: String?
    @Published var coordenadas: CLLocation?
    @Published var autorizado: Bool = false
    @Published var denegado: Bool = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        let estado = manager.authorizationStatus
        autorizado = estado == .authorizedWhenInUse || estado == .authorizedAlways
    }

    func solicitar() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            autorizado = true
            manager.requestLocation()
        default:
            break
        }
    }
}

extension GestorUbicacion: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.autorizado = status == .authorizedWhenInUse || status == .authorizedAlways
            self.denegado   = status == .denied || status == .restricted
            if self.autorizado { manager.requestLocation() }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor [weak self] in
            self?.coordenadas = location
            self?.geocodificar(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // CLError.locationUnknown es transitorio y se reintenta automaticamente
        guard (error as? CLError)?.code != .locationUnknown else { return }
        print("[GestorUbicacion] Error de ubicacion: \(error.localizedDescription)")
    }

    private func geocodificar(_ location: CLLocation) {
        Task {
            guard let solicitud = MKReverseGeocodingRequest(location: location) else { return }
            guard let item = try? await solicitud.mapItems.first,
                  let direccion = item.address else { return }
            nombreUbicacion = direccion.shortAddress ?? direccion.fullAddress
        }
    }
}
