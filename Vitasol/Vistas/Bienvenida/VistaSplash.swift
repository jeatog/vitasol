import SwiftUI

struct VistaSplash: View {
    @State private var escala: CGFloat = 0.3
    @State private var rotacion: Double = 0
    @State private var opacidad: Double = 1
    @State private var terminado = false

    var body: some View {
        ZStack {
            // Fondo que coincide con el gradiente de la app
            FondoSolar()

            if !terminado {
                VStack(spacing: 16) {
                    if let logo = UIImage(named: "logo_solo") {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .scaleEffect(escala)
                            .rotationEffect(.degrees(rotacion))
                    }

                    Text("Vitasol")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.textoPrimario)
                        .opacity(escala > 0.8 ? 1 : 0)
                }
                .opacity(opacidad)
            }
        }
        .onAppear {
            // Fase 1: zoom in + giro (0 -> 1s)
            withAnimation(.easeOut(duration: 1.0)) {
                escala = 1.0
                rotacion = 360
            }

            // Fase 2: fade out (1.2s -> 1.6s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.4)) {
                    opacidad = 0
                }
            }

            // Fase 3: marcar como terminado
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                terminado = true
            }
        }
    }

    var estaTerminado: Bool { terminado }
}
