import SwiftUI

// MARK: Vista principal de Aprender

struct VistaAprender: View {
    @AppStorage("idiomaApp") private var idiomaApp = "es"
    @State private var articuloSeleccionado: Articulo?

    private var articulos: [Articulo] {
        CargadorArticulos.cargar(idioma: idiomaApp)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(spacing: Diseno.espaciado) {
                        ForEach(articulos) { articulo in
                            TarjetaArticulo(articulo: articulo) {
                                articuloSeleccionado = articulo
                            }
                        }
                        avisoImportante
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Diseno.relleno)
                    .padding(.top, 4)
                }
            }
            .navigationTitle(Textos.Aprender.titulo)
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $articuloSeleccionado) { articulo in
                DetalleArticulo(articulo: articulo)
            }
        }
    }

    // MARK: Disclaimer
    private var avisoImportante: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.ambar)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 6) {
                Text(Textos.Aprender.avisoTitulo)
                    .font(.fuenteCabecera)
                    .foregroundStyle(.textoPrimario)

                Text(Textos.Aprender.avisoTexto)
                    .font(.fuenteCuerpo)
                    .foregroundStyle(.textoSecundario)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Diseno.relleno)
        .tarjetaVidrio()
        .accessibilityElement(children: .combine)
    }
}

// MARK: Tarjeta de artículo (lista principal)

struct TarjetaArticulo: View {
    let articulo: Articulo
    let alSeleccionar: () -> Void

    var body: some View {
        Button(action: alSeleccionar) {
            VStack(spacing: 0) {
                // Encabezado con gradiente e ícono
                ZStack {
                    LinearGradient(
                        colors: [articulo.colorInicio, articulo.colorFin],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Ícono decorativo grande semitransparente
                    Image(systemName: articulo.icono)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white.opacity(0.2))
                        .offset(x: 60, y: -10)

                    // Ícono principal centrado
                    Image(systemName: articulo.icono)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .frame(height: 120)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: Diseno.radio,
                        topTrailingRadius: Diseno.radio
                    )
                )

                // Título y subtítulo
                VStack(alignment: .leading, spacing: 6) {
                    Text(articulo.titulo)
                        .font(.fuenteCabecera)
                        .foregroundStyle(.textoPrimario)
                        .multilineTextAlignment(.leading)

                    Text(articulo.subtitulo)
                        .font(.fuenteCaption)
                        .foregroundStyle(.textoApagado)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Diseno.relleno)
            }
            .tarjetaVidrio()
            .clipShape(RoundedRectangle(cornerRadius: Diseno.radio, style: .continuous))
        }
        .buttonStyle(EstiloBotonTarjeta())
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: Detalle del artículo (sheet)

struct DetalleArticulo: View {
    let articulo: Articulo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Encabezado con gradiente y parallax
                    GeometryReader { geo in
                        let desplazamiento = geo.frame(in: .scrollView).minY
                        let estirado = max(0, desplazamiento)

                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [articulo.colorInicio, articulo.colorFin],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            // Íconos decorativos
                            Image(systemName: articulo.icono)
                                .font(.system(size: 120, weight: .bold))
                                .foregroundStyle(.white.opacity(0.1))
                                .offset(x: 180, y: -20 - estirado * 0.3)

                            Image(systemName: articulo.icono)
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                                .padding(Diseno.rellenoG)
                        }
                        .frame(height: 200 + estirado)
                        .offset(y: -estirado)
                    }
                    .frame(height: 200)

                    // Contenido
                    VStack(alignment: .leading, spacing: 24) {
                        // Título
                        Text(articulo.titulo)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.textoPrimario)

                        // Secciones
                        ForEach(Array(articulo.secciones.enumerated()), id: \.offset) { _, seccion in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(seccion.titulo)
                                    .font(.fuenteTitulo2)
                                    .foregroundStyle(.textoPrimario)

                                ForEach(seccion.parrafos, id: \.self) { parrafo in
                                    Text(parrafo)
                                        .font(.fuenteCuerpo)
                                        .foregroundStyle(.textoSecundario)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineSpacing(4)
                                }
                            }
                        }

                        // Fuentes
                        if !articulo.fuentes.isEmpty {
                            Divider()
                                .overlay(Color.textoApagado.opacity(0.2))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(String(localized: "aprender.fuentes"))
                                    .font(.fuenteCaption)
                                    .foregroundStyle(.textoApagado)
                                    .textCase(.uppercase)
                                    .tracking(0.8)

                                ForEach(articulo.fuentes, id: \.self) { fuente in
                                    Text("• \(fuente)")
                                        .font(.fuenteMicro)
                                        .foregroundStyle(.textoApagado)
                                }
                            }
                        }
                    }
                    .padding(Diseno.relleno)
                    .padding(.top, 8)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.textoApagado)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}
