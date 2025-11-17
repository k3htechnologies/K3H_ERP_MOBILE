class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class BadRequestException extends AppException {
  BadRequestException(super.message);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class TokenExpiredException extends AppException{
  TokenExpiredException(super.message);
}

class MenuChangedException extends AppException {
  MenuChangedException(super.message);
}

class UserDeletedException extends AppException{
  UserDeletedException(super.message);
}