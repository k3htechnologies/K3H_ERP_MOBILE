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
import 'package:k3h_erp_app/utils/common_function.dart';
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

  // <---- GET SINGLE ENQUIRY BY ID ---->
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

  Future<void> saveApplicantRequests(
    BuildContext context, {
    required int bookingId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    try {
      final pendingApplicants =
          state.bookingApplicantModificationRequestModel
              .where((e) => e.bookingApplicantModificationRequestId == 0)
              .toList();

      if (pendingApplicants.isEmpty) {
        goRouter.pop();

        showErrorMessage(context, "Error", "No applicant requests to save");
        return;
      }

      for (final applicant in pendingApplicants) {
        final Map<String, String> requestBody = {
          "BookingApplicantModificationRequestId":
              applicant.bookingApplicantModificationRequestId.toString(),

          "BookingId": bookingId.toString(),

          "ProjectId": projectId.toString(),

          "ApplicantType": applicant.applicantType,

          "ApplicantName": applicant.applicantName,

          "ApplicantMobileNumber": applicant.applicantMobileNumber,

          "ApplicantEmailId": applicant.applicantEmailId,

          "AadharCardNumber": applicant.aadharCardNumber,

          "PanNumber": applicant.panNumber,

          "PassportNumber": applicant.passportNumber,

          "DrivingLicenseNumber": applicant.drivingLicenseNumber,

          "VotingIdNumber": applicant.votingIdNumber,

          "GSTNumber": applicant.gstNumber,

          "ApprovalStatus": applicant.approvalStatus,

          "VersionNumber": applicant.versionNumber,
        };

        final result = await _requestManagementRepository
            .updateBookingApplicantModificationRequest(
              bookingId: bookingId,
              projectId: projectId,
              body: requestBody,
              fileList: [],
            );

        result.fold((failure) {
          throw Exception(failure.message);
        }, (_) {});
      }

      goRouter.pop();

      if (context.mounted) {
        showSuccessMessage(
          context,
          subTitle: "Applicant requests saved successfully",
        );
      }

      if (context.mounted) {
        await getBookingApplicantModificationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
      }
    } catch (e) {
      goRouter.pop();

      if (context.mounted) {
        showErrorMessage(context, "Error", e.toString());
      }
    }
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
    required String uniquekey,
    required int projectId,
    required int bookingId,
    required int inventoryFlatId,
    required String parkingId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "Uniquekey": uniquekey,
      "ProjectId": projectId.toString(),
      "InventoryFlatId": inventoryFlatId.toString(),
      "ParkingId": parkingId,
    };
    final List<Map<String, dynamic>> fileList = [];
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

        await getBookingById(context, 1, projectId, bookingId);
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

        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Refund payment added successfully",
        );
      },
    );
  }
}
