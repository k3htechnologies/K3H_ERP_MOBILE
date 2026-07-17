import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/datasource/proposed_offer.datasource.dart';

abstract interface class ProposedOfferRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullExtraCarpetArea({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateExtraCarpetArea({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullHardshipDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateHardshipDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteHardshipDetails({
    required int projectId,
    required int buildingId,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullShiftingDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateShiftingDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteShiftingDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateSecurityDepositDetails({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> deleteSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullLienToSocietyDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateLienToSocietyDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullParkingAllotment({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateParkingAllotment({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullGSTonExistingPlusFreeArea({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateGSTonExistingPlusFreeArea({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> pullProjectCompletion({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectCompletion({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullRentDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateRentDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteRentDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferRentDetailsId,
    required String uniquekey,
  });
}

class ProposedOfferRepositoryImpl implements ProposedOfferRepository {
  final ProposedOfferDatasource proposedOfferDatasource;

  ProposedOfferRepositoryImpl({required this.proposedOfferDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullExtraCarpetArea({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullExtraCarpetArea(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateExtraCarpetArea({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateExtraCarpetArea(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullHardshipDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullHardshipDetails(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteHardshipDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallDeleteHardshipDetails(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateHardshipDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateHardshipDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullShiftingDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullShiftingDetails(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateShiftingDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateShiftingDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteShiftingDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallDeleteShiftingDetails(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullSecurityDepositDetails(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateSecurityDepositDetails({required Map<String, dynamic> body}) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateSecurityDepositDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallDeleteSecurityDepositDetails(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullLienToSocietyDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullLienToSocietyDetails(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLienToSocietyDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateLienToSocietyDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullParkingAllotment({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullParkingAllotment(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateParkingAllotment({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateParkingAllotment(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullGSTonExistingPlusFreeArea({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullGSTonExistingPlusFreeArea(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateGSTonExistingPlusFreeArea({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateGSTonExistingPlusFreeArea(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullProjectCompletion({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullProjectCompletion(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectCompletion({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateProjectCompletion(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullRentDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallPullRentDetails(
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateRentDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallAddUpdateRentDetails(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRentDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferRentDetailsId,
    required String uniquekey,
  }) async {
    try {
      var result = await proposedOfferDatasource.apicallDeleteRentDetails(
        projectId: projectId,
        buildingId: buildingId,
        proposedOfferRentDetailsId: proposedOfferRentDetailsId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
