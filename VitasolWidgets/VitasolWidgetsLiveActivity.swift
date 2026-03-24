import ActivityKit
import WidgetKit
import SwiftUI

// MARK: Color local

private let colAmbar = Color(red: 0.910, green: 0.533, blue: 0.227) // #E8883A

// (sin struct auxiliar, todo inline en el DI)

// MARK: Banner / Pantalla de bloqueo

private struct BannerSesion: View {
    let context: ActivityViewContext<SesionSolarActividad>

    private var inicioSesion: Date {
        context.state.fechaFin.addingTimeInterval(-Double(context.attributes.duracionSegundos))
    }

    private var esIngles: Bool { context.attributes.idioma == "en" }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: context.isStale ? "checkmark.circle.fill" : "sun.min.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(colAmbar)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(context.isStale
                         ? (esIngles ? "Session completed!" : "¡Sesión completada!")
                         : (esIngles ? "Solar session" : "Sesión solar"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Spacer()

                    if context.isStale {
                        Text("0:00")
                            .monospacedDigit()
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(colAmbar)
                    } else {
                        Text(context.state.fechaFin, style: .timer)
                            .monospacedDigit()
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(colAmbar)
                    }
                }

                if context.isStale {
                    ProgressView(value: 1.0, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(colAmbar)
                } else {
                    ProgressView(
                        timerInterval: inicioSesion...context.state.fechaFin,
                        countsDown: false
                    )
                    .labelsHidden()
                    .progressViewStyle(.linear)
                    .tint(colAmbar)
                }
            }
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.06))
        .activitySystemActionForegroundColor(colAmbar)
    }
}

// MARK: Widget principal

struct VitasolWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SesionSolarActividad.self) { context in

            BannerSesion(context: context)

        } dynamicIsland: { context in

            let inicio = context.state.fechaFin.addingTimeInterval(-Double(context.attributes.duracionSegundos))

            return DynamicIsland {

                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.isStale ? "checkmark.circle.fill" : "sun.min.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(colAmbar)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.center) {
                    let esEn = context.attributes.idioma == "en"
                    if context.isStale {
                        Text(esEn ? "Session completed!" : "¡Sesión completada!")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        Text(context.state.fechaFin, style: .timer)
                            .monospacedDigit()
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(colAmbar)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Link(destination: URL(string: "vitasol://sesion")!) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(colAmbar)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.trailing, 6)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        timerInterval: inicio...context.state.fechaFin,
                        countsDown: false
                    )
                    .labelsHidden()
                    .progressViewStyle(.linear)
                    .tint(colAmbar)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }

            } compactLeading: {

                Image(systemName: context.isStale ? "checkmark.circle.fill" : "sun.min.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(colAmbar)

            } compactTrailing: {

                if context.isStale {
                    Text("0:00")
                        .monospacedDigit()
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colAmbar)
                } else {
                    Text(context.state.fechaFin, style: .timer)
                        .monospacedDigit()
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colAmbar)
                        .frame(maxWidth: 44)
                }

            } minimal: {

                Image(systemName: context.isStale ? "checkmark.circle.fill" : "sun.min.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colAmbar)

            }
            .keylineTint(colAmbar)
        }
    }
}

// MARK: Preview

extension SesionSolarActividad {
    fileprivate static var preview: SesionSolarActividad {
        SesionSolarActividad(duracionSegundos: 900, idioma: "es")
    }
}

extension SesionSolarActividad.ContentState {
    fileprivate static var enCurso: SesionSolarActividad.ContentState {
        SesionSolarActividad.ContentState(progreso: 0.6,  fechaFin: Date.now.addingTimeInterval(360))
    }
    fileprivate static var casiCompleta: SesionSolarActividad.ContentState {
        SesionSolarActividad.ContentState(progreso: 0.92, fechaFin: Date.now.addingTimeInterval(72))
    }
}

#Preview("Banner", as: .content, using: SesionSolarActividad.preview) {
    VitasolWidgetsLiveActivity()
} contentStates: {
    SesionSolarActividad.ContentState.enCurso
    SesionSolarActividad.ContentState.casiCompleta
}
