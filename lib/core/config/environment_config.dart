enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.ethercinema.com/v2.1';
      case Environment.staging:
        return 'https://staging-api.ethercinema.com/v2.1';
      case Environment.prod:
        return 'https://api.ethercinema.com/v2.1';
    }
  }

  static bool get isDebugMode => _environment != Environment.prod;
}
