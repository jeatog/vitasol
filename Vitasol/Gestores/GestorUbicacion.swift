import CoreLocation
import MapKit
import Observation

@Observable
@MainActor
final class GestorUbicacion {
    var nombreUbicacion: String?
    var coordenadas: CLLocation?
    var autorizado: Bool = false
    var denegado: Bool = false

    private let manager  = CLLocationManager()
    private let delegado = DelegadoUbicacion()

    init() {
        manager.delegate = delegado
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        let estado = manager.authorizationStatus
        autorizado = estado == .authorizedWhenInUse || estado == .authorizedAlways

        delegado.alCambiarAutorizacion = { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.autorizado = status == .authorizedWhenInUse || status == .authorizedAlways
                self.denegado   = status == .denied || status == .restricted
                if self.autorizado { self.manager.requestLocation() }
            }
        }

        delegado.alActualizarUbicacion = { [weak self] location in
            Task { @MainActor [weak self] in
                self?.coordenadas = location
                self?.geocodificar(location)
            }
        }

        delegado.alFallar = { error in
            // CLError.locationUnknown es transitorio y se reintenta automáticamente
            guard (error as? CLError)?.code != .locationUnknown else { return }
            print("[GestorUbicacion] Error de ubicación: \(error.localizedDescription)")
        }
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

    private func geocodificar(_ location: CLLocation) {
        Task {
            guard let solicitud = MKReverseGeocodingRequest(location: location) else { return }
            guard let item = try? await solicitud.mapItems.first,
                  let direccion = item.address else { return }
            nombreUbicacion = direccion.shortAddress ?? direccion.fullAddress
        }
    }
}

// MARK: Delegado de CLLocationManager (requiere NSObject)

private class DelegadoUbicacion: NSObject, CLLocationManagerDelegate {
    var alCambiarAutorizacion: ((CLAuthorizationStatus) -> Void)?
    var alActualizarUbicacion: ((CLLocation) -> Void)?
    var alFallar: ((Error) -> Void)?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        alCambiarAutorizacion?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        alActualizarUbicacion?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alFallar?(error)
    }
}
