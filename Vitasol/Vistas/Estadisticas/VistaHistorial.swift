import SwiftUI
import UIKit

// MARK: Filtro de período

enum PeriodoFiltro: CaseIterable, Equatable {
    case dias7, mes, meses3, todo

    var etiqueta: LocalizedStringKey {
        switch self {
        case .dias7:  return Textos.Estadisticas.periodo7dias
        case .mes:    return Textos.Estadisticas.periodoMes
        case .meses3: return Textos.Estadisticas.periodo3meses
        case .todo:   return Textos.Estadisticas.periodoTodo
        }
    }

    var fechaCorte: Date? {
        let cal = Calendar.current
        switch self {
        case .dias7:  return cal.date(byAdding: .day,   value: -7, to: .now)
        case .mes:    return cal.date(byAdding: .month, value: -1, to: .now)
        case .meses3: return cal.date(byAdding: .month, value: -3, to: .now)
        case .todo:   return nil
        }
    }
}

// MARK: Categoría UV

enum UVCategoria: CaseIterable, Equatable, Hashable {
    case bajo, medio, alto, muyAlto

    var etiqueta: LocalizedStringKey {
        switch self {
        case .bajo:    return Textos.Estadisticas.uvBajoLabel
        case .medio:   return Textos.Estadisticas.uvMedioLabel
        case .alto:    return Textos.Estadisticas.uvAltoLabel
        case .muyAlto: return Textos.Estadisticas.uvMuyAltoLabel
        }
    }

    var rango: ClosedRange<Double> {
        switch self {
        case .bajo:    return 0...2.999
        case .medio:   return 3...5.999
        case .alto:    return 6...7.999
        case .muyAlto: return 8...20
        }
    }

    var color: Color {
        switch self {
        case .bajo:    return .uvBajo
        case .medio:   return .uvMedio
        case .alto:    return .uvAlto
        case .muyAlto: return .uvMuyAlto
        }
    }

    func contiene(_ uv: Double) -> Bool { rango.contains(uv) }
}

// MARK: Vista del sheet de historial

struct VistaHistorial: View {
    let sesiones: [SesionSolar]
    @Environment(\.dismiss) private var dismiss
    @AppStorage("idiomaApp") private var idiomaApp = "es"

    @State private var periodo:          PeriodoFiltro = .todo
    @State private var uvFiltro:         UVCategoria?  = nil
    @State private var ubicacionFiltro:  String?       = nil
    @State private var archivoExportar:  ArchivoExportable?

    private var ubicacionesUnicas: [String] {
        Array(Set(sesiones.compactMap { $0.ubicacion })).sorted()
    }

