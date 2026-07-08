import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/repository/loan_details.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track_booking_files.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class LoanDetailsCubit extends Cubit<LoanDetailsState> {
  LoanDetailsCubit() : super(LoanDetailsState.initial());
  final PayTrackBookingFilesRepository _payTrackBookingFilesRepository =
      serviceLocator<PayTrackBookingFilesRepository>();
  final BankLoanDetailsRepository _bankLoanDetailsRepository =
      serviceLocator<BankLoanDetailsRepository>();

  Future searchBankDocuments(
    BuildContext context,
    int projectId,
    int bookingId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, bankDocumentList: []));
    await getBankDocumentList(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      bookingId: bookingId,
    );
  }

  Future getBankLoanDetailsList(
    BuildContext context,
    int pageSize,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _bankLoanDetailsRepository.getBookingLoanDetailsList(
      pageSize: pageSize,
      pageNumber: pageNumber,
      projectId: projectId,
      bookingId: bookingId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<BookingLoanDetailsModel> list =
            List<BookingLoanDetailsModel>.from(response['data'] ?? []);

        emit(
          state.copyWith(
            isLoading: false,
            bankDetailsList: list,
            bankLoanDetails: list.isNotEmpty ? list.first : null,
          ),
        );
      },
    );
  }

  Future addBankLoanDetails({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required int bankListMasterId,
    required String loanSanctionAmount,
    required String loanSanctionDate,
    required String loanAccountNumber,
    required String bankBranchName,
    required String address,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "BookingLoanDetailsId": 0,
      "ProjectId": projectId,
      "BookingId": bookingId,
      "LoanSanctionAmount": loanSanctionAmount,
      "LoanSanctionDate": loanSanctionDate,
      "BankListMasterId": bankListMasterId,
      "LoanAccountNumber": loanAccountNumber,
      "BankBranchName": bankBranchName,
      "Address": address,
    };

    var addResult = await _bankLoanDetailsRepository
        .addUpdateBookingLoanDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        emit(state.copyWith(isLoading: false));
        return;
      },
      (response) async {
        emit(
          state.copyWith(
            bankLoanDetails: response['data'][0],
            isLoading: false,
          ),
        );

        await getBankLoanDetailsList(context, 50, 1, projectId, bookingId);
        goRouter.pop();
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response['message']);
        }
      },
    );
  }

  Future updateBankLoanDetails({
    required BuildContext context,
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
    required String loanSanctionAmount,
    required String loanSanctionDate,
    required int bankListMasterId,
    required String loanAccountNumber,
    required String bankBranchName,
    required String address,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "BookingLoanDetailsId": bookingLoanDetailsId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "BookingId": bookingId,
      "LoanSanctionAmount": loanSanctionAmount,
      "LoanSanctionDate": loanSanctionDate,
      "BankListMasterId": bankListMasterId,
      "LoanAccountNumber": loanAccountNumber,
      "BankBranchName": bankBranchName,
      "Address": address,
    };

    var addResult = await _bankLoanDetailsRepository
        .addUpdateBookingLoanDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        emit(state.copyWith(isLoading: false));
        return;
      },
      (response) {
        emit(
          state.copyWith(
            bankLoanDetails: response['data'][0],
            isLoading: false,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteBankDetails(
    int index,
    int bookingLoanDetailsId,
    String uniquekey,
    int projectId,
    int bookingId,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _bankLoanDetailsRepository.deleteBookingLoanDetails(
      bookingLoanDetailsId: bookingLoanDetailsId,
      uniqueKey: uniquekey,
      projectId: projectId,
      bookingId: bookingId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (response) {
        final updatedList = List<BookingLoanDetailsModel>.from(
          state.bankDetailsList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            bankDetailsList: updatedList,
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

  Future<void> addOrUpdateBankLoan({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required Map<String, dynamic> selectedBank,
    required String address,
    required String branchName,
    required String accountNumber,
    required DateTime sanctionDate,
    required String sanctionAmount,
    required int index,
  }) async {
    if (state.bankLoanDetails != null) {
      // UPDATE
      await updateBankLoanDetails(
        context: context,
        bookingLoanDetailsId: state.bankLoanDetails!.bookingLoanDetailsId,
        uniqueKey: state.bankLoanDetails!.uniquekey,
        projectId: projectId,
        bookingId: bookingId,
        bankListMasterId: selectedBank["zAttributesId"],
        loanSanctionAmount: sanctionAmount,
        address: address,
        bankBranchName: branchName,
        loanSanctionDate: sanctionDate.toIso8601String(),
        loanAccountNumber: accountNumber,
        index: index,
      );
    } else {
      // ADD
      await addBankLoanDetails(
        context: context,
        projectId: projectId,
        bookingId: bookingId,
        bankListMasterId: selectedBank["zAttributesId"],
        address: address,
        bankBranchName: branchName,
        loanAccountNumber: accountNumber,
        loanSanctionDate: sanctionDate.toIso8601String(),
        loanSanctionAmount: sanctionAmount,
      );
    }
  }

  Future getBankDocumentList({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    int? bookingLoanDetailsId,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "ApplicantName": state.searchText,
      "BookingLoanDetailsId": bookingLoanDetailsId,
    };

    var result = await _payTrackBookingFilesRepository
        .getPayTrackBookingFilesList(
          pageSize: 10,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          fileType: "BANK DOCUMENT",
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        if (bookingLoanDetailsId == null) return;

        final updatedMap = Map<int, List<PayTrackBookingFilesModel>>.from(
          state.bankDocumentMap,
        );
        updatedMap[bookingLoanDetailsId] =
            response['data'] as List<PayTrackBookingFilesModel>;

        emit(
          state.copyWith(
            bankDocumentMap: updatedMap,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addBankDocument({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required String fileName,
    required MultiFilePickerModel bankDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'PayTrackBookingFilesId': '0',
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': "BANK DOCUMENT",
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < bankDocuments.fileNameList.length; i++) {
      if (bankDocuments.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": bankDocuments.fileBytesList[i],
        "fileName": bankDocuments.fileNameList[i],
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

        await getBankDocumentList(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          bookingId: bookingId,
          bookingLoanDetailsId: state.bankLoanDetails?.bookingLoanDetailsId,
        );

        if (context.mounted) {
          await getBankLoanDetailsList(context, 10, 1, projectId, bookingId);
        }
      },
    );
  }

  Future updateBankDocument({
    required BuildContext context,
    required int payTrackBookingFilesId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
    required String fileName,
    required MultiFilePickerModel bankDocuments,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'PayTrackBookingFilesId': payTrackBookingFilesId.toString(),
      'Uniquekey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BookingId': bookingId.toString(),
      'FileName': fileName,
      'FileType': "BANK DOCUMENT",
      'RemovePayTrackBookingFilesURL': bankDocuments.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < bankDocuments.fileNameList.length; i++) {
      if (bankDocuments.fileNameList[i].contains("http")) {
        continue; // Skip already uploaded files
      }
      fileList.add({
        "key": "PayTrackBookingFilesURL",
        "value": bankDocuments.fileBytesList[i],
        "fileName": bankDocuments.fileNameList[i],
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
          state.bankDocumentList,
        );
        updatedList[index] = (response['data'][0] as PayTrackBookingFilesModel);
        emit(state.copyWith(bankDocumentList: updatedList));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteBankDocument(
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
          state.bankDocumentList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            bankDocumentList: updatedList,
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

  Future closeAccount({
    required BuildContext context,
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "BookingLoanDetailsId": bookingLoanDetailsId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "BookingId": bookingId,
    };

    var addResult = await _bankLoanDetailsRepository
        .updateBookingLoanDetailsStatus(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        emit(state.copyWith(isLoading: false));
        return;
      },
      (response) async {
        goRouter.pop();
        emit(
          state.copyWith(
            bankLoanDetails: response['data'][0],
            isLoading: false,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
        await getBankDocumentList(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          bookingId: bookingId,
          bookingLoanDetailsId: state.bankLoanDetails?.bookingLoanDetailsId,
        );

        if (context.mounted) {
          await getBankLoanDetailsList(context, 10, 1, projectId, bookingId);
        }
      },
    );
  }
}
