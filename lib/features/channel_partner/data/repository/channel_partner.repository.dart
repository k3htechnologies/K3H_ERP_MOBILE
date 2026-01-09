import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/channel_partner/data/datasource/channel_partner.datasource.dart';

abstract interface class ChannelPartnerRepository {
  Future<Either<Failure, Map<String, dynamic>>> getChannelPartnerList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateChannelPartner({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteChannelPartner({
    required int channelPartnerId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportChannelPartner({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ChannelPartnerRepositoryImpl implements ChannelPartnerRepository {
  final ChannelPartnerDatasource channelPartnerDatasource;

  ChannelPartnerRepositoryImpl({required this.channelPartnerDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getChannelPartnerList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await channelPartnerDatasource
          .apicallPullChannelPartnerMaster(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateChannelPartner({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await channelPartnerDatasource
          .apicallAddUpdateChannelPartnerMaster(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteChannelPartner({
    required int channelPartnerId,
    required String uniqueKey,
  }) async {
    try {
      var result = await channelPartnerDatasource
          .apicallDeleteChannelPartnerMaster(
            channelPartnerId: channelPartnerId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportChannelPartner({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await channelPartnerDatasource
          .apicallPullChannelPartnerMasterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
