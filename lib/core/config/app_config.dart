/// Configurações globais do app.
///
/// No web (multizone) o cliente usa `/api` relativo porque o navegador está na
/// mesma origem do host. No mobile isso não existe — o app precisa da URL
/// ABSOLUTA do backend hospedado (o mesmo tech-challenge da Vercel).
///
/// Dá pra sobrescrever em build/run com:
///   flutter run --dart-define=API_URL=http://192.168.0.10:3000/api
abstract class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://tech-challenge-one.vercel.app/api',
  );
}
