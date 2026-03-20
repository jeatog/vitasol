# Vitasol

Aplicación iOS para el seguimiento consciente de la exposición solar y la síntesis de vitamina D.

---

## Qué es

Vitasol ayuda a los usuarios a exponerse al sol de forma inteligente y registrar sus sesiones de exposición. La app calcula el momento del día, las condiciones climáticas reales y el tiempo acumulado para que el usuario sepa cuándo y cuánto sol tomar.

El nombre combina *vita* (vida) y *sol*, reflejando el vínculo entre la exposición solar y la salud.

---

## Qué hace

- Registra sesiones de exposición solar con timer configurable (5–60 min)
- Muestra el índice UV y temperatura en tiempo real según la ubicación GPS
- Bloquea el inicio de sesiones en horario nocturno (19:00–06:59)
- Advierte al usuario cuando las condiciones climáticas son desfavorables (lluvia, nieve, UV bajo)
- Guarda cada sesión en SwiftData con fecha, duración, UV, temperatura y ubicación
- Sincroniza el tiempo de exposición con Apple Salud (HealthKit)
- Envía recordatorios diarios configurables por día de la semana y hora
- Muestra estadísticas con layout bento: racha hero + sesiones, tiempo y días con meta
- Desbloquea 14 logros con SF Symbols (rachas, horario, volumen, exploración, UV)
- Muestra un historial filtrable por período, índice UV y ubicación
- Contiene contenido educativo sobre vitamina D (qué es, beneficios, fuentes, consejos)
- Muestra una Live Activity en el Dynamic Island y la pantalla de bloqueo durante la sesión
- Widget de progreso diario con estado del día y UV actual
- Vibración háptica al completar la meta de exposición
- Soporta español e inglés con cambio de idioma en runtime sin reiniciar la app
- Adapta colores y estilo entre modo día (paleta cálida) y modo noche (paleta fría) automáticamente
- Accesibilidad: VoiceOver en todas las vistas, Dynamic Type con estilos semánticos

---

## Objetivo

Dar a los usuarios una herramienta simple para cubrir su necesidad diaria de vitamina D a través del sol, evitando tanto la subexposición como los excesos. No reemplaza consejo médico.

---

## Tecnología

- **Plataforma:** iOS 26+
- **Lenguaje:** Swift 5.10
- **UI Framework:** SwiftUI (iOS 26, Liquid Glass)
- **Persistencia:** SwiftData (esquema versionado con migración)
- **Concurrencia:** async/await, @MainActor
- **Arquitectura:** MVVM con @Observable (Observation framework) y @Environment
- **Localización:** String Catalogs (.xcstrings), idioma fuente español
- **Tests:** Swift Testing (55 casos en 6 suites)

---

## Frameworks y kits utilizados

| Framework | Uso |
|-----------|-----|
| SwiftUI | UI declarativa, animaciones, navegación, Liquid Glass |
| SwiftData | Persistencia de sesiones solares con esquema versionado |
| ActivityKit | Live Activity durante sesión activa |
| WidgetKit | Widget de progreso diario y Live Activity |
| HealthKit | Registro de tiempo de exposición en Apple Salud |
| CoreLocation | Coordenadas GPS para datos climáticos |
| MapKit | Geocodificación inversa (MKReverseGeocodingRequest) |
| UserNotifications | Recordatorios diarios configurables |
| Observation | Reactividad con @Observable y tracking granular por propiedad |
| Foundation / URLSession | Consumo de la API Open-Meteo |

---

## Dependencias externas

Ninguna. La app usa exclusivamente frameworks de Apple y la API pública de Open-Meteo.

**Open-Meteo** (https://open-meteo.com): API meteorológica gratuita y sin autenticación. Provee temperatura, índice UV y código climático WMO en tiempo real según coordenadas GPS.

---

## Estructura del proyecto

```
Vitasol/
├── App/                        Entrada y navegación principal
├── Gestores/                   Lógica de negocio (sesión, clima, ubicación, salud, tema, notificaciones)
├── Modelos/                    Entidades SwiftData y structs de datos (SesionSolar, Logro)
├── Vistas/                     Pantallas SwiftUI por sección
│   ├── Inicio/
│   ├── Sesion/
│   ├── Estadisticas/
│   ├── Aprender/
│   └── Ajustes/
├── Recursos/                   Localizable.xcstrings (es / en)
├── Tema.swift                  Sistema de diseño Solsticio (colores, tipografía, Liquid Glass)
└── Textos.swift                Todas las claves de UI como LocalizedStringKey

VitasolWidgets/                 Widget extension
├── VitasolWidget               Widget de progreso diario (systemSmall)
└── VitasolWidgetsLiveActivity  Live Activity del timer de sesión

VitasolTests/                   Tests unitarios (Swift Testing)
├── LogroTests                  Racha actual y evaluación de 14 logros
├── GestorSesionTests           Progreso, segundos restantes, formato de tiempo
├── GestorClimaTests            Mapeos de clima, UV y condiciones
└── SesionSolarTests            Duración formateada, esHoy, rangos UV
```

---

## Roadmap

### v1.0.0 (requiere cuenta de desarrollador de pago)
- Migración de Open-Meteo a Apple WeatherKit
- Horario dinámico de sol basado en sunrise/sunset de WeatherKit (con fallback a 6:30–19:00)
- StoreKit 2 para in-app purchase "Vitasol Pro"
- Paywall en historial completo, filtros, exportación y logros extendidos

### v1.1.0
- Respaldo del historial en iCloud vía CloudKit
- Gráfico de UV promedio semanal con Swift Charts
- Distribución horaria de sesiones
- Histórico de rachas pasadas
- Filtro de historial por rango de temperatura
- Filtro de historial por franja horaria (ej. 8–10 h, 12–14 h)
- Filtro de historial por mes/año específico

### v1.2.0+
- Tipo de piel (escala Fitzpatrick I–VI) para exposición personalizada
- Edad y factores de riesgo opcionales
- Meta de vitamina D personalizable (UI/día)
- Onboarding: carousel de 3 pantallas al primer lanzamiento
- Modo de alto contraste
- CI/CD con Xcode Cloud
