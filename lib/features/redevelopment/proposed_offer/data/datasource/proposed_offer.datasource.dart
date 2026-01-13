import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/corpus_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/extra_carpet_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/gst_on_existing_plus_free_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/parking_allotment.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/project_completion.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ProposedOfferDatasource {
  Future<Map<String, dynamic>> apicallPullExtraCarpetArea({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateExtraCarpetArea({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullCorpusDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateCorpusDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullShiftingDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateShiftingDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateSecurityDepositDetails({
    required Map<String, dynamic> body,
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

  Future<Map<String, dynamic>> apicallPullRentDetails({
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateRentDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteRentDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferRentDetailsId,
    required String uniquekey,
  });
}

class ProposedOfferDatasourceImpl implements ProposedOfferDatasource {
  final BaseClient baseClient = BaseClient();

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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
  Future<Map<String, dynamic>> apicallPullCorpusDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCorpusDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullCorpusDetails?ProjectId=$projectId&BuildingId=$buildingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCorpusDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CorpusDetailsModel>.from(
          networkResponse['data'].map((x) => CorpusDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCorpusDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateCorpusDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateCorpusDetailsUrl = "ProposedOffer/AddUpdateCorpusDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateCorpusDetailsUrl,
        body,
      );
      return {
        'data': List<CorpusDetailsModel>.from(
          networkResponse['data'].map((x) => CorpusDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateCorpusDetails(body: body);
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
  Future<Map<String, dynamic>> apicallPullRentDetails({
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullRentDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProposedOffer/PullRentDetails?ProjectId=$projectId&BuildingId=$buildingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullRentDetailsUrl(projectId: projectId, buildingId: buildingId),
      );
      return {
        'data': List<RentDetailsModel>.from(
          networkResponse['data'].map((x) => RentDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullRentDetails(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateRentDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateRentDetailsUrl = "ProposedOffer/AddUpdateRentDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateRentDetailsUrl,
        body,
      );
      return {
        'data': List<RentDetailsModel>.from(
          networkResponse['data'].map((x) => RentDetailsModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateRentDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteRentDetails({
    required int projectId,
    required int buildingId,
    required int proposedOfferRentDetailsId,
    required String uniquekey,
  }) async {
    String deleteRentDetailsUrl({
      required int proposedOfferRentDetailsId,
      required int buildingId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProposedOffer/DeleteRentDetails?ProposedOfferRentDetailsId=$proposedOfferRentDetailsId&Uniquekey=$uniqueKey&BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteRentDetailsUrl(
          proposedOfferRentDetailsId: proposedOfferRentDetailsId,
          buildingId: buildingId,
          projectId: projectId,
          uniqueKey: uniquekey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteRentDetails(
          projectId: projectId,
          buildingId: buildingId,
          proposedOfferRentDetailsId: proposedOfferRentDetailsId,
          uniquekey: uniquekey,
        );
      }
      rethrow;
    }
  }
}
