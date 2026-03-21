import SwiftUI

struct VistaBienvenida: View {
    @Environment(GestorNotificaciones.self) private var gestorNotificaciones
    @Environment(GestorUbicacion.self)      private var gestorUbicacion
    @Environment(GestorSalud.self)          private var gestorSalud

    @AppStorage("notificacionesActivas") private var notificacionesActivas = false
    @AppStorage("ubicacionActiva")       private var ubicacionActiva      = false
    @AppStorage("saludActiva")           private var saludActiva          = false
    @AppStorage("primerLanzamiento")     private var primerLanzamiento    = true

    @State private var pasoActual = 0

    var body: some View {
        ZStack {
            FondoSolar()

            VStack(spacing: 0) {
                Spacer()

                // Logo y nombre
                if pasoActual == 0 {
                    contenidoBienvenida
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    contenidoPermisos
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                Spacer()

                // Botón principal
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        if pasoActual == 0 {
                            pasoActual = 1
                        } else {
                            primerLanzamiento = false
                        }
                    }
                } label: {
                    Text(pasoActual == 0
                         ? String(localized: "bienvenida.continuar")
                         : String(localized: "bienvenida.comenzar"))
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.ambar.gradient, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, Diseno.relleno)

                // Skip / indicador
                if pasoActual == 1 {
                    Text(String(localized: "bienvenida.despues"))
                        .font(.fuenteCaption)
                        .foregroundStyle(.textoApagado)
                        .padding(.top, 10)
                }

                Spacer(minLength: 40)
            }
        }
    }

    // MARK: Paso 1 — Bienvenida
    private var contenidoBienvenida: some View {
        VStack(spacing: 24) {
            if let logo = UIImage(named: "logo_solo") {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }

            VStack(spacing: 8) {
                Text("Vitasol")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.textoPrimario)

                Text(String(localized: "bienvenida.subtitulo"))
                    .font(.fuenteCuerpo)
                    .foregroundStyle(.textoSecundario)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Diseno.rellenoG)
            }
        }
    }

    // MARK: Paso 2 — Permisos
    private var contenidoPermisos: some View {
        VStack(spacing: Diseno.espaciado) {
            Text(String(localized: "bienvenida.permisos_titulo"))
                .font(.fuenteTitulo2)
                .foregroundStyle(.textoPrimario)

            Text(String(localized: "bienvenida.permisos_desc"))
                .font(.fuenteCuerpo)
                .foregroundStyle(.textoSecundario)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Diseno.relleno)

            VStack(spacing: Diseno.rellenoS) {
                filaPermiso(
                    icono: "location.fill",
                    color: .salvia,
                    titulo: String(localized: "bienvenida.permiso_ubicacion"),
                    descripcion: String(localized: "bienvenida.permiso_ubicacion_desc"),
                    activado: $ubicacionActiva
                ) { activar in
                    if activar { gestorUbicacion.solicitar() }
                }

                filaPermiso(
                    icono: "bell.badge.fill",
                    color: .ambar,
                    titulo: String(localized: "bienvenida.permiso_notificaciones"),
                    descripcion: String(localized: "bienvenida.permiso_notificaciones_desc"),
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
                    titulo: String(localized: "bienvenida.permiso_salud"),
                    descripcion: String(localized: "bienvenida.permiso_salud_desc"),
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
        titulo: String, descripcion: String,
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
