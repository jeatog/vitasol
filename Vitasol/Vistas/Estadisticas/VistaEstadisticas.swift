import SwiftUI
import SwiftData

struct VistaEstadisticas: View {
    @Query(sort: \SesionSolar.fecha, order: .reverse) private var sesiones: [SesionSolar]
    @Environment(GestorSesion.self) private var gestorSesion

    @State private var mostrarHistorial = false
    @State private var mostrarInfoStats = false
    @State private var progresoAnimado: Double = 0

    private var completadas: [SesionSolar] { sesiones.filter { $0.completada } }

    private var totalSegundos: Int { completadas.reduce(0) { $0 + $1.duracionSegundos } }

    private var tiempoTotalTexto: String {
        let horas = totalSegundos / 3600
        let mins  = (totalSegundos % 3600) / 60
        return horas > 0 ? "\(horas)h \(mins)m" : "\(mins)m"
    }

    private var racha: Int { Logro.rachaActual(de: completadas) }

    private var diasConMeta: Int {
        Set(completadas.map { Calendar.current.startOfDay(for: $0.fecha) }).count
    }

    private var logros: [Logro] { Logro.evaluar(sesiones: sesiones) }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(spacing: Diseno.espaciado) {
                        if !sesiones.isEmpty { seccionHistorial }
                        cabeceraStats
                        cuadriculaStats
                        seccionLogros
                        if sesiones.isEmpty { estadoVacio }
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Diseno.relleno)
                    .padding(.top, 4)
                }
            }
            .navigationTitle(Textos.Estadisticas.titulo)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $mostrarHistorial) {
                VistaHistorial(sesiones: sesiones)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: Cabecera de la cuadrícula
    private var cabeceraStats: some View {
        HStack(spacing: 8) {
            Text(Textos.Estadisticas.sesionesCompletadas)
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoPrimario)

            Button { mostrarInfoStats = true } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(.textoApagado.opacity(0.6))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $mostrarInfoStats, arrowEdge: .bottom) {
                Text(Textos.Estadisticas.completadasInfo)
                    .font(.fuenteCuerpo)
                    .foregroundStyle(.textoPrimario)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(Diseno.relleno)
                    .frame(width: 260)
                    .presentationCompactAdaptation(.popover)
            }

            Spacer()
        }
    }

    // MARK: Estadísticas — bento asimétrico
    private var cuadriculaStats: some View {
        VStack(spacing: Diseno.espaciadoS) {
            // Card hero: racha actual
            tarjetaRachaHero

            // Fila de 3 stats compactas
            HStack(spacing: Diseno.espaciadoS) {
                MosaicoStatCompacto(icono: "calendar.badge.checkmark",
                                    etiqueta: Textos.Estadisticas.totalSesiones,
                                    valor: "\(completadas.count)",
                                    color: .ambar)
                MosaicoStatCompacto(icono: "clock.fill",
                                    etiqueta: Textos.Estadisticas.tiempoTotal,
                                    valor: completadas.isEmpty ? "0m" : tiempoTotalTexto,
                                    color: .dorado)
                MosaicoStatCompacto(icono: "flag.checkered",
                                    etiqueta: Textos.Estadisticas.diasConMeta,
                                    valor: "\(diasConMeta)",
                                    color: .salvia)
            }
        }
    }

    // MARK: Card hero de racha
    private var tarjetaRachaHero: some View {
        HStack(spacing: 16) {
            // Anillo de progreso de racha (meta visual: 30 días)
            ZStack {
                Circle()
                    .stroke(Color.ambar.opacity(0.12), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progresoAnimado)
                    .stroke(Color.ambar.gradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.ambar)
            }
            .frame(width: 56, height: 56)
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                    progresoAnimado = min(Double(racha) / 30.0, 1.0)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(Textos.Estadisticas.rachaActual)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(String(localized: "estadisticas.dias \(racha)"))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.textoPrimario)
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
        .accessibilityElement(children: .combine)
    }

    // MARK: Sección de logros
    private var seccionLogros: some View {
        VStack(alignment: .leading, spacing: Diseno.rellenoS) {
            Text(Textos.Estadisticas.logros)
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoPrimario)

            VStack(spacing: 0) {
                ForEach(Array(logros.enumerated()), id: \.element.id) { indice, logro in
                    FilaLogro(logro: logro)
                    if indice < logros.count - 1 {
                        Divider()
                            .overlay(Color.textoApagado.opacity(0.15))
                            .padding(.leading, 58)
                    }
                }
            }
            .tarjetaVidrio()
        }
    }

    // MARK: Historial (botón que lleva a la lista)
    private var seccionHistorial: some View {
        Button { mostrarHistorial = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
                    .foregroundStyle(.ambar)
                    .frame(width: 40, height: 40)
                    .background(Color.ambar.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(Textos.Estadisticas.historial)
                        .font(.fuenteCabecera)
                        .foregroundStyle(.textoPrimario)
                    Text(Textos.Estadisticas.sesionesCount(sesiones.count))
                        .font(.fuenteCaption)
                        .foregroundStyle(.textoApagado)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.textoApagado)
            }
            .padding(Diseno.rellenoS + 4)
            .tarjetaVidrio()
        }
        .buttonStyle(EstiloBotonTarjeta())
    }

    // MARK: Estado vacío
    private var estadoVacio: some View {
        VStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 52))
                .foregroundStyle(.ambar)
                .symbolEffect(.bounce, value: sesiones.isEmpty)

            Text(Textos.Estadisticas.empezarViaje)
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoPrimario)

            Text(Textos.Estadisticas.sinSesiones)
                .font(.fuenteCuerpo)
                .foregroundStyle(.textoSecundario)
                .multilineTextAlignment(.center)

            Button {
                gestorSesion.navegarASesion = true
            } label: {
                Label(Textos.Inicio.iniciarSesion, systemImage: "play.fill")
            }
            .buttonStyle(EstiloBotonPrincipal())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(Diseno.rellenoG)
        .tarjetaVidrio()
    }
}

