import ActivityKit
import Foundation
import Observation
import UIKit
import UserNotifications

@Observable
@MainActor
final class GestorSesion {
    var estaActiva:       Bool = false
    var segundosSesion:   Int  = 0
    var segundosObjetivo: Int  = 600
    var completo:         Bool = false
    var navegarASesion:   Bool = false

    private var temporizador:       Timer?
    private var actividad:          Activity<SesionSolarActividad>?
    private var ticksActualizacion: Int = 0
    private var fechaBackground:    Date?
    private var tareaBackground:    Task<Void, Never>?
    private var tareaForeground:    Task<Void, Never>?

    // MARK: Manejamos estado en background

    init() {
        // Al ir a background se pausa el timer y anota la hora
        tareaBackground = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: UIApplication.didEnterBackgroundNotification
            ) {
                guard let self, self.estaActiva else { continue }
                self.fechaBackground = Date.now
                self.temporizador?.invalidate()
                self.temporizador = nil
            }
        }
        // Al volver al frente compensamos el tiempo real transcurrido
        tareaForeground = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: UIApplication.willEnterForegroundNotification
            ) {
                guard let self, self.estaActiva, let inicio = self.fechaBackground else { continue }
                let tiempoPasado = Int(Date.now.timeIntervalSince(inicio))
                self.segundosSesion = min(self.segundosSesion + tiempoPasado, self.segundosObjetivo)
                self.fechaBackground = nil
                if self.segundosSesion < self.segundosObjetivo {
                    self.actualizarActividad()   // corrige fechaFin en la Live Activity
                    self.programarTemporizador()
                } else {
                    self.estaActiva = false
                    self.completo   = true
                    self.cancelarNotificacionFin()
                    self.terminarActividad()
                }
            }
        }
    }

    var progreso: Double {
        guard segundosObjetivo > 0 else { return 0 }
        return min(Double(segundosSesion) / Double(segundosObjetivo), 1.0)
    }

    var segundosRestantes: Int {
        max(segundosObjetivo - segundosSesion, 0)
    }

    var tiempoTexto: String {
        let mins = segundosRestantes / 60
        let segs = segundosRestantes % 60
        return String(format: "%02d:%02d", mins, segs)
    }

    // MARK: Controles

    func iniciar(duracionMinutos: Int) {
        segundosObjetivo = duracionMinutos * 60
        segundosSesion   = 0
        completo         = false
        estaActiva       = true
        fechaBackground  = nil
        programarTemporizador()
        iniciarActividad()
        programarNotificacionFin()
    }

    func pausar() {
        temporizador?.invalidate()
        temporizador = nil
        estaActiva   = false
    }

    func reanudar() {
        guard !completo else { return }
        estaActiva = true
        programarTemporizador()
    }

    func detener() {
        temporizador?.invalidate()
        temporizador    = nil
        estaActiva      = false
        fechaBackground = nil
        cancelarNotificacionFin()
        terminarActividad()
    }

    func reiniciar() {
        detener()
        segundosSesion = 0
        completo       = false
    }

    // MARK: Privado

    private func programarTemporizador() {
        ticksActualizacion = 0
        temporizador = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.segundosSesion < self.segundosObjetivo {
                    self.segundosSesion      += 1
                    self.ticksActualizacion  += 1
                    // Actualización normal cada 5 s; forzada en los últimos 5 s
                    // para evitar que fechaFin expire antes del dismiss
                    if self.ticksActualizacion >= 5 || self.segundosRestantes <= 5 {
                        self.ticksActualizacion = 0
                        self.actualizarActividad()
                    }
                } else {
                    self.temporizador?.invalidate()
                    self.temporizador = nil
                    self.estaActiva   = false
                    self.completo     = true
                    self.cancelarNotificacionFin()
                    self.terminarActividad()
                }
            }
        }
    }

    // MARK: Live Activity (para la Dynamic Island)

    private func iniciarActividad() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let atributos = SesionSolarActividad(duracionSegundos: segundosObjetivo)
        let fechaFin  = Date.now.addingTimeInterval(Double(segundosObjetivo))
        let estado    = SesionSolarActividad.ContentState(progreso: 0, fechaFin: fechaFin)
        actividad = try? Activity.request(
            attributes: atributos,
            content:    ActivityContent(state: estado, staleDate: fechaFin),
            pushType:   nil
        )
    }

    private func actualizarActividad() {
        guard let actividad else { return }
        let fechaFin = Date.now.addingTimeInterval(Double(segundosRestantes))
        let estado   = SesionSolarActividad.ContentState(progreso: progreso, fechaFin: fechaFin)
        Task { await actividad.update(ActivityContent(state: estado, staleDate: fechaFin)) }
    }

    // MARK: Notificación de fin de sesión

    private func programarNotificacionFin() {
        let contenido      = UNMutableNotificationContent()
        contenido.title    = Textos.Notificacion.sesionCompletadaTitulo
        contenido.body     = Textos.Notificacion.sesionCompletadaCuerpo(segundosObjetivo / 60)
        contenido.sound    = .default

        let disparador = UNTimeIntervalNotificationTrigger(
            timeInterval: Double(segundosObjetivo), repeats: false
        )
        let solicitud = UNNotificationRequest(
            identifier: "sesion_solar_fin",
            content:    contenido,
            trigger:    disparador
        )
        UNUserNotificationCenter.current().add(solicitud)
    }

    private func cancelarNotificacionFin() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["sesion_solar_fin"])
    }

    private func terminarActividad() {
        let progresoFinal      = progreso
        let segsRestantes      = segundosRestantes
        let actividadATerminar = self.actividad   // captura ANTES de nil para evitar race condition
        self.actividad         = nil

        Task {
            let estado = SesionSolarActividad.ContentState(
                progreso: progresoFinal,
                fechaFin: Date.now.addingTimeInterval(Double(max(segsRestantes, 5)))
            )

            if let act = actividadATerminar {
                // Caso normal: referencia directa a la actividad actual
                await act.end(
                    ActivityContent(state: estado, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            } else {
                // Caso reactivación desde estado terminado (app relanzada vía URL):
                // Activity.activities puede estar vacío un instante, tons reintentamos
                var actividades = Activity<SesionSolarActividad>.activities
                var intento = 0
                while actividades.isEmpty && intento < 5 {
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 s
                    actividades = Activity<SesionSolarActividad>.activities
                    intento += 1
                }
                for act in actividades {
                    await act.end(
                        ActivityContent(state: estado, staleDate: nil),
                        dismissalPolicy: .immediate
                    )
                }
            }
        }
    }
}
