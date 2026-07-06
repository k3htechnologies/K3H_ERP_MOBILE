import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/repository/resignation.repository.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:bloc/bloc.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ResignationCubit extends Cubit<ResignationState> {
  ResignationCubit() : super(ResignationState.initial());

  //REPOSITORY
  final ResignationRepository _resignationRepository =
      serviceLocator<ResignationRepository>();

  // GET RESIGNATION LIST
  Future getResignationList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    var result = await _resignationRepository.getResignationList(
      pageNumber: pageNumber,
      pageSize: 10,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ResignationModel> newData = List<ResignationModel>.from(
          response['data'] ?? [],
        );

        final List<ResignationModel> updatedList =
            pageNumber == 1 ? newData : [...state.resignationList, ...newData];
        emit(
          state.copyWith(
            resignationList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future deleteResignation({
    required BuildContext context,
    required int resignationId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _resignationRepository.deleteResignation(
      resignationId: resignationId,
      uniqueKey: uniqueKey,
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
          subTitle: 'Resignation Deleted Successfully!!!',
        );
        if (index != null) {
          final updatedList = List<ResignationModel>.from(
            state.resignationList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              resignationList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getResignationList(context, state.currentPage);
        }
      },
    );
  }

  Future<void> addResignation({
    required BuildContext context,
    required String employeeId,
    required String resignationDate,
    required String expectedRelievingDate,
    required String reasonOfLeaving,
    required bool isAnyOfferInHand,
    required String offerAmount,
    required MultiFilePickerModel offerLetter,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "EmployeeResignationId": 0.toString(),
      "EmployeeId": employeeId,
      "ResignationDate": resignationDate,
      "ExpectedRelievingDate": expectedRelievingDate,
      "ReasonOfLeaving": reasonOfLeaving,
      "IsAnyOfferInHand": isAnyOfferInHand.toString(),
      "OfferAmount": offerAmount,
      "RemoveOfferLetterURL": offerLetter.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < offerLetter.fileNameList.length; i++) {
      if (offerLetter.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "OfferLetterURL",
        "value": offerLetter.fileBytesList[i],
        "fileName": offerLetter.fileNameList[i],
      });
    }
    var addResult = await _resignationRepository.addUpdateResignation(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Resignation added successfully");
        goRouter.pop();
        getResignationList(context, 1);
      },
    );
  }

  Future<void> updateLeave({
    required int index,
    required BuildContext context,
    required String employeeResignationId,
    required String uniquekey,
    required String employeeId,
    required String resignationDate,
    required String expectedRelievingDate,
    required String reasonOfLeaving,
    required bool isAnyOfferInHand,
    required String offerAmount,
    required MultiFilePickerModel offerLetter,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "EmployeeResignationId": employeeResignationId,
      "Uniquekey": uniquekey,
      "EmployeeId": employeeId,
      "ResignationDate": resignationDate,
      "ExpectedRelievingDate": expectedRelievingDate,
      "ReasonOfLeaving": reasonOfLeaving,
      "IsAnyOfferInHand": isAnyOfferInHand.toString(),
      "OfferAmount": offerAmount,
      "RemoveOfferLetterURL": offerLetter.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < offerLetter.fileNameList.length; i++) {
      if (offerLetter.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "OfferLetterURL",
        "value": offerLetter.fileBytesList[i],
        "fileName": offerLetter.fileNameList[i],
      });
    }
    var addResult = await _resignationRepository.addUpdateResignation(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedLeave = response['data'][0] as ResignationModel;

        if (state.resignationList.isNotEmpty &&
            index < state.resignationList.length) {
          final updatedList = List<ResignationModel>.from(
            state.resignationList,
          );
          updatedList[index] = updatedLeave;
          emit(state.copyWith(resignationList: updatedList, isLoading: false));
        }
        showSuccessMessage(
          context,
          subTitle: "Resignation updated successfully",
        );
      },
    );
  }
}
