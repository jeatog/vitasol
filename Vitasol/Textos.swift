import SwiftUI

// MARK: Textos localizados
// Fuente: Localizable.xcstrings  (idioma base: español)

enum Textos {

    // MARK: General
    enum General {
        static let buenosDias:    LocalizedStringKey = "general.buenos_dias"
        static let buenasTardes:  LocalizedStringKey = "general.buenas_tardes"
        static let buenasNoches:  LocalizedStringKey = "general.buenas_noches"
        static let guardar:       LocalizedStringKey = "general.guardar"
        static let cancelar:      LocalizedStringKey = "general.cancelar"
        static let descartar:     LocalizedStringKey = "general.descartar"
        static let abrirAjustes:  LocalizedStringKey = "general.abrir_ajustes"
        static let minutos:       LocalizedStringKey = "general.minutos"
        static let hoy:           LocalizedStringKey = "general.hoy"
        static let ayer:          LocalizedStringKey = "general.ayer"
    }

    // MARK: Inicio
    enum Inicio {
        static let tabNombre:        LocalizedStringKey = "inicio.tab"
        static let metaCumplida:     LocalizedStringKey = "inicio.meta_cumplida"
        static let listaDosis:       LocalizedStringKey = "inicio.lista_dosis"
        static let climaActual:      LocalizedStringKey = "inicio.clima_actual"
        static let indiceUV:         LocalizedStringKey = "inicio.indice_uv"
        static let buenDia:          LocalizedStringKey = "inicio.buen_dia"
        static let intentaManana:    LocalizedStringKey = "inicio.intenta_manana"
        static let listoParaSol:     LocalizedStringKey = "inicio.listo_sol"
        static let iniciarSesion:    LocalizedStringKey = "inicio.iniciar_sesion"
        static let metaHoyCumplida:  LocalizedStringKey = "inicio.meta_hoy_cumplida"
        static let sesionEnCurso:    LocalizedStringKey = "inicio.sesion_en_curso"

        static func recordatorio(_ hora: String) -> LocalizedStringKey {
            "inicio.recordatorio \(hora)"
        }
        static func recordatorioManana(_ hora: String) -> LocalizedStringKey {
            "inicio.recordatorio_manana \(hora)"
        }
        static func duracionRecomendada(_ mins: Int) -> LocalizedStringKey {
            "inicio.duracion_recomendada \(mins)"
        }
        static func duracionSesion(_ texto: String) -> LocalizedStringKey {
            "inicio.duracion_sesion \(texto)"
        }
    }

    // MARK: Sesión
    enum Sesion {
        static let tabNombre:      LocalizedStringKey = "sesion.tab"
        static let titulo:         LocalizedStringKey = "sesion.titulo"
        static let subtitulo:      LocalizedStringKey = "sesion.subtitulo"
        static let objetivo:       LocalizedStringKey = "sesion.objetivo"
        static let indiceUV:       LocalizedStringKey = "sesion.indice_uv"
        static let temperatura:    LocalizedStringKey = "sesion.temperatura"
        static let iniciar:        LocalizedStringKey = "sesion.iniciar"
        static let nueva:          LocalizedStringKey = "sesion.nueva"
        static let alertaTitulo:             LocalizedStringKey = "sesion.alerta_titulo"
        static let confirmarNuevaTitulo:     LocalizedStringKey = "sesion.confirmar_nueva_titulo"
        static let confirmarNuevaIniciar:    LocalizedStringKey = "sesion.confirmar_nueva_iniciar"
        static let alertaUVTitulo:           LocalizedStringKey = "sesion.alerta_uv_titulo"
        static let alertaUVCancelar:         LocalizedStringKey = "sesion.alerta_uv_cancelar"
        static let alertaUVContinuar:        LocalizedStringKey = "sesion.alerta_uv_continuar"
        static let sinSolTitulo:             LocalizedStringKey = "sesion.sin_sol_titulo"
        static let sinSolSub:                LocalizedStringKey = "sesion.sin_sol_sub"

        static func alertaUVMensaje(_ uv: Int) -> LocalizedStringKey {
            "sesion.alerta_uv_mensaje \(uv)"
        }

        static let alertaMalClimaTitulo:     LocalizedStringKey = "sesion.alerta_mal_clima_titulo"
        static let alertaMalClimaContinuar:  LocalizedStringKey = "sesion.alerta_mal_clima_continuar"
        static let alertaMalClimaMensaje:    LocalizedStringKey = "sesion.alerta_mal_clima_mensaje"

        static func completado(_ pct: Int) -> LocalizedStringKey {
            "sesion.completado \(pct)"
        }
        static func alertaMensaje(_ mins: Int) -> LocalizedStringKey {
            "sesion.alerta_mensaje \(mins)"
        }
    }

