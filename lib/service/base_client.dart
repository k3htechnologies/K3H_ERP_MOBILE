/*import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:k3h_erp_app/env/env.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';

import 'exceptions.dart';

class BaseClient {
  // BASE CONFIG
  static final String baseUrl = ENV.baseUrl;
  static final String apiKey = ENV.apiKey;

  final LocalStorageManager _storage = LocalStorageManager();

  late String token;
  String? userUniqueKey; // <-- NOT FINAL ANYMORE

  BaseClient() {
    token = _storage.getString(StorageKey.authorizationToken) ?? "";
    userUniqueKey = _storage.getString(StorageKey.userUniqueKey);
  }

  // ------------------------------ GET WITHOUT AUTH ------------------------------

  Future<dynamic> getRequestWithoutAuthentication(String url) async {
    try {
      final response = await http
          .get(
        Uri.parse("$baseUrl/$url"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "apikey": apiKey,
        },
      )
          .timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on TimeoutException {
      throw ApiNotRespondingException("REQUEST TIMED OUT. PLEASE TRY AGAIN LATER.");
    }
  }

  // ------------------------------ GET WITH AUTH ------------------------------

  Future<dynamic> getRequestWithAuthentication(String url) async {
    try {
      _reloadToken();
      final response = await http
          .get(
        Uri.parse("$baseUrl/$url"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "apiKey": apiKey,
          "Authorization": "Bearer $token",
        },
      )
          .timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on TimeoutException {
      throw ApiNotRespondingException("REQUEST TIMED OUT. PLEASE TRY AGAIN LATER.");
    }
  }

  // ------------------------------ POST WITH AUTH ------------------------------

  Future<dynamic> postRequestWithAuthentication(String url, dynamic payload) async {
    try {
      _reloadToken();
      final response = await http
          .post(
        Uri.parse("$baseUrl/$url"),
        body: json.encode(payload),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "apiKey": apiKey,
          "Authorization": "Bearer $token",
        },
      )
          .timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on TimeoutException {
      throw ApiNotRespondingException("REQUEST TIMED OUT. PLEASE TRY AGAIN LATER.");
    }
  }

  // ------------------------------ DELETE WITH AUTH ------------------------------

  Future<dynamic> deleteRequestWithAuthentication(String url) async {
    try {
      _reloadToken();
      final response = await http
          .delete(
        Uri.parse("$baseUrl/$url"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "apiKey": apiKey,
          "Authorization": "Bearer $token",
        },
      )
          .timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on TimeoutException {
      throw ApiNotRespondingException("REQUEST TIMED OUT. PLEASE TRY AGAIN LATER.");
    }
  }

  // ------------------------------ MULTIPART WITH BYTES ------------------------------

  Future<dynamic> multipartRequestWithAuthenticationBytes(
      String url,
      List<Map<String, dynamic>> fileList,
      Map<String, String> payload,
      ) async {
    try {
      _reloadToken();
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/$url"));

      for (var item in fileList) {
        String fileName = item["fileName"];
        String ext = fileName.split('.').last.toLowerCase();

        String mime = _mimeType(ext);
        String subtype = _mimeSubtype(ext);

        request.files.add(
          http.MultipartFile.fromBytes(
            item["key"],
            item["value"],
            filename: fileName,
            contentType: MediaType(mime, subtype),
          ),
        );
      }

      request.headers.addAll({
        "Accept": "application/json",
        "apiKey": apiKey,
        "Authorization": "Bearer $token",
      });

      request.fields.addAll(payload);

      var result = await request.send();
      var response = await http.Response.fromStream(result);

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // ------------------------------ RESPONSE HANDLER ------------------------------

  dynamic _processResponse(http.Response response) async {
    log(response.body);
    log(response.statusCode.toString());

    switch (response.statusCode) {
      case 200:
        return _validateResponse(response.body);

      case 401:
        throw UnauthorizedException("Unauthorized user");

      case 402:
        throw UserDeletedException("Your session has expired due to inactivity.");

      case 403:
        await refreshToken();
        return;

      case 404:
        throw BadRequestException("Invalid request");

      default:
        throw ApiNotRespondingException("Unexpected error occurred");
    }
  }

  dynamic _validateResponse(String apiResponse) {
    final jsonResponse = jsonDecode(apiResponse);

    if (jsonResponse["IsSuccess"]) {
      return {
        "totalNumberOfRecord": jsonResponse["TotalNumberOfRecord"],
        "data": jsonResponse["Data"],
        "message": jsonResponse["SuccessMessage"].isEmpty
            ? ""
            : jsonResponse["SuccessMessage"][0],
      };
    } else {
      final errorList = jsonResponse["ErrorMessage"];
      final warnList = jsonResponse["WarningMessage"];

      throw BadRequestException(
        errorList.isNotEmpty ? errorList[0] : warnList[0],
      );
    }
  }

  // ------------------------------ REFRESH TOKEN ------------------------------

  Future<String?> refreshToken() async {
    if (userUniqueKey == null) return null;

    final url = "Authentication/RefreshToken?Uniquekey=$userUniqueKey";

    try {
      final res = await getRequestWithoutAuthentication(url);
      final newToken = res["data"];

      token = newToken;
      _storage.setString(StorageKey.authorizationToken, token);

      return token;
    } catch (e) {
      return null;
    }
  }

  // ------------------------------ HELPERS ------------------------------

  void _reloadToken() {
    token = _storage.getString(StorageKey.authorizationToken)??"";
  }

  String _mimeType(String ext) {
    switch (ext) {
      case "png":
      case "jpg":
      case "jpeg":
        return "image";
      case "pdf":
        return "application";
      default:
        return "application";
    }
  }

  String _mimeSubtype(String ext) {
    switch (ext) {
      case "png":
        return "png";
      case "jpg":
      case "jpeg":
        return "jpeg";
      case "pdf":
        return "pdf";
      default:
        return "octet-stream";
    }
  }
}*/

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:k3h_erp_app/env/env.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';

