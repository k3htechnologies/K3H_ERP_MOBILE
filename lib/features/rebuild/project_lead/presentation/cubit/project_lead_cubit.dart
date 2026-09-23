import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/land.model.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/redevelopment.model.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/repository/project_lead.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'project_lead_state.dart';

class ProjectLeadCubit extends Cubit<ProjectLeadState> {
  ProjectLeadCubit() : super(ProjectLeadState.initial());

  // REPOSITORY
  final ProjectLeadRepository _projectLeadRepository =
      serviceLocator<ProjectLeadRepository>();

  Future getRedevelopmentList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      "BuildingName": state.redevelopmentSearchText,
      "BuildingAddress": state.redevelopmentBuildingAddressText,
      "ContactPersonName": state.redevelopmentContactPersonNameText,
      "ContactPersonMobile": state.redevelopmentContactPersonMobileNumberText,
      "PinCode": state.redevelopmentPinCode,
      "PlotNumber": state.redevelopmentPlotNumberText,
      "WardNumberZone": state.redevelopmentWardNumberZone,
      "ExistingBuildingType": state.redevelopmentExistingBuildingType,
      "ConstructionType": state.redevelopmentConstructionType,
      "TypeOfLandTenure": state.redevelopmentTypeOfLandTenure,
      "FromDate": state.redevelopmentByFromDate.apiDate,
      "ToDate": state.redevelopmentByToDate.apiDate,
    };
    var result = await _projectLeadRepository.getRedevelopmentList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<RedevelopmentModel> newData = List<RedevelopmentModel>.from(
          response['data'] ?? [],
        );

        final List<RedevelopmentModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.redevelopmentList, ...newData];
        emit(
          state.copyWith(
            redevelopmentList: updatedList,
            isLoading: false,
            redevelopmentTotalNumberOfRecord: response["totalNumberOfRecord"],
            redevelopmentCurrentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addRedevelopment({
    required BuildContext context,
    required String buildingName,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required String pnCode,
    required String plotCTSSurveySubdivisionNumberC,
    required MultiFilePickerModel projectPhotoMap,
    required String buildingAddress,
    required String wardNumberZone,
    required String totalPlotAreaSqM,
    required String yearOfOriginalConstruction,
    required String existingBuildingType,
    required String numberOfExistingFloors,
    required String totalNumberExistingFlatsUnits,
    required String identificationLocation,
    required String latitudeLongitude,
    required String contactPersonName,
    required String contactPersonMobile,
    required String contactPersonEmail,
    required double percentageMemberInFavor,
    required String typeOfLandTenureType,
    required String plotShape,
    required String plotDepth,
    required String roadWidth,
    required String numberOfExistingBuildingWings,
    required String numberOfFloorPerWings,
    required String totalBuildUpArea,
    required String totalCarpetArea,
    required String totalCommonArea,
    required String constructionType,
    bool? isIsLiftAvailable,
    bool? isFireSafetyProvisionPresent,
    bool? isPlotUnderLitigationStay,
    bool? isConveyanceDeed,
    required String remark,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "BuildingName": buildingName,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "PinCode": pnCode,
      "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber":
          plotCTSSurveySubdivisionNumberC,
      "BuildingAddress": buildingAddress,
      "WardNumberZone": wardNumberZone,
      "TotalPlotAreaSqM": totalPlotAreaSqM,
      "YearOfOriginalConstruction": yearOfOriginalConstruction,
      "ExistingBuildingType": existingBuildingType,
      "NumberOfExistingFloors": numberOfExistingFloors,
      "TotalNumberExistingFlatsUnits": totalNumberExistingFlatsUnits,
      "IdentificationLocation": identificationLocation,
      "LatitudeLongitude": latitudeLongitude,
      "ContactPersonName": contactPersonName,
      "ContactPersonMobile": contactPersonMobile,
      "ContactPersonEmail": contactPersonEmail,
      "PercentageMemberInFavor": percentageMemberInFavor.toString(),
      "TypeOfLandTenure": typeOfLandTenureType,
      "PlotShape": plotShape,
      "PlotDepth": plotDepth,
      "RoadWidth": roadWidth,
      "NumberOfExistingBuildingsWings": numberOfExistingBuildingWings,
      "NumberOfFloorsPerWing": numberOfFloorPerWings,
      "TotalBuildUpArea": totalBuildUpArea,
      "TotalCarpetArea": totalCarpetArea,
      "TotalCommonArea": totalCommonArea,
      "ConstructionType": constructionType,
      "IsLiftAvailable": isIsLiftAvailable.toString(),
      "IsFireSafetyProvisionPresent": isFireSafetyProvisionPresent.toString(),
      "IsPlotUnderLitigationStay": isPlotUnderLitigationStay.toString(),
      "IsConveyanceDeed": isConveyanceDeed.toString(),
      "Remarks": remark,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }
    var updateResult = await _projectLeadRepository
        .addUpdateProjectLeadRedevelopment(
          body: requestBody,
          fileList: fileList,
        );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getRedevelopmentList(context, 1);
      },
    );
  }

  Future updateRedevelopment({
    required BuildContext context,
    required int projectRedevelopmentId,
    required String uniquekey,
    required String buildingName,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required String pinCode,
    required String plotCTSSurveySubdivisionNumberC,
    required MultiFilePickerModel projectPhotoMap,
    required String buildingAddress,
    required String wardNumberZone,
    required String totalPlotAreaSqM,
    required String yearOfOriginalConstruction,
    required String existingBuildingType,
    required String numberOfExistingFloors,
    required String totalNumberExistingFlatsUnits,
    required String identificationLocation,
    required String latitudeLongitude,
    required String contactPersonName,
    required String contactPersonMobile,
    required String contactPersonEmail,
    required double percentageMemberInFavor,
    required String typeOfLandTenureType,
    required String plotShape,
    required String plotDepth,
    required String roadWidth,
    required String numberOfExistingBuildingWings,
    required String numberOfFloorPerWings,
    required String totalBuildUpArea,
    required String totalCarpetArea,
    required String totalCommonArea,
    required String constructionType,
    bool? isIsLiftAvailable,
    bool? isFireSafetyProvisionPresent,
    bool? isPlotUnderLitigationStay,
    bool? isConveyanceDeed,
    required String remark,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "ProjectRedevelopmentId": projectRedevelopmentId.toString(),
      "Uniquekey": uniquekey,
      "BuildingName": buildingName,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "PinCode": pinCode,
      "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber":
          plotCTSSurveySubdivisionNumberC,
      "BuildingAddress": buildingAddress,
      "WardNumberZone": wardNumberZone,
      "TotalPlotAreaSqM": totalPlotAreaSqM,
      "YearOfOriginalConstruction": yearOfOriginalConstruction,
      "ExistingBuildingType": existingBuildingType,
      "NumberOfExistingFloors": numberOfExistingFloors,
      "TotalNumberExistingFlatsUnits": totalNumberExistingFlatsUnits,
      "IdentificationLocation": identificationLocation,
      "LatitudeLongitude": latitudeLongitude,
      "ContactPersonName": contactPersonName,
      "ContactPersonMobile": contactPersonMobile,
      "ContactPersonEmail": contactPersonEmail,
      "PercentageMemberInFavor": percentageMemberInFavor.toString(),
      "TypeOfLandTenure": typeOfLandTenureType,
      "PlotShape": plotShape,
      "PlotDepth": plotDepth.toString(),
      "RoadWidth": roadWidth,
      "NumberOfExistingBuildingsWings": numberOfExistingBuildingWings,
      "NumberOfFloorsPerWing": numberOfFloorPerWings,
      "TotalBuildUpArea": totalBuildUpArea,
      "TotalCarpetArea": totalCarpetArea,
      "TotalCommonArea": totalCommonArea,
      "ConstructionType": constructionType,
      "IsLiftAvailable": isIsLiftAvailable.toString(),
      "IsFireSafetyProvisionPresent": isFireSafetyProvisionPresent.toString(),
      "IsPlotUnderLitigationStay": isPlotUnderLitigationStay.toString(),
      "IsConveyanceDeed": isConveyanceDeed.toString(),
      "Remarks": remark,
      "RemovePhotoURL": projectPhotoMap.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }
    var updateResult = await _projectLeadRepository
        .addUpdateProjectLeadRedevelopment(
          body: requestBody,
          fileList: fileList,
        );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        final newData = (response['data'] as List<RedevelopmentModel>?) ?? [];
        final updatedItem = newData.first;

        final updatedList = List<RedevelopmentModel>.from(
          state.redevelopmentList,
        );
        if (index >= 0 && index < updatedList.length) {
          updatedList[index] = updatedItem;
        }
        showSuccessMessage(context, subTitle: response["message"]);
        emit(state.copyWith(redevelopmentList: updatedList));
        goRouter.pop();
      },
    );
  }

  Future<void> deleteRedevelopment({
    required BuildContext context,
    required int projectRedevelopmentId,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _projectLeadRepository.deleteRedevelopment(
      projectRedevelopmentId: projectRedevelopmentId,
      uniquekey: uniquekey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
        await getRedevelopmentList(context, 1);
      },
    );
  }

  Future searchRedevlopment(
    BuildContext context,
    int pageNumber,
    String value,
  ) async {
    emit(state.copyWith(redevelopmentSearchText: value, redevelopmentList: []));
    await getRedevelopmentList(context, pageNumber);
  }

  Future applyRedevlopmentFilterAndSort({
    required BuildContext context,
    String? buildingName,
    String? buildingAddress,
    String? contactPersonName,
    String? contactPersonMobileNumber,
    String? pinCode,
    String? plotNumber,
    String? wardNumber,
    String? buildingType,
    String? constructionType,
    String? typeOfLandTenure,
    DateTime? filterByFromDate,
    DateTime? filterByToDate,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          redevelopmentSearchText: "",
          redevelopmentBuildingAddressText: "",
          redevelopmentContactPersonNameText: "",
          redevelopmentContactPersonMobileNumberText: "",
          redevelopmentPinCode: "",
          redevelopmentPlotNumberText: "",
          redevelopmentWardNumberZone: "",
          redevelopmentExistingBuildingType: "",
          redevelopmentConstructionType: "",
          redevelopmentTypeOfLandTenure: "",
          redevelopmentByFromDate: null,
          redevelopmentByToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          redevelopmentSearchText:
              buildingName ?? state.redevelopmentSearchText,
          redevelopmentBuildingAddressText:
              buildingAddress ?? state.redevelopmentBuildingAddressText,
          redevelopmentContactPersonNameText:
              contactPersonName ?? state.redevelopmentContactPersonNameText,
          redevelopmentContactPersonMobileNumberText:
              contactPersonMobileNumber ??
              state.redevelopmentContactPersonMobileNumberText,
          redevelopmentPinCode: pinCode ?? state.redevelopmentPinCode,
          redevelopmentPlotNumberText:
              plotNumber ?? state.redevelopmentPlotNumberText,
          redevelopmentWardNumberZone:
              wardNumber ?? state.redevelopmentWardNumberZone,
          redevelopmentExistingBuildingType:
              buildingType ?? state.redevelopmentExistingBuildingType,
          redevelopmentConstructionType:
              constructionType ?? state.redevelopmentConstructionType,
          redevelopmentTypeOfLandTenure:
              typeOfLandTenure ?? state.redevelopmentTypeOfLandTenure,
          redevelopmentByFromDate: filterByFromDate,
          redevelopmentByToDate: filterByToDate,
        ),
      );
    }
    await getRedevelopmentList(context, 1);
  }

  int updateRedevelopmentFilterCount(ProjectLeadState state) {
    return getActiveFilterCount([
      state.redevelopmentSearchText.trim().isNotEmpty,
      state.redevelopmentBuildingAddressText.trim().isNotEmpty,
      state.redevelopmentContactPersonNameText.trim().isNotEmpty,
      state.redevelopmentContactPersonMobileNumberText.trim().isNotEmpty,
      state.redevelopmentPinCode.trim().isNotEmpty,
      state.redevelopmentPlotNumberText.trim().isNotEmpty,
      state.redevelopmentWardNumberZone.trim().isNotEmpty,
      state.redevelopmentExistingBuildingType.trim().isNotEmpty,
      state.redevelopmentConstructionType.trim().isNotEmpty,
      state.redevelopmentTypeOfLandTenure.trim().isNotEmpty,
      state.redevelopmentByFromDate != null,
      state.redevelopmentByToDate != null,
    ]);
  }

  Future getLandList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      "LandOwnerName": state.landSearchText,
      "LandAddress": state.landAddress,
      "ContactPersonName": state.landContactPersonName,
      "ContactPersonMobile": state.landContactPersonMobileNumber,
      "PinCode": state.landPinCode,
      "PlotNumber": state.landPlotNumberText,
      "WardNumberZone": state.landWardNumberZone,
      "PlotShape": state.landPlotShape,
      "LandOwnershipType": state.landOwnershipType,
      "FromDate": state.landByFromDate.apiDate,
      "ToDate": state.landByToDate.apiDate,
    };
    var result = await _projectLeadRepository.getLandList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LandModel> newData = List<LandModel>.from(
          response['data'] ?? [],
        );

        final List<LandModel> updatedList =
            pageNumber == 1 ? newData : [...state.landList, ...newData];
        emit(
          state.copyWith(
            landList: updatedList,
            isLoading: false,
            landTotalNumberOfRecord: response["totalNumberOfRecord"],
            landCurrentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future updateLand({
    required BuildContext context,
    required int projectLandId,
    required String uniquekey,
    required String ownerName,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required String pinCode,
    required String plotCTSSurveySubdivisionNumberC,
    required String landAddress,
    required String wardNumberZone,
    required String totalPlotAreaSqM,
    required String identificationLocation,
    required String latitudeLongitude,
    required String contactPersonName,
    required String contactPersonMobile,
    required String contactPersonEmail,
    required String typeOfLandTenureType,
    required String plotShape,
    required String frontage,
    required String plotDepth,
    required String roadWidth,
    required String soilType,
    required String existingGroundCondition,
    bool? isAnyPowerOfAttorneyInvolved,
    bool? isFencingBoundaryWallPresent,
    bool? isLandConvertedToNonAgricultural,
    bool? isAccessRoadAvailable,
    bool? isElectricityConnectionNearby,
    bool? isUnderLitigationOrStayOrder,
    bool? is712Available,
    required String fsiPermissible,
    required String waterSupplyAvailable,
    String? surroundingLandUse,
    String? landOwnershipType,
    required String distanceFromNearestTownKM,
    required String distanceFromHighwayKM,
    required String distanceFromRailwayStationKM,
    required String distanceFromAirportKM,
    required String totalNumberOfTreesonSite,
    required String remark,
    required MultiFilePickerModel projectPhotoMap,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "ProjectLandId": projectLandId.toString(),
      "Uniquekey": uniquekey,
      "LandOwnerName": ownerName,
      "LandAddress": landAddress,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "PinCode": pinCode,
      "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber":
          plotCTSSurveySubdivisionNumberC,
      "WardNumberZone": wardNumberZone,
      "TotalPlotAreaSqM": totalPlotAreaSqM,
      "IdentificationLocation": identificationLocation,
      "LatitudeLongitude": latitudeLongitude,
      "ContactPersonName": contactPersonName,
      "ContactPersonMobile": contactPersonMobile,
      "ContactPersonEmail": contactPersonEmail,
      "TypeOfLandTenureType": typeOfLandTenureType,
      "PlotShape": plotShape,
      "Frontage": frontage,
      "PlotDepth": plotDepth,
      "RoadWidth": roadWidth,
      "SoilType": soilType,
      "ExistingGroundCondition": existingGroundCondition,
      "IsAnyPowerofAttorneyInvolved": isAnyPowerOfAttorneyInvolved.toString(),
      "IsFencingBoundaryWallPresent": isFencingBoundaryWallPresent.toString(),
      "IsLandConvertedToNonAgricultural":
          isLandConvertedToNonAgricultural.toString(),
      "IsAccessRoadAvailable": isAccessRoadAvailable.toString(),
      "IsElectricityConnectionNearby": isElectricityConnectionNearby.toString(),
      "IsUnderLitigationOrStayOrder": isUnderLitigationOrStayOrder.toString(),
      "Is712Available": is712Available.toString(),
      "FSIPermissible": fsiPermissible,
      "WaterSupplyAvailable": waterSupplyAvailable,
      "SurroundingLandUse": surroundingLandUse.toString(),
      "LandOwnershipType": landOwnershipType.toString(),
      "DistanceFromNearestTownKM": distanceFromNearestTownKM,
      "DistanceFromHighwayKM": distanceFromHighwayKM,
      "DistanceFromRailwayStationKM": distanceFromRailwayStationKM,
      "DistanceFromAirportKM": distanceFromAirportKM,
      "TotalNumberOfTreesonSite": totalNumberOfTreesonSite,
      "Remark": remark,
      "RemovePhotoURL": projectPhotoMap.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }
    var updateResult = await _projectLeadRepository.addUpdateProjectLand(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getLandList(context, 1);
      },
    );
  }

  Future addLand({
    required BuildContext context,
    required String ownerName,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required String pinCode,
    required String plotCTSSurveySubdivisionNumberC,
    required String landAddress,
    required String wardNumberZone,
    required String totalPlotAreaSqM,
    required String identificationLocation,
    required String latitudeLongitude,
    required String contactPersonName,
    required String contactPersonMobile,
    required String contactPersonEmail,
    required String typeOfLandTenureType,
    required String plotShape,
    required String frontage,
    required String plotDepth,
    required String roadWidth,
    required String soilType,
    required String existingGroundCondition,
    bool? isAnyPowerOfAttorneyInvolved,
    bool? isFencingBoundaryWallPresent,
    bool? isLandConvertedToNonAgricultural,
    bool? isAccessRoadAvailable,
    bool? isElectricityConnectionNearby,
    bool? isUnderLitigationOrStayOrder,
    bool? is712Available,
    required String fsiPermissible,
    required String waterSupplyAvailable,
    required String surroundingLandUse,
    required String landOwnershipType,
    required String distanceFromNearestTownKM,
    required String distanceFromHighwayKM,
    required String distanceFromRailwayStationKM,
    required String distanceFromAirportKM,
    required String totalNumberOfTreesonSite,
    required String remark,
    required MultiFilePickerModel projectPhotoMap,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "LandOwnerName": ownerName,
      "LandAddress": landAddress,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "PinCode": pinCode,
      "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber":
          plotCTSSurveySubdivisionNumberC,
      "WardNumberZone": wardNumberZone,
      "TotalPlotAreaSqM": _decimalValue(totalPlotAreaSqM),
      "IdentificationLocation": identificationLocation,
      "LatitudeLongitude": latitudeLongitude,
      "ContactPersonName": contactPersonName,
      "ContactPersonMobile": contactPersonMobile,
      "ContactPersonEmail": contactPersonEmail,
      "TypeOfLandTenureType": typeOfLandTenureType,
      "PlotShape": plotShape,
      "Frontage": _decimalValue(frontage),
      "PlotDepth": _decimalValue(plotDepth),
      "RoadWidth": roadWidth,
      "SoilType": soilType,
      "ExistingGroundCondition": existingGroundCondition,
      "IsAnyPowerofAttorneyInvolved": isAnyPowerOfAttorneyInvolved.toString(),
      "IsFencingBoundaryWallPresent": isFencingBoundaryWallPresent.toString(),
      "IsLandConvertedToNonAgricultural":
          isLandConvertedToNonAgricultural.toString(),
      "IsAccessRoadAvailable": isAccessRoadAvailable.toString(),
      "IsElectricityConnectionNearby": isElectricityConnectionNearby.toString(),
      "IsUnderLitigationOrStayOrder": isUnderLitigationOrStayOrder.toString(),
      "Is712Available": is712Available.toString(),
      "FSIPermissible": _decimalValue(fsiPermissible),
      "WaterSupplyAvailable": waterSupplyAvailable,
      "SurroundingLandUse": surroundingLandUse,
      "LandOwnershipType": landOwnershipType,
      "DistanceFromNearestTownKM": _decimalValue(distanceFromNearestTownKM),
      "DistanceFromHighwayKM": _decimalValue(distanceFromHighwayKM),
      "DistanceFromRailwayStationKM": _decimalValue(
        distanceFromRailwayStationKM,
      ),
      "DistanceFromAirportKM": _decimalValue(distanceFromAirportKM),
      "TotalNumberOfTreesonSite": _decimalValue(totalNumberOfTreesonSite),
      "Remark": remark,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }
    var updateResult = await _projectLeadRepository.addUpdateProjectLand(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getLandList(context, 1);
      },
    );
  }

  Future searchLand(BuildContext context, int pageNumber, String value) async {
    emit(state.copyWith(landSearchText: value, landList: []));
    await getLandList(context, pageNumber);
  }

  Future applyLandFilterAndSort({
    required BuildContext context,
    String? landOwnerName,
    String? landAddress,
    String? landContactPersonName,
    String? landContactPersonMobileNumber,
    String? landPinCode,
    String? landPlotNumber,
    String? landWardNumber,
    String? plotShape,
    String? ownershipType,
    DateTime? filterByLandFromDate,
    DateTime? filterByLandToDate,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          landSearchText: "",
          landAddress: "",
          landContactPersonName: "",
          landContactPersonMobileNumber: "",
          landPinCode: "",
          landPlotNumberText: "",
          landWardNumberZone: "",
          landPlotShape: "",
          landOwnershipType: "",
          landByFromDate: null,
          landByToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          landSearchText: landOwnerName ?? state.landSearchText,
          landAddress: landAddress ?? state.landAddress,
          landContactPersonName:
              landContactPersonName ?? state.landContactPersonName,
          landContactPersonMobileNumber:
              landContactPersonMobileNumber ??
              state.redevelopmentContactPersonMobileNumberText,
          landPinCode: landPinCode ?? state.landPinCode,
          landPlotNumberText: landPlotNumber ?? state.landPlotNumberText,
          landWardNumberZone: landWardNumber ?? state.landWardNumberZone,
          landPlotShape: plotShape ?? state.landPlotShape,
          landOwnershipType: ownershipType ?? state.landOwnershipType,
          landByFromDate: filterByLandFromDate,
          landByToDate: filterByLandToDate,
        ),
      );
    }
    await getLandList(context, 1);
  }

  int updateLandFilterCount(ProjectLeadState state) {
    return getActiveFilterCount([
      state.landSearchText.trim().isNotEmpty,
      state.landAddress.trim().isNotEmpty,
      state.landContactPersonName.trim().isNotEmpty,
      state.landContactPersonMobileNumber.trim().isNotEmpty,
      state.landPinCode.trim().isNotEmpty,
      state.landPlotNumberText.trim().isNotEmpty,
      state.landWardNumberZone.trim().isNotEmpty,
      state.landPlotShape.trim().isNotEmpty,
      state.landOwnershipType.trim().isNotEmpty,
      state.landByFromDate != null,
      state.landByToDate != null,
    ]);
  }

  Future<void> deleteLand({
    required BuildContext context,
    required int projectLandId,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _projectLeadRepository.deleteLand(
      projectLandId: projectLandId,
      uniquekey: uniquekey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
        await getLandList(context, 1);
      },
    );
  }

  Future exportRedevelopmentExcelPdf(
    BuildContext context,
    String exportType,
  ) async {
    if (state.redevelopmentTotalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectLeadRepository.exportRedevlopment(
      pageNumber: 1,
      pageSize: state.redevelopmentTotalNumberOfRecord,
      queryParams:
          state.redevelopmentSearchText != ""
              ? {
                "BuildingName": state.redevelopmentSearchText,
                "ExportType": exportType,
              }
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Project Redevelopment ${DateTime.now()}.pdf"
              : "Project Redevelopment ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportLandExcelPdf(BuildContext context, String exportType) async {
    if (state.landTotalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectLeadRepository.exportLand(
      pageNumber: 1,
      pageSize: state.redevelopmentTotalNumberOfRecord,
      queryParams:
          state.redevelopmentSearchText != ""
              ? {
                "LandOwnerName": state.landSearchText,
                "ExportType": exportType,
              }
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Project Land ${DateTime.now()}.pdf"
              : "Project Land ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  String _decimalValue(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return "0";
    }

    return trimmedValue;
  }
}
