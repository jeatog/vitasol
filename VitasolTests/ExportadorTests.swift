import Testing
import Foundation
@testable import Vitasol

@Suite("Exportador de historial")
struct ExportadorTests {

    private func sesion(
        diasAtras: Int = 0,
        duracion: Int = 600,
        completada: Bool = true,
        uv: Double = 4.0,
        temp: Double = 25.0,
        ubicacion: String? = "Ciudad"
    ) -> SesionSolar {
        let fecha = Calendar.current.date(byAdding: .day, value: -diasAtras, to: .now)!
        return SesionSolar(
            fecha: fecha,
            duracionSegundos: duracion,
            completada: completada,
            indiceUV: uv,
            temperatura: temp,
            ubicacion: ubicacion
        )
    }

    // MARK: CSV

    @Test("CSV con sesiones genera archivo válido")
    func csvGeneraArchivo() {
        let sesiones = [sesion(diasAtras: 0), sesion(diasAtras: 1)]
        let url = ExportadorHistorial.generarCSV(sesiones: sesiones, idioma: "es")
        #expect(url != nil)
        #expect(FileManager.default.fileExists(atPath: url!.path))
    }

    @Test("CSV contiene cabecera en español")
    func csvCabeceraEspanol() throws {
        let url = ExportadorHistorial.generarCSV(sesiones: [sesion()], idioma: "es")!
        let contenido = try String(contentsOf: url, encoding: .utf8)
        #expect(contenido.hasPrefix("Fecha,"))
    }

    @Test("CSV contiene cabecera en inglés")
    func csvCabeceraIngles() throws {
        let url = ExportadorHistorial.generarCSV(sesiones: [sesion()], idioma: "en")!
        let contenido = try String(contentsOf: url, encoding: .utf8)
        #expect(contenido.hasPrefix("Date,"))
    }

    @Test("CSV tiene una fila por sesión más cabecera")
    func csvFilasPorSesion() throws {
        let sesiones = [sesion(diasAtras: 0), sesion(diasAtras: 1), sesion(diasAtras: 2)]
        let url = ExportadorHistorial.generarCSV(sesiones: sesiones, idioma: "es")!
        let contenido = try String(contentsOf: url, encoding: .utf8)
        let lineas = contenido.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lineas.count == 4) // 1 cabecera + 3 sesiones
    }

    @Test("CSV escapa comas en ubicación")
    func csvEscapaComas() throws {
        let s = sesion(ubicacion: "Ciudad, Estado, País")
        let url = ExportadorHistorial.generarCSV(sesiones: [s], idioma: "es")!
        let contenido = try String(contentsOf: url, encoding: .utf8)
        // Las comas se reemplazan por punto y coma
        #expect(contenido.contains("Ciudad; Estado; País"))
    }

    @Test("CSV con lista vacía genera solo cabecera")
    func csvVacio() throws {
        let url = ExportadorHistorial.generarCSV(sesiones: [], idioma: "es")!
        let contenido = try String(contentsOf: url, encoding: .utf8)
        let lineas = contenido.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lineas.count == 1)
    }

    // MARK: PDF

    @Test("PDF con sesiones genera archivo válido")
    func pdfGeneraArchivo() {
        let sesiones = [sesion(diasAtras: 0), sesion(diasAtras: 1)]
        let url = ExportadorHistorial.generarPDF(
            sesiones: sesiones,
            racha: 2,
            logros: Logro.evaluar(sesiones: sesiones),
            idioma: "es"
        )
        #expect(url != nil)
        #expect(FileManager.default.fileExists(atPath: url!.path))
    }

    @Test("PDF genera datos con encabezado PDF válido")
    func pdfFormatoValido() throws {
        let url = ExportadorHistorial.generarPDF(
            sesiones: [sesion()],
            racha: 1,
            logros: [],
            idioma: "es"
        )!
        let datos = try Data(contentsOf: url)
        // Los PDFs empiezan con %PDF
        let encabezado = String(data: datos.prefix(4), encoding: .ascii)
        #expect(encabezado == "%PDF")
    }

    @Test("PDF con lista vacía no crashea")
    func pdfVacio() {
        let url = ExportadorHistorial.generarPDF(
            sesiones: [],
            racha: 0,
            logros: [],
            idioma: "es"
        )
        #expect(url != nil)
    }
}
