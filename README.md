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
- Muestra estadísticas: total de sesiones, tiempo acumulado, racha actual y días con meta cumplida
- Desbloquea logros según el historial (primera sesión, rachas, constancia)
- Muestra un historial filtrable por período, índice UV y ubicación
- Contiene contenido educativo sobre vitamina D (qué es, beneficios, fuentes, consejos)
- Muestra una Live Activity en el Dynamic Island y la pantalla de bloqueo durante la sesión
- Soporta español e inglés con cambio de idioma en runtime sin reiniciar la app
- Adapta colores y estilo entre modo día (paleta cálida) y modo noche (paleta fría) automáticamente

---

## Objetivo

Dar a los usuarios una herramienta simple para cubrir su necesidad diaria de vitamina D a través del sol, evitando tanto la subexposición como los excesos. No reemplaza consejo médico.

---

## Tecnología

- **Plataforma:** iOS 26+
- **Lenguaje:** Swift 5.10
- **UI Framework:** SwiftUI (iOS 26, Liquid Glass)
- **Persistencia:** SwiftData
- **Concurrencia:** async/await, @MainActor
- **Arquitectura:** MVVM con @Observable (Observation framework) y @Environment
- **Localización:** String Catalogs (.xcstrings), idioma fuente español

---

## Frameworks y kits utilizados

| Framework | Uso |
|-----------|-----|
| SwiftUI | UI declarativa, animaciones, navegación |
| SwiftData | Persistencia de sesiones solares |
| ActivityKit | Live Activity durante sesión activa |
| WidgetKit | Widget extension (placeholder v1.0) |
| HealthKit | Registro de tiempo de exposición en Apple Salud |
| CoreLocation | Coordenadas GPS y geocodificación inversa |
| UserNotifications | Recordatorios diarios configurables |
| Observation | Reactividad con @Observable y tracking granular por propiedad |
| Foundation / URLSession | Consumo de la API Open-Meteo |

---

## Dependencias externas

Ninguna. La app usa exclusivamente frameworks de Apple y la API pública de Open-Meteo.

**Open-Meteo** (https://open-meteo.com): API meteorológica gratuita y sin autenticación. Provee temperatura, índice UV y código climático WMO en tiempo real según coordenadas GPS. Diseñada para migrar a Apple WeatherKit en una versión futura sin cambiar la interfaz del GestorClima.

---

## Estructura del proyecto

```
Vitasol/
├── App/                        Entrada y navegación principal
├── Gestores/                   Lógica de negocio (sesión, clima, ubicación, salud, etc.)
├── Modelos/                    Entidades SwiftData y structs de datos
├── Vistas/                     Pantallas SwiftUI por sección
│   ├── Inicio/
│   ├── Sesion/
│   ├── Estadisticas/
│   ├── Aprender/
│   └── Ajustes/
├── Recursos/                   Localizable.xcstrings (es / en)
├── Tema.swift                  Sistema de diseño Solsticio
└── Textos.swift                Todas las claves de UI como LocalizedStringKey

VitasolWidgets/                 Widget extension
└── VitasolWidgetsLiveActivity  Live Activity del timer de sesión
```

---

## TODOs (v1.1+)

Las siguientes funcionalidades fueron diferidas conscientemente de la v1.0 y se priorizarán según el feedback de usuarios.

### Historial
- Filtro por rango de temperatura
- Filtro por franja horaria (ej. 8–10 h, 12–14 h)
- Filtro por mes/año específico

### Estadísticas
- Gráfico de UV promedio semanal con Swift Charts
- Distribución horaria de sesiones
- Histórico de rachas pasadas
- Exportar historial como CSV

### Widget de pantalla de inicio
- Widget estático con progreso diario y UV actual

### Sesión
- Vibración háptica al completar la meta

### Perfil de usuario
- Perfiles de usuario y datos en nube
- Tipo de piel (escala Fitzpatrick I–VI) para calcular exposición segura personalizada
- Edad y factores de riesgo opcionales
- Meta de vitamina D personalizable (UI/día)

### Accesibilidad
- Modo de alto contraste

### Onboarding
- Carousel de 3 pantallas al primer lanzamiento

### Técnico
- CI/CD con Xcode Cloud
- Migración de Open-Meteo a Apple WeatherKit
