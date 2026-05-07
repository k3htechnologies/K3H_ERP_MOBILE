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

  @EnviedField(varName: 'APP_STORE_ID', obfuscate: true)
  static final String appStoreId = _ENV.appStoreId;

  @EnviedField(varName: 'ANDROID_PACKAGE_NAME', obfuscate: true)
  static final String androidPackageName = _ENV.androidPackageName;
}

// flutter pub run build_runner build
