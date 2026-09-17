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
    final Map<String, dynamic> queryParams = {};
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

  Future getLandList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {};
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
                "ApplicantName": state.redevelopmentSearchText,
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
}
