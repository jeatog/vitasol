import SwiftUI
import SwiftData

struct VistaSesion: View {
    @Environment(\.modelContext) private var contexto
    @EnvironmentObject private var gestorSesion:    GestorSesion
    @EnvironmentObject private var gestorSalud:     GestorSalud
    @EnvironmentObject private var gestorUbicacion: GestorUbicacion
    @EnvironmentObject private var gestorTema:      GestorTema
    @EnvironmentObject private var gestorClima:    GestorClima

    @AppStorage("duracionSesionMinutos") private var duracionMinutos  = 15
    @AppStorage("saludActiva")           private var saludActiva      = false
    @AppStorage("idiomaApp")             private var idiomaApp        = "es"
    @AppStorage("ubicacionActiva")       private var ubicacionActiva  = false
    @AppStorage("unidadTemp")            private var unidadTemp       = "C"

    @State private var mostrarAlertaCompletado  = false
    @State private var mostrarConfirmacionNueva = false
    @State private var mostrarAlertaUVAlto      = false
    @State private var mostrarAlertaMalClima    = false
    @State private var pausado                  = false

    private var tempFormateada: String {
        guard let temp = gestorClima.temperatura else { return "--" }
        let valor = unidadTemp == "F" ? Int(temp * 9/5 + 32) : Int(temp)
        return "\(valor)°\(unidadTemp)"
    }

