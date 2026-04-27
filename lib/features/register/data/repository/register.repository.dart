import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';
import 'package:k3h_erp_app/features/register/data/datasource/register.datasource.dart';

abstract interface class RegisterRepository {
  Future<Either<Failure, Map<String, dynamic>>> sendOTPModuleBased({
    String? mobileNumber,
    String? module,
  });

  Future<Either<Failure, UserModel>> validateOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  });
}

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterDatasource registerDatasource;
  final UtilsDatasource utilsDatasource;

  RegisterRepositoryImpl({
    required this.registerDatasource,
    required this.utilsDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOTPModuleBased({
    String? mobileNumber,
    String? module,
  }) async {
    try {
      var result = await utilsDatasource.apiCallSendOTPModuleBased(
        mobileNumber: mobileNumber!,
        module: module!,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, UserModel>> validateOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  }) async {
    try {
      var result = await registerDatasource.apicallIsValidOTP(
        mobileNumber: mobileNumber,
        otp: otp,
        type: type,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
