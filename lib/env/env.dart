import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class ENV {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _ENV.apiKey;

  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _ENV.baseUrl;
}


// flutter pub run build_runner build