    // MARK: Estadísticas
    enum Estadisticas {
        static let titulo:          LocalizedStringKey = "estadisticas.titulo"
        static let totalSesiones:   LocalizedStringKey = "estadisticas.total_sesiones"
        static let tiempoTotal:     LocalizedStringKey = "estadisticas.tiempo_total"
        static let rachaActual:     LocalizedStringKey = "estadisticas.racha_actual"
        static let diasConMeta:     LocalizedStringKey = "estadisticas.dias_meta"
        static let logros:          LocalizedStringKey = "estadisticas.logros"
        static let empezarViaje:    LocalizedStringKey = "estadisticas.empezar_viaje"
        static let sinSesiones:     LocalizedStringKey = "estadisticas.sin_sesiones"
        static let historial:       LocalizedStringKey = "estadisticas.historial"
        static let verHistorial:    LocalizedStringKey = "estadisticas.ver_historial"
        static let sinResultados:   LocalizedStringKey = "estadisticas.sin_resultados"
        static let filtroTodo:      LocalizedStringKey = "estadisticas.filtro_todo"
        static let periodo7dias:    LocalizedStringKey = "estadisticas.periodo_7dias"
        static let periodoMes:      LocalizedStringKey = "estadisticas.periodo_mes"
        static let periodo3meses:   LocalizedStringKey = "estadisticas.periodo_3meses"
        static let periodoTodo:     LocalizedStringKey = "estadisticas.periodo_todo"
        static let uvBajoLabel:     LocalizedStringKey = "estadisticas.uv_bajo"
        static let uvMedioLabel:    LocalizedStringKey = "estadisticas.uv_medio"
        static let uvAltoLabel:     LocalizedStringKey = "estadisticas.uv_alto"
        static let uvMuyAltoLabel:  LocalizedStringKey = "estadisticas.uv_muy_alto"

        static func dias(_ n: Int) -> LocalizedStringKey {
            "estadisticas.dias \(n)"
        }
        static let sesionesCompletadas: LocalizedStringKey = "estadisticas.sesiones_completadas"
        static let completadasInfo:     LocalizedStringKey = "estadisticas.completadas_info"

        static func sesionesCount(_ n: Int) -> LocalizedStringKey {
            "estadisticas.sesiones_count \(n)"
        }
    }

    // MARK: Aprender
    enum Aprender {
        static let titulo:          LocalizedStringKey = "aprender.titulo"
        static let avisoTitulo:     LocalizedStringKey = "aprender.aviso_titulo"
        static let avisoTexto:      LocalizedStringKey = "aprender.aviso_texto"

        static let queEsTitulo:     LocalizedStringKey = "aprender.que_es_titulo"
        static let beneficiosTitulo:LocalizedStringKey = "aprender.beneficios_titulo"
        static let fuentesTitulo:   LocalizedStringKey = "aprender.fuentes_titulo"
        static let consejosTitulo:  LocalizedStringKey = "aprender.consejos_titulo"

        static let queEsB1:         LocalizedStringKey = "aprender.que_es_b1"
        static let queEsB2:         LocalizedStringKey = "aprender.que_es_b2"
        static let queEsB3:         LocalizedStringKey = "aprender.que_es_b3"

        static let beneficiosB1:    LocalizedStringKey = "aprender.beneficios_b1"
        static let beneficiosB2:    LocalizedStringKey = "aprender.beneficios_b2"
        static let beneficiosB3:    LocalizedStringKey = "aprender.beneficios_b3"
        static let beneficiosB4:    LocalizedStringKey = "aprender.beneficios_b4"
        static let beneficiosB5:    LocalizedStringKey = "aprender.beneficios_b5"

        static let fuentesB1:       LocalizedStringKey = "aprender.fuentes_b1"
        static let fuentesB2:       LocalizedStringKey = "aprender.fuentes_b2"
        static let fuentesB3:       LocalizedStringKey = "aprender.fuentes_b3"
        static let fuentesB4:       LocalizedStringKey = "aprender.fuentes_b4"
        static let fuentesB5:       LocalizedStringKey = "aprender.fuentes_b5"

        static let consejosB1:      LocalizedStringKey = "aprender.consejos_b1"
        static let consejosB2:      LocalizedStringKey = "aprender.consejos_b2"
        static let consejosB3:      LocalizedStringKey = "aprender.consejos_b3"
        static let consejosB4:      LocalizedStringKey = "aprender.consejos_b4"
        static let consejosB5:      LocalizedStringKey = "aprender.consejos_b5"
    }

