import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/datasource/proposed_offer.datasource.dart';

abstract interface class ProposedOfferRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullProposedOfferForPDFExport({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
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

  Future<Either<Failure, Map<String, dynamic>>>
  pullTemporaryAccommodationAlternativeDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTemporaryAccommodationAlternativeDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  deleteTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferTemporaryAlternateAccommodationDetailsId,
    required String uniquekey,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateGenerateProposedOffer({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateReadyReckonerRateDetails({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> deleteReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferReadyReckonerRateDetailsId,
    required String uniquekey,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  pullAdditionalInformationDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateAdditionalInformationDetails({required Map<String, dynamic> body});
  Future<Either<Failure, Map<String, dynamic>>> pullBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBankGuaranteeDetails({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
  });
}

class ProposedOfferRepositoryImpl implements ProposedOfferRepository {
  final ProposedOfferDatasource proposedOfferDatasource;

  ProposedOfferRepositoryImpl({required this.proposedOfferDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullProposedOfferForPDFExport({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullProposedOfferForPDFExport(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

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
  Future<Either<Failure, Map<String, dynamic>>>
  pullTemporaryAccommodationAlternativeDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullTemporaryAlternateAccommodationDetails(
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
  addUpdateTemporaryAccommodationAlternativeDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateTemporaryAccommodationAlternativeDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferTemporaryAlternateAccommodationDetailsId,
    required String uniquekey,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallDeleteTemporaryAlternateAccommodationDetails(
            projectId: projectId,
            buildingId: buildingId,
            proposedOfferTemporaryAlternateAccommodationDetailsId:
                proposedOfferTemporaryAlternateAccommodationDetailsId,
            uniquekey: uniquekey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateGenerateProposedOffer({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateGenerateProposedOffer(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullReadyReckonerRateDetails(
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
  addUpdateReadyReckonerRateDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateReadyReckonerRateDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferReadyReckonerRateDetailsId,
    required String uniquekey,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallDeleteReadyReckonerRateDetails(
            projectId: projectId,
            buildingId: buildingId,
            proposedOfferReadyReckonerRateDetailsId:
                proposedOfferReadyReckonerRateDetailsId,
            uniquekey: uniquekey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  pullAdditionalInformationDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullAdditionalInformationDetails(
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
  addUpdateAdditionalInformationDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateAdditionalInformationDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallPullBankGuaranteeDetails(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBankGuaranteeDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallAddUpdateBankGuaranteeDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await proposedOfferDatasource
          .apicallDeleteBankGuranteeDetails(
            projectId: projectId,
            buildingId: buildingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
