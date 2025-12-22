import 'package:flutter/material.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

class ErrorHandler {
  static String getErrorMessage(error) {
    if (error is BadRequestException) {
      return error.message;
    } else if (error is ApiNotRespondingException) {
      return error.message;
    } else if (error is UnauthorizedException) {
      return error.message;
    } else if (error is UserDeletedException) {
      return error.message;
    } else if (error is MenuChangedException) {
      return error.message;
    } else {
      debugPrint(error.toString());
      return "Unexpected error occured";
    }
  }

  static bool isMenuChangedException(error) {
    return error is MenuChangedException;
  }
}