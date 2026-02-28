import Combine
import UserNotifications
import Foundation

@MainActor
final class GestorNotificaciones: ObservableObject {
    @Published var estado: UNAuthorizationStatus = .notDetermined

    var autorizado: Bool { estado == .authorized }

    // MARK: Verificar estado actual
    func actualizar() async {
        let configuracion = await UNUserNotificationCenter.current().notificationSettings()
        estado = configuracion.authorizationStatus
    }

    // MARK: Solicitar permiso
    @discardableResult
    func solicitarPermiso() async -> Bool {
        do {
            let concedido = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            estado = concedido ? .authorized : .denied
            return concedido
        } catch {
            return false
        }
    }

    // MARK: Programar recordatorios diarios
    func programar(hora: Int, minuto: Int, dias: Set<Int>, mensaje: String) {
        let centro = UNUserNotificationCenter.current()

        // Eliiminar recordatorios anteriores
        let idsAnteriores = (1...7).map { "sol_dia_\($0)" }
        centro.removePendingNotificationRequests(withIdentifiers: idsAnteriores)

        let contenido      = UNMutableNotificationContent()
        contenido.title    = Textos.Notificacion.titulo
        contenido.body     = mensaje.isEmpty ? Textos.Notificacion.cuerpoDefault : mensaje
        contenido.sound    = .default

        for dia in dias {
            var componentes        = DateComponents()
            componentes.hour       = hora
            componentes.minute     = minuto
            componentes.weekday    = dia

            let disparador = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: true)
            let solicitud  = UNNotificationRequest(
                identifier: "sol_dia_\(dia)",
                content:    contenido,
                trigger:    disparador
            )
            centro.add(solicitud)
        }
    }

    // MARK: Cancelar todo alv
    func cancelarTodo() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
