import CoreLocation
import SwiftUI
import SwiftData
import WidgetKit

struct VistaInicio: View {
    @Binding var tabSeleccionada: Int

    @Environment(\.modelContext) private var contexto
    @Query private var sesiones: [SesionSolar]
    @Environment(GestorSesion.self)    private var gestorSesion
    @Environment(GestorUbicacion.self) private var gestorUbicacion
    @Environment(GestorTema.self)      private var gestorTema
    @Environment(GestorClima.self)     private var gestorClima

    @AppStorage("duracionSesionMinutos") private var duracionMinutos    = 15
    @AppStorage("horarioHora")           private var horaRecordatorio   = 10
    @AppStorage("horarioMinuto")         private var minutoRecordatorio = 0
    @AppStorage("ubicacionActiva")       private var ubicacionActiva    = false
    @AppStorage("unidadTemp")            private var unidadTemp         = "C"

    init(tabSeleccionada: Binding<Int>) {
        _tabSeleccionada = tabSeleccionada
        let inicioHoy = Calendar.current.startOfDay(for: .now)
        _sesiones = Query(
            filter: #Predicate<SesionSolar> { $0.fecha >= inicioHoy },
            sort: \SesionSolar.fecha,
            order: .reverse
        )
    }

    private var sesionHoyCompletada: Bool {
        sesiones.first { $0.completada } != nil
    }

    private var sesionDeHoy: SesionSolar? {
        sesiones.first
    }

