import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/additional_information_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/bank_guarantee_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/offer_hardship_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/extra_carpet_area.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/gst_on_existing_plus_free_area.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/parking_allotment.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/project_completion.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/ready_reckover_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ProposedOfferDatasource {
  Future<Map<String, dynamic>> apicallPullProposedOfferForPDFExport({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullExtraCarpetArea({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateExtraCarpetArea({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullHardshipDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateHardshipDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteHardshipDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallPullShiftingDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateShiftingDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteShiftingDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallPullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateSecurityDepositDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallPullLienToSocietyDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateLienToSocietyDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullParkingAllotment({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateParkingAllotment({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullGSTonExistingPlusFreeArea({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateGSTonExistingPlusFreeArea({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullProjectCompletion({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectCompletion({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>>
  apicallPullTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>>
  apicallAddUpdateTemporaryAccommodationAlternativeDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>>
  apicallDeleteTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferTemporaryAlternateAccommodationDetailsId,
    required String uniquekey,
  });
  Future<Map<String, dynamic>> apicallAddUpdateGenerateProposedOffer({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateReadyReckonerRateDetails({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferReadyReckonerRateDetailsId,
    required String uniquekey,
  });
  Future<Map<String, dynamic>> apicallPullAdditionalInformationDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateAdditionalInformationDetails({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallPullBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateBankGuaranteeDetails({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteBankGuranteeDetails({
    required int projectId,
    required int buildingId,
  });
}

class ProposedOfferDatasourceImpl implements ProposedOfferDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProposedOfferForPDFExport({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProposedOfferPDF({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullProposedOfferPDF?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProposedOfferPDF(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullExtraCarpetArea(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullExtraCarpetArea({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullExtraCarpetAreaUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullExtraCarpetArea?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullExtraCarpetAreaUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ExtraCarpetAreaModel>.from(
          networkResponse['data'].map((x) => ExtraCarpetAreaModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullExtraCarpetArea(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateExtraCarpetArea({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "ProposedOffer/AddUpdateExtraCarpetArea";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<ExtraCarpetAreaModel>.from(
          networkResponse['data'].map((x) => ExtraCarpetAreaModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateExtraCarpetArea(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullHardshipDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullHardshipDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullHardshipDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullHardshipDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<HardshipOfferDetailsModel>.from(
          networkResponse['data'].map(
            (x) => HardshipOfferDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullHardshipDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateHardshipDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateHardshipDetailsUrl =
        "ProposedOffer/AddUpdateHardshipDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateHardshipDetailsUrl,
        body,
      );
      return {
        'data': List<HardshipOfferDetailsModel>.from(
          networkResponse['data'].map(
            (x) => HardshipOfferDetailsModel.fromJson(x),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateHardshipDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteHardshipDetails({
    required int projectId,
    required int buildingId,
  }) async {
    String deleteHardshipDetailsUrl({
      required int projectId,
      required int buildingId,
    }) {
      return "ProposedOffer/DeleteHardshipDetails?ProjectId=$projectId&BuildingId=$buildingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteHardshipDetailsUrl(projectId: projectId, buildingId: buildingId),
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallDeleteHardshipDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullShiftingDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftingDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullShiftingDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftingDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ShiftingDetailsModel>.from(
          networkResponse['data'].map((x) => ShiftingDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullShiftingDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateShiftingDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateShiftingDetailsUrl =
        "ProposedOffer/AddUpdateShiftingDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateShiftingDetailsUrl,
        body,
      );
      return {
        'data': List<ShiftingDetailsModel>.from(
          networkResponse['data'].map((x) => ShiftingDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateShiftingDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteShiftingDetails({
    required int projectId,
    required int buildingId,
  }) async {
    String deleteShiftingDetailsUrl({
      required int projectId,
      required int buildingId,
    }) {
      return "ProposedOffer/DeleteShiftingDetails?ProjectId=$projectId&BuildingId=$buildingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteShiftingDetailsUrl(projectId: projectId, buildingId: buildingId),
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallDeleteShiftingDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSecurityDepositDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullSecurityDepositDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSecurityDepositDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<SecurityDepositModel>.from(
          networkResponse['data'].map((x) => SecurityDepositModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSecurityDepositDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateSecurityDepositDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateSecurityDepositDetailsUrl =
        "ProposedOffer/AddUpdateSecurityDepositDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateSecurityDepositDetailsUrl,
        body,
      );
      return {
        'data': List<SecurityDepositModel>.from(
          networkResponse['data'].map((x) => SecurityDepositModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateSecurityDepositDetails(body: body);
      }

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  }) async {
    String deleteSecurityDepositDetailsUrl({
      required int projectId,
      required int buildingId,
    }) {
      return "ProposedOffer/DeleteSecurityDepositDetails?ProjectId=$projectId&BuildingId=$buildingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteSecurityDepositDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallDeleteSecurityDepositDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLienToSocietyDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLienToSocietyDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullLienToSocietyDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLienToSocietyDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<LienToSocietyDetailsModel>.from(
          networkResponse['data'].map(
            (x) => LienToSocietyDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullLienToSocietyDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateLienToSocietyDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateLienToSocietyDetailsUrl =
        "ProposedOffer/AddUpdateLienToSocietyDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateLienToSocietyDetailsUrl,
        body,
      );
      return {
        'data': List<LienToSocietyDetailsModel>.from(
          networkResponse['data'].map(
            (x) => LienToSocietyDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateLienToSocietyDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullParkingAllotment({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullParkingAllotmentUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullParkingAllotment?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullParkingAllotmentUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ParkingAllotmentModel>.from(
          networkResponse['data'].map((x) => ParkingAllotmentModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullParkingAllotment(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateParkingAllotment({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateParkingAllotmentUrl =
        "ProposedOffer/AddUpdateParkingAllotment";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateParkingAllotmentUrl,
        body,
      );
      return {
        'data': List<ParkingAllotmentModel>.from(
          networkResponse['data'].map((x) => ParkingAllotmentModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateParkingAllotment(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullGSTonExistingPlusFreeArea({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullGSTonExistingPlusFreeAreaUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullGSTonExistingPlusFreeArea?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullGSTonExistingPlusFreeAreaUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': List<GstOnExistingPlusFreeAreaModel>.from(
          networkResponse['data'].map(
            (x) => GstOnExistingPlusFreeAreaModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullGSTonExistingPlusFreeArea(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateGSTonExistingPlusFreeArea({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateGSTonExistingPlusFreeAreaUrl =
        "ProposedOffer/AddUpdateGSTonExistingPlusFreeArea";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateGSTonExistingPlusFreeAreaUrl,
        body,
      );
      return {
        'data': List<GstOnExistingPlusFreeAreaModel>.from(
          networkResponse['data'].map(
            (x) => GstOnExistingPlusFreeAreaModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateGSTonExistingPlusFreeArea(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullProjectCompletion({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectCompletionUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullProjectCompletion?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectCompletionUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ProjectCompletionModel>.from(
          networkResponse['data'].map(
            (x) => ProjectCompletionModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectCompletion(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProjectCompletion({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectCompletionUrl =
        "ProposedOffer/AddUpdateProjectCompletion";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectCompletionUrl,
        body,
      );
      return {
        'data': List<ProjectCompletionModel>.from(
          networkResponse['data'].map(
            (x) => ProjectCompletionModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectCompletion(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallPullTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTemporaryAccommodationAlternativeDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullTemporaryAlternateAccommodationDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTemporaryAccommodationAlternativeDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': List<TemporaryAlternativeAccommodationDetailsModel>.from(
          networkResponse['data'].map(
            (x) => TemporaryAlternativeAccommodationDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTemporaryAlternateAccommodationDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallAddUpdateTemporaryAccommodationAlternativeDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateTemporaryAccommodationAlternativeDetailsUrl =
        "ProposedOffer/AddUpdateTemporaryAlternateAccommodationDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateTemporaryAccommodationAlternativeDetailsUrl,
        body,
      );
      return {
        'data': List<TemporaryAlternativeAccommodationDetailsModel>.from(
          networkResponse['data'].map(
            (x) => TemporaryAlternativeAccommodationDetailsModel.fromJson(x),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTemporaryAccommodationAlternativeDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallDeleteTemporaryAlternateAccommodationDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferTemporaryAlternateAccommodationDetailsId,
    required String uniquekey,
  }) async {
    String deleteRentDetailsUrl({
      required int proposedOfferTemporaryAlternateAccommodationDetailsId,
      required int buildingId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProposedOffer/DeleteTemporaryAlternateAccommodationDetails?ProposedOfferTemporaryAlternateAccommodationDetailsId=$proposedOfferTemporaryAlternateAccommodationDetailsId&Uniquekey=$uniqueKey&BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteRentDetailsUrl(
          proposedOfferTemporaryAlternateAccommodationDetailsId:
              proposedOfferTemporaryAlternateAccommodationDetailsId,
          buildingId: buildingId,
          projectId: projectId,
          uniqueKey: uniquekey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteTemporaryAlternateAccommodationDetails(
          projectId: projectId,
          buildingId: buildingId,
          proposedOfferTemporaryAlternateAccommodationDetailsId:
              proposedOfferTemporaryAlternateAccommodationDetailsId,
          uniquekey: uniquekey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateGenerateProposedOffer({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateGenerateProposedOfferUrl =
        "ProposedOffer/AddUpdateGenerateProposedOffer";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateGenerateProposedOfferUrl,
        body,
      );
      return {
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateGenerateProposedOffer(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullReadyReckonerRateDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullReadyReckonerRateDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullReadyReckonerRateDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': List<ReadyReckonerRateDetailsModel>.from(
          networkResponse['data'].map(
            (x) => ReadyReckonerRateDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullReadyReckonerRateDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateReadyReckonerRateDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateReadyReckonerRateDetailsUrl =
        "ProposedOffer/AddUpdateReadyReckonerRateDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateReadyReckonerRateDetailsUrl,
        body,
      );
      return {
        'data': List<ReadyReckonerRateDetailsModel>.from(
          networkResponse['data'].map(
            (x) => ReadyReckonerRateDetailsModel.fromJson(x),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateReadyReckonerRateDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteReadyReckonerRateDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferReadyReckonerRateDetailsId,
    required String uniquekey,
  }) async {
    String deleteReckonerRateDetailsUrl({
      required int proposedOfferReadyReckonerRateDetailsId,
      required int buildingId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProposedOffer/DeleteReadyReckonerRateDetails?ProposedOfferReadyReckonerRateDetailsId=$proposedOfferReadyReckonerRateDetailsId&Uniquekey=$uniqueKey&BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteReckonerRateDetailsUrl(
          proposedOfferReadyReckonerRateDetailsId:
              proposedOfferReadyReckonerRateDetailsId,
          buildingId: buildingId,
          projectId: projectId,
          uniqueKey: uniquekey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteReadyReckonerRateDetails(
          proposedOfferReadyReckonerRateDetailsId:
              proposedOfferReadyReckonerRateDetailsId,
          projectId: projectId,
          buildingId: buildingId,
          uniquekey: uniquekey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullAdditionalInformationDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullReadyReckonerRateDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullAdditionalInformation?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullReadyReckonerRateDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': List<AdditionalInformationDetailsModel>.from(
          networkResponse['data'].map(
            (x) => AdditionalInformationDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullAdditionalInformationDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateAdditionalInformationDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateAdditionalInformationUrl =
        "ProposedOffer/AddUpdateAdditionalInformation";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateAdditionalInformationUrl,
        body,
      );
      return {
        'data': List<AdditionalInformationDetailsModel>.from(
          networkResponse['data'].map(
            (x) => AdditionalInformationDetailsModel.fromJson(x),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateAdditionalInformationDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBankGuaranteeDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullReadyReckonerRateDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullBankGuaranteeDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullReadyReckonerRateDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': List<BankGuaranteeDetailsModel>.from(
          networkResponse['data'].map(
            (x) => BankGuaranteeDetailsModel.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBankGuaranteeDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBankGuaranteeDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateBankGuaranteeUrl =
        "ProposedOffer/AddUpdateBankGuaranteeDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateBankGuaranteeUrl,
        body,
      );
      return {
        'data': List<BankGuaranteeDetailsModel>.from(
          networkResponse['data'].map(
            (x) => BankGuaranteeDetailsModel.fromJson(x),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateBankGuaranteeDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBankGuranteeDetails({
    required int projectId,
    required int buildingId,
  }) async {
    String deleteBankGuaranteeDetailsUrl({
      required int buildingId,
      required int projectId,
    }) {
      return "ProposedOffer/DeleteBankGuaranteeDetails?BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBankGuaranteeDetailsUrl(
          buildingId: buildingId,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        deleteBankGuaranteeDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }
}
