import WidgetKit
import SwiftUI

// MARK: Datos compartidos con la app vía App Group

private let suiteName = "group.dev.jeatog.Vitasol"

private struct DatosWidget {
    let metaCumplida: Bool
    let uvActual: Int
    let tieneDatosUV: Bool

    init() {
        let defaults = UserDefaults(suiteName: suiteName)
        metaCumplida  = defaults?.bool(forKey: "widget_meta_cumplida") ?? false
        uvActual      = defaults?.integer(forKey: "widget_uv_actual") ?? 0
        tieneDatosUV  = defaults?.bool(forKey: "widget_tiene_datos_uv") ?? false
    }
}

// MARK: Timeline

struct ProveedorWidget: TimelineProvider {
    func placeholder(in context: Context) -> EntradaWidget {
        EntradaWidget(date: .now, metaCumplida: false, uvActual: 4, tieneDatosUV: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (EntradaWidget) -> Void) {
        let datos = DatosWidget()
        completion(EntradaWidget(
            date: .now,
            metaCumplida: datos.metaCumplida,
            uvActual: datos.uvActual,
            tieneDatosUV: datos.tieneDatosUV
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaWidget>) -> Void) {
        let datos = DatosWidget()
        let entrada = EntradaWidget(
            date: .now,
            metaCumplida: datos.metaCumplida,
            uvActual: datos.uvActual,
            tieneDatosUV: datos.tieneDatosUV
        )
        // Refrescar cada 30 minutos
        let siguiente = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entrada], policy: .after(siguiente)))
    }
}

struct EntradaWidget: TimelineEntry {
    let date: Date
    let metaCumplida: Bool
    let uvActual: Int
    let tieneDatosUV: Bool
}

// MARK: Colores locales

private let colAmbar  = Color(red: 0.910, green: 0.533, blue: 0.227)
private let colSalvia = Color(red: 0.416, green: 0.659, blue: 0.471)
private let colDorado = Color(red: 0.973, green: 0.784, blue: 0.427)

// MARK: Vista del widget

struct VistaWidget: View {
    let entrada: EntradaWidget

    private var esDeNoche: Bool {
        let hora = Calendar.current.component(.hour, from: entrada.date)
        return hora < 7 || hora >= 19
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Ícono de estado
            HStack {
                Image(systemName: iconoEstado)
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorEstado, colorEstado.opacity(0.6))

                Spacer()

                if entrada.tieneDatosUV && !esDeNoche {
                    Text("\(entrada.uvActual)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(colorUV.gradient, in: Capsule())
                }
            }

            Spacer()

            // Texto de estado
            Text(textoEstado)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(esDeNoche
                 ? String(localized: "widget.descansa")
                 : String(localized: "widget.toca_para_iniciar"))
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var iconoEstado: String {
        if entrada.metaCumplida { return "checkmark.seal.fill" }
        if esDeNoche { return "moon.stars.fill" }
        return "sun.max.fill"
    }

    private var colorEstado: Color {
        if entrada.metaCumplida { return colSalvia }
        if esDeNoche { return .secondary }
        return colAmbar
    }

    private var textoEstado: String {
        if entrada.metaCumplida { return String(localized: "widget.meta_cumplida") }
        if esDeNoche { return String(localized: "widget.buenas_noches") }
        return String(localized: "widget.listo_para_sol")
    }

    private var colorUV: Color {
        switch entrada.uvActual {
        case 0...2:  return colSalvia
        case 3...5:  return colDorado
        case 6...7:  return colAmbar
        default:     return Color(red: 0.839, green: 0.271, blue: 0.173)
        }
    }
}

// MARK: Configuración del widget

struct VitasolWidget: Widget {
    let kind = "VitasolWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorWidget()) { entrada in
            VistaWidget(entrada: entrada)
        }
        .configurationDisplayName(String(localized: "widget.nombre"))
        .description(String(localized: "widget.descripcion"))
        .supportedFamilies([.systemSmall])
    }
}

// MARK: Preview

#Preview(as: .systemSmall) {
    VitasolWidget()
} timeline: {
    EntradaWidget(date: .now, metaCumplida: false, uvActual: 5, tieneDatosUV: true)
    EntradaWidget(date: .now, metaCumplida: true, uvActual: 3, tieneDatosUV: true)
}
