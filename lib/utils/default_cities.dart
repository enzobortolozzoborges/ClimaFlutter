import '../models/city_model.dart';

/// Lista curada com 40 cidades (20 brasileiras e 20 internacionais)
/// para composição do catálogo paginado do aplicativo.
class DefaultCities {
  static const List<City> list = [
    // Cidades Brasileiras (20)
    City(name: 'São Paulo', country: 'Brasil', latitude: -23.5505, longitude: -46.6333),
    City(name: 'Rio de Janeiro', country: 'Brasil', latitude: -22.9068, longitude: -43.1729),
    City(name: 'Curitiba', country: 'Brasil', latitude: -25.4278, longitude: -49.2731),
    City(name: 'Salvador', country: 'Brasil', latitude: -12.9777, longitude: -38.5016),
    City(name: 'Brasília', country: 'Brasil', latitude: -15.7975, longitude: -47.8919),
    City(name: 'Fortaleza', country: 'Brasil', latitude: -3.7327, longitude: -38.5270),
    City(name: 'Belo Horizonte', country: 'Brasil', latitude: -19.9167, longitude: -43.9345),
    City(name: 'Manaus', country: 'Brasil', latitude: -3.1190, longitude: -60.0217),
    City(name: 'Porto Alegre', country: 'Brasil', latitude: -30.0346, longitude: -51.2177),
    City(name: 'Recife', country: 'Brasil', latitude: -8.0476, longitude: -34.8770),
    City(name: 'Belém', country: 'Brasil', latitude: -1.4558, longitude: -48.4902),
    City(name: 'Florianópolis', country: 'Brasil', latitude: -27.5954, longitude: -48.5480),
    City(name: 'Goiânia', country: 'Brasil', latitude: -16.6869, longitude: -49.2648),
    City(name: 'Vitória', country: 'Brasil', latitude: -20.3155, longitude: -40.3128),
    City(name: 'Natal', country: 'Brasil', latitude: -5.7945, longitude: -35.2110),
    City(name: 'Maceió', country: 'Brasil', latitude: -9.6658, longitude: -35.7351),
    City(name: 'João Pessoa', country: 'Brasil', latitude: -7.1195, longitude: -34.8450),
    City(name: 'Campo Grande', country: 'Brasil', latitude: -20.4697, longitude: -54.6201),
    City(name: 'Cuiabá', country: 'Brasil', latitude: -15.6014, longitude: -56.0979),
    City(name: 'Teresina', country: 'Brasil', latitude: -5.0920, longitude: -42.8038),

    // Cidades Internacionais (20)
    City(name: 'Nova York', country: 'Estados Unidos', latitude: 40.7128, longitude: -74.0060),
    City(name: 'Londres', country: 'Reino Unido', latitude: 51.5074, longitude: -0.1278),
    City(name: 'Paris', country: 'França', latitude: 48.8566, longitude: 2.3522),
    City(name: 'Tóquio', country: 'Japão', latitude: 35.6762, longitude: 139.6503),
    City(name: 'Sydney', country: 'Austrália', latitude: -33.8688, longitude: 151.2093),
    City(name: 'Buenos Aires', country: 'Argentina', latitude: -34.6037, longitude: -58.3816),
    City(name: 'Lisboa', country: 'Portugal', latitude: 38.7223, longitude: -9.1393),
    City(name: 'Roma', country: 'Itália', latitude: 41.9028, longitude: 12.4964),
    City(name: 'Berlim', country: 'Alemanha', latitude: 52.5200, longitude: 13.4050),
    City(name: 'Madrid', country: 'Espanha', latitude: 40.4168, longitude: -3.7038),
    City(name: 'Toronto', country: 'Canadá', latitude: 43.6532, longitude: -79.3832),
    City(name: 'Cairo', country: 'Egito', latitude: 30.0444, longitude: 31.2357),
    City(name: 'Dubai', country: 'Emirados Árabes Unidos', latitude: 25.2048, longitude: 55.2708),
    City(name: 'Santiago', country: 'Chile', latitude: -33.4489, longitude: -70.6693),
    City(name: 'Cidade do México', country: 'México', latitude: 19.4326, longitude: -99.1332),
    City(name: 'Amsterdã', country: 'Holanda', latitude: 52.3676, longitude: 4.9041),
    City(name: 'Pequim', country: 'China', latitude: 39.9042, longitude: 116.4074),
    City(name: 'Seul', country: 'Coreia do Sul', latitude: 37.5665, longitude: 126.9780),
    City(name: 'Moscou', country: 'Rússia', latitude: 55.7558, longitude: 37.6173),
    City(name: 'Cidade do Cabo', country: 'África do Sul', latitude: -33.9249, longitude: 18.4241),
  ];
}
