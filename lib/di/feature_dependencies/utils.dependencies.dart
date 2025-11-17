import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

void registerUtilsDependencies(GetIt serviceLocator) {
  String? token = LocalStorageManager().getString(
    StorageKey.authorizationToken,
  );
  String? userString = LocalStorageManager().getString(StorageKey.currentUser);
  UserModel? user;
  if (userString != null) {
    user = UserModel.fromJson(jsonDecode(userString));
  }
  // serviceLocator.registerSingleton<K3hHttpClient>(
  //   K3hHttpClient(
  //     apiKey: ENV.apiKey,
  //     baseUrl: ENV.baseUrl,
  //     token: token,
  //     userUniqueKey: user?.uniqueKey,
  //   ),
  // );
  serviceLocator.registerSingleton<UtilsDatasource>(UtilsDatasourceImpl());
  serviceLocator.registerSingleton<UtilsRepository>(
    UtilsRepositoryImpl(serviceLocator<UtilsDatasource>()),
  );
}