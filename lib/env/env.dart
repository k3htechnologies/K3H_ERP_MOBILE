import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class ENV {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _ENV.apiKey;

  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _ENV.baseUrl;

  @EnviedField(varName: 'ANDROID_VERSION', obfuscate: true)
  static final String androidVersion = _ENV.androidVersion;

  @EnviedField(varName: 'IOS_VERSION', obfuscate: true)
  static final String iosVersion = _ENV.iosVersion;
}
