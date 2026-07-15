import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/refund_amount_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/repository/request_management.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'request_management_state.dart';

class RequestManagementCubit extends Cubit<RequestManagementState> {
  RequestManagementCubit() : super(RequestManagementState.initial());

  // REPOSITORIES
  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();
  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();
  final RequestManagementRepository _requestManagementRepository =
      serviceLocator<RequestManagementRepository>();

  //  GET BOOKING BY ID LIST
  Future<BookingModel?> getBookingById(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"BookingId": bookingId};

    final result = await _bookingRepository.getBookingList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return null;
      },
      (response) {
        final List<BookingModel> list = List<BookingModel>.from(
          response['data'] ?? [],
        );

        final booking = list.isNotEmpty ? list.first : null;

        emit(
          state.copyWith(
            isLoading: false,
            bookingData: booking,
            showRefundPaymentLedgerTab:
                booking?.approvalStatus.trim().toUpperCase() == "REFUND",
          ),
        );

        return booking;
      },
    );
  }

  // GET SINGLE ENQUIRY BY ID
  Future<void> getEnquiryById({
    required int enquiryId,
    required int projectId,
  }) async {
    emit(state.copyWith(isFetchingEnquiryDetails: true));

    final queryParams = {"EnquiryId": enquiryId};

    final result = await _enquiryRepository.getEnquiryList(
      pageNumber: 1,
      pageSize: 1,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isFetchingEnquiryDetails: false,
            currentEnquiryDetails: null,
          ),
        );
      },
      (response) {
        /// IMPORTANT: Repository already returns List<EnquiryModel>
        final List<EnquiryModel> dataList =
            (response['data'] as List?)?.cast<EnquiryModel>() ?? [];

        if (dataList.isNotEmpty) {
          final updatedEnquiry = dataList.first;

          emit(
            state.copyWith(
              currentEnquiryDetails: updatedEnquiry,
              isFetchingEnquiryDetails: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isFetchingEnquiryDetails: false,
              currentEnquiryDetails: null,
            ),
          );
        }
      },
    );
  }

  Future cancelBooking(
    BuildContext context, {
    required String uniquekey,
    required int projectId,
    required int bookingId,
    required int inventoryFlatId,
    required String parkingId,
    required String cancelRemark,
    required MultiFilePickerModel proofDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "CancelRemark": cancelRemark,
      "InventoryFlatId": inventoryFlatId.toString(),
      "ParkingId": parkingId,
      "Uniquekey": uniquekey,
      "RemoveProofOfDocumentURL": proofDocument.deletedFileList,
    };
    final List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < proofDocument.fileNameList.length; i++) {
      if (proofDocument.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ProofOfDocumentURL",
        "value": proofDocument.fileBytesList[i],
        "fileName": proofDocument.fileNameList[i],
      });
    }

    var result = await _bookingRepository.cancelBooking(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Booking cancelled successfully",
        );
        goRouter.pop();

        await getBookingById(context, 1, projectId, bookingId);
      },
    );
  }

  Future getParkingModificationRequestList(
    BuildContext context,
    int pageSize,
    int pageNumber,
    int bookingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _requestManagementRepository
        .getParkingModificationRequestList(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: {"TabName": "REQUESTS"},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        // Always replace list to avoid duplicates on mobile refresh/approval
        final updatedList =
            response['data'] as List<ParkingModificationRequestModel>;
        emit(
          state.copyWith(
            isLoading: false,
            parkingModificationRequestList: updatedList,
          ),
        );
      },
    );
  }

  Future deleteBookingApplicantModificationRequest({
    required BuildContext context,
    required BookingApplicantModificationRequestModel model,
    required int bookingId,
    required int projectId,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final deleteResult = await _requestManagementRepository
        .deleteBookingApplicantModificationRequest(
          projectId: projectId,
          bookingApplicantModificationRequestId:
              model.bookingApplicantModificationRequestId,
          bookingId: bookingId,
        );

    goRouter.pop();

    deleteResult.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Applicant deleted successfully");

        final updatedList = List<BookingApplicantModificationRequestModel>.from(
          state.bookingApplicantModificationRequestModel,
        );

        updatedList.removeAt(index);

        emit(
          state.copyWith(bookingApplicantModificationRequestModel: updatedList),
        );
        getBookingApplicantModificationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
      },
    );
  }

  Future getFlatAlterationRequestList(
    BuildContext context,
    int pageSize,
    int pageNumber,
    int bookingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _requestManagementRepository
        .getFlatAlterationRequestList(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: {"TabName": "REQUESTS"},
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedList =
            response['data'] as List<FlatAlterationRequestsModel>;
        emit(
          state.copyWith(
            isLoading: false,
            flatAlterationRequestsModel: updatedList,
          ),
        );
      },
    );
  }

  void addApplicantLocally(BookingApplicantModificationRequestModel applicant) {
    final list = List<BookingApplicantModificationRequestModel>.from(
      state.bookingApplicantModificationRequestModel,
    );

    list.add(applicant);

    emit(state.copyWith(bookingApplicantModificationRequestModel: list));
  }

  Future initiateRefund(
    BuildContext context, {
    required String uniquekey,
    required int projectId,
    required int bookingId,
    required String totalRefundAmountAgainstBooking,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "BookingId": bookingId,
      "Uniquekey": uniquekey,
      "ProjectId": projectId,
      "TotalAmountRefundedAgainstBooking": totalRefundAmountAgainstBooking,
    };
    var result = await _requestManagementRepository
        .addAmountRefundedAgainstBookingAddUpdateRefundedAmount(
          body: requestBody,
        );
    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(
          context,
          subTitle:
              response['message'] ?? "Refund Amount Initiated successfully",
        );

        await getBookingById(context, 1, projectId, bookingId);
        emit(state.copyWith(showRefundPaymentLedgerTab: true));
      },
    );
  }

  Future updateBookingApplicantModificationRequest(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required MultiFilePickerModel panCardPhoto,
    required MultiFilePickerModel aadharCardPhoto,
    required MultiFilePickerModel votingCardPhoto,
    required MultiFilePickerModel poaCardPhoto,
    required MultiFilePickerModel paymentProofPhoto,
    required MultiFilePickerModel nreNroBankDetailsPhoto,
    required MultiFilePickerModel drivingLicensePhoto,
    required MultiFilePickerModel proofOfDocumentPhoto,
    required MultiFilePickerModel statementOfSourceOfFundsPhoto,
    required MultiFilePickerModel incomeForm16ITRPhoto,
    required MultiFilePickerModel nomineeFormPhoto,
    required MultiFilePickerModel cancelledChequePhoto,
    required MultiFilePickerModel photoPhoto,
    required MultiFilePickerModel passportPhoto,
    required MultiFilePickerModel gstNumberPhoto,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
    };
    final List<Map<String, dynamic>> fileList = [];
    for (
      int applicantIndex = 0;
      applicantIndex < state.bookingApplicantModificationRequestModel.length;
      applicantIndex++
    ) {
      final e = state.bookingApplicantModificationRequestModel[applicantIndex];

      requestBody.addAll({
        "bookingApplicantModificationRequests[$applicantIndex].BookingApplicantModificationRequestId":
            e.bookingApplicantModificationRequestId.toString(),

        "bookingApplicantModificationRequests[$applicantIndex].ApplicantType":
            e.applicantType,

        "bookingApplicantModificationRequests[$applicantIndex].ApplicantName":
            e.applicantName,

        "bookingApplicantModificationRequests[$applicantIndex].ApplicantMobileNumberCountryCode":
            "+91",

        "bookingApplicantModificationRequests[$applicantIndex].ApplicantMobileNumber":
            e.applicantMobileNumber,

        "bookingApplicantModificationRequests[$applicantIndex].ApplicantEmailId":
            e.applicantEmailId,

        "bookingApplicantModificationRequests[$applicantIndex].AadharCardNumber":
            e.aadharCardNumber,

        "bookingApplicantModificationRequests[$applicantIndex].PanNumber":
            e.panNumber,

        "bookingApplicantModificationRequests[$applicantIndex].PassportNumber":
            e.passportNumber,

        "bookingApplicantModificationRequests[$applicantIndex].DrivingLicenseNumber":
            e.drivingLicenseNumber,

        "bookingApplicantModificationRequests[$applicantIndex].VotingIdNumber":
            e.votingIdNumber,

        "bookingApplicantModificationRequests[$applicantIndex].GSTNumber":
            e.gstNumber,

        // Remove fields
        "bookingApplicantModificationRequests[$applicantIndex].RemovePhotoURL":
            photoPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveAadharCardURL":
            aadharCardPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePanCardURL":
            panCardPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePassportURL":
            passportPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveDrivingLicenseURL":
            drivingLicensePhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveVotingIdURL":
            votingCardPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveGSTNumberURL":
            gstNumberPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveCancelledChequeURL":
            cancelledChequePhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePOAURL":
            poaCardPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveIncomeForm16ITRURL":
            incomeForm16ITRPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveNreNroBankDetailsURL":
            nreNroBankDetailsPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveNomineeFormURL":
            nomineeFormPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveStatementOfSourceOfFundsURL":
            statementOfSourceOfFundsPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePaymentProofURL":
            paymentProofPhoto.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveProofOfDocumentURL":
            proofOfDocumentPhoto.deletedFileList,
      });

      for (int i = 0; i < panCardPhoto.fileNameList.length; i++) {
        if (panCardPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].PanCardURL",
          "value": panCardPhoto.fileBytesList[i],
          "fileName": panCardPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < aadharCardPhoto.fileNameList.length; i++) {
        if (aadharCardPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].AadharCardURL",
          "value": aadharCardPhoto.fileBytesList[i],
          "fileName": aadharCardPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < votingCardPhoto.fileNameList.length; i++) {
        if (votingCardPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].VotingIdURL",
          "value": votingCardPhoto.fileBytesList[i],
          "fileName": votingCardPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < poaCardPhoto.fileNameList.length; i++) {
        if (poaCardPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key": "bookingApplicantModificationRequests[$applicantIndex].POAURL",
          "value": poaCardPhoto.fileBytesList[i],
          "fileName": poaCardPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < paymentProofPhoto.fileNameList.length; i++) {
        if (paymentProofPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].PaymentProofURL",
          "value": paymentProofPhoto.fileBytesList[i],
          "fileName": paymentProofPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < nreNroBankDetailsPhoto.fileNameList.length; i++) {
        if (nreNroBankDetailsPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].NreNroBankDetailsURL",
          "value": nreNroBankDetailsPhoto.fileBytesList[i],
          "fileName": nreNroBankDetailsPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < drivingLicensePhoto.fileNameList.length; i++) {
        if (drivingLicensePhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].DrivingLicenseURL",
          "value": drivingLicensePhoto.fileBytesList[i],
          "fileName": drivingLicensePhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < proofOfDocumentPhoto.fileNameList.length; i++) {
        if (proofOfDocumentPhoto.fileNameList[i].contains("http")) continue;

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].ProofOfDocumentURL",
          "value": proofOfDocumentPhoto.fileBytesList[i],
          "fileName": proofOfDocumentPhoto.fileNameList[i],
        });
      }
      for (
        int i = 0;
        i < statementOfSourceOfFundsPhoto.fileNameList.length;
        i++
      ) {
        if (statementOfSourceOfFundsPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].StatementOfSourceOfFundsURL",
          "value": statementOfSourceOfFundsPhoto.fileBytesList[i],
          "fileName": statementOfSourceOfFundsPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < incomeForm16ITRPhoto.fileNameList.length; i++) {
        if (incomeForm16ITRPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].IncomeForm16ITRURL",
          "value": incomeForm16ITRPhoto.fileBytesList[i],
          "fileName": incomeForm16ITRPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < nomineeFormPhoto.fileNameList.length; i++) {
        if (nomineeFormPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].NomineeFormURL",
          "value": nomineeFormPhoto.fileBytesList[i],
          "fileName": nomineeFormPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < cancelledChequePhoto.fileNameList.length; i++) {
        if (cancelledChequePhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].CancelledChequeURL",
          "value": cancelledChequePhoto.fileBytesList[i],
          "fileName": cancelledChequePhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < photoPhoto.fileNameList.length; i++) {
        if (photoPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].PhotoURL",
          "value": photoPhoto.fileBytesList[i],
          "fileName": photoPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < passportPhoto.fileNameList.length; i++) {
        if (passportPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].PassportURL",
          "value": passportPhoto.fileBytesList[i],
          "fileName": passportPhoto.fileNameList[i],
        });
      }
      for (int i = 0; i < gstNumberPhoto.fileNameList.length; i++) {
        if (gstNumberPhoto.fileNameList[i].contains("http")) {
          continue;
        }

        fileList.add({
          "key":
              "bookingApplicantModificationRequests[$applicantIndex].GSTNumberURL",
          "value": gstNumberPhoto.fileBytesList[i],
          "fileName": gstNumberPhoto.fileNameList[i],
        });
      }
    }

    var result = await _requestManagementRepository
        .updateBookingApplicantModificationRequest(
          bookingId: bookingId,
          projectId: projectId,
          body: requestBody,
          fileList: fileList,
        );
    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Booking cancelled successfully",
        );

        await getBookingApplicantModificationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
      },
    );
  }

  Future getBookingApplicantModificationRequestList(
    BuildContext context,
    int pageSize,
    int pageNumber,
    int bookingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _requestManagementRepository
        .getBookingApplicantModificationRequestList(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: {"TabName": "REQUESTS"},
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedList =
            response['data'] as List<BookingApplicantModificationRequestModel>;
        emit(
          state.copyWith(
            isLoading: false,
            bookingApplicantModificationRequestModel: updatedList,
          ),
        );
      },
    );
  }

  Future addParkingModificationRequest(
    BuildContext context, {
    required int bookingId,
    required int projectId,
    required String parkingId,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "ParkingModificationRequestId": 0,
      "BookingId": bookingId,
      "ProjectId": projectId,
      "ParkingId": parkingId,
      "Uniquekey": uniquekey,
    };
    final result = await _requestManagementRepository
        .addUpdateParkingModificationRequest(body: requestBody);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(
          context,
          subTitle:
              response['message'] ??
              "Parking modification request added successfully",
        );

        goRouter.pop();

        await getParkingModificationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
      },
    );
  }

  Future addFlatAlterationRequest({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required String uniquekey,
    required String flatAlterationRemark,
    required MultiFilePickerModel proofDocumentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "FlatAlterationRequestId": 0.toString(),
      "UniqueKey": uniquekey,
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "FlatAlterationRemark": flatAlterationRemark,
      "ApprovalStatus": "",
      "VersionNumber": "",
    };

    var addResult = await _requestManagementRepository.addFlatAlterationRequest(
      body: requestBody,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);

        emit(state.copyWith(isLoading: false));

        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: "Request done successfully");
        await getFlatAlterationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
        goRouter.pop();
      },
    );
  }

  Future getRefundAmountPaymentLedger(
    BuildContext context,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _requestManagementRepository.getRefundedAmountLedgerList(
      bookingId: bookingId,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            refundAmountLedgerList: response['data'],
          ),
        );
      },
    );
  }

  Future refundAmountPaymentLedger({
    required BuildContext context,
    required int refundedAmountLedgerId,
    required String uniquekey,
    required int bookingId,
    required int projectId,
    required String paymentMode,
    required String projectBankListMasterId,
    required String accountHolderName,
    required String bankListMasterId,
    required String accountNumber,
    required String ifscCode,
    required String refundedAmount,
    required String transactionChequeDemandDraftNumber,
    required String transactionChequeDemandDraftDate,
    required MultiFilePickerModel chequeFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "RefundedAmountLedgerId": refundedAmountLedgerId.toString(),
      "Uniquekey": uniquekey,
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "PaymentMode": paymentMode,
      "ProjectBankListMasterId": projectBankListMasterId,
      "AccountHolderName": accountHolderName,
      "BankListMasterId": bankListMasterId,
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "RefundedAmount": refundedAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate": transactionChequeDemandDraftDate,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < chequeFile.fileNameList.length; i++) {
      if (chequeFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "TransactionChequeDemandDraftURL",
        "value": chequeFile.fileBytesList[i],
        "fileName": chequeFile.fileNameList[i],
      });
    }

    var addResult = await _requestManagementRepository
        .addUpdateRefundedAmountLedger(body: requestBody, fileList: fileList);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        getRefundAmountPaymentLedger(context, projectId, bookingId);
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Refund payment added successfully",
        );
      },
    );
  }

  Future deleteRefundedAmountLedger({
    required BuildContext context,
    required RefundedAmountLedgerModel refundModel,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _requestManagementRepository
        .deleteRefundedAmountLedger(
          projectId: refundModel.projectId,
          refundedAmountLedgerId: refundModel.refundedAmountLedgerId,
          bookingId: refundModel.bookingId,
          uniqueKey: refundModel.uniquekey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: 'Invoice Deleted Successfully');
        final updatedList = List<RefundedAmountLedgerModel>.from(
          state.refundAmountLedgerList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            refundAmountLedgerList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
      },
    );
  }
}