    private var haySessionActiva: Bool {
        gestorSesion.segundosSesion > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(spacing: Diseno.espaciado) {
                        bannerEstado
                        tarjetaClima
                        if haySessionActiva {
                            tarjetaSesionEnCurso
                        } else {
                            tarjetaListo
                            seccionCTA
                        }
                        if sesionHoyCompletada { tarjetaCompletada }
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Diseno.relleno)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Vitasol")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if ubicacionActiva { gestorUbicacion.solicitar() }
                sincronizarWidget()
            }
            .onChange(of: gestorUbicacion.coordenadas) { _, coords in
                if let coords {
                    Task {
                        await gestorClima.obtener(
                            latitud: coords.coordinate.latitude,
                            longitud: coords.coordinate.longitude
                        )
                    }
                }
            }
        }
    }

    // MARK: Banner de estado
    private var bannerEstado: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(saludo)
                    .font(.fuenteMicro)
                    .foregroundStyle(.textoApagado)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(sesionHoyCompletada ? Textos.Inicio.metaCumplida : Textos.Inicio.listaDosis)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(sesionHoyCompletada
                          ? Color.salvia.opacity(0.15)
                          : Color.ambar.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: sesionHoyCompletada ? "checkmark.seal.fill"
                                  : gestorTema.esDeNoche ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(sesionHoyCompletada ? .salvia : .ambar)
                    .symbolEffect(.bounce, value: sesionHoyCompletada)
            }
        }
        .padding(.top, 6)
        .accessibilityElement(children: .combine)
    }

    // MARK: Tarjeta de clima
    private var tarjetaClima: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(Textos.Inicio.climaActual,
                          systemImage: gestorTema.esDeNoche ? "cloud.moon.fill" : gestorClima.iconoSistema)
                        .font(.fuenteMicro)
                        .foregroundStyle(.textoApagado)
                        .textCase(.uppercase)
                        .tracking(1.0)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(tempNumero)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.textoPrimario)
                        Text(tempUnidad)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.textoSecundario)
                            .baselineOffset(8)
                    }

                    Text(gestorClima.condicion)
                        .font(.fuenteCuerpo)
                        .foregroundStyle(.textoSecundario)

                    if ubicacionActiva, let lugar = gestorUbicacion.nombreUbicacion {
                        Text(lugar)
                            .font(.fuenteMicro)
                            .foregroundStyle(.textoApagado)
                    }
                }

                Spacer()

                Image(systemName: gestorTema.esDeNoche ? "moon.stars.fill" : gestorClima.iconoSistema)
                    .font(.system(size: 48))
                    .foregroundStyle(.dorado)
                    .shadow(color: .ambar.opacity(0.35), radius: 12, x: 0, y: 6)
            }

            Divider()
                .overlay(Color.textoApagado.opacity(0.25))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Textos.Inicio.indiceUV)
                        .font(.fuenteMicro)
                        .foregroundStyle(.textoApagado)
                        .textCase(.uppercase)
                        .tracking(1.0)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(gestorClima.uvEntero)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(colorUV)
                        Text(gestorClima.etiquetaUV)
                            .font(.fuenteCaption)
                            .foregroundStyle(colorUV)
                    }
                }

                Spacer()

                if gestorClima.esBuenDia {
                    Label(Textos.Inicio.buenDia, systemImage: "checkmark.circle.fill")
                        .font(.fuenteCaption)
                        .foregroundStyle(.salvia)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.salvia.opacity(0.12))
                        .clipShape(Capsule())
                } else {
                    Label(Textos.Inicio.intentaManana, systemImage: gestorClima.iconoSistema)
                        .font(.fuenteCaption)
                        .foregroundStyle(.textoApagado)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.textoApagado.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
        .accessibilityElement(children: .combine)
    }

    // MARK: Tarjeta "¿Listo?"
    private var tarjetaListo: some View {
        VStack(spacing: 14) {
            Image(systemName: gestorTema.esDeNoche ? "moon.fill" : "sun.horizon.fill")
                .font(.system(size: 40))
                .foregroundStyle(.ambar)

            VStack(spacing: 5) {
                Text(Textos.Inicio.listoParaSol)
                    .font(.fuenteTitulo2)
                    .foregroundStyle(.textoPrimario)

                Text(recordatorioYaPaso
                     ? Textos.Inicio.recordatorioManana(horaTexto)
                     : Textos.Inicio.recordatorio(horaTexto))
                    .font(.fuenteCuerpo)
                    .foregroundStyle(.textoSecundario)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Diseno.rellenoG)
        .padding(.horizontal, Diseno.relleno)
        .tarjetaVidrio()
    }

    // MARK: CTA principal (sin sesión activa)
    private var seccionCTA: some View {
        VStack(spacing: 10) {
            Button { tabSeleccionada = 1 } label: {
                Label(Textos.Inicio.iniciarSesion, systemImage: "play.fill")
            }
            .buttonStyle(EstiloBotonPrincipal())

            Text(Textos.Inicio.duracionRecomendada(duracionMinutos))
                .font(.fuenteCaption)
                .foregroundStyle(.textoApagado)
        }
    }

    // MARK: Tarjeta sesión en curso
    private var tarjetaSesionEnCurso: some View {
        Button { tabSeleccionada = 1 } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.ambar.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "timer")
                        .font(.system(size: 20))
                        .foregroundStyle(.ambar)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(Textos.Inicio.sesionEnCurso)
                        .font(.fuenteCabecera)
                        .foregroundStyle(.textoPrimario)
                    Text(gestorSesion.tiempoTexto)
                        .font(.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.textoSecundario)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.5), value: gestorSesion.tiempoTexto)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.textoApagado)
            }
            .padding(Diseno.rellenoS + 4)
        }
        .buttonStyle(.plain)
        .tarjetaVidrio()
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.ambar.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityHint(String(localized: "general.toca_para_ver"))
    }

    // MARK: Tarjeta de sesión completada
    private var tarjetaCompletada: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 32))
                .foregroundStyle(.salvia)

            VStack(alignment: .leading, spacing: 3) {
                Text(Textos.Inicio.metaHoyCumplida)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)

                if let sesion = sesionDeHoy {
                    Text(Textos.Inicio.duracionSesion(sesion.duracionFormateada))
                        .font(.fuenteCuerpo)
                        .foregroundStyle(.textoSecundario)
                }
            }

            Spacer()
        }
        .padding(Diseno.rellenoS + 4)
        .tarjetaVidrio(Diseno.radioS + 4)
        .overlay(
            RoundedRectangle(cornerRadius: Diseno.radioS + 4, style: .continuous)
                .strokeBorder(Color.salvia.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: Auxiliares
    private var saludo: LocalizedStringKey {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12:  return Textos.General.buenosDias
        case 12..<18: return Textos.General.buenasTardes
        default:      return Textos.General.buenasNoches
        }
    }

    private var horaTexto: String {
        let h12    = horaRecordatorio % 12 == 0 ? 12 : horaRecordatorio % 12
        let periodo = horaRecordatorio < 12 ? "a.m." : "p.m."
        return String(format: "%d:%02d %@", h12, minutoRecordatorio, periodo)
    }

    private var tempNumero: String {
        guard let temp = gestorClima.temperatura else { return "--" }
        let valor = unidadTemp == "F" ? Int(temp * 9/5 + 32) : Int(temp)
        return "\(valor)"
    }

    private var tempUnidad: String { unidadTemp == "F" ? "°F" : "°C" }

    private var recordatorioYaPaso: Bool {
        let ahora     = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let minActual = (ahora.hour ?? 0) * 60 + (ahora.minute ?? 0)
        let minConfig = horaRecordatorio * 60 + minutoRecordatorio
        return minActual >= minConfig
    }

    private var colorUV: Color {
        switch gestorClima.uvEntero {
        case 0...2: return .uvBajo
        case 3...5: return .uvMedio
        case 6...7: return .uvAlto
        default:    return .uvMuyAlto
        }
    }

    private func sincronizarWidget() {
        let defaults = UserDefaults(suiteName: "group.dev.jeatog.Vitasol")
        defaults?.set(sesionHoyCompletada, forKey: "widget_meta_cumplida")
        defaults?.set(gestorClima.uvEntero, forKey: "widget_uv_actual")
        defaults?.set(gestorClima.tieneDatos, forKey: "widget_tiene_datos_uv")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
