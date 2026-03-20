import SwiftUI
import UIKit

struct VistaAjustes: View {
    @EnvironmentObject private var gestorNotificaciones: GestorNotificaciones
    @EnvironmentObject private var gestorSalud:          GestorSalud
    @EnvironmentObject private var gestorUbicacion:      GestorUbicacion

    @AppStorage("idiomaApp")              private var idiomaApp              = "es"
    @AppStorage("unidadTemp")             private var unidadTemp             = "C"
    @AppStorage("horarioHora")            private var horaRecordatorio       = 10
    @AppStorage("horarioMinuto")          private var minutoRecordatorio     = 0
    @AppStorage("duracionSesionMinutos")  private var duracionMinutos        = 15
    @AppStorage("notificacionesActivas")  private var notificacionesActivas  = true
    @AppStorage("ubicacionActiva")        private var ubicacionActiva        = false
    @AppStorage("saludActiva")            private var saludActiva            = false
    @AppStorage("mensajePersonalizado")   private var mensajePersonalizado   = ""
    @AppStorage("diasActivosTexto")       private var diasActivosTexto       = "2,3,4,5,6"

    @State private var horaSeleccionada          = Date()
    @State private var mostrarNotifBloqueada     = false
    @State private var mostrarSaludBloqueada     = false
    @State private var mostrarUbicacionBloqueada = false
    @State private var primeraVez                = true

    private let diasSemana = [(1, "dia.dom"), (2, "dia.lun"), (3, "dia.mar"),
                               (4, "dia.mie"), (5, "dia.jue"), (6, "dia.vie"), (7, "dia.sab")]

