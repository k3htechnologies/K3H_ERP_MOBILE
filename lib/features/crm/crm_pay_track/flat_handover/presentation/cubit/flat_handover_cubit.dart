import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/cubit/flat_handover_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track_booking_files.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class FlatHandoverCubit extends Cubit<FlatHandoverState> {
  FlatHandoverCubit() : super(FlatHandoverState.initial());
  final PayTrackBookingFilesRepository _payTrackBookingFilesRepository =
      serviceLocator<PayTrackBookingFilesRepository>();

  Future searchFlatHandoverFiles(
    BuildContext context,
    int projectId,
    int bookingId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, flatHandoverFileList: []));
    await getFlatHandoverFilesList(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      bookingId: bookingId,
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchText: "", flatHandoverFileList: []));
  }

  Future getFlatHandoverFilesList({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int bookingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"FileName": state.searchText.trim()};

    var result = await _payTrackBookingFilesRepository
        .getPayTrackBookingFilesList(
          pageSize: 10,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          fileType: "FLAT HANDOVER",
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            flatHandoverFileList:
                response['data'] as List<PayTrackBookingFilesModel>,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addFlatHandoverFile({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required String fileName,
    required MultiFilePickerModel flatHandoverDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'PayTrackBookingFilesId': '0',
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': "FILES",
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < flatHandoverDocuments.fileNameList.length; i++) {
      if (flatHandoverDocuments.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": flatHandoverDocuments.fileBytesList[i],
        "fileName": flatHandoverDocuments.fileNameList[i],
      });
    }

    var result = await _payTrackBookingFilesRepository
        .addUpdatePayTrackBookingFilesBookingFiles(
          body: body,
          fileList: fileList,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) async {
        goRouter.pop();

        showSuccessMessage(context, subTitle: response['message']);
        getFlatHandoverFilesList(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          bookingId: bookingId,
        );
      },
    );
  }

  Future updateFlatHandoverFile({
    required BuildContext context,
    required int payTrackBookingFilesId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
    required String fileName,
    required MultiFilePickerModel flatHandoverDocuments,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'PayTrackBookingFilesId': payTrackBookingFilesId.toString(),
      'Uniquekey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': "FLAT HANDOVER",
      'RemovePayTrackBookingFilesURL': flatHandoverDocuments.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < flatHandoverDocuments.fileNameList.length; i++) {
      if (flatHandoverDocuments.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": flatHandoverDocuments.fileBytesList[i],
        "fileName": flatHandoverDocuments.fileNameList[i],
      });
    }

    var result = await _payTrackBookingFilesRepository
        .addUpdatePayTrackBookingFilesBookingFiles(
          body: body,
          fileList: fileList,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) async {
        goRouter.pop();
        final updatedList = List<PayTrackBookingFilesModel>.from(
          state.flatHandoverFileList,
        );
        updatedList[index] = (response['data'][0] as PayTrackBookingFilesModel);
        emit(state.copyWith(flatHandoverFileList: updatedList));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteFlatHandoverFile(
    int index,
    PayTrackBookingFilesModel payTrackBookingFilesModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _payTrackBookingFilesRepository
        .deletePayTrackBookingFilesBookingFiles(
          payTrackBookingFilesId:
              payTrackBookingFilesModel.payTrackBookingFilesId,
          uniqueKey: payTrackBookingFilesModel.uniquekey,
          projectId: payTrackBookingFilesModel.projectId,
          bookingId: payTrackBookingFilesModel.bookingId,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (response) {
        final updatedList = List<PayTrackBookingFilesModel>.from(
          state.flatHandoverFileList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            flatHandoverFileList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }
}