    private var sesionesFiltradas: [SesionSolar] {
        sesiones.filter { sesion in
            if let corte = periodo.fechaCorte, sesion.fecha < corte { return false }
            if let uv    = uvFiltro,           !uv.contiene(sesion.indiceUV) { return false }
            if let lugar = ubicacionFiltro,    sesion.ubicacion != lugar     { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FondoSolar()

                ScrollView {
                    VStack(alignment: .leading, spacing: Diseno.espaciado) {
                        filtroPeriodo
                        filtroUV
                        if !ubicacionesUnicas.isEmpty { filtroUbicacion }
                        listaFiltrada
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Diseno.relleno)
                    .padding(.top, 4)
                }
            }
            .navigationTitle(Textos.Estadisticas.historial)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            if let url = ExportadorHistorial.generarCSV(
                                sesiones: sesionesFiltradas, idioma: idiomaApp
                            ) {
                                archivoExportar = ArchivoExportable(url: url)
                            }
                        } label: {
                            Label(String(localized: "exportar.csv"), systemImage: "tablecells")
                        }

                        Button {
                            let completadas = sesiones.filter { $0.completada }
                            if let url = ExportadorHistorial.generarPDF(
                                sesiones: sesionesFiltradas,
                                racha: Logro.rachaActual(de: completadas),
                                logros: Logro.evaluar(sesiones: sesiones),
                                idioma: idiomaApp
                            ) {
                                archivoExportar = ArchivoExportable(url: url)
                            }
                        } label: {
                            Label(String(localized: "exportar.pdf"), systemImage: "doc.richtext")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundStyle(.ambar)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.textoApagado)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(item: $archivoExportar) { archivo in
                ActivityViewController(items: [archivo.url])
            }
        }
        .environment(\.locale, Locale(identifier: idiomaApp))
    }

    // MARK: Filtros

    private var filtroPeriodo: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PeriodoFiltro.allCases, id: \.self) { p in
                    ChipFiltro(p.etiqueta, seleccionado: periodo == p) {
                        withAnimation(.spring(response: 0.25)) { periodo = p }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private var filtroUV: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipFiltro(Textos.Estadisticas.filtroTodo, seleccionado: uvFiltro == nil) {
                    withAnimation(.spring(response: 0.25)) { uvFiltro = nil }
                }
                ForEach(UVCategoria.allCases, id: \.self) { cat in
                    ChipFiltro(cat.etiqueta, seleccionado: uvFiltro == cat, color: cat.color) {
                        withAnimation(.spring(response: 0.25)) {
                            uvFiltro = uvFiltro == cat ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private var filtroUbicacion: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipFiltro(Textos.Estadisticas.filtroTodo, seleccionado: ubicacionFiltro == nil) {
                    withAnimation(.spring(response: 0.25)) { ubicacionFiltro = nil }
                }
                ForEach(ubicacionesUnicas, id: \.self) { lugar in
                    ChipFiltroTexto(lugar, seleccionado: ubicacionFiltro == lugar) {
                        withAnimation(.spring(response: 0.25)) {
                            ubicacionFiltro = ubicacionFiltro == lugar ? nil : lugar
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    // MARK: Lista

    private var listaFiltrada: some View {
        Group {
            if sesionesFiltradas.isEmpty {
                Text(Textos.Estadisticas.sinResultados)
                    .font(.fuenteCuerpo)
                    .foregroundStyle(.textoApagado)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 48)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sesionesFiltradas.enumerated()), id: \.element.id) { indice, sesion in
                        FilaHistorial(sesion: sesion)
                        if indice < sesionesFiltradas.count - 1 {
                            Divider()
                                .overlay(Color.textoApagado.opacity(Diseno.opacidadDivider))
                                .padding(.leading, 16)
                        }
                    }
                }
                .tarjetaVidrio()
            }
        }
    }
}

// MARK: Chip de filtro (clave localizada)

struct ChipFiltro: View {
    let etiqueta:     LocalizedStringKey
    let seleccionado: Bool
    var color:        Color = .ambar
    let alSeleccionar: () -> Void

    init(_ etiqueta: LocalizedStringKey, seleccionado: Bool, color: Color = .ambar, alSeleccionar: @escaping () -> Void) {
        self.etiqueta      = etiqueta
        self.seleccionado  = seleccionado
        self.color         = color
        self.alSeleccionar = alSeleccionar
    }

    var body: some View {
        if seleccionado {
            chipBase
                .background(color.gradient, in: Capsule())
        } else {
            chipBase
                .glassEffect(in: Capsule())
        }
    }

    private var chipBase: some View {
        Button(action: alSeleccionar) {
            Text(etiqueta)
                .font(.system(size: 13, weight: seleccionado ? .semibold : .regular))
                .foregroundStyle(seleccionado ? .white : .textoPrimario)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Chip de filtro (texto verbatim — ubicaciones)

struct ChipFiltroTexto: View {
    let texto:        String
    let seleccionado: Bool
    let alSeleccionar: () -> Void

    init(_ texto: String, seleccionado: Bool, alSeleccionar: @escaping () -> Void) {
        self.texto         = texto
        self.seleccionado  = seleccionado
        self.alSeleccionar = alSeleccionar
    }

    var body: some View {
        ChipFiltro(LocalizedStringKey(texto), seleccionado: seleccionado, alSeleccionar: alSeleccionar)
    }
}

// MARK: Wrapper para .sheet(item:)

struct ArchivoExportable: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: Share sheet (UIKit wrapper)

struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
