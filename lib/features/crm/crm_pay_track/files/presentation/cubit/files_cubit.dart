import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track_booking_files.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class FilesCubit extends Cubit<FilesState> {
  FilesCubit() : super(FilesState.initial());
  final PayTrackBookingFilesRepository _payTrackBookingFilesRepository =
      serviceLocator<PayTrackBookingFilesRepository>();

  Future searchFiles(
    BuildContext context,
    int projectId,
    int bookingId,
    String value,
    String fileType,
  ) async {
    emit(state.copyWith(searchText: value, payTrackBookingFileList: []));

    await getFilesList(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      bookingId: bookingId,
      fileType: fileType,
    );
  }

  Future resetSearch() async {
    emit(state.copyWith(searchText: ""));
  }

  Future getFilesList({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    required String fileType,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"FileName": state.searchText};

    var result = await _payTrackBookingFilesRepository
        .getPayTrackBookingFilesList(
          pageSize: 10,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          fileType: "FILES",
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },

      // (response) {
      //   emit(
      //     state.copyWith(
      //       payTrackBookingFileList:
      //           pageNumber == 1
      //               ? response['data'] as List<PayTrackBookingFilesModel>
      //               : [
      //                 ...state.payTrackBookingFileList,
      //                 ...(response['data'] as List<PayTrackBookingFilesModel>),
      //               ],
      //       totalNumberOfRecord: response['totalNumberOfRecord'],
      //       currentPage: pageNumber,
      //       isLoading: false,
      //     ),
      //   );
      // },
      (response) {
        debugPrint("FILES List Count = ${response['data'].length}");
        final List<PayTrackBookingFilesModel> newList =
            response['data'] as List<PayTrackBookingFilesModel>;

        final updatedList =
            pageNumber == 1
                ? newList
                : [...state.payTrackBookingFileList, ...newList];

        emit(
          state.copyWith(
            payTrackBookingFileList: updatedList,
            payTrackBookingFileModel: newList.isNotEmpty ? newList.first : null,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addPayTrackBookingFile({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required String fileName,
    required MultiFilePickerModel filePicker,
    required String fileType,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = <String, String>{
      'PayTrackBookingFilesId': '0',
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': fileType,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < filePicker.fileNameList.length; i++) {
      if (filePicker.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": filePicker.fileBytesList[i],
        "fileName": filePicker.fileNameList[i],
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

        await getFilesList(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          bookingId: bookingId,
          fileType: fileType,
        );
      },
    );
  }

  Future updatePayTrackBookingFile({
    required BuildContext context,
    required int payTrackBookingFilesId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
    required String fileName,
    required String fileType,
    required MultiFilePickerModel payTrackFiles,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'PayTrackBookingFilesId': payTrackBookingFilesId.toString(),
      'Uniquekey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': fileType,
      'RemovePayTrackBookingFilesURL': payTrackFiles.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < payTrackFiles.fileNameList.length; i++) {
      if (payTrackFiles.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": payTrackFiles.fileBytesList[i],
        "fileName": payTrackFiles.fileNameList[i],
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
          state.payTrackBookingFileList,
        );
        updatedList[index] = (response['data'][0] as PayTrackBookingFilesModel);
        emit(state.copyWith(payTrackBookingFileList: updatedList));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deletePayTrackBookingFilesBookingFile(
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
          state.payTrackBookingFileList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            payTrackBookingFileList: updatedList,
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
