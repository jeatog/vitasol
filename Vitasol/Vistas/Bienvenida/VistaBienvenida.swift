import SwiftUI

// MARK: Datos de las cards del onboarding

private struct CardOnboarding: Identifiable {
    let id: Int
    let icono: String
    let titulo: LocalizedStringKey
    let descripcion: LocalizedStringKey
    let colorInicio: Color
    let colorFin: Color
}

private let cardsInfo: [CardOnboarding] = [
    CardOnboarding(
        id: 0,
        icono: "timer",
        titulo: "onboarding.card1_titulo",
        descripcion: "onboarding.card1_desc",
        colorInicio: .ambar,
        colorFin: .dorado
    ),
    CardOnboarding(
        id: 1,
        icono: "sun.max.fill",
        titulo: "onboarding.card2_titulo",
        descripcion: "onboarding.card2_desc",
        colorInicio: .dorado,
        colorFin: .salvia
    ),
    CardOnboarding(
        id: 2,
        icono: "trophy.fill",
        titulo: "onboarding.card3_titulo",
        descripcion: "onboarding.card3_desc",
        colorInicio: .salvia,
        colorFin: .ambar
    ),
]

// MARK: Vista principal de bienvenida

struct VistaBienvenida: View {
    @Environment(GestorNotificaciones.self) private var gestorNotificaciones
    @Environment(GestorUbicacion.self)      private var gestorUbicacion
    @Environment(GestorSalud.self)          private var gestorSalud

    @AppStorage("notificacionesActivas") private var notificacionesActivas = false
    @AppStorage("ubicacionActiva")       private var ubicacionActiva      = false
    @AppStorage("saludActiva")           private var saludActiva          = false
    @AppStorage("primerLanzamiento")     private var primerLanzamiento    = true
    @AppStorage("idiomaApp")             private var idiomaApp            = "es"

    @State private var paginaActual = -1 // -1 = idioma, 0-2 = cards, 3 = permisos
    private let ultimaPagina = 3 // permisos