    private var diasActivos: Set<Int> {
        Set(diasActivosTexto.split(separator: ",").compactMap { Int($0) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(spacing: Diseno.espaciado) {
                        seccionIdioma
                        seccionHorario
                        seccionDuracion
                        seccionDiasActivos
                        seccionNotificaciones
                        seccionUbicacion
                        seccionSalud
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Diseno.relleno)
                    .padding(.top, 4)
                }
            }
            .navigationTitle(Textos.Ajustes.titulo)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                guard primeraVez else { return }
                primeraVez = false
                sincronizarSelectorHora()
                Task { await gestorNotificaciones.actualizar() }
            }
            .alert(Textos.Ajustes.saludBloqueada, isPresented: $mostrarSaludBloqueada) {
                Button(Textos.General.abrirAjustes) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(Textos.General.cancelar, role: .cancel) { }
            } message: {
                Text(Textos.Ajustes.saludBloqueadaMsg)
            }
            .alert(Textos.Ajustes.notifBloqueadas, isPresented: $mostrarNotifBloqueada) {
                Button(Textos.General.abrirAjustes) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(Textos.General.cancelar, role: .cancel) { }
            } message: {
                Text(Textos.Ajustes.notifBloqueadasMsg)
            }
            .alert(Textos.Ajustes.ubicacionBloqueada, isPresented: $mostrarUbicacionBloqueada) {
                Button(Textos.General.abrirAjustes) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(Textos.General.cancelar, role: .cancel) { }
            } message: {
                Text(Textos.Ajustes.ubicacionBloqueadaMsg)
            }
        }
    }

    // MARK: Sección de idioma y unidades
    private var seccionIdioma: some View {
        VStack(alignment: .leading, spacing: Diseno.espaciado) {
            CabeceraSeccion(icono: "globe", titulo: Textos.Ajustes.idioma)

            Picker("", selection: $idiomaApp) {
                Text(Textos.Ajustes.espanol).tag("es")
                Text(Textos.Ajustes.ingles).tag("en")
            }
            .pickerStyle(.segmented)

            Divider()
                .overlay(Color.textoApagado.opacity(0.15))

            HStack {
                CabeceraSeccion(icono: "thermometer", titulo: Textos.Ajustes.unidadTemp)
                Spacer()
                Picker("", selection: $unidadTemp) {
                    Text("°C").tag("C")
                    Text("°F").tag("F")
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
            }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
    }

    // MARK: Sección de horario
    private var seccionHorario: some View {
        VStack(alignment: .leading, spacing: Diseno.rellenoS) {
            CabeceraSeccion(icono: "bell.fill", titulo: Textos.Ajustes.horaRecordatorio)

            DatePicker("", selection: $horaSeleccionada, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .onChange(of: horaSeleccionada) { _, nueva in
                    let c               = Calendar.current.dateComponents([.hour, .minute], from: nueva)
                    horaRecordatorio    = c.hour   ?? 10
                    minutoRecordatorio  = c.minute ?? 0
                    reprogramarSiProcede()
                }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
    }

    // MARK: Sección de la duración
    private var seccionDuracion: some View {
        VStack(alignment: .leading, spacing: Diseno.espaciado) {
            HStack {
                CabeceraSeccion(icono: "timer", titulo: Textos.Ajustes.duracionRecomendada)
                Spacer()
                Text(Textos.Ajustes.duracionValor(duracionMinutos))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.ambar)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: duracionMinutos)
            }

            Slider(
                value: Binding(
                    get: { Double(duracionMinutos) },
                    set: { duracionMinutos = Int($0) }
                ),
                in: 5...60, step: 5
            )
            .tint(.ambar)

            HStack {
                Text(Textos.Ajustes.duracionMin).font(.fuenteCaption).foregroundStyle(.textoApagado)
                Spacer()
                Text(Textos.Ajustes.duracionMax).font(.fuenteCaption).foregroundStyle(.textoApagado)
            }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
    }

    // MARK: Sección de días activos
    private var seccionDiasActivos: some View {
        VStack(alignment: .leading, spacing: Diseno.espaciado) {
            CabeceraSeccion(icono: "calendar", titulo: Textos.Ajustes.diasActivos)

            HStack(spacing: 6) {
                ForEach(diasSemana, id: \.0) { numero, claveTexto in
                    let activo = diasActivos.contains(numero)
                    Button { alternarDia(numero) } label: {
                        Text(LocalizedStringKey(claveTexto))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(activo ? .white : .textoSecundario)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(activo ? Color.ambar : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        activo ? Color.clear : Color.textoApagado.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .accessibilityAddTraits(activo ? .isSelected : [])
                    .animation(.easeInOut(duration: 0.18), value: activo)
                }
            }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
    }

    // MARK: Sección de notificaciones
    private var seccionNotificaciones: some View {
        FilaConfiguracion(
            icono:     "bell.badge.fill",
            titulo:    Textos.Ajustes.notificaciones,
            subtitulo: Textos.Ajustes.notificacionesSub,
            color:     .ambar,
            activado:  $notificacionesActivas
        ) { activar in
            Task {
                if activar {
                    let concedido = await gestorNotificaciones.solicitarPermiso()
                    if concedido {
                        reprogramarSiProcede()
                    } else {
                        notificacionesActivas    = false
                        mostrarNotifBloqueada = true
                    }
                } else {
                    gestorNotificaciones.cancelarTodo()
                }
            }
        }
        .tarjetaVidrio()
    }

    // MARK: Sección de ubicación
    private var seccionUbicacion: some View {
        FilaConfiguracion(
            icono:     "location.fill",
            titulo:    Textos.Ajustes.ubicacion,
            subtitulo: Textos.Ajustes.ubicacionSub,
            color:     .salvia,
            activado:  $ubicacionActiva
        ) { activar in
            if activar {
                if gestorUbicacion.denegado {
                    ubicacionActiva = false
                    mostrarUbicacionBloqueada = true
                } else {
                    gestorUbicacion.solicitar()
                }
            }
        }
        .onChange(of: gestorUbicacion.denegado) { _, denegado in
            if denegado && ubicacionActiva {
                ubicacionActiva = false
                mostrarUbicacionBloqueada = true
            }
        }
        .tarjetaVidrio()
    }

    // MARK: Sección de salud
    private var seccionSalud: some View {
        FilaConfiguracion(
            icono:     "heart.fill",
            titulo:    Textos.Ajustes.salud,
            subtitulo: Textos.Ajustes.saludSub,
            color:     .red,
            activado:  $saludActiva
        ) { activar in
            guard activar else { return }
            Task {
                let concedido = await gestorSalud.solicitarPermiso()
                if !concedido {
                    saludActiva            = false
                    mostrarSaludBloqueada  = true
                }
            }
        }
        .tarjetaVidrio()
    }

    // MARK: Auxiliares
    private func sincronizarSelectorHora() {
        var c       = DateComponents()
        c.hour      = horaRecordatorio
        c.minute    = minutoRecordatorio
        horaSeleccionada = Calendar.current.date(from: c) ?? .now
    }

    private func alternarDia(_ dia: Int) {
        var actuales = diasActivos
        if actuales.contains(dia) { actuales.remove(dia) } else { actuales.insert(dia) }
        diasActivosTexto = actuales.sorted().map(String.init).joined(separator: ",")
        reprogramarSiProcede()
    }

    private func reprogramarSiProcede() {
        guard notificacionesActivas, gestorNotificaciones.autorizado else { return }
        let mensaje = mensajePersonalizado.isEmpty
            ? Textos.Notificacion.cuerpoDefault
            : mensajePersonalizado
        gestorNotificaciones.programar(
            hora:    horaRecordatorio,
            minuto:  minutoRecordatorio,
            dias:    diasActivos,
            mensaje: mensaje
        )
    }
}

// MARK: Componente fila de configuración con toggle
struct FilaConfiguracion: View {
    let icono:     String
    let titulo:    LocalizedStringKey
    let subtitulo: LocalizedStringKey
    let color:     Color
    @Binding var activado: Bool
    let alCambiar: (Bool) -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icono)
                .font(.system(size: 17))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)
                Text(subtitulo)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
            }

            Spacer()

            Toggle("", isOn: $activado)
                .tint(.ambar)
                .labelsHidden()
                .onChange(of: activado) { _, nuevoValor in
                    alCambiar(nuevoValor)
                }
        }
        .padding(Diseno.rellenoS + 4)
    }
}
