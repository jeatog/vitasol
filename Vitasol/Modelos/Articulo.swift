import SwiftUI

// MARK: Modelo de artículo educativo

struct Articulo: Identifiable, Codable {
    let id: String
    let titulo: String
    let subtitulo: String
    let icono: String
    let secciones: [SeccionArticulo]
    let fuentes: [String]

    // Colores no se decodifican del JSON, se asignan por índice
    var colorInicio: Color { Self.gradientes[safeIndex].0 }
    var colorFin:    Color { Self.gradientes[safeIndex].1 }

    private var safeIndex: Int {
        abs(id.hashValue) % Self.gradientes.count
    }

    private static let gradientes: [(Color, Color)] = [
        (Color(red: 0.910, green: 0.533, blue: 0.227), Color(red: 0.973, green: 0.784, blue: 0.427)), // ámbar -> dorado
        (Color(red: 0.416, green: 0.659, blue: 0.471), Color(red: 0.545, green: 0.765, blue: 0.592)), // salvia -> salvia claro
        (Color(red: 0.482, green: 0.557, blue: 0.878), Color(red: 0.651, green: 0.706, blue: 0.933)), // índigo -> periwinkle
        (Color(red: 0.839, green: 0.271, blue: 0.173), Color(red: 0.910, green: 0.533, blue: 0.227)), // rojo -> ámbar
        (Color(red: 0.973, green: 0.784, blue: 0.427), Color(red: 0.910, green: 0.533, blue: 0.227)), // dorado -> ámbar
        (Color(red: 0.604, green: 0.643, blue: 0.784), Color(red: 0.482, green: 0.557, blue: 0.878)), // lavanda -> índigo
        (Color(red: 0.416, green: 0.659, blue: 0.471), Color(red: 0.973, green: 0.784, blue: 0.427)), // salvia -> dorado
        (Color(red: 0.910, green: 0.533, blue: 0.227), Color(red: 0.839, green: 0.271, blue: 0.173)), // ámbar -> rojo
    ]
}

struct SeccionArticulo: Codable {
    let titulo: String
    let parrafos: [String]
}

// MARK: Cargador de artículos desde JSON

enum CargadorArticulos {
    static func cargar(idioma: String) -> [Articulo] {
        let nombre = idioma == "en" ? "articulos_en" : "articulos_es"
        guard let url = Bundle.main.url(forResource: nombre, withExtension: "json"),
              let datos = try? Data(contentsOf: url),
              let articulos = try? JSONDecoder().decode([Articulo].self, from: datos)
        else { return [] }
        return articulos
    }
}