// MARK: Mosaico compacto (3 en fila)
struct MosaicoStatCompacto: View {
    let icono:    String
    let etiqueta: LocalizedStringKey
    let valor:    String
    let color:    Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(valor)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.textoPrimario)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .contentTransition(.numericText())

            Text(etiqueta)
                .font(.fuenteMicro)
                .foregroundStyle(.textoApagado)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Diseno.rellenoS + 2)
        .padding(.horizontal, 6)
        .tarjetaVidrio()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(etiqueta))
        .accessibilityValue(Text(valor))
    }
}

// MARK: Fila de historial
struct FilaHistorial: View {
    let sesion: SesionSolar
    @AppStorage("unidadTemp") private var unidadTemp = "C"
    @AppStorage("idiomaApp")  private var idiomaApp  = "es"

    private static let fmtHora: DateFormatter = {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none
        return fmt
    }()

    private static let fmtFecha: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt
    }()

    private var tempFormateada: String {
        unidadTemp == "F"
            ? "\(Int(sesion.temperatura * 9/5 + 32))°F"
            : "\(Int(sesion.temperatura))°C"
    }

    private var rangoHoras: String {
        let locale = Locale(identifier: idiomaApp)
        Self.fmtHora.locale = locale
        let fin    = sesion.fecha
        let inicio = fin.addingTimeInterval(-TimeInterval(sesion.duracionSegundos))
        return "\(Self.fmtHora.string(from: inicio)) – \(Self.fmtHora.string(from: fin))"
    }

    private var etiquetaFecha: String {
        if Calendar.current.isDateInToday(sesion.fecha)     { return String(localized: "general.hoy")  }
        if Calendar.current.isDateInYesterday(sesion.fecha) { return String(localized: "general.ayer") }
        Self.fmtFecha.locale = Locale(identifier: idiomaApp)
        return Self.fmtFecha.string(from: sesion.fecha)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Fila principal: fecha/hora - UV - temp - check - duración
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(etiquetaFecha)
                        .font(.fuenteMicro)
                        .foregroundStyle(.textoApagado)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(rangoHoras)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.textoPrimario)
                }

                Spacer()

                Label("\(Int(sesion.indiceUV)) UV", systemImage: "sun.max.fill")
                    .foregroundStyle(.ambar)
                Label(tempFormateada, systemImage: "thermometer")
                    .foregroundStyle(.textoSecundario)

                if sesion.completada {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.salvia)
                }

                Text(sesion.duracionFormateada)
                    .foregroundStyle(.textoSecundario)
            }
            .font(.fuenteCaption)

            // Fila secundaria: ubicación (opcional)
            if let lugar = sesion.ubicacion {
                Label(lugar, systemImage: "location.fill")
                    .font(.fuenteMicro)
                    .foregroundStyle(.textoApagado)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Diseno.rellenoS + 4)
        .padding(.vertical, Diseno.rellenoS)
        .accessibilityElement(children: .combine)
    }
}

// MARK: Fila de logro
struct FilaLogro: View {
    let logro: Logro

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(logro.desbloqueado
                          ? logro.colorIcono.opacity(0.15)
                          : Color.textoApagado.opacity(0.08))
                    .frame(width: 44, height: 44)

                Image(systemName: logro.icono)
                    .font(.system(size: 20))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        logro.desbloqueado ? logro.colorIcono : .textoApagado,
                        logro.desbloqueado ? logro.colorIcono.opacity(0.6) : Color.textoApagado.opacity(0.4)
                    )
                    .opacity(logro.desbloqueado ? 1 : 0.45)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(logro.titulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(logro.desbloqueado ? .textoPrimario : .textoApagado)

                Text(logro.descripcion)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
            }

            Spacer()

            if logro.desbloqueado {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.salvia)
                    .font(.system(size: 20))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, Diseno.rellenoS + 4)
        .padding(.vertical, Diseno.rellenoS)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: logro.desbloqueado)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(logro.desbloqueado ? .isSelected : [])
    }
}