import 'exceptions.dart';

class BaseClient {
  static final String baseUrl = ENV.baseUrl;
  static final String apiKey = ENV.apiKey;

  final LocalStorageManager _storage = LocalStorageManager();

  late Dio _dio;
  late String token;
  String? userUniqueKey;

  BaseClient() {
    token = _storage.getString(StorageKey.authorizationToken) ?? "";
    userUniqueKey = _storage.getString(StorageKey.userUniqueKey);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "apikey": apiKey,
        },
      ),
    );

    _addInterceptors();
  }

  // --------------------------------------------------------------------------
  // INTERCEPTORS
  // --------------------------------------------------------------------------

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _reloadToken();
          options.headers["Authorization"] = "Bearer $token";
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Check if response indicates menu/authorization change
          // This will throw MenuChangedException if detected, which will be caught by error handlers
          try {
            _checkForMenuChangeInResponse(response.data);
          } catch (e) {
            if (e is MenuChangedException) {
              // Convert to error so it gets handled properly
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: e,
                ),
              );
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // HANDLE 403 → REFRESH TOKEN
          if (e.response?.statusCode == 403) {
            final newToken = await refreshToken();
            if (newToken != null) {
              e.requestOptions.headers["Authorization"] = "Bearer $newToken";
              final cloneReq = await _dio.fetch(e.requestOptions);
              return handler.resolve(cloneReq);
            }
          }

          // HANDLE 412 → MENU/AUTHORIZATION CHANGED
          // Status code 412 (Precondition Failed) typically indicates menu/authorization change
          if (e.response?.statusCode == 412) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                type: DioExceptionType.badResponse,
                error: MenuChangedException("Menu - Your access has been modified"),
              ),
            );
          }

          // Check error response for menu changes
          if (e.response?.data != null) {
            try {
              _checkForMenuChangeInResponse(e.response!.data);
            } catch (menuException) {
              if (menuException is MenuChangedException) {
                // Re-throw as DioException so it gets handled
                return handler.reject(
                  DioException(
                    requestOptions: e.requestOptions,
                    response: e.response,
                    type: DioExceptionType.badResponse,
                    error: menuException,
                  ),
                );
              }
            }
          }

          return handler.next(e);
        },
      ),
    );
  }


  // --------------------------------------------------------------------------
  // GET WITHOUT AUTH
  // --------------------------------------------------------------------------

  Future<dynamic> getRequestWithoutAuthentication(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {"apikey": apiKey}),
      );
      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --------------------------------------------------------------------------
  // GET WITH AUTH
  // --------------------------------------------------------------------------

  Future<dynamic> getRequestWithAuthentication(String url) async {
    try {
      final response = await _dio.get(url);
      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --------------------------------------------------------------------------
  // POST WITH AUTH
  // --------------------------------------------------------------------------

  Future<dynamic> postRequestWithAuthentication(
    String url,
    dynamic payload,
  ) async {
    try {
      final response = await _dio.post(url, data: payload);
      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --------------------------------------------------------------------------
  // DELETE WITH AUTH
  // --------------------------------------------------------------------------

  Future<dynamic> deleteRequestWithAuthentication(String url) async {
    try {
      final response = await _dio.delete(url);
      return _processResponse(response);
    } on SocketException {
      throw ApiNotRespondingException("PLEASE CHECK YOUR INTERNET CONNECTION");
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --------------------------------------------------------------------------
  // MULTIPART (WITH BYTES)
  // --------------------------------------------------------------------------

  Future<dynamic> multipartRequestWithAuthenticationBytes(
    String url,
    List<Map<String, dynamic>> fileList,
    Map<String, String> payload,
  ) async {
    try {
      List<MultipartFile> files = [];

      for (var item in fileList) {
        String fileName = item["fileName"];
        String ext = fileName.split('.').last.toLowerCase();

        files.add(
          MultipartFile.fromBytes(
            item["value"],
            filename: fileName,
            contentType: MediaType(_mimeType(ext), _mimeSubtype(ext)),
          ),
        );
      }

      final formData = FormData.fromMap({
        ...payload,
        for (int i = 0; i < fileList.length; i++) fileList[i]["key"]: files[i],
      });

      final response = await _dio.post(url, data: formData);
      return _processResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --------------------------------------------------------------------------
  // RESPONSE HANDLER
  // --------------------------------------------------------------------------

  dynamic _processResponse(Response response) {
    log(response.statusCode.toString());
    log(response.data.toString());

    // Check response headers for menu change indication
    final headers = response.headers;
    if (headers.value('x-menu-changed') == 'true' ||
        headers.value('menu-changed') == 'true') {
      throw MenuChangedException("Menu - Your access has been modified");
    }

    switch (response.statusCode) {
      case 200:
        return _validateResponse(response.data);

      case 401:
        throw UnauthorizedException("Unauthorized user");

      case 402:
        throw UserDeletedException(
          "Your session has expired due to inactivity.",
        );

      case 412:
        // Status code 412 (Precondition Failed) typically indicates menu/authorization change
        throw MenuChangedException("Menu - Your access has been modified");

      case 404:
        throw BadRequestException("Invalid request");

      default:
        throw ApiNotRespondingException("Unexpected error occurred");
    }
  }

  dynamic _validateResponse(dynamic jsonResponse) {
    // Check for menu/authorization changes in response FIRST
    // This must be done before processing success/error
    try {
      _checkForMenuChangeInResponse(jsonResponse);
    } catch (e) {
      if (e is MenuChangedException) {
        rethrow;
      }
    }

    if (jsonResponse["IsSuccess"]) {
      // Also check success messages for menu change indication
      if (jsonResponse.containsKey("SuccessMessage") &&
          jsonResponse["SuccessMessage"] is List) {
        final successList = jsonResponse["SuccessMessage"];
        if (successList.isNotEmpty) {
          final successMessage = successList[0].toString().toLowerCase();
          if (successMessage.contains("menu") ||
              successMessage.contains("authorization")) {
            throw MenuChangedException("Menu - ${jsonResponse["SuccessMessage"][0]}");
          }
        }
      }

      return {
        "totalNumberOfRecord": jsonResponse["TotalNumberOfRecord"],
        "data": jsonResponse["Data"],
        "message":
            jsonResponse["SuccessMessage"].isEmpty
                ? ""
                : jsonResponse["SuccessMessage"][0],
      };
    } else {
      final errorList = jsonResponse["ErrorMessage"];
      final warnList = jsonResponse["WarningMessage"];

      // Check if error/warning message indicates menu change
      if (errorList.isNotEmpty) {
        final errorMessage = errorList[0].toString();
        if (errorMessage.toLowerCase().contains("menu") ||
            errorMessage.toLowerCase().contains("authorization")) {
          throw MenuChangedException("Menu - $errorMessage");
        }
      }
      if (warnList.isNotEmpty) {
        final warnMessage = warnList[0].toString();
        if (warnMessage.toLowerCase().contains("menu") ||
            warnMessage.toLowerCase().contains("authorization")) {
          throw MenuChangedException("Menu - $warnMessage");
        }
      }

      throw BadRequestException(
        errorList.isNotEmpty ? errorList[0] : warnList[0],
      );
    }
  }

  // Check if response indicates menu/authorization change
  void _checkForMenuChangeInResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Check if there's a specific flag indicating menu change
        if (responseData.containsKey("IsMenuChanged") &&
            responseData["IsMenuChanged"] == true) {
          throw MenuChangedException("Menu - Your access has been modified");
        }

        // Check data field for menu change indication
        if (responseData.containsKey("Data") && responseData["Data"] != null) {
          final data = responseData["Data"];
          if (data is Map<String, dynamic> &&
              data.containsKey("IsMenuChanged") &&
              data["IsMenuChanged"] == true) {
            throw MenuChangedException("Menu - Your access has been modified");
          }
        }
      }
    } catch (e) {
      if (e is MenuChangedException) {
        rethrow;
      }
      // Ignore other errors in menu check
    }
  }

  // --------------------------------------------------------------------------
  // TOKEN REFRESH
  // --------------------------------------------------------------------------

  Future<String?> refreshToken() async {
    if (userUniqueKey == null) return null;

    final url = "Authentication/RefreshToken?Uniquekey=$userUniqueKey";

    try {
      final res = await getRequestWithoutAuthentication(url);
      final newToken = res["data"];

      token = newToken;
      _storage.setString(StorageKey.authorizationToken, token);

      return token;
    } catch (e) {
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // HELPERS
  // --------------------------------------------------------------------------

  void _reloadToken() {
    token = _storage.getString(StorageKey.authorizationToken) ?? "";
  }

  String _mimeType(String ext) {
    switch (ext) {
      case "png":
      case "jpg":
      case "jpeg":
        return "image";
      case "pdf":
        return "application";
      default:
        return "application";
    }
  }

  String _mimeSubtype(String ext) {
    switch (ext) {
      case "png":
        return "png";
      case "jpg":
      case "jpeg":
        return "jpeg";
      case "pdf":
        return "pdf";
      default:
        return "octet-stream";
    }
  }

  // HANDLE COMMON DIO ERRORS
  dynamic _handleDioError(DioException e) {
    // Check if the error is a MenuChangedException - this is the most important check
    if (e.error is MenuChangedException) {
      throw e.error as MenuChangedException;
    }
    
    // Also check if the response data indicates menu change
    if (e.response?.data != null) {
      try {
        _checkForMenuChangeInResponse(e.response!.data);
      } catch (menuException) {
        if (menuException is MenuChangedException) {
          throw menuException;
        }
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw ApiNotRespondingException("REQUEST TIMED OUT. PLEASE TRY AGAIN.");
    }
    if (e.error is SocketException) {
      throw ApiNotRespondingException("NO INTERNET CONNECTION");
    }
    throw ApiNotRespondingException("Unexpected error: ${e.message}");
  }
}
