import SwiftUI
import UIKit

// MARK: Sistema de diseño "Solsticio"
// Colores adaptativos para modo día y modo noche
// El cambio se activa vía preferredColorScheme

// MARK: Helper interno para colores adaptativos
private func colorAdaptativo(dia: (CGFloat, CGFloat, CGFloat), noche: (CGFloat, CGFloat, CGFloat)) -> Color {
    Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: noche.0, green: noche.1, blue: noche.2, alpha: 1)
            : UIColor(red: dia.0,   green: dia.1,   blue: dia.2,   alpha: 1)
    })
}

// MARK: Colores
extension Color {
    // Día:  ámbar  #E8883A  |  Noche: índigo periwinkle #7B8EE0
    static let ambar = colorAdaptativo(
        dia:   (0.910, 0.533, 0.227),
        noche: (0.482, 0.557, 0.878)
    )
    // Día:  ámbar profundo #BC5926  |  Noche: índigo profundo #5569C3
    static let ambarProfundo = colorAdaptativo(
        dia:   (0.737, 0.349, 0.149),
        noche: (0.333, 0.412, 0.765)
    )
    // Día:  dorado  #F8C86D  |  Noche: plata lavanda #BEC6EB
    static let dorado = colorAdaptativo(
        dia:   (0.973, 0.784, 0.427),
        noche: (0.745, 0.776, 0.922)
    )
    // Salvia (éxito):cigual en día y noche
    static let salvia = Color(red: 0.416, green: 0.659, blue: 0.471) // #6AA878

    // Día:  crema  #FDF8F2  |  Noche: navy profundo #0F101F
    static let fondoCrema = colorAdaptativo(
        dia:   (0.992, 0.973, 0.949),
        noche: (0.059, 0.063, 0.122)
    )
    // Día:  melocotón #F5E9D9  |  Noche: navy índigo #161728
    static let fondoMelocoton = colorAdaptativo(
        dia:   (0.961, 0.914, 0.851),
        noche: (0.086, 0.090, 0.157)
    )

    // Día:  tinta oscura #1D1106  |  Noche: casi blanco #EEF0F8
    static let textoPrimario = colorAdaptativo(
        dia:   (0.114, 0.067, 0.024),
        noche: (0.933, 0.941, 0.973)
    )
    // Día:  marrón cálido #6B4A2A  |  Noche: lavanda suave #9AA4C8
    static let textoSecundario = colorAdaptativo(
        dia:   (0.420, 0.290, 0.165),
        noche: (0.604, 0.643, 0.784)
    )
    // Día:  canela #A5886A  |  Noche: azul-gris claro #7880A3 (WCAG AA 4.5:1)
    static let textoApagado = colorAdaptativo(
        dia:   (0.647, 0.533, 0.412),
        noche: (0.471, 0.502, 0.639)
    )

    // UV semántico (no adaptativos pues son colores de alerta universales)
    static let uvBajo    = Color(red: 0.416, green: 0.659, blue: 0.471) // verde (salvia)
    static let uvMedio   = Color(red: 0.973, green: 0.784, blue: 0.427) // dorado
    static let uvAlto    = Color(red: 0.910, green: 0.533, blue: 0.227) // ámbar
    static let uvMuyAlto = Color(red: 0.839, green: 0.271, blue: 0.173) // rojo #D6452C
}

extension ShapeStyle where Self == Color {
    static var ambar:           Color { Color.ambar }
    static var ambarProfundo:   Color { Color.ambarProfundo }
    static var dorado:          Color { Color.dorado }
    static var salvia:          Color { Color.salvia }
    static var fondoCrema:      Color { Color.fondoCrema }
    static var fondoMelocoton:  Color { Color.fondoMelocoton }
    static var textoPrimario:   Color { Color.textoPrimario }
    static var textoSecundario: Color { Color.textoSecundario }
    static var textoApagado:    Color { Color.textoApagado }
}

// MARK: Fondo gradiente de la app
// Usa colores adaptativos, cambia automáticamente al activar preferredColorScheme
struct FondoSolar: View {
    var body: some View {
        LinearGradient(
            colors: [.fondoCrema, .fondoMelocoton],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: Tarjeta Liquid Glass
struct EstiloTarjetaVidrio: ViewModifier {
    var radio: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .glassEffect(in: RoundedRectangle(cornerRadius: radio, style: .continuous))
    }
}

extension View {
    func tarjetaVidrio(_ radio: CGFloat = 20) -> some View {
        modifier(EstiloTarjetaVidrio(radio: radio))
    }
}

// MARK: Estilo de botón principal
struct EstiloBotonPrincipal: ButtonStyle {
    var destructivo: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(destructivo ? Color.red.gradient : Color.ambar.gradient)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: Tipografía (fuente redondeada, escala con Dynamic Type)
extension Font {
    static let fuenteTitular   = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let fuenteTitulo    = Font.system(.title,      design: .rounded, weight: .bold)
    static let fuenteTitulo2   = Font.system(.title2,     design: .rounded, weight: .semibold)
    static let fuenteCabecera  = Font.system(.headline,   design: .rounded, weight: .semibold)
    static let fuenteCuerpo    = Font.system(.body,       design: .rounded, weight: .regular)
    static let fuenteCaption   = Font.system(.caption,    design: .rounded, weight: .medium)
    static let fuenteMicro     = Font.system(.caption2,   design: .rounded, weight: .medium)
}

// MARK: Constantes de espaciado / diseño
enum Diseno {
    static let relleno:         CGFloat = 20
    static let rellenoS:        CGFloat = 12
    static let rellenoG:        CGFloat = 28
    static let radio:           CGFloat = 20
    static let radioS:          CGFloat = 12
    static let espaciado:       CGFloat = 16
    static let espaciadoS:      CGFloat = 10
    static let opacidadDivider: Double  = 0.2
}

// MARK: Estilo de botón para tarjetas interactivas
struct EstiloBotonTarjeta: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: Cabecera de sección reutilizable
struct CabeceraSeccion: View {
    let icono: String
    let titulo: LocalizedStringKey

    var body: some View {
        Label(titulo, systemImage: icono)
            .font(.fuenteCabecera)
            .foregroundStyle(.textoPrimario)
    }
}
