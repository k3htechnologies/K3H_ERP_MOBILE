import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_master.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingState.initial());

  // REPOSITORIES
  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();

  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();

  final OtherChargesRepository _otherChargesRepository =
      serviceLocator<OtherChargesRepository>();

  final ParkingRepository _parkingRepository =
      serviceLocator<ParkingRepository>();

  final TermsAndConditionsMasterRepository _termsAndConditionsRepository =
      serviceLocator<TermsAndConditionsMasterRepository>();

  // CLEAR ENQUIRY LIST
  void clearEnquiryList() {
    emit(state.copyWith(enquiryList: []));
  }

  // VIEW BOOKINGS TAB
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  // ADD FORM TAB
  void onTabChangedAddForm(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndexAddForm: index));
  }

  // <---- GET BOOKING LIST ---->
  Future getBookingList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"ApplicantName": state.searchText};
    var result = await _bookingRepository.getBookingList(
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
        final List<BookingModel> newData = List<BookingModel>.from(
          response['data'] ?? [],
        );

        final List<BookingModel> updatedList =
            pageNumber == 1 ? newData : [...state.bookingList, ...newData];
        emit(
          state.copyWith(
            bookingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET BOOKING BY ID LIST ---->
  Future getBookingListById(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true, bookingListById: []));
    Map<String, dynamic> queryParams = {"BookingId": bookingId};
    var result = await _bookingRepository.getBookingList(
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
        emit(
          state.copyWith(
            bookingListById: List<BookingModel>.from(response['data'] ?? []),
            isLoading: false,
          ),
        );
      },
    );
  }

  // <---- GET ENQUIRY LIST ---->
  Future getEnquiryList(
    BuildContext context,
    int pageNumber,
    int projectId,
    String systemGeneratedCode,
  ) async {
    emit(state.copyWith(isLoading: true, enquiryList: []));
    Map<String, dynamic> queryParams = {
      "SystemGeneratedCode": systemGeneratedCode,
    };
    var result = await _enquiryRepository.getEnquiryList(
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
        final List<EnquiryModel> newData = List<EnquiryModel>.from(
          response['data'] ?? [],
        );

        final List<EnquiryModel> updatedList =
            pageNumber == 1 ? newData : [...state.enquiryList, ...newData];
        emit(state.copyWith(enquiryList: updatedList, isLoading: false));
      },
    );
  }

  // <---- GET ENQUIRY LIST BY ID ---->
  Future getEnquiryListById(
    BuildContext context,
    int pageNumber,
    int projectId,
    int enquiryId,
  ) async {
    emit(state.copyWith(isLoading: true, enquiryListById: []));
    Map<String, dynamic> queryParams = {"EnquiryId": enquiryId};
    var result = await _enquiryRepository.getEnquiryList(
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
        emit(
          state.copyWith(
            enquiryListById: List<EnquiryModel>.from(response['data'] ?? []),
            isLoading: false,
          ),
        );
      },
    );
  }

  // <---- GET OTHER CHARGES LIST ---->
  Future getOtherChargesList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _otherChargesRepository.getOtherChargesList(
      pageNumber: pageNumber,
      pageSize: 1,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            otherChargesList: List<OtherChargeModel>.from(
              response['data'] ?? [],
            ),
            isLoading: false,
          ),
        );
      },
    );
  }

  // <---- GET BOOKING LIST ---->
  Future getParkingList(
    BuildContext context,
    int pageNumber,
    int projectId, {
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _parkingRepository.getParkingWithPagination(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams:
          searchQuery != null && searchQuery.isNotEmpty
              ? {"ParkingNumber": searchQuery}
              : null,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ParkingModel> newData = List<ParkingModel>.from(
          response['data'] ?? [],
        );

        final List<ParkingModel> updatedList =
            pageNumber == 1 ? newData : [...state.parkingList, ...newData];
        emit(
          state.copyWith(
            parkingList: updatedList,
            isLoading: false,
            totalNumberOfRecordParking: response["totalNumberOfRecord"],
            currentPageParking: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET TERMS AND CONDITIONS LIST ---->
  Future getTermsAndConditionsList(
    BuildContext context,
    int pageNumber, {
    String moduleName = 'BOOKING',
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic>? queryParams =
        (searchQuery != null && searchQuery.isNotEmpty)
            ? {"Title": searchQuery}
            : null;

    var result = await _termsAndConditionsRepository.getTermsAndConditionsList(
      pageNumber: pageNumber,
      pageSize: 10,
      moduleName: moduleName,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<TermsAndConditionsModel> newData =
            List<TermsAndConditionsModel>.from(response['data'] ?? []);

        final List<TermsAndConditionsModel> updatedList =
            pageNumber == 1 ? newData : [...state.termsList, ...newData];

        emit(
          state.copyWith(
            termsList: updatedList,
            isLoading: false,
            totalNumberOfRecordTerms:
                response["totalNumberOfRecord"] ?? updatedList.length,
            currentPageTerms: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD BOOKING ---->
  Future addBooking({
    required BuildContext context,
    required int projectId,
    required int enquiryId,
    required String permanentAddress,
    required String communicationAddress,
    required double brokeragePercentage,
    required double brokerageAmount,
    required int inventoryFlatId,
    required double agreementValue,
    required double agreementValueTds,
    required double agreementValueGSTPercentage,
    required double agreementValueGSTAmount,
    required double stampDutyPercentage,
    required double stampDutyAmount,
    required double registrationFees,
    String? parkingId,
    required String handoverType,
    required DateTime registrationDate,
    required String modeOfPayment,

    /// CHANGE LATER IN API
    required String flatAlterationRemark,
    required String termsAndConditionsDescription,
    String bookingType = 'FLAT',
    required List<OtherChargeModel> otherChargesDetailJSON,
    required List<BookingPaymentScheduleData> paymentScheduleDetailJSON,
    required double bookingAmount,
    required String chequeRTGSNumber,
    DateTime? chequeRTGSDate,
    int? bankListMasterId,
    int? transferBookingId,
    int? tenantId,
    required String otp,
    required List<BookingApplicantData> addUpdateBookingApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": 0.toString(),
      "ProjectId": projectId.toString(),
      "EnquiryId": enquiryId.toString(),
      "PermanentAddress": permanentAddress,
      "CommunicationAddress": communicationAddress,
      "BrokeragePercentage": brokeragePercentage.toString(),
      "BrokerageAmount": brokerageAmount.toString(),
      "InventoryFlatId": inventoryFlatId.toString(),
      "AgreementValue": agreementValue.toString(),
      "AgreementValueTDS": agreementValueTds.toString(),
      "AgreementValueGSTPercentage": agreementValueGSTPercentage.toString(),
      "AgreementValueGSTAmount": agreementValueGSTAmount.toString(),
      "StampDutyPercentage": stampDutyPercentage.toString(),
      "StampDutyAmount": stampDutyAmount.toString(),
      "RegistrationFees": registrationFees.toString(),
      if (parkingId != null) "ParkingId": parkingId.toString(),
      "HandoverType": handoverType,
      "RegistrationDate": registrationDate.toIso8601String(),
      "ModeOfPayment": modeOfPayment,

      /// CHANGE LATER IN API
      "FlatAlterationRemark": flatAlterationRemark,
      "TermsAndConditionsDescription": termsAndConditionsDescription,
      "BookingType": bookingType,
      "OtherChargesDetailJSON": jsonEncode(
        otherChargesDetailJSON
            .where((e) => e.isSelected)
            .map(
              (e) => {
                'BookingOtherChargesId': e.bookingOtherChargesId,
                'ChargeName': e.chargeName,
                'CalculatedOn': e.calculatedOn,
                'Value': e.value,
                'GSTPercentage': e.gstPercentage,
                'GSTValue': e.gstValue,
              },
            )
            .toList(),
      ),
      "PaymentScheduleDetailJSON": jsonEncode(
        paymentScheduleDetailJSON
            .map(
              (e) => {
                "BookingPaymentScheduleId": e.bookingPaymentScheduleId,
                "Type": e.type,
                "Name": e.name,
                if (e.date != null) "Date": e.date!.toIso8601String(),
                "PaymentSchedulePercentage": e.paymentSchedulePercentage,
                "PaymentScheduleAmount": e.paymentScheduleAmount,
                "PaymentScheduleGSTAmount": e.paymentScheduleGSTAmount,
                "PaymentScheduleTDSAmount": e.paymentScheduleTDSAmount,
              },
            )
            .toList(),
      ),
      'BookingAmount': bookingAmount.toString(),
      "ChequeRTGSNumber": chequeRTGSNumber,
      if (chequeRTGSDate != null)
        "ChequeRTGSDate": chequeRTGSDate.toIso8601String(),
      if (bankListMasterId != null)
        "BankListMasterId": bankListMasterId.toString(),
      if (transferBookingId != null)
        "TransferBookingId": transferBookingId.toString(),
      if (tenantId != null) "TenantId": tenantId.toString(),
      "OTP": otp,
    };

    for (int i = 0; i < addUpdateBookingApplicant.length; i++) {
      var e = addUpdateBookingApplicant[i];
      requestBody.addAll({
        "AddUpdateBookingApplicant[$i].ApplicantType": e.applicantType,
        "AddUpdateBookingApplicant[$i].BookingApplicantId":
            e.bookingApplicantId.toString(),
        "AddUpdateBookingApplicant[$i].ApplicantName": e.applicantName,
        "AddUpdateBookingApplicant[$i].ApplicantMobileNumber":
            e.applicantMobileNumber,
        "AddUpdateBookingApplicant[$i].ApplicantEmailId": e.applicantEmailId,
        "AddUpdateBookingApplicant[$i].RemovePhotoURL":
            e.profilePhotoImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].AadharCardNumber": e.aadharCardNumber,
        "AddUpdateBookingApplicant[$i].RemoveAadharCardURL":
            e.aadhaarImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].PanNumber": e.panNumber,
        "AddUpdateBookingApplicant[$i].RemovePanCardURL":
            e.panImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].PassportNumber": e.passportNumber,
        "AddUpdateBookingApplicant[$i].RemovePassportURL":
            e.passportImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].DrivingLicenseNumber":
            e.drivingLicenseNumber,
        "AddUpdateBookingApplicant[$i].RemoveDrivingLicenseURL":
            e.drivingLicenseImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].VotingIdNumber": e.votingIdNumber,
        "AddUpdateBookingApplicant[$i].RemoveVotingIdURL":
            e.votingIdImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].GstNumber": e.gstNumber,
        "AddUpdateBookingApplicant[$i].RemoveGSTNumberURL":
            e.gstImage.deletedFileList,
      });
    }

    List<Map<String, dynamic>> fileList = [];

    for (var applicantData in addUpdateBookingApplicant) {
      for (
        int i = 0;
        i < applicantData.profilePhotoImage.fileNameList.length;
        i++
      ) {
        if (applicantData.profilePhotoImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PhotoURL",
          "value": applicantData.profilePhotoImage.fileBytesList[i],
          "fileName": applicantData.profilePhotoImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.aadhaarImage.fileNameList.length; i++) {
        if (applicantData.aadhaarImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].AadharCardURL",
          "value": applicantData.aadhaarImage.fileBytesList[i],
          "fileName": applicantData.aadhaarImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.panImage.fileNameList.length; i++) {
        if (applicantData.panImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PanCardURL",
          "value": applicantData.panImage.fileBytesList[i],
          "fileName": applicantData.panImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.passportImage.fileNameList.length;
        i++
      ) {
        if (applicantData.passportImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PassportURL",
          "value": applicantData.passportImage.fileBytesList[i],
          "fileName": applicantData.passportImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.drivingLicenseImage.fileNameList.length;
        i++
      ) {
        if (applicantData.drivingLicenseImage.fileNameList[i].contains(
          "http",
        )) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].DrivingLicenseURL",
          "value": applicantData.drivingLicenseImage.fileBytesList[i],
          "fileName": applicantData.drivingLicenseImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.votingIdImage.fileNameList.length;
        i++
      ) {
        if (applicantData.votingIdImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].VotingIdURL",
          "value": applicantData.votingIdImage.fileBytesList[i],
          "fileName": applicantData.votingIdImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.gstImage.fileNameList.length; i++) {
        if (applicantData.gstImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].GstNumberURL",
          "value": applicantData.gstImage.fileBytesList[i],
          "fileName": applicantData.gstImage.fileNameList[i],
        });
      }
    }

    var addResult = await _bookingRepository.addUpdateBooking(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();

    addResult.fold((failure) async {
      showErrorMessage(context, 'Error Message', failure.message);
      return;
    }, (response) async {});
  }

  // <---- UPDATE BOOKING ---->
  Future updateBooking({
    required BuildContext context,
    required int index,
    required int bookingId,
    required String uniqueKey,
    required int projectId,
    required int enquiryId,
    required String permanentAddress,
    required String communicationAddress,
    required double brokeragePercentage,
    required double brokerageAmount,
    required int inventoryFlatId,
    required double agreementValue,
    required double agreementValueTds,
    required double agreementValueGSTPercentage,
    required double agreementValueGSTAmount,
    required double stampDutyPercentage,
    required double stampDutyAmount,
    required double registrationFees,
    String? parkingId,
    required String handoverType,
    required DateTime registrationDate,
    required String modeOfPayment,

    /// CHANGE LATER IN API
    required String flatAlterationRemark,
    required String termsAndConditionsDescription,
    String bookingType = 'FLAT',
    required List<OtherChargeModel> otherChargesDetailJSON,
    required List<BookingPaymentScheduleData> paymentScheduleDetailJSON,
    required double bookingAmount,
    required String chequeRTGSNumber,
    DateTime? chequeRTGSDate,
    int? bankListMasterId,
    int? transferBookingId,
    int? tenantId,
    required String otp,
    required List<BookingApplicantData> addUpdateBookingApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingId": transferBookingId != null ? '0' : bookingId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": projectId.toString(),
      "PermanentAddress": permanentAddress,
      "CommunicationAddress": communicationAddress,
      "BrokeragePercentage": brokeragePercentage.toString(),
      "BrokerageAmount": brokerageAmount.toString(),
      "InventoryFlatId": inventoryFlatId.toString(),
      "AgreementValue": agreementValue.toString(),
      "AgreementValueTDS": agreementValueTds.toString(),
      "AgreementValueGSTPercentage": agreementValueGSTPercentage.toString(),
      "AgreementValueGSTAmount": agreementValueGSTAmount.toString(),
      "StampDutyPercentage": stampDutyPercentage.toString(),
      "StampDutyAmount": stampDutyAmount.toString(),
      "RegistrationFees": registrationFees.toString(),
      if (parkingId != null) "ParkingId": parkingId.toString(),
      "HandoverType": handoverType,
      "RegistrationDate": registrationDate.toIso8601String(),
      "ModeOfPayment": modeOfPayment,

      /// CHANGE IT LATER IN API
      "FlatAlterationRemark": flatAlterationRemark,
      "TermsAndConditionsDescription": termsAndConditionsDescription,
      "BookingType": bookingType,
      "OtherChargesDetailJSON": jsonEncode(
        otherChargesDetailJSON
            .where((e) => e.isSelected)
            .map(
              (e) => {
                'BookingOtherChargesId': e.bookingOtherChargesId,
                'Uniquekey': e.uniquekey,
                'ChargeName': e.chargeName,
                'CalculatedOn': e.calculatedOn,
                'Value': e.value,
                'GSTPercentage': e.gstPercentage,
                'GSTValue': e.gstValue,
              },
            )
            .toList(),
      ),
      "PaymentScheduleDetailJSON": jsonEncode(
        paymentScheduleDetailJSON
            .map(
              (e) => {
                "BookingPaymentScheduleId": e.bookingPaymentScheduleId,
                "Type": e.type,
                "Name": e.name,
                if (e.date != null) "Date": e.date!.toIso8601String(),
                "PaymentSchedulePercentage": e.paymentSchedulePercentage,
                "PaymentScheduleAmount": e.paymentScheduleAmount,
                "PaymentScheduleGSTAmount": e.paymentScheduleGSTAmount,
                "PaymentScheduleTDSAmount": e.paymentScheduleTDSAmount,
              },
            )
            .toList(),
      ),
      'BookingAmount': bookingAmount.toString(),
      "ChequeRTGSNumber": chequeRTGSNumber,
      if (chequeRTGSDate != null)
        "ChequeRTGSDate": chequeRTGSDate.toIso8601String(),
      if (bankListMasterId != null)
        "BankListMasterId": bankListMasterId.toString(),
      if (transferBookingId != null)
        "TransferBookingId": transferBookingId.toString(),
      if (tenantId != null) "TenantId": tenantId.toString(),
      "OTP": otp,
    };

    for (int i = 0; i < addUpdateBookingApplicant.length; i++) {
      var e = addUpdateBookingApplicant[i];
      requestBody.addAll({
        "AddUpdateBookingApplicant[$i].ApplicantType": e.applicantType,
        "AddUpdateBookingApplicant[$i].BookingApplicantId":
            e.bookingApplicantId.toString(),
        "AddUpdateBookingApplicant[$i].ApplicantName": e.applicantName,
        "AddUpdateBookingApplicant[$i].ApplicantMobileNumber":
            e.applicantMobileNumber,
        "AddUpdateBookingApplicant[$i].ApplicantEmailId": e.applicantEmailId,
        "AddUpdateBookingApplicant[$i].RemovePhotoURL":
            e.profilePhotoImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].AadharCardNumber": e.aadharCardNumber,
        "AddUpdateBookingApplicant[$i].RemoveAadharCardURL":
            e.aadhaarImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].PanNumber": e.panNumber,
        "AddUpdateBookingApplicant[$i].RemovePanCardURL":
            e.panImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].PassportNumber": e.passportNumber,
        "AddUpdateBookingApplicant[$i].RemovePassportURL":
            e.passportImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].DrivingLicenseNumber":
            e.drivingLicenseNumber,
        "AddUpdateBookingApplicant[$i].RemoveDrivingLicenseURL":
            e.drivingLicenseImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].VotingIdNumber": e.votingIdNumber,
        "AddUpdateBookingApplicant[$i].RemoveVotingIdURL":
            e.votingIdImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].GstNumber": e.gstNumber,
        "AddUpdateBookingApplicant[$i].RemoveGSTNumberURL":
            e.gstImage.deletedFileList,
      });
    }

    List<Map<String, dynamic>> fileList = [];

    for (var applicantData in addUpdateBookingApplicant) {
      for (
        int i = 0;
        i < applicantData.profilePhotoImage.fileNameList.length;
        i++
      ) {
        if (applicantData.profilePhotoImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PhotoURL",
          "value": applicantData.profilePhotoImage.fileBytesList[i],
          "fileName": applicantData.profilePhotoImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.aadhaarImage.fileNameList.length; i++) {
        if (applicantData.aadhaarImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].AadharCardURL",
          "value": applicantData.aadhaarImage.fileBytesList[i],
          "fileName": applicantData.aadhaarImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.panImage.fileNameList.length; i++) {
        if (applicantData.panImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PanCardURL",
          "value": applicantData.panImage.fileBytesList[i],
          "fileName": applicantData.panImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.passportImage.fileNameList.length;
        i++
      ) {
        if (applicantData.passportImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].PassportURL",
          "value": applicantData.passportImage.fileBytesList[i],
          "fileName": applicantData.passportImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.drivingLicenseImage.fileNameList.length;
        i++
      ) {
        if (applicantData.drivingLicenseImage.fileNameList[i].contains(
          "http",
        )) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].DrivingLicenseURL",
          "value": applicantData.drivingLicenseImage.fileBytesList[i],
          "fileName": applicantData.drivingLicenseImage.fileNameList[i],
        });
      }

      for (
        int i = 0;
        i < applicantData.votingIdImage.fileNameList.length;
        i++
      ) {
        if (applicantData.votingIdImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].VotingIdURL",
          "value": applicantData.votingIdImage.fileBytesList[i],
          "fileName": applicantData.votingIdImage.fileNameList[i],
        });
      }

      for (int i = 0; i < applicantData.gstImage.fileNameList.length; i++) {
        if (applicantData.gstImage.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateBookingApplicant[$i].GstNumberURL",
          "value": applicantData.gstImage.fileBytesList[i],
          "fileName": applicantData.gstImage.fileNameList[i],
        });
      }
    }

    var updateResult = await _bookingRepository.addUpdateBooking(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) async {
        await showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context);
      },
    );
  }

  void updateRanking(int index, int ranking) {
    final updatedList = List.of(state.paymentScheduleMasterList);

    updatedList[index].ranking = ranking;

    emit(state.copyWith(paymentScheduleMasterList: updatedList));
  }

  // <---- GET PAYMENT SCHEDULE MASTER LIST ---->
  Future getPaymentScheduleMasterList(
    BuildContext context,
    int pageNumber,
    int projectId,
    String wing,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _bookingRepository.getPaymentScheduleMasterList(
      pageNumber: pageNumber,
      pageSize: 100,
      projectId: projectId,
      queryParams: {"Wing": wing},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            paymentScheduleMasterList: List<PaymentScheduleMasterModel>.from(
              response['data'] ?? [],
            ),
            isLoading: false,
          ),
        );
      },
    );
  }
}
