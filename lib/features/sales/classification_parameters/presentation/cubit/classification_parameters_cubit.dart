import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/village.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/model/classification_paramerter.model.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/repository/classification_parameters.repositiory.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'classification_parameters_state.dart';

class ClassificationParametersCubit
    extends Cubit<ClassificationParametersState> {
  ClassificationParametersCubit()
    : super(ClassificationParametersState.initial());
  // REPOSITORY
  final ClassificationParametersRepository _classificationParametersRepository =
      serviceLocator<ClassificationParametersRepository>();

  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();

  // <---- GET CLASSIFICATION PARAMETERS LIST ---->
  Future getClassificationParametersList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {};
    var result = await _classificationParametersRepository
        .getClassificationParametersList(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ClassificationParameterModel> newData =
            List<ClassificationParameterModel>.from(response['data'] ?? []);
        final List<ClassificationParameterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.classificationParameterList, ...newData];

        emit(
          state.copyWith(
            classificationParameterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD CLASSIFICATION PARAMETER ---->
  Future addUpdateClassificationParameters({
    required BuildContext context,

    int? index,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _classificationParametersRepository
        .addUpdateClassificationParameter(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final newItem = response['data'][0] as ClassificationParameterModel;

        List<ClassificationParameterModel> updatedList = List.from(
          state.classificationParameterList,
        );

        if (index != null) {
          updatedList[index] = newItem;
        } else {
          getClassificationParametersList(context, 1, getProject().projectId);
        }

        emit(state.copyWith(classificationParameterList: updatedList));
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle:
              index != null
                  ? 'Classification Paramter Updated Successfully'
                  : 'Classification Paramter Added Successfully',
        );
      },
    );
  }

  // <---- DELETE CLASSIFICATION PARAMETERS ---->
  Future deleteClassificationParameters({
    required BuildContext context,
    required int classificationParameterId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _classificationParametersRepository
        .deleteClassificationParameters(
          classificationParameterId: classificationParameterId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Classification Parameter Deleted Successfully',
        );
        if (index != null) {
          final updatedList = List<ClassificationParameterModel>.from(
            state.classificationParameterList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              classificationParameterList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getClassificationParametersList(
            context,
            state.currentPage,
            projectId,
          );
        }
      },
    );
  }

  // FETCH VILLAGES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchVillages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _enquiryRepository.getVillageList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"VillageName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final villages = response['data'] as List<VillageModel>;

        return {
          "itemList":
              villages.map((village) {
                return {
                  "zAttributesId": village.villageMasterId,
                  "DisplayName": village.villageName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _classificationParametersRepository
        .exportClassificationParameters(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          projectId: projectId,
          queryParams:
              state.searchText != ""
                  ? {
                    "DepartmentName": state.searchText,
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
              ? "Classification Parameters ${DateTime.now()}.pdf"
              : "Classification Parameters ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