    private var uvActual: Int { gestorClima.uvEntero }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                VStack(spacing: 0) {
                    Spacer()
                    anilloCronometro
                    Spacer(minLength: 32)
                    controlesRow
                    Spacer(minLength: 40)
                    tarjetaInfo
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, Diseno.relleno)
            }
            .navigationTitle(Textos.Sesion.titulo)
            .navigationBarTitleDisplayMode(.large)
            .alert(Textos.Sesion.alertaTitulo, isPresented: $mostrarAlertaCompletado) {
                Button(Textos.General.guardar) { guardarSesion(completada: true) }
                Button(Textos.General.descartar, role: .destructive) {
                    gestorSesion.reiniciar()
                    pausado = false
                }
            } message: {
                Text(Textos.Sesion.alertaMensaje(duracionMinutos))
            }
            .alert(Textos.Sesion.confirmarNuevaTitulo, isPresented: $mostrarConfirmacionNueva) {
                Button(Textos.Sesion.confirmarNuevaIniciar) {
                    guardarSesion(completada: false)
                    gestorSesion.iniciar(duracionMinutos: duracionMinutos)
                    pausado = false
                }
                Button(Textos.General.cancelar, role: .cancel) {}
            }
            .alert(Textos.Sesion.alertaUVTitulo, isPresented: $mostrarAlertaUVAlto) {
                Button(Textos.Sesion.alertaUVContinuar, role: .destructive) {
                    gestorSesion.iniciar(duracionMinutos: duracionMinutos)
                    pausado = false
                }
                Button(Textos.Sesion.alertaUVCancelar, role: .cancel) {}
            } message: {
                Text(Textos.Sesion.alertaUVMensaje(uvActual))
            }
            .alert(Textos.Sesion.alertaMalClimaTitulo, isPresented: $mostrarAlertaMalClima) {
                Button(Textos.Sesion.alertaMalClimaContinuar, role: .destructive) {
                    gestorSesion.iniciar(duracionMinutos: duracionMinutos)
                    pausado = false
                }
                Button(Textos.General.cancelar, role: .cancel) {}
            } message: {
                Text(Textos.Sesion.alertaMalClimaMensaje)
            }
            .onChange(of: gestorSesion.completo) { _, terminado in
                if terminado { mostrarAlertaCompletado = true }
            }
            .onAppear {
                if !gestorSesion.estaActiva {
                    gestorSesion.segundosObjetivo = duracionMinutos * 60
                }
            }
            .onChange(of: duracionMinutos) { _, nuevoValor in
                if !gestorSesion.estaActiva {
                    gestorSesion.segundosObjetivo = nuevoValor * 60
                }
            }
        }
        .id(idiomaApp)
    }

    // MARK: Anillo cronómetro
    private var anilloCronometro: some View {
        ZStack {
            // Pista base
            Circle()
                .stroke(Color.ambar.opacity(0.12), lineWidth: 14)
                .frame(width: 250, height: 250)

            // Arco de progreso
            Circle()
                .trim(from: 0, to: gestorSesion.progreso)
                .stroke(
                    AngularGradient(
                        colors: [.dorado, .ambar, .ambarProfundo, .ambar],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: gestorSesion.progreso)

            // Solecito en la punta del arco
            solEnPunta()

            // Centro con vidrio
            VStack(spacing: 6) {
                Text(gestorSesion.tiempoTexto)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.textoPrimario)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.5), value: gestorSesion.tiempoTexto)

                Text(Textos.Sesion.completado(Int(gestorSesion.progreso * 100)))
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    // Solecito posicionado en la punta del arco de progreso
    private func solEnPunta(radio: CGFloat = 125) -> some View {
        let angulo = Angle(degrees: -90.0 + 360.0 * gestorSesion.progreso)
        return Image(systemName: gestorTema.esDeNoche ? "moon.fill" : "sun.min.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.ambar)
            .shadow(color: .ambar.opacity(0.6), radius: 4, x: 0, y: 0)
            .offset(
                x: radio * CGFloat(cos(angulo.radians)),
                y: radio * CGFloat(sin(angulo.radians))
            )
            .opacity(gestorSesion.progreso > 0 ? 1 : 0)
            .animation(.linear(duration: 1), value: gestorSesion.progreso)
    }

    // MARK: Controles
    private var controlesRow: some View {
        HStack(spacing: Diseno.espaciado) {
            // Pausa / reanudar y detener, solo cuando hay sesión activa
            if gestorSesion.segundosSesion > 0 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if gestorSesion.estaActiva {
                            gestorSesion.pausar()
                            pausado = true
                        } else {
                            gestorSesion.reanudar()
                            pausado = false
                        }
                    }
                } label: {
                    Image(systemName: pausado ? "play.fill" : "pause.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.textoSecundario)
                        .padding(18)
                        .glassEffect(in: Circle())
                }

                Button {
                    withAnimation {
                        guardarSesion(completada: false)
                        pausado = false
                    }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.textoApagado)
                        .padding(18)
                        .glassEffect(in: Circle())
                }
            }

            // Botón principal: iniciar (con checks) o nueva sesión / card de noche
            if gestorSesion.segundosSesion == 0 && gestorTema.esDeNoche {
                cardNoche
            } else {
                Button {
                    if gestorSesion.segundosSesion == 0 {
                        if uvActual >= 8 {
                            mostrarAlertaUVAlto = true
                        } else if !gestorClima.esBuenDia && gestorClima.tieneDatos {
                            mostrarAlertaMalClima = true
                        } else {
                            gestorSesion.iniciar(duracionMinutos: duracionMinutos)
                            pausado = false
                        }
                    } else {
                        mostrarConfirmacionNueva = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: gestorSesion.segundosSesion == 0 ? "play.fill" : "arrow.clockwise")
                        Text(gestorSesion.segundosSesion == 0 ? Textos.Sesion.iniciar : Textos.Sesion.nueva)
                            .font(.fuenteCabecera)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 18)
                    .background(Color.ambar.gradient, in: Capsule())
                }
            }
        }
    }

    // MARK: Card de noche
    private var cardNoche: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 20))
                .foregroundStyle(.textoSecundario)
            VStack(alignment: .leading, spacing: 2) {
                Text(Textos.Sesion.sinSolTitulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)
                Text(Textos.Sesion.sinSolSub)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .glassEffect(in: Capsule())
    }

    // MARK: Tarjeta de info
    private var tarjetaInfo: some View {
        HStack(spacing: 0) {
            celdaInfo(icono: "timer",           etiqueta: Textos.Sesion.objetivo,    valor: "\(duracionMinutos) min")
            lineaDivisoria
            celdaInfo(icono: "sun.max.fill",    etiqueta: Textos.Sesion.indiceUV,    valor: gestorClima.tieneDatos ? "\(uvActual)" : "--")
            lineaDivisoria
            celdaInfo(icono: "thermometer.sun", etiqueta: Textos.Sesion.temperatura, valor: tempFormateada)
        }
        .padding(.vertical, 18)
        .tarjetaVidrio()
    }

    private func celdaInfo(icono: String, etiqueta: LocalizedStringKey, valor: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icono)
                .font(.system(size: 18))
                .foregroundStyle(.ambar)
            Text(valor)
                .font(.fuenteCabecera)
                .foregroundStyle(.textoPrimario)
            Text(etiqueta)
                .font(.fuenteMicro)
                .foregroundStyle(.textoApagado)
        }
        .frame(maxWidth: .infinity)
    }

    private var lineaDivisoria: some View {
        Rectangle()
            .fill(Color.textoApagado.opacity(0.2))
            .frame(width: 1, height: 40)
    }

    // MARK: Guardar sesión
    private func guardarSesion(completada: Bool) {
        guard gestorSesion.segundosSesion > 0 else { return }
        let duracion = gestorSesion.segundosSesion
        let ahora    = Date.now
        let sesion   = SesionSolar(
            fecha:            ahora,
            duracionSegundos: duracion,
            completada:       completada,
            indiceUV:         gestorClima.indiceUV ?? 0,
            temperatura:      gestorClima.temperatura ?? 0,
            ubicacion:        ubicacionActiva ? gestorUbicacion.nombreUbicacion : nil
        )
        contexto.insert(sesion)
        try? contexto.save()
        if saludActiva {
            gestorSalud.registrar(duracionSegundos: duracion, fin: ahora)
        }
        gestorSesion.reiniciar()
    }
}
