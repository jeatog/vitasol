import Testing
@testable import Vitasol

@Suite("GestorTema — horario día/noche")
struct GestorTemaTests {

    @Test("3:00 AM (180 min) es de noche")
    func madrugada() {
        #expect(GestorTema.calcularEsDeNoche(minutosDia: 180))
    }

    @Test("6:29 AM (389 min) es de noche")
    func antesDeAmanecer() {
        #expect(GestorTema.calcularEsDeNoche(minutosDia: 389))
    }

    @Test("6:30 AM (390 min) es de día")
    func amanecer() {
        #expect(!GestorTema.calcularEsDeNoche(minutosDia: 390))
    }

    @Test("12:00 PM (720 min) es de día")
    func mediodia() {
        #expect(!GestorTema.calcularEsDeNoche(minutosDia: 720))
    }

    @Test("18:59 (1139 min) es de día")
    func antesDeAnochecer() {
        #expect(!GestorTema.calcularEsDeNoche(minutosDia: 1139))
    }

    @Test("19:00 (1140 min) es de noche")
    func anochecer() {
        #expect(GestorTema.calcularEsDeNoche(minutosDia: 1140))
    }

    @Test("23:00 (1380 min) es de noche")
    func nocheAvanzada() {
        #expect(GestorTema.calcularEsDeNoche(minutosDia: 1380))
    }

    @Test("0:00 (0 min) es de noche")
    func medianoche() {
        #expect(GestorTema.calcularEsDeNoche(minutosDia: 0))
    }
}
