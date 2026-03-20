import UIKit
import Foundation

// MARK: Exportador de historial a CSV y PDF

enum ExportadorHistorial {

    // MARK: Colores del PDF (no dependen de UITraitCollection)

    private static let colAmbar      = UIColor(red: 0.910, green: 0.533, blue: 0.227, alpha: 1)
    private static let colDorado     = UIColor(red: 0.973, green: 0.784, blue: 0.427, alpha: 1)
    private static let colSalvia     = UIColor(red: 0.416, green: 0.659, blue: 0.471, alpha: 1)
    private static let colRojo       = UIColor(red: 0.839, green: 0.271, blue: 0.173, alpha: 1)
    private static let colCrema      = UIColor(red: 0.992, green: 0.973, blue: 0.949, alpha: 1)
    private static let colTexto      = UIColor(red: 0.114, green: 0.067, blue: 0.024, alpha: 1)
    private static let colTextoSuave = UIColor(red: 0.420, green: 0.290, blue: 0.165, alpha: 1)
    private static let colFondoFila  = UIColor(red: 0.992, green: 0.973, blue: 0.949, alpha: 0.5)

    // MARK: CSV

    static func generarCSV(sesiones: [SesionSolar], idioma: String) -> URL? {
        let esIngles = idioma == "en"

        let cabecera = esIngles
            ? "Date,Start,End,Duration (min),UV,Temperature (°C),Location,Completed"
            : "Fecha,Inicio,Fin,Duración (min),UV,Temperatura (°C),Ubicación,Completada"

        let fmtFecha = DateFormatter()
        fmtFecha.dateStyle = .short
        fmtFecha.locale = Locale(identifier: idioma)

        let fmtHora = DateFormatter()
        fmtHora.timeStyle = .short
        fmtHora.locale = Locale(identifier: idioma)

        var csv = cabecera + "\n"

        for sesion in sesiones.sorted(by: { $0.fecha > $1.fecha }) {
            let fin    = sesion.fecha
            let inicio = fin.addingTimeInterval(-TimeInterval(sesion.duracionSegundos))
            let mins   = sesion.duracionSegundos / 60
            let estado = sesion.completada ? (esIngles ? "Yes" : "Sí") : "No"
            let lugar  = sesion.ubicacion?.replacingOccurrences(of: ",", with: ";") ?? ""

            csv += "\(fmtFecha.string(from: fin)),"
            csv += "\(fmtHora.string(from: inicio)),"
            csv += "\(fmtHora.string(from: fin)),"
            csv += "\(mins),"
            csv += "\(String(format: "%.1f", sesion.indiceUV)),"
            csv += "\(Int(sesion.temperatura)),"
            csv += "\(lugar),"
            csv += "\(estado)\n"
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Vitasol_Historial_\(UUID().uuidString.prefix(8)).csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: PDF

    static func generarPDF(
        sesiones: [SesionSolar],
        racha: Int,
        logros: [Logro],
        idioma: String
    ) -> URL? {
        let esIngles    = idioma == "en"
        let completadas = sesiones.filter { $0.completada }
        let ordenadas   = sesiones.sorted { $0.fecha > $1.fecha }

        let tamano   = CGRect(x: 0, y: 0, width: 612, height: 792) // Carta
        let margen:  CGFloat = 40
        let ancho    = tamano.width - margen * 2

        let renderer = UIGraphicsPDFRenderer(bounds: tamano)

        let datos = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margen

            // --- Encabezado con logo ---
            y = dibujarEncabezado(en: ctx, y: y, margen: margen, ancho: ancho, esIngles: esIngles, sesiones: ordenadas)
            y += 20

            // --- Resumen ---
            y = dibujarResumen(y: y, margen: margen, ancho: ancho, completadas: completadas, racha: racha, esIngles: esIngles)
            y += 20

            // --- Tabla ---
            y = dibujarTabla(en: ctx, y: y, margen: margen, ancho: ancho, tamano: tamano, sesiones: ordenadas, idioma: idioma, esIngles: esIngles)
            y += 20

            // --- Logros ---
            if y > tamano.height - 120 {
                ctx.beginPage()
                y = margen
            }
            y = dibujarLogros(y: y, margen: margen, ancho: ancho, logros: logros, esIngles: esIngles)

            // --- Pie ---
            dibujarPie(tamano: tamano, margen: margen, ancho: ancho, esIngles: esIngles)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Vitasol_Reporte.pdf")
        try? datos.write(to: url)
        return url
    }

    // MARK: - Componentes del PDF

    private static func dibujarEncabezado(
        en ctx: UIGraphicsPDFRendererContext,
        y: CGFloat, margen: CGFloat, ancho: CGFloat,
        esIngles: Bool, sesiones: [SesionSolar]
    ) -> CGFloat {
        var y = y

        // Logo
        if let logo = UIImage(named: "logo_solo") {
            let tamLogo: CGFloat = 40
            logo.draw(in: CGRect(x: margen, y: y, width: tamLogo, height: tamLogo))

            // Nombre al lado del logo
            let titulo = esIngles ? "Vitasol — Solar Report" : "Vitasol — Reporte Solar"
            let attrTitulo: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: colTexto
            ]
            let tituloStr = NSString(string: titulo)
            let tituloSize = tituloStr.size(withAttributes: attrTitulo)
            tituloStr.draw(at: CGPoint(x: margen + tamLogo + 10, y: y + (tamLogo - tituloSize.height) / 2), withAttributes: attrTitulo)

            y += tamLogo + 8
        }

        // Rango de fechas
        if let primera = sesiones.last?.fecha, let ultima = sesiones.first?.fecha {
            let fmt = DateFormatter()
            fmt.dateStyle = .long
            fmt.locale = Locale(identifier: esIngles ? "en" : "es")
            let rango = "\(fmt.string(from: primera)) – \(fmt.string(from: ultima))"
            let attrRango: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: colTextoSuave
            ]
            NSString(string: rango).draw(at: CGPoint(x: margen, y: y), withAttributes: attrRango)
            y += 18
        }

        // Barra decorativa ámbar
        let barraPath = UIBezierPath(roundedRect: CGRect(x: margen, y: y, width: ancho, height: 3), cornerRadius: 1.5)
        colAmbar.setFill()
        barraPath.fill()
        y += 3

        return y
    }