    // MARK: Ajustes
    enum Ajustes {
        static let titulo:                  LocalizedStringKey = "ajustes.titulo"
        static let horaRecordatorio:        LocalizedStringKey = "ajustes.hora_recordatorio"
        static let duracionRecomendada:     LocalizedStringKey = "ajustes.duracion_recomendada"
        static let diasActivos:             LocalizedStringKey = "ajustes.dias_activos"
        static let notificaciones:          LocalizedStringKey = "ajustes.notificaciones"
        static let notificacionesSub:       LocalizedStringKey = "ajustes.notificaciones_sub"
        static let ubicacion:               LocalizedStringKey = "ajustes.ubicacion"
        static let ubicacionSub:            LocalizedStringKey = "ajustes.ubicacion_sub"
        static let salud:                   LocalizedStringKey = "ajustes.salud"
        static let saludSub:                LocalizedStringKey = "ajustes.salud_sub"
        static let saludBloqueada:          LocalizedStringKey = "ajustes.salud_bloqueada"
        static let saludBloqueadaMsg:       LocalizedStringKey = "ajustes.salud_bloqueada_msg"
        static let idioma:                  LocalizedStringKey = "ajustes.idioma"
        static let idiomaSub:               LocalizedStringKey = "ajustes.idioma_sub"
        static let notifBloqueadas:         LocalizedStringKey = "ajustes.notif_bloqueadas"
        static let notifBloqueadasMsg:      LocalizedStringKey = "ajustes.notif_bloqueadas_msg"
        static let espanol:                 LocalizedStringKey = "ajustes.espanol"
        static let ingles:                  LocalizedStringKey = "ajustes.ingles"
        static let unidadTemp:              LocalizedStringKey = "ajustes.unidad_temp"

        static func duracionValor(_ mins: Int) -> LocalizedStringKey {
            "ajustes.duracion_valor \(mins)"
        }
    }

    // MARK: Notificación
    enum Notificacion {
        static var titulo: String {
            String(localized: "notificacion.titulo")
        }
        static var cuerpoDefault: String {
            String(localized: "notificacion.cuerpo_default")
        }
    }

    // MARK: Clima
    enum Clima {
        static let sinDatos:             LocalizedStringKey = "clima.sin_datos"
        static let despejado:            LocalizedStringKey = "clima.despejado"
        static let parcialmenteNublado:  LocalizedStringKey = "clima.parcialmente_nublado"
        static let nublado:              LocalizedStringKey = "clima.nublado"
        static let niebla:               LocalizedStringKey = "clima.niebla"
        static let llovizna:             LocalizedStringKey = "clima.llovizna"
        static let lluvia:               LocalizedStringKey = "clima.lluvia"
        static let nieve:                LocalizedStringKey = "clima.nieve"
        static let chubascos:            LocalizedStringKey = "clima.chubascos"
        static let tormenta:             LocalizedStringKey = "clima.tormenta"
        static let uvBajo:               LocalizedStringKey = "clima.uv_bajo"
        static let uvMedio:              LocalizedStringKey = "clima.uv_medio"
        static let uvAlto:               LocalizedStringKey = "clima.uv_alto"
        static let uvMuyAlto:            LocalizedStringKey = "clima.uv_muy_alto"
    }

    // MARK: Logros
    enum Logros {
        static let primerRayoTitulo:  LocalizedStringKey = "logro.primer_rayo_titulo"
        static let primerRayoDesc:    LocalizedStringKey = "logro.primer_rayo_desc"
        static let racha3Titulo:      LocalizedStringKey = "logro.racha_3_titulo"
        static let racha3Desc:        LocalizedStringKey = "logro.racha_3_desc"
        static let semanaTitulo:      LocalizedStringKey = "logro.semana_titulo"
        static let semanaDesc:        LocalizedStringKey = "logro.semana_desc"
        static let devotoTitulo:      LocalizedStringKey = "logro.devoto_titulo"
        static let devotoDesc:        LocalizedStringKey = "logro.devoto_desc"
        static let mesTitulo:         LocalizedStringKey = "logro.mes_titulo"
        static let mesDesc:           LocalizedStringKey = "logro.mes_desc"
    }

    // MARK: Días de la semana
    enum DiaSemana {
        static let domingo:    LocalizedStringKey = "dia.dom"
        static let lunes:      LocalizedStringKey = "dia.lun"
        static let martes:     LocalizedStringKey = "dia.mar"
        static let miercoles:  LocalizedStringKey = "dia.mie"
        static let jueves:     LocalizedStringKey = "dia.jue"
        static let viernes:    LocalizedStringKey = "dia.vie"
        static let sabado:     LocalizedStringKey = "dia.sab"

        /// Devuelve la clave localizada para un número de día (1=Dom…7=Sáb)
        static func clave(para numero: Int) -> LocalizedStringKey {
            switch numero {
            case 1: return domingo
            case 2: return lunes
            case 3: return martes
            case 4: return miercoles
            case 5: return jueves
            case 6: return viernes
            default: return sabado
            }
        }
    }
}
