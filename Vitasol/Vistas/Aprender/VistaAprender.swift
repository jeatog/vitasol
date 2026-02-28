import SwiftUI

// MARK: Modelo de tema de aprendizaje
struct TemaAprendizaje: Identifiable {
    let id    = UUID()
    let icono:  String
    let titulo: LocalizedStringKey
    let color:  Color
    let puntos: [LocalizedStringKey]
}

// MARK: Vista principal
struct VistaAprender: View {
    private let temas: [TemaAprendizaje] = [
        TemaAprendizaje(
            icono: "sun.max.fill",
            titulo: Textos.Aprender.queEsTitulo,
            color: .ambar,
            puntos: [
                Textos.Aprender.queEsB1,
                Textos.Aprender.queEsB2,
                Textos.Aprender.queEsB3,
            ]
        ),
        TemaAprendizaje(
            icono: "heart.fill",
            titulo: Textos.Aprender.beneficiosTitulo,
            color: Color(red: 0.80, green: 0.25, blue: 0.45),
            puntos: [
                Textos.Aprender.beneficiosB1,
                Textos.Aprender.beneficiosB2,
                Textos.Aprender.beneficiosB3,
                Textos.Aprender.beneficiosB4,
                Textos.Aprender.beneficiosB5,
            ]
        ),
        TemaAprendizaje(
            icono: "leaf.fill",
            titulo: Textos.Aprender.fuentesTitulo,
            color: .salvia,
            puntos: [
                Textos.Aprender.fuentesB1,
                Textos.Aprender.fuentesB2,
                Textos.Aprender.fuentesB3,
                Textos.Aprender.fuentesB4,
                Textos.Aprender.fuentesB5,
            ]
        ),
        TemaAprendizaje(
            icono: "lightbulb.fill",
            titulo: Textos.Aprender.consejosTitulo,
            color: .dorado,
            puntos: [
                Textos.Aprender.consejosB1,
                Textos.Aprender.consejosB2,
                Textos.Aprender.consejosB3,
                Textos.Aprender.consejosB4,
                Textos.Aprender.consejosB5,
            ]
        ),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(spacing: Diseno.espaciado) {
                        ForEach(temas) { tema in
                            TarjetaTema(tema: tema)
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
        }
    }

    // MARK: Aviso legal / disclaimer
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
        .background(Color.ambar.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Diseno.radio, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Diseno.radio, style: .continuous)
                .strokeBorder(Color.ambar.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: Tarjeta de tema (expandible)
struct TarjetaTema: View {
    let tema: TemaAprendizaje
    @State private var expandido = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera — tap para expandir
            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                    expandido.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: tema.icono)
                        .font(.system(size: 17))
                        .foregroundStyle(tema.color)
                        .frame(width: 40, height: 40)
                        .background(tema.color.opacity(0.12))
                        .clipShape(Circle())

                    Text(tema.titulo)
                        .font(.fuenteCabecera)
                        .foregroundStyle(.textoPrimario)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.textoApagado)
                        .rotationEffect(.degrees(expandido ? 90 : 0))
                }
                .padding(Diseno.relleno)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Contenido expandido
            if expandido {
                Divider()
                    .overlay(Color.textoApagado.opacity(0.18))
                    .padding(.horizontal, Diseno.relleno)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(tema.puntos.enumerated()), id: \.offset) { _, punto in
                        Text(punto)
                            .font(.fuenteCuerpo)
                            .foregroundStyle(.textoSecundario)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Diseno.relleno)
                .transition(.opacity.combined(with: .push(from: .top)))
            }
        }
        .tarjetaVidrio()
        .clipShape(RoundedRectangle(cornerRadius: Diseno.radio, style: .continuous))
    }
}