    private var idiomaDetectado: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "es"
        return lang == "en" ? "en" : "es"
    }

    var body: some View {
        ZStack {
            // Fondo con logo blur
            FondoSolar()
            fondoLogoBlur

            VStack(spacing: 0) {
                // Logo y nombre (fijos arriba)
                cabeceraLogo
                    .padding(.top, 60)

                Spacer()

                // Idioma, carrusel o permisos
                if paginaActual == -1 {
                    selectorIdioma
                        .transition(.opacity)
                } else if paginaActual < 3 {
                    carrusel3D
                        .transition(.opacity)
                } else {
                    contenidoPermisos
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                Spacer()

                // Indicadores de página (no se muestran en la pantalla de idioma)
                if paginaActual >= 0 {
                    indicadores
                        .padding(.bottom, 20)
                }

                // Botón comenzar (solo en la última)
                if paginaActual == 3 {
                    botonComenzar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 10)
                }

                // Texto helper
                Text("bienvenida.despues")
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
                    .opacity(paginaActual == 3 ? 1 : 0)
                    .padding(.bottom, 30)
            }
        }
        .animation(.spring(response: 0.5), value: paginaActual)
        .onChange(of: paginaActual) { _, nueva in
            // Clamp para evitar ir más allá de los permisos
            if nueva > ultimaPagina { paginaActual = ultimaPagina }
        }
        .onAppear {
            idiomaApp = idiomaDetectado
        }
    }

    // MARK: Selector de idioma (pantalla 0)
    private var selectorIdioma: some View {
        VStack(spacing: 24) {
            Text("Choose your language")
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoApagado)

            VStack(spacing: Diseno.rellenoS) {
                botonIdioma(nombre: "Español", codigo: "es", bandera: "🇲🇽")
                botonIdioma(nombre: "English", codigo: "en", bandera: "🇺🇸")
            }
            .padding(.horizontal, Diseno.rellenoG)
        }
    }

    private func botonIdioma(nombre: String, codigo: String, bandera: String) -> some View {
        Button {
            idiomaApp = codigo
            withAnimation { paginaActual = 0 }
        } label: {
            HStack(spacing: 14) {
                Text(bandera)
                    .font(.system(size: 28))

                Text(nombre)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)

                Spacer()

                if idiomaApp == codigo {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.ambar)
                        .font(.system(size: 20))
                }
            }
            .padding(Diseno.rellenoS + 4)
            .tarjetaVidrio()
        }
        .buttonStyle(EstiloBotonTarjeta())
    }

    // MARK: Logo blur de fondo
    private var fondoLogoBlur: some View {
        Group {
            if let logo = UIImage(named: "logo_solo") {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .blur(radius: 60)
                    .opacity(0.12)
            }
        }
    }

    // MARK: Cabecera con logo
    private var cabeceraLogo: some View {
        VStack(spacing: 10) {
            if let logo = UIImage(named: "logo_solo") {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
            }

            Text("Vitasol")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.textoPrimario)

            if paginaActual >= 0 {
                Text("bienvenida.subtitulo")
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Diseno.rellenoG)
            }
        }
    }

    // MARK: Carrusel 3D
    private let espacioCards: CGFloat = 16

    private var carrusel3D: some View {
        GeometryReader { geo in
            let anchoCard: CGFloat = geo.size.width * 0.65
            let paso = anchoCard + espacioCards
            let inicioX = (geo.size.width - anchoCard) / 2
            let desplazamientoX = inicioX - CGFloat(paginaActual) * paso

            HStack(spacing: espacioCards) {
                ForEach(cardsInfo) { card in
                    let distancia = CGFloat(card.id - paginaActual)
                    let angulo = Double(distancia) * 18
                    let escala = distancia == 0 ? 1.0 : 0.82
                    let opacidad = abs(distancia) > 1.5 ? 0.3 : (distancia == 0 ? 1.0 : 0.55)

                    cardView(card: card)
                        .frame(width: anchoCard, height: anchoCard * 1.3)
                        .scaleEffect(escala)
                        .rotation3DEffect(.degrees(angulo), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
                        .opacity(opacidad)
                        .zIndex(distancia == 0 ? 1 : 0)
                }
            }
            .offset(x: desplazamientoX)
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: paginaActual)
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < -50 && paginaActual < ultimaPagina {
                            paginaActual += 1
                        } else if value.translation.width > 50 && paginaActual > 0 {
                            paginaActual -= 1
                        }
                    }
            )
        }
        .frame(height: 340)
    }

    // MARK: Card individual
    private func cardView(card: CardOnboarding) -> some View {
        VStack(spacing: 20) {
            // Gradiente con ícono
            ZStack {
                LinearGradient(
                    colors: [card.colorInicio, card.colorFin],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: card.icono)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white.opacity(0.15))
                    .offset(x: 40, y: -20)

                Image(systemName: card.icono)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .frame(height: 140)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: Diseno.radio, topTrailingRadius: Diseno.radio))

            // Texto
            VStack(spacing: 8) {
                Text(card.titulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)
                    .multilineTextAlignment(.center)

                Text(card.descripcion)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Diseno.rellenoS)

            Spacer()
        }
        .glassEffect(in: RoundedRectangle(cornerRadius: Diseno.radio, style: .continuous))
    }

    // MARK: Indicadores de página (4: cards 0-2 + permisos)
    private var indicadores: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { indice in
                if indice == 3 {
                    // Último es checkmark
                    Image(systemName: paginaActual == indice ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 10))
                        .foregroundStyle(paginaActual == indice ? .ambar : .textoApagado.opacity(0.4))
                } else {
                    Circle()
                        .fill(paginaActual == indice ? Color.ambar : Color.textoApagado.opacity(0.3))
                        .frame(width: paginaActual == indice ? 10 : 7, height: paginaActual == indice ? 10 : 7)
                }
            }
        }
        .animation(.spring(response: 0.3), value: paginaActual)
    }

    // MARK: Botón comenzar
    private var botonComenzar: some View {
        Button {
            withAnimation {
                primerLanzamiento = false
            }
        } label: {
            Label("bienvenida.comenzar", systemImage: "checkmark")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.ambar.gradient, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, Diseno.relleno)
    }

    // MARK: Contenido de permisos (página 4)
    private var contenidoPermisos: some View {
        VStack(spacing: Diseno.espaciado) {
            Text("bienvenida.permisos_titulo")
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoPrimario)

            Text("bienvenida.permisos_desc")
                .font(.fuenteCuerpo)
                .foregroundStyle(.textoSecundario)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Diseno.relleno)

            VStack(spacing: Diseno.rellenoS) {
                filaPermiso(
                    icono: "location.fill",
                    color: .salvia,
                    titulo: "bienvenida.permiso_ubicacion",
                    descripcion: "bienvenida.permiso_ubicacion_desc",
                    activado: $ubicacionActiva
                ) { activar in
                    if activar { gestorUbicacion.solicitar() }
                }

                filaPermiso(
                    icono: "bell.badge.fill",
                    color: .ambar,
                    titulo: "bienvenida.permiso_notificaciones",
                    descripcion: "bienvenida.permiso_notificaciones_desc",
                    activado: $notificacionesActivas
                ) { activar in
                    if activar {
                        Task {
                            let concedido = await gestorNotificaciones.solicitarPermiso()
                            if !concedido { notificacionesActivas = false }
                        }
                    }
                }

                filaPermiso(
                    icono: "heart.fill",
                    color: .red,
                    titulo: "bienvenida.permiso_salud",
                    descripcion: "bienvenida.permiso_salud_desc",
                    activado: $saludActiva
                ) { activar in
                    if activar {
                        Task {
                            let concedido = await gestorSalud.solicitarPermiso()
                            if !concedido { saludActiva = false }
                        }
                    }
                }
            }
            .padding(.horizontal, Diseno.relleno)
        }
    }

    // MARK: Fila de permiso
    private func filaPermiso(
        icono: String, color: Color,
        titulo: LocalizedStringKey, descripcion: LocalizedStringKey,
        activado: Binding<Bool>,
        alCambiar: @escaping (Bool) -> Void
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icono)
                .font(.system(size: 17))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)
                Text(descripcion)
                    .font(.fuenteCaption)
                    .foregroundStyle(.textoApagado)
            }

            Spacer()

            Toggle("", isOn: activado)
                .tint(.ambar)
                .labelsHidden()
                .onChange(of: activado.wrappedValue) { _, nuevo in
                    alCambiar(nuevo)
                }
        }
        .padding(Diseno.rellenoS + 4)
        .tarjetaVidrio()
    }
}
