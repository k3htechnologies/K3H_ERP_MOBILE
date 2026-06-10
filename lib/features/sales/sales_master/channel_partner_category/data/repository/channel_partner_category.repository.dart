import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/datasource/channel_partner_category.datasource.dart';

abstract interface class PaymentScheduleRepository {
  Future<Either<Failure, Map<String, dynamic>>> getChannelPartnerCategoryList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateChannelPartnerCategory({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> exportChannelPartnerCategory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleRepositoryImpl extends PaymentScheduleRepository {
  final ChannelPartnerCategoryDatasource channelPartnerCategoryDatasource;

  PaymentScheduleRepositoryImpl({
    required this.channelPartnerCategoryDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getChannelPartnerCategoryList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await channelPartnerCategoryDatasource
          .apicallPullChannelPartnerCategory(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateChannelPartnerCategory({required Map<String, dynamic> body}) async {
    try {
      var result = await channelPartnerCategoryDatasource
          .apicallAddUpdateChannelPartnerCategory(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportChannelPartnerCategory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await channelPartnerCategoryDatasource
          .apicallPullChannelPartnerCategoryForExport(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
