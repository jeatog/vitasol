import Combine
import CoreLocation

@MainActor
final class GestorUbicacion: NSObject, ObservableObject {
    @Published var nombreUbicacion: String?
    @Published var coordenadas: CLLocation?
    @Published var autorizado: Bool = false

    private let manager  = CLLocationManager()
    // swiftlint:disable:next deployment_target
    private let geocoder = CLGeocoder()   // CLGeocoder deprecated en iOS 26 — migrar a MKReverseGeocodingRequest cuando la API sea estable, no tengo referencias de esto aún, así que lo dejo así lel. Igual no es mucho pedo en iOS 26 aún.

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

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    private func geocodificar(_ location: CLLocation) {
        // Lo mismo del CLGeocoder que psue arriba
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let pm = placemarks?.first else { return }
            let partes = [pm.locality, pm.administrativeArea, pm.country].compactMap { $0 }
            let nombre = partes.joined(separator: ", ")
            Task { @MainActor [weak self] in
                self?.nombreUbicacion = nombre
            }
        }
    }
}
