import Foundation
import Observation
import SwiftUI

// MARK: Modelo de respuesta Open-Meteo

private struct RespuestaOpenMeteo: Decodable {
    let current: DatosActuales

    struct DatosActuales: Decodable {
        let temperature2m: Double
        let uvIndex: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {
            case temperature2m  = "temperature_2m"
            case uvIndex        = "uv_index"
            case weatherCode    = "weather_code"
        }
    }
}

// MARK: Gestor de clima con Open-Meteo
// TODO: Migrar a Apple WeatherKit llegado el momento, a saber cuándo eso sí

@Observable
@MainActor
final class GestorClima {
    var temperatura:  Double?
    var indiceUV:     Double?
    var codigoClima:  Int?
    var cargando:     Bool = false

    private var ultimaActualizacion: Date?

    // MARK: Obtener datos

    func obtener(latitud: Double, longitud: Double) async {
        // pa no refrescar si la última petición fue hace < 5 minutos
        if let ultima = ultimaActualizacion,
           Date.now.timeIntervalSince(ultima) < 300 {
            return
        }

        cargando = true
        defer { cargando = false }

        let urlString = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(latitud)"
            + "&longitude=\(longitud)"
            + "&current=temperature_2m,uv_index,weather_code"
            + "&timezone=auto"

        guard let url = URL(string: urlString) else { return }

        do {
            let (datos, respuestaHTTP) = try await URLSession.shared.data(from: url)
            guard let http = respuestaHTTP as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else { return }
            let respuesta = try JSONDecoder().decode(RespuestaOpenMeteo.self, from: datos)
            temperatura  = respuesta.current.temperature2m
            indiceUV     = respuesta.current.uvIndex
            codigoClima  = respuesta.current.weatherCode
            ultimaActualizacion = Date.now
        } catch {
            // Sin conexion o error de decodificacion: mantenemos los ultimos datos validos
        }
    }

    /// Fuerza una nueva petición ignorando el throttle (ej. al iniciar sesión)
    func forzarActualizacion(latitud: Double, longitud: Double) async {
        ultimaActualizacion = nil
        await obtener(latitud: latitud, longitud: longitud)
    }

    var condicion: LocalizedStringKey {
        guard let codigo = codigoClima else { return Textos.Clima.sinDatos }
        switch codigo {
        case 0:         return Textos.Clima.despejado
        case 1, 2, 3:   return Textos.Clima.parcialmenteNublado
        case 45, 48:     return Textos.Clima.niebla
        case 51, 53, 55: return Textos.Clima.llovizna
        case 61, 63, 65: return Textos.Clima.lluvia
        case 71, 73, 75, 77: return Textos.Clima.nieve
        case 80, 81, 82: return Textos.Clima.chubascos
        case 95, 96, 99: return Textos.Clima.tormenta
        default:         return Textos.Clima.nublado
        }
    }

    var iconoSistema: String {
        guard let codigo = codigoClima else { return "cloud.fill" }
        switch codigo {
        case 0:               return "sun.max.fill"
        case 1, 2, 3:         return "cloud.sun.fill"
        case 45, 48:           return "cloud.fog.fill"
        case 51, 53, 55:       return "cloud.drizzle.fill"
        case 61, 63, 65:       return "cloud.rain.fill"
        case 71, 73, 75, 77:   return "cloud.snow.fill"
        case 80, 81, 82:       return "cloud.heavyrain.fill"
        case 95, 96, 99:       return "cloud.bolt.rain.fill"
        default:               return "cloud.fill"
        }
    }

    var etiquetaUV: LocalizedStringKey {
        guard let uv = indiceUV else { return Textos.Clima.sinDatos }
        switch Int(uv) {
        case 0...2:  return Textos.Clima.uvBajo
        case 3...5:  return Textos.Clima.uvMedio
        case 6...7:  return Textos.Clima.uvAlto
        default:     return Textos.Clima.uvMuyAlto
        }
    }

    /// Buen día para tomar sol: UV >= 3 y sin lluvia/tormenta/nieve
    var esBuenDia: Bool {
        guard let uv = indiceUV, let codigo = codigoClima else { return false }
        let sinPrecipitacion = ![51, 53, 55, 61, 63, 65, 71, 73, 75, 77, 80, 81, 82, 95, 96, 99].contains(codigo)
        return uv >= 3 && sinPrecipitacion
    }

    var uvEntero: Int {
        Int(indiceUV ?? 0)
    }

    var temperaturaEntera: Int {
        Int(temperatura ?? 0)
    }

    var tieneDatos: Bool {
        temperatura != nil && indiceUV != nil
    }
}
