import 'dart:typed_data';

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

    Map<String, dynamic> queryParams = {
      "BookingId": bookingId,
      "IsCheckPermission": false,
    };

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
        goRouter.pop(true);
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

        getBookingApplicantModificationRequestList(
          context,
          10,
          1,
          bookingId,
          projectId,
        );
        emit(
          state.copyWith(
            bookingApplicantModificationRequestModel: updatedList,
            hasUnsavedApplicantChanges: true,
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

    emit(
      state.copyWith(
        bookingApplicantModificationRequestModel: list,
        hasUnsavedApplicantChanges: true,
      ),
    );
  }

  void updateApplicantLocally(
    int index,
    BookingApplicantModificationRequestModel applicant,
  ) {
    final list = List<BookingApplicantModificationRequestModel>.from(
      state.bookingApplicantModificationRequestModel,
    );

    final oldApplicant = list[index];
    if (applicant.aadhaarFile.fileBytesList.isEmpty &&
        oldApplicant.aadhaarFile.fileBytesList.isNotEmpty &&
        applicant.aadhaarFile.fileNameList.isNotEmpty) {
      applicant.aadhaarFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.aadhaarFile.fileBytesList,
      );
    }

    if (applicant.panFile.fileBytesList.isEmpty &&
        oldApplicant.panFile.fileBytesList.isNotEmpty &&
        applicant.panFile.fileNameList.isNotEmpty) {
      applicant.panFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.panFile.fileBytesList,
      );
    }

    if (applicant.photoFile.fileBytesList.isEmpty &&
        oldApplicant.photoFile.fileBytesList.isNotEmpty &&
        applicant.photoFile.fileNameList.isNotEmpty) {
      applicant.photoFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.photoFile.fileBytesList,
      );
    }
    if (applicant.proofOfDocumentFile.fileBytesList.isEmpty &&
        oldApplicant.proofOfDocumentFile.fileBytesList.isNotEmpty &&
        applicant.proofOfDocumentFile.fileNameList.isNotEmpty) {
      applicant.proofOfDocumentFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.proofOfDocumentFile.fileBytesList,
      );
    }

    if (applicant.passportFile.fileBytesList.isEmpty &&
        oldApplicant.passportFile.fileBytesList.isNotEmpty &&
        applicant.passportFile.fileNameList.isNotEmpty) {
      applicant.passportFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.passportFile.fileBytesList,
      );
    }
    if (applicant.drivingLicenseFile.fileBytesList.isEmpty &&
        oldApplicant.drivingLicenseFile.fileBytesList.isNotEmpty &&
        applicant.drivingLicenseFile.fileNameList.isNotEmpty) {
      applicant.drivingLicenseFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.drivingLicenseFile.fileBytesList,
      );
    }
    if (applicant.drivingLicenseFile.fileBytesList.isEmpty &&
        oldApplicant.drivingLicenseFile.fileBytesList.isNotEmpty &&
        applicant.drivingLicenseFile.fileNameList.isNotEmpty) {
      applicant.drivingLicenseFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.drivingLicenseFile.fileBytesList,
      );
    }
    if (applicant.votingIdFile.fileBytesList.isEmpty &&
        oldApplicant.votingIdFile.fileBytesList.isNotEmpty &&
        applicant.votingIdFile.fileNameList.isNotEmpty) {
      applicant.votingIdFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.votingIdFile.fileBytesList,
      );
    }
    if (applicant.gstFile.fileBytesList.isEmpty &&
        oldApplicant.gstFile.fileBytesList.isNotEmpty &&
        applicant.gstFile.fileNameList.isNotEmpty) {
      applicant.gstFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.gstFile.fileBytesList,
      );
    }
    if (applicant.poaFile.fileBytesList.isEmpty &&
        oldApplicant.poaFile.fileBytesList.isNotEmpty &&
        applicant.poaFile.fileNameList.isNotEmpty) {
      applicant.poaFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.poaFile.fileBytesList,
      );
    }
    if (applicant.nreNroBankDetailsFile.fileBytesList.isEmpty &&
        oldApplicant.nreNroBankDetailsFile.fileBytesList.isNotEmpty &&
        applicant.nreNroBankDetailsFile.fileNameList.isNotEmpty) {
      applicant.nreNroBankDetailsFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.nreNroBankDetailsFile.fileBytesList,
      );
    }
    if (applicant.statementOfSourceOfFundFile.fileBytesList.isEmpty &&
        oldApplicant.statementOfSourceOfFundFile.fileBytesList.isNotEmpty &&
        applicant.statementOfSourceOfFundFile.fileNameList.isNotEmpty) {
      applicant
          .statementOfSourceOfFundFile
          .fileBytesList = List<Uint8List>.from(
        oldApplicant.statementOfSourceOfFundFile.fileBytesList,
      );
    }
    if (applicant.paymentProofURLFundFile.fileBytesList.isEmpty &&
        oldApplicant.paymentProofURLFundFile.fileBytesList.isNotEmpty &&
        applicant.paymentProofURLFundFile.fileNameList.isNotEmpty) {
      applicant.paymentProofURLFundFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.paymentProofURLFundFile.fileBytesList,
      );
    }
    if (applicant.nomineeFormFile.fileBytesList.isEmpty &&
        oldApplicant.nomineeFormFile.fileBytesList.isNotEmpty &&
        applicant.nomineeFormFile.fileNameList.isNotEmpty) {
      applicant.nomineeFormFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.nomineeFormFile.fileBytesList,
      );
    }
    if (applicant.incomeForm16ItrFile.fileBytesList.isEmpty &&
        oldApplicant.incomeForm16ItrFile.fileBytesList.isNotEmpty &&
        applicant.incomeForm16ItrFile.fileNameList.isNotEmpty) {
      applicant.incomeForm16ItrFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.incomeForm16ItrFile.fileBytesList,
      );
    }
    if (applicant.chequeFile.fileBytesList.isEmpty &&
        oldApplicant.chequeFile.fileBytesList.isNotEmpty &&
        applicant.chequeFile.fileNameList.isNotEmpty) {
      applicant.chequeFile.fileBytesList = List<Uint8List>.from(
        oldApplicant.chequeFile.fileBytesList,
      );
    }
    list[index] = applicant;

    emit(
      state.copyWith(
        bookingApplicantModificationRequestModel: list,
        hasUnsavedApplicantChanges: true,
      ),
    );
  }

  void deleteApplicantLocally(int index) {
    final list = List<BookingApplicantModificationRequestModel>.from(
      state.bookingApplicantModificationRequestModel,
    );

    list.removeAt(index);

    emit(
      state.copyWith(
        bookingApplicantModificationRequestModel: list,
        hasUnsavedApplicantChanges: true,
      ),
    );
  }

  bool _isExistingFile(String fileName) {
    return fileName.startsWith("http://") || fileName.startsWith("https://");
  }

  Future updateBookingApplicantModificationRequest(
    BuildContext context, {
    required int projectId,
    required int bookingId,
  }) async {
    emit(state.copyWith(isSavingApplicantRequest: true));

    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
    };

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
            e.applicantMobileNumberCountryCode,

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
        "bookingApplicantModificationRequests[$applicantIndex].PhotoURL":
            e.photoUrl,

        "bookingApplicantModificationRequests[$applicantIndex].AadharCardURL":
            e.aadharCardUrl,

        "bookingApplicantModificationRequests[$applicantIndex].PanCardURL":
            e.panCardUrl,

        "bookingApplicantModificationRequests[$applicantIndex].PassportURL":
            e.passportUrl,

        "bookingApplicantModificationRequests[$applicantIndex].DrivingLicenseURL":
            e.drivingLicenseUrl,

        "bookingApplicantModificationRequests[$applicantIndex].VotingIdURL":
            e.votingIdUrl,

        "bookingApplicantModificationRequests[$applicantIndex].GSTNumberURL":
            e.gstNumberUrl,

        "bookingApplicantModificationRequests[$applicantIndex].CancelledChequeURL":
            e.cancelledChequeUrl,

        "bookingApplicantModificationRequests[$applicantIndex].POAURL":
            e.poaurl,

        "bookingApplicantModificationRequests[$applicantIndex].IncomeForm16ITRURL":
            e.incomeForm16Itrurl,

        "bookingApplicantModificationRequests[$applicantIndex].NreNroBankDetailsURL":
            e.nreNroBankDetailsUrl,

        "bookingApplicantModificationRequests[$applicantIndex].NomineeFormURL":
            e.nomineeFormUrl,

        "bookingApplicantModificationRequests[$applicantIndex].StatementOfSourceOfFundsURL":
            e.statementOfSourceOfFundsUrl,

        "bookingApplicantModificationRequests[$applicantIndex].PaymentProofURL":
            e.paymentProofUrl,

        "bookingApplicantModificationRequests[$applicantIndex].ProofOfDocumentURL":
            e.proofOfDocumentUrl,
        // Remove fields
        "bookingApplicantModificationRequests[$applicantIndex].RemovePhotoURL":
            e.photoFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveAadharCardURL":
            e.aadhaarFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePanCardURL":
            e.panFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePassportURL":
            e.passportFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveDrivingLicenseURL":
            e.drivingLicenseFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveVotingIdURL":
            e.votingIdFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveGSTNumberURL":
            e.gstFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveCancelledChequeURL":
            e.chequeFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePOAURL":
            e.poaFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveIncomeForm16ITRURL":
            e.incomeForm16ItrFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveNreNroBankDetailsURL":
            e.nreNroBankDetailsFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveNomineeFormURL":
            e.nomineeFormFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveStatementOfSourceOfFundsURL":
            e.statementOfSourceOfFundFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemovePaymentProofURL":
            e.paymentProofURLFundFile.deletedFileList,

        "bookingApplicantModificationRequests[$applicantIndex].RemoveProofOfDocumentURL":
            e.proofOfDocumentFile.deletedFileList,
      });
    }
    final List<Map<String, dynamic>> fileList = [];

    for (
      int applicantIndex = 0;
      applicantIndex < state.bookingApplicantModificationRequestModel.length;
      applicantIndex++
    ) {
      var applicantData =
          state.bookingApplicantModificationRequestModel[applicantIndex];

      void addFiles(MultiFilePickerModel? file, String keyName) {
        if (file == null) return;

        final names = file.fileNameList;
        final bytes = file.fileBytesList;

        for (int i = 0; i < names.length; i++) {
          final name = names[i];

          if (_isExistingFile(name)) {
            continue;
          }

          if (i >= bytes.length) {
            continue;
          }

          if (bytes[i].isEmpty) {
            continue;
          }

          fileList.add({"key": keyName, "value": bytes[i], "fileName": name});
        }
      }

      addFiles(
        applicantData.panFile,
        "bookingApplicantModificationRequests[$applicantIndex].PanCardURL",
      );
      addFiles(
        applicantData.aadhaarFile,
        "bookingApplicantModificationRequests[$applicantIndex].AadharCardURL",
      );
      addFiles(
        applicantData.votingIdFile,
        "bookingApplicantModificationRequests[$applicantIndex].VotingIdURL",
      );
      addFiles(
        applicantData.poaFile,
        "bookingApplicantModificationRequests[$applicantIndex].POAURL",
      );
      addFiles(
        applicantData.paymentProofURLFundFile,
        "bookingApplicantModificationRequests[$applicantIndex].PaymentProofURL",
      );
      addFiles(
        applicantData.nreNroBankDetailsFile,
        "bookingApplicantModificationRequests[$applicantIndex].NreNroBankDetailsURL",
      );
      addFiles(
        applicantData.drivingLicenseFile,
        "bookingApplicantModificationRequests[$applicantIndex].DrivingLicenseURL",
      );
      addFiles(
        applicantData.proofOfDocumentFile,
        "bookingApplicantModificationRequests[$applicantIndex].ProofOfDocumentURL",
      );

      addFiles(
        applicantData.statementOfSourceOfFundFile,
        "bookingApplicantModificationRequests[$applicantIndex].StatementOfSourceOfFundsURL",
      );
      addFiles(
        applicantData.incomeForm16ItrFile,
        "bookingApplicantModificationRequests[$applicantIndex].IncomeForm16ITRURL",
      );
      addFiles(
        applicantData.nomineeFormFile,
        "bookingApplicantModificationRequests[$applicantIndex].NomineeFormURL",
      );
      addFiles(
        applicantData.chequeFile,
        "bookingApplicantModificationRequests[$applicantIndex].CancelledChequeURL",
      );
      addFiles(
        applicantData.photoFile,
        "bookingApplicantModificationRequests[$applicantIndex].PhotoURL",
      );
      addFiles(
        applicantData.passportFile,
        "bookingApplicantModificationRequests[$applicantIndex].PassportURL",
      );
      addFiles(
        applicantData.gstFile,
        "bookingApplicantModificationRequests[$applicantIndex].GSTNumberURL",
      );
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
        emit(state.copyWith(isSavingApplicantRequest: false));
      },
      (response) async {
        emit(
          state.copyWith(
            isSavingApplicantRequest: false,
            hasUnsavedApplicantChanges: false,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
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

  void clearRefundPaymentSuccessMessage() {
    emit(state.copyWith(showRefundPaymentSuccessMessage: false));
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
        await getBookingById(context, 1, projectId, bookingId);
        emit(
          state.copyWith(
            showRefundPaymentLedgerTab: true,
            showRefundPaymentSuccessMessage: true,
          ),
        );
        goRouter.pop(true);
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
            hasUnsavedApplicantChanges: false,
          ),
        );
      },
    );
  }

  Future getBookingApplicantModificationActivitytList(
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
          queryParams: {"TabName": "ACTIVITY"},
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

  Future getParkingModificationActivityList(
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
          queryParams: {"TabName": "ACTIVITY"},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
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

  Future getFlatAlterationActivityList(
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
          queryParams: {"TabName": "ACTIVITY"},
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

  Future addParkingModificationRequest(
    BuildContext context, {
    required int bookingId,
    required int projectId,
    required String parkingId,
    required MultiFilePickerModel proofDocumentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "ParkingId": parkingId,
    };
    List<Map<String, dynamic>> fileList = [];

    // PAN
    for (int i = 0; i < proofDocumentFile.fileNameList.length; i++) {
      if (proofDocumentFile.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ProofOfDocumentURL",
        "value": proofDocumentFile.fileBytesList[i],
        "fileName": proofDocumentFile.fileNameList[i],
      });
    }

    final result = await _requestManagementRepository
        .addUpdateParkingModificationRequest(
          body: requestBody,
          fileList: fileList,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);

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

  Future updateParkingModificationRequest(
    BuildContext context, {
    required int parkingModificationRequestId,
    required int bookingId,
    required int projectId,
    required String uniquekey,
    required String parkingId,
    required MultiFilePickerModel proofDocumentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "ParkingModificationRequestId": parkingModificationRequestId.toString(),
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "ParkingId": parkingId,
      "Uniquekey": uniquekey,
      "RemoveProofOfDocumentURL": proofDocumentFile.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < proofDocumentFile.fileNameList.length; i++) {
      if (proofDocumentFile.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ProofOfDocumentURL",
        "value": proofDocumentFile.fileBytesList[i],
        "fileName": proofDocumentFile.fileNameList[i],
      });
    }

    final result = await _requestManagementRepository
        .addUpdateParkingModificationRequest(body: body, fileList: fileList);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);

        await getParkingModificationRequestList(
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

  Future deleteParkingModificationRequest({
    required BuildContext context,
    required int parkingModificationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _requestManagementRepository
        .deleteParkingModificationRequest(
          parkingModificationRequestId: parkingModificationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        if (index != null) {
          final updatedList = List<ParkingModificationRequestModel>.from(
            state.parkingModificationRequestList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              parkingModificationRequestList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getParkingModificationRequestList(
            context,
            10,
            1,
            bookingId,
            projectId,
          );
        }
      },
    );
  }

  Future addFlatAlterationRequest({
    required BuildContext context,
    required int projectId,
    required int bookingId,
    required String flatAlterationRemark,
    required MultiFilePickerModel proofDocumentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "FlatAlterationRemark": flatAlterationRemark,
      "ApprovalStatus": "",
      "VersionNumber": "",
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < proofDocumentFile.fileNameList.length; i++) {
      if (proofDocumentFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "ProofOfDocumentURL",
        "value": proofDocumentFile.fileBytesList[i],
        "fileName": proofDocumentFile.fileNameList[i],
      });
    }

    var addResult = await _requestManagementRepository.addFlatAlterationRequest(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);

        emit(state.copyWith(isLoading: false));

        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
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

  Future updateFlatAlterationRequest({
    required BuildContext context,
    required int flatAlterationRequestId,
    required int projectId,
    required int bookingId,
    required String uniquekey,
    required String flatAlterationRemark,
    required MultiFilePickerModel proofDocumentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "FlatAlterationRequestId": flatAlterationRequestId.toString(),
      "UniqueKey": uniquekey,
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "FlatAlterationRemark": flatAlterationRemark,
      "ApprovalStatus": "",
      "VersionNumber": "",
      "RemoveProofOfDocumentURL": proofDocumentFile.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < proofDocumentFile.fileNameList.length; i++) {
      if (proofDocumentFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "ProofOfDocumentURL",
        "value": proofDocumentFile.fileBytesList[i],
        "fileName": proofDocumentFile.fileNameList[i],
      });
    }

    var addResult = await _requestManagementRepository.addFlatAlterationRequest(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);

        emit(state.copyWith(isLoading: false));

        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
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

  Future deleteFlatAlterationRequest({
    required BuildContext context,
    required int flatAlterationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _requestManagementRepository
        .deleteFlatAlterationRequest(
          flatAlterationRequestId: flatAlterationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        if (index != null) {
          final updatedList = List<FlatAlterationRequestsModel>.from(
            state.flatAlterationRequestsModel,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              flatAlterationRequestsModel: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getFlatAlterationRequestList(context, 10, 1, bookingId, projectId);
        }
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
        showSuccessMessage(context, subTitle: response['message']);

        goRouter.pop(true);
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
        showSuccessMessage(context, subTitle: response["message"]);
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
