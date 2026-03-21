import SwiftUI

struct VistaSplash: View {
    @State private var escala: CGFloat = 1.0
    @State private var rotacion: Double = 0
    @State private var opacidadFondo: Double = 1

    var body: some View {
        ZStack {
            // Fondo sólido que se desvanece al final
            FondoSolar()
                .opacity(opacidadFondo)

            // Logo que gira y escala hasta cubrir toda la pantalla
            if let logo = UIImage(named: "logo_solo") {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .scaleEffect(escala)
                    .rotationEffect(.degrees(rotacion))
            }
        }
        .onAppear {
            // Fase 1: giro lento + escala masiva estilo Twitter
            withAnimation(.easeIn(duration: 1.2)) {
                rotacion = 180
                escala = 25
            }

            // Fase 2: fade out del fondo (revela la app detrás)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacidadFondo = 0
                }
            }
        }
    }
}