    private static func dibujarResumen(
        y: CGFloat, margen: CGFloat, ancho: CGFloat,
        completadas: [SesionSolar], racha: Int, esIngles: Bool
    ) -> CGFloat {
        var y = y

        let totalSegundos = completadas.reduce(0) { $0 + $1.duracionSegundos }
        let horas = totalSegundos / 3600
        let mins  = (totalSegundos % 3600) / 60
        let tiempoTexto = horas > 0 ? "\(horas)h \(mins)m" : "\(mins)m"
        let diasMeta = Set(completadas.map { Calendar.current.startOfDay(for: $0.fecha) }).count

        let metricas: [(String, String)] = [
            (esIngles ? "Sessions" : "Sesiones", "\(completadas.count)"),
            (esIngles ? "Total time" : "Tiempo total", tiempoTexto),
            (esIngles ? "Streak" : "Racha", esIngles ? "\(racha) days" : "\(racha) días"),
            (esIngles ? "Goal days" : "Días meta", "\(diasMeta)"),
        ]

        let anchoMetrica = ancho / CGFloat(metricas.count)

        for (i, metrica) in metricas.enumerated() {
            let x = margen + anchoMetrica * CGFloat(i)

            // Valor grande
            let attrValor: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: colAmbar
            ]
            NSString(string: metrica.1).draw(at: CGPoint(x: x, y: y), withAttributes: attrValor)

            // Etiqueta
            let attrEtiqueta: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: colTextoSuave
            ]
            NSString(string: metrica.0).draw(at: CGPoint(x: x, y: y + 24), withAttributes: attrEtiqueta)
        }

        y += 46
        return y
    }

    private static func dibujarTabla(
        en ctx: UIGraphicsPDFRendererContext,
        y: CGFloat, margen: CGFloat, ancho: CGFloat, tamano: CGRect,
        sesiones: [SesionSolar], idioma: String, esIngles: Bool
    ) -> CGFloat {
        var y = y

        let fmtFecha = DateFormatter()
        fmtFecha.dateStyle = .short
        fmtFecha.locale = Locale(identifier: idioma)

        let fmtHora = DateFormatter()
        fmtHora.timeStyle = .short
        fmtHora.locale = Locale(identifier: idioma)

        // Anchos de columna
        let anchos: [CGFloat] = [70, 90, 50, 40, 55, ancho - 305 - 30, 30]

        let cabeceras = esIngles
            ? ["Date", "Time", "Duration", "UV", "Temp", "Location", "✓"]
            : ["Fecha", "Horario", "Duración", "UV", "Temp", "Ubicación", "✓"]

        let attrCabecera: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .bold),
            .foregroundColor: colTexto
        ]
        let attrCelda: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: colTexto
        ]
        let alturaFila: CGFloat = 18

        // Cabecera de tabla
        var x = margen
        for (i, cabecera) in cabeceras.enumerated() {
            NSString(string: cabecera).draw(at: CGPoint(x: x, y: y), withAttributes: attrCabecera)
            x += anchos[i]
        }
        y += alturaFila

        // Línea debajo de cabecera
        let lineaPath = UIBezierPath()
        lineaPath.move(to: CGPoint(x: margen, y: y))
        lineaPath.addLine(to: CGPoint(x: margen + ancho, y: y))
        colAmbar.withAlphaComponent(0.4).setStroke()
        lineaPath.lineWidth = 0.5
        lineaPath.stroke()
        y += 4

        // Filas
        for (indice, sesion) in sesiones.enumerated() {
            // Nueva página si se acaba el espacio
            if y > tamano.height - 80 {
                dibujarPie(tamano: tamano, margen: margen, ancho: ancho, esIngles: esIngles)
                ctx.beginPage()
                y = margen
            }

            // Fondo alterno
            if indice % 2 == 0 {
                let fondo = UIBezierPath(rect: CGRect(x: margen, y: y - 2, width: ancho, height: alturaFila))
                colFondoFila.setFill()
                fondo.fill()
            }

            let fin    = sesion.fecha
            let inicio = fin.addingTimeInterval(-TimeInterval(sesion.duracionSegundos))
            let horario = "\(fmtHora.string(from: inicio)) – \(fmtHora.string(from: fin))"
            let duracion = "\(sesion.duracionSegundos / 60) min"
            let uv     = String(format: "%.1f", sesion.indiceUV)
            let temp   = "\(Int(sesion.temperatura))°C"
            let lugar  = sesion.ubicacion ?? "—"
            let estado = sesion.completada ? "✓" : "—"

            let valores = [fmtFecha.string(from: fin), horario, duracion, uv, temp, lugar, estado]

            x = margen
            for (i, valor) in valores.enumerated() {
                // Color UV semántico
                var attrActual = attrCelda
                if i == 3 { // columna UV
                    attrActual[.foregroundColor] = colorParaUV(sesion.indiceUV)
                }
                if i == 6 && sesion.completada { // checkmark
                    attrActual[.foregroundColor] = colSalvia
                    attrActual[.font] = UIFont.systemFont(ofSize: 9, weight: .bold)
                }

                let texto = NSString(string: valor)
                let disponible = anchos[i] - 4
                let truncado = truncar(texto: texto as String, ancho: disponible, atributos: attrActual)
                NSString(string: truncado).draw(at: CGPoint(x: x, y: y), withAttributes: attrActual)
                x += anchos[i]
            }
            y += alturaFila
        }

        return y
    }

    private static func dibujarLogros(
        y: CGFloat, margen: CGFloat, ancho: CGFloat,
        logros: [Logro], esIngles: Bool
    ) -> CGFloat {
        var y = y

        let desbloqueados = logros.filter { $0.desbloqueado }
        guard !desbloqueados.isEmpty else { return y }

        let tituloSeccion = esIngles ? "Unlocked achievements" : "Logros desbloqueados"
        let attrSeccion: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: colTexto
        ]
        NSString(string: tituloSeccion).draw(at: CGPoint(x: margen, y: y), withAttributes: attrSeccion)
        y += 22

        let attrLogro: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: colTextoSuave
        ]

        // Dibujar en filas de 3
        let columnas = 3
        let anchoCol = ancho / CGFloat(columnas)

        for (i, logro) in desbloqueados.enumerated() {
            let col = i % columnas
            let x   = margen + anchoCol * CGFloat(col)

            // Círculo ámbar pequeño
            let circulo = UIBezierPath(ovalIn: CGRect(x: x, y: y + 1, width: 10, height: 10))
            colAmbar.withAlphaComponent(0.3).setFill()
            circulo.fill()

            let textoLogro = logro.id.replacingOccurrences(of: "_", with: " ").capitalized
            NSString(string: textoLogro).draw(at: CGPoint(x: x + 14, y: y), withAttributes: attrLogro)

            if col == columnas - 1 || i == desbloqueados.count - 1 {
                y += 18
            }
        }

        return y
    }

    private static func dibujarPie(tamano: CGRect, margen: CGFloat, ancho: CGFloat, esIngles: Bool) {
        let y = tamano.height - 35

        // Línea
        let linea = UIBezierPath()
        linea.move(to: CGPoint(x: margen, y: y))
        linea.addLine(to: CGPoint(x: margen + ancho, y: y))
        UIColor.lightGray.withAlphaComponent(0.3).setStroke()
        linea.lineWidth = 0.5
        linea.stroke()

        let fmtFecha = DateFormatter()
        fmtFecha.dateStyle = .medium
        fmtFecha.locale = Locale(identifier: esIngles ? "en" : "es")

        let generado = esIngles
            ? "Generated by Vitasol — \(fmtFecha.string(from: .now))"
            : "Generado por Vitasol — \(fmtFecha.string(from: .now))"

        let attrPie: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        NSString(string: generado).draw(at: CGPoint(x: margen, y: y + 4), withAttributes: attrPie)

        let disclaimer = esIngles
            ? "This information does not replace professional medical advice."
            : "Esta información no sustituye consejo médico profesional."
        let attrDisclaimer: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 7),
            .foregroundColor: UIColor.gray
        ]
        let disclaimerSize = NSString(string: disclaimer).size(withAttributes: attrDisclaimer)
        NSString(string: disclaimer).draw(
            at: CGPoint(x: margen + ancho - disclaimerSize.width, y: y + 4),
            withAttributes: attrDisclaimer
        )
    }

    // MARK: - Auxiliares

    private static func colorParaUV(_ uv: Double) -> UIColor {
        switch Int(uv) {
        case 0...2:  return colSalvia
        case 3...5:  return colDorado
        case 6...7:  return colAmbar
        default:     return colRojo
        }
    }

    private static func truncar(texto: String, ancho: CGFloat, atributos: [NSAttributedString.Key: Any]) -> String {
        var resultado = texto
        while NSString(string: resultado).size(withAttributes: atributos).width > ancho && resultado.count > 1 {
            resultado = String(resultado.dropLast(2)) + "…"
        }
        return resultado
    }
}
