import ActivityKit
import WidgetKit
import SwiftUI

// MARK: Color local

private let colAmbar = Color(red: 0.910, green: 0.533, blue: 0.227) // #E8883A

// MARK: Arco de progreso (Dynamic Island expandida)

private struct ArcoProgreso: View {
    let progreso: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(colAmbar.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progreso)
                .stroke(colAmbar, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progreso)
            Image(systemName: "sun.min.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(colAmbar)
        }
    }
}

// MARK: Banner / Pantalla de bloqueo

private struct BannerSesion: View {
    let context: ActivityViewContext<SesionSolarActividad>

    private var inicioSesion: Date {
        context.state.fechaFin.addingTimeInterval(-Double(context.attributes.duracionSegundos))
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: context.isStale ? "checkmark.circle.fill" : "sun.min.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(colAmbar)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(context.isStale ? String(localized: "live.sesion_completada") : String(localized: "live.sesion_solar"))
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

            return DynamicIsland {

                // Arco — muestra 100% si la sesión expiró
                DynamicIslandExpandedRegion(.leading) {
                    ArcoProgreso(progreso: context.isStale ? 1.0 : context.state.progreso)
                        .frame(width: 52, height: 52)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("Vitasol")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.trailing, 10)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Link(destination: URL(string: "vitasol://sesion")!) {
                        HStack(spacing: 6) {
                            if context.isStale {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(colAmbar)
                                Text(String(localized: "live.sesion_completada"))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(colAmbar)
                            } else {
                                Text(String(localized: "live.quedan"))
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text(context.state.fechaFin, style: .timer)
                                    .monospacedDigit()
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(colAmbar)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 2)
                        .padding(.bottom, 8)
                    }
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
        SesionSolarActividad(duracionSegundos: 900)
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
