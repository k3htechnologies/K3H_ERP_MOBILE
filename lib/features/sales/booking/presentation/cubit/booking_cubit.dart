import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver_plus/files.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_data.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/model/payment_schedule.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/respository/payment_schedule.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

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
  final PaymentScheduleRepository _paymentScheduleRepository =
      serviceLocator<PaymentScheduleRepository>();

  final TermsAndConditionsMasterRepository _termsAndConditionsRepository =
      serviceLocator<TermsAndConditionsMasterRepository>();

  Future<void> resetState() async {
    emit(BookingState.initial());
  }

  // CLEAR ENQUIRY LIST
  void clearEnquiryList() {
    emit(state.copyWith(enquiryList: []));
  }

  // VIEW BOOKINGS TAB
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  Future searchBooking(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, bookingList: []));
    await getBookingList(context, 1, getProject().projectId);
  }

  // ADD FORM TAB
  void onTabChangedAddForm(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndexAddForm: index));
  }

  void clearParkingList() {
    emit(state.copyWith(parkingList: [], totalNumberOfRecordParking: 0));
  }

  void clearTermsList() {
    emit(state.copyWith(termsList: [], totalNumberOfRecordTerms: 0));
  }

  //  GET BOOKING LIST
  Future getBookingList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error Message", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));

      return;
    }
    Map<String, dynamic> queryParams = {
      if (state.searchText.isNotEmpty) "ApplicantName": state.searchText.trim(),
      if (state.filterMobileNumber.isNotEmpty)
        "ApplicantMobileNumber": state.filterMobileNumber,
      if (state.filterWing.isNotEmpty) "Wing": state.filterWing,
      if (state.filterFlat.isNotEmpty) "Flat": state.filterFlat,
      if (state.filterFloor.isNotEmpty) "Floor": state.filterFloor,
      if (state.filterSource.isNotEmpty) "Source": state.filterSource,
      if (state.filterSubSource.isNotEmpty) "SubSource": state.filterSubSource,
      if (state.filterAgreementValue != 0)
        "AgreementValue": state.filterAgreementValue,
      if (state.filterBookingType.isNotEmpty)
        "BookingType": state.filterBookingType,

      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    // Date filters
    if (state.filterStartDate != null) {
      queryParams["FromDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterStartDate!);
    }
    if (state.filterEndDate != null) {
      queryParams["ToDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterEndDate!);
    }

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

        emit(state.copyWith(isLoading: false));

        return booking;
      },
    );
  }

  //  GET ENQUIRY LIST
  Future getEnquiryList(
    BuildContext context,
    int pageNumber,
    int projectId,
    String? systemGeneratedCode,
    int? enquiryId,
  ) async {
    emit(state.copyWith(isLoading: true, enquiryList: []));
    Map<String, dynamic> queryParams = {
      if (systemGeneratedCode != null)
        "SystemGeneratedCode": systemGeneratedCode,
      if (enquiryId != null) "EnquiryId": enquiryId,
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

  //  GET OTHER CHARGES LIST
  Future getOtherChargesList(
    BuildContext context,
    int pageNumber,
    int projectId,
    double reraArea,
  ) async {
    emit(state.copyWith(isLoading: true));
    DialogHelper.showProcessingOverlay(context);

    var result = await _otherChargesRepository.getOtherChargesList(
      pageNumber: pageNumber,
      pageSize: 500,
      projectId: projectId,
      queryParams: {"IsCheckPermission": false},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        goRouter.pop();
      },
      (response) {
        final rawList = List<OtherChargeModel>.from(response['data'] ?? []);

        final calculatedList =
            rawList.map((oc) {
              final baseAmount =
                  oc.calculatedOn == "Per Sq Ft"
                      ? oc.value * reraArea
                      : oc.value;

              final gstValue = (oc.gstPercentage / 100) * baseAmount;

              // REUSE EXISTING FIELDS: VALUE=BASE AMOUNT,GST AMOUNT
              return oc.copyWith(value: baseAmount, gstValue: gstValue);
            }).toList();
        goRouter.pop();
        emit(
          state.copyWith(otherChargesList: calculatedList, isLoading: false),
        );
      },
    );
  }

  //  GET BOOKING LIST
  Future getParkingList(
    BuildContext context,
    int pageNumber,
    int projectId, {
    String? searchQuery,
    String? displayParkingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _parkingRepository.getParkingWithPagination(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams:
          searchQuery != null && searchQuery.isNotEmpty
              ? {"ParkingNumber": searchQuery}
              : displayParkingId != null
              ? {"DisplayParkingId": displayParkingId}
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

  //  GET TERMS AND CONDITIONS LIST
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

  Future<void> _addFiles({
    required List<Map<String, dynamic>> fileList,
    required int applicantIndex,
    required String fieldName,
    required MultiFilePickerModel fileModel,
  }) async {
    for (int i = 0; i < fileModel.fileNameList.length; i++) {
      final fileName = fileModel.fileNameList[i];

      // skip already uploaded files
      if (fileName.contains("http")) continue;

      if (i >= fileModel.fileBytesList.length) continue;

      final bytes = fileModel.fileBytesList[i];

      final finalBytes = isImage(fileName) ? await compress(bytes) : bytes;

      fileList.add({
        "key": "AddUpdateBookingApplicant[$applicantIndex].$fieldName",
        "value": finalBytes,
        "fileName": fileName,
      });
    }
  }

  Future<Uint8List> compress(Uint8List bytes) async {
    return await FlutterImageCompress.compressWithList(bytes, quality: 50);
  }

  //  ADD BOOKING
  Future addBooking({
    required int buildingIndex,
    required int wingIndex,
    required int floorIndex,
    required int flatIndex,
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
    required String sourceOfFunding,
    String? parkingId,
    int? numberOfParking,
    required String handoverType,
    required DateTime registrationDate,
    required String modeOfPayment,
    required int paymentScheduleSchemeMasterId,
    required String paymentScheduleScheme,

    /// CHANGE LATER IN API
    required double referelPercentage,
    required double referelAmount,

    required double loyaltyPercentage,
    required double loyaltyAmount,

    required double employeeReferencePercentage,
    required double employeeReferenceAmount,
    required String flatAlterationRemark,
    required String paymentRemark,
    required String otherRemark,
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
    required bool isApplicableOtherCharge,
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

      "ReferelPercentage": referelPercentage.toString(),
      "ReferelAmount": referelAmount.toString(),

      "LoyaltyPercentage": loyaltyPercentage.toString(),
      "LoyaltyAmount": loyaltyAmount.toString(),

      "EmployeeReferencePercentage": employeeReferencePercentage.toString(),
      "EmployeeReferenceAmount": employeeReferenceAmount.toString(),
      "InventoryFlatId": inventoryFlatId.toString(),
      "AgreementValue": agreementValue.toString(),
      "AgreementValueTDS": agreementValueTds.toString(),
      "AgreementValueGSTPercentage": agreementValueGSTPercentage.toString(),
      "AgreementValueGSTAmount": agreementValueGSTAmount.toString(),
      "StampDutyPercentage": stampDutyPercentage.toString(),
      "StampDutyAmount": stampDutyAmount.toString(),
      "RegistrationFees": registrationFees.toString(),
      "SourceOfFunding": sourceOfFunding,
      if (parkingId != null) "ParkingId": parkingId.toString(),
      if (numberOfParking != null)
        "NumberOfParking": numberOfParking.toString(),
      "HandoverType": handoverType,
      "RegistrationDate": registrationDate.toIso8601String(),
      "ModeOfPayment": modeOfPayment,

      /// CHANGE LATER IN API
      "FlatAlterationRemark": flatAlterationRemark,
      "PaymentRemark": paymentRemark,
      "OtherRemark": otherRemark,
      "TermsAndConditionsDescription": termsAndConditionsDescription,
      "BookingType": bookingType,
      "IsApplicableOtherCharge": isApplicableOtherCharge.toString(),
      "OtherChargesDetailJSON": jsonEncode(
        otherChargesDetailJSON
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
      "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId.toString(),
      "PaymentScheduleScheme": paymentScheduleScheme,
      "PaymentScheduleDetailJSON": jsonEncode(
        paymentScheduleDetailJSON
            .map(
              (e) => {
                "BookingPaymentScheduleId": e.bookingPaymentScheduleId,
                "Type": e.type,
                "Name": e.name,
                if (e.date != null) "Date": e.date!.toIso8601String(),
                "PaymentSchedulePercentage": e.paymentSchedulePercentage,
                "PaymentScheduleCumulative": e.paymentCummulativePercentage,
                "PaymentScheduleAmount": e.paymentScheduleAmount,
                "PaymentScheduleGSTAmount": e.paymentScheduleGSTAmount,
                "PaymentScheduleTDSAmount": e.paymentScheduleTDSAmount,
                "Rank": e.ranking,
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
        "AddUpdateBookingApplicant[$i].ApplicantMobileNumberCountryCode":
            e.applicantMobileNumberCountryCode,
        "AddUpdateBookingApplicant[$i].ApplicantEmailId": e.applicantEmailId,
        "AddUpdateBookingApplicant[$i].AadharCardNumber": e.aadharCardNumber,
        "AddUpdateBookingApplicant[$i].PanNumber": e.panNumber,
        "AddUpdateBookingApplicant[$i].PassportNumber": e.passportNumber,
        "AddUpdateBookingApplicant[$i].DrivingLicenseNumber":
            e.drivingLicenseNumber,
        "AddUpdateBookingApplicant[$i].VotingIdNumber": e.votingIdNumber,
        "AddUpdateBookingApplicant[$i].GstNumber": e.gstNumber,
      });
    }

    List<Map<String, dynamic>> fileList = [];

    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateBookingApplicant.length;
      applicantIndex++
    ) {
      final applicant = addUpdateBookingApplicant[applicantIndex];

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PhotoURL",
        fileModel: applicant.profilePhotoImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "AadharCardURL",
        fileModel: applicant.aadhaarImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PanCardURL",
        fileModel: applicant.panImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PassportURL",
        fileModel: applicant.passportImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "DrivingLicenseURL",
        fileModel: applicant.drivingLicenseImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "VotingIdURL",
        fileModel: applicant.votingIdImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "GstNumberURL",
        fileModel: applicant.gstImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "CancelledChequeURL",
        fileModel: applicant.cancelledChequeImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "POAURL",
        fileModel: applicant.poaImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "IncomeForm16ITRURL",
        fileModel: applicant.incomeForm16ItrImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "NreNroBankDetailsURL",
        fileModel: applicant.nreNroBankDetailsImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "NomineeFormURL",
        fileModel: applicant.nomineeFormImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "StatementOfSourceOfFundsURL",
        fileModel: applicant.statementOfSourceOfFundImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PaymentProofURL",
        fileModel: applicant.paymentProofImage,
      );
    }

    var addResult = await _bookingRepository.addUpdateBooking(
      body: requestBody,
      fileList: fileList,
    );

    addResult.fold(
      (failure) async {
        goRouter.pop();

        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        //CLOSE VERIFICATION DIALOG
        goRouter.pop();
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Booking Added Successfully');
        final newBooking = (response['data'] as List<BookingModel>).first;

        goRouter.pop({
          "ownerName": newBooking.applicantName,
          "status": "Booked",
        });
      },
    );
  }

  //  UPDATE BOOKING
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
    required String sourceOfFunding,
    required double agreementValue,
    required double agreementValueTds,
    required double agreementValueGSTPercentage,
    required double agreementValueGSTAmount,
    required double stampDutyPercentage,
    required double stampDutyAmount,
    required double registrationFees,
    String? parkingId,
    int? numberOfParking,
    required String handoverType,
    required DateTime registrationDate,
    required String modeOfPayment,

    /// CHANGE LATER IN API
    required String paymentRemark,
    required String otherRemark,
    required double referelPercentage,
    required double referelAmount,

    required double loyaltyPercentage,
    required double loyaltyAmount,

    required double employeeReferencePercentage,
    required double employeeReferenceAmount,
    required String flatAlterationRemark,
    required String termsAndConditionsDescription,
    String bookingType = 'FLAT',
    required int paymentScheduleSchemeMasterId,
    required String paymentScheduleScheme,
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
    required bool isApplicableOtherCharge,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "Uniquekey": uniqueKey,
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
      "SourceOfFunding": sourceOfFunding,
      if (parkingId != null && parkingId.isNotEmpty) "ParkingId": parkingId,
      if (numberOfParking != null)
        "NumberOfParking": numberOfParking.toString(),
      "HandoverType": handoverType,
      "RegistrationDate": registrationDate.toIso8601String(),
      "ModeOfPayment": modeOfPayment,
      "ReferelPercentage": referelPercentage.toString(),
      "ReferelAmount": referelAmount.toString(),
      "EmployeeReferencePercentage": employeeReferencePercentage.toString(),
      "EmployeeReferenceAmount": employeeReferenceAmount.toString(),
      "LoyaltyPercentage": loyaltyPercentage.toString(),
      "LoyaltyAmount": loyaltyAmount.toString(),
      "FlatAlterationRemark": flatAlterationRemark,
      "PaymentRemark": paymentRemark,
      "OtherRemark": otherRemark,
      "TermsAndConditionsDescription": termsAndConditionsDescription,
      "BookingType": bookingType,
      "IsApplicableOtherCharge": isApplicableOtherCharge.toString(),
      "OtherChargesDetailJSON": jsonEncode(
        otherChargesDetailJSON
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
      "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId.toString(),
      "PaymentScheduleScheme": paymentScheduleScheme,
      "PaymentScheduleDetailJSON": jsonEncode(
        paymentScheduleDetailJSON
            .map(
              (e) => {
                "BookingPaymentScheduleId": e.bookingPaymentScheduleId,
                "Type": e.type,
                "Name": e.name,
                if (e.date != null) "Date": e.date!.toIso8601String(),
                "PaymentSchedulePercentage": e.paymentSchedulePercentage,
                "PaymentScheduleCumulative": e.paymentCummulativePercentage,
                "PaymentScheduleAmount": e.paymentScheduleAmount,
                "PaymentScheduleGSTAmount": e.paymentScheduleGSTAmount,
                "PaymentScheduleTDSAmount": e.paymentScheduleTDSAmount,
                "Rank": e.ranking,
              },
            )
            .toList(),
      ),
      "BookingAmount": bookingAmount.toString(),
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
        "AddUpdateBookingApplicant[$i].ApplicantMobileNumberCountryCode":
            e.applicantMobileNumberCountryCode,
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
        "AddUpdateBookingApplicant[$i].RemoveCancelledChequeURL":
            e.cancelledChequeImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemovePOAURL":
            e.poaImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemoveIncomeForm16ITRURL":
            e.incomeForm16ItrImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemoveNreNroBankDetailsURL":
            e.nreNroBankDetailsImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemoveNomineeFormURL":
            e.nomineeFormImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemoveStatementOfSourceOfFundsURL":
            e.statementOfSourceOfFundImage.deletedFileList,
        "AddUpdateBookingApplicant[$i].RemovePaymentProofURL":
            e.paymentProofImage.deletedFileList,
      });
    }

    List<Map<String, dynamic>> fileList = [];
    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateBookingApplicant.length;
      applicantIndex++
    ) {
      final applicant = addUpdateBookingApplicant[applicantIndex];

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PhotoURL",
        fileModel: applicant.profilePhotoImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "AadharCardURL",
        fileModel: applicant.aadhaarImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PanCardURL",
        fileModel: applicant.panImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PassportURL",
        fileModel: applicant.passportImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "DrivingLicenseURL",
        fileModel: applicant.drivingLicenseImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "VotingIdURL",
        fileModel: applicant.votingIdImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "GstNumberURL",
        fileModel: applicant.gstImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "CancelledChequeURL",
        fileModel: applicant.cancelledChequeImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "POAURL",
        fileModel: applicant.poaImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "IncomeForm16ITRURL",
        fileModel: applicant.incomeForm16ItrImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "NreNroBankDetailsURL",
        fileModel: applicant.nreNroBankDetailsImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "NomineeFormURL",
        fileModel: applicant.nomineeFormImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "StatementOfSourceOfFundsURL",
        fileModel: applicant.statementOfSourceOfFundImage,
      );

      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PaymentProofURL",
        fileModel: applicant.paymentProofImage,
      );
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
        final updatedBooking = (response['data'] as List<BookingModel>).first;

        if (state.bookingList.isNotEmpty && index < state.bookingList.length) {
          final updatedList = List<BookingModel>.from(state.bookingList);

          updatedList[index] = updatedBooking;

          emit(state.copyWith(isLoading: false, bookingList: updatedList));
        }
        showSuccessMessage(context, subTitle: 'Booking Updated Successfully');
        goRouter.pop();
      },
    );
  }

  //  GET PAYMENT SCHEDULE MASTER LIST
  Future<bool> getPaymentScheduleMasterList(
    BuildContext context,
    int pageNumber, {
    required int paymentScheduleSchemeMasterId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required double agreementValueWithoutTds,
    required double agreementValueTds,
    required double agreementValueGST,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "Stage": state.searchText,
      "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId,
      "InventoryBuildingId": inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "IsCheckPermission": false,
    };

    var result = await _paymentScheduleRepository.getPaymentScheduleMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return false;
      },
      (response) {
        final List<PaymentScheduleMasterModel> masterList =
            List<PaymentScheduleMasterModel>.from(response['data'] ?? []);

        final List<BookingPaymentScheduleData> newData =
            masterList.asMap().entries.map((entry) {
              int index = entry.key;
              final master = entry.value;

              /// CALCULATIONS
              final amount =
                  (agreementValueWithoutTds *
                      master.paymentSchedulePercentage) /
                  100;
              final gstAmount =
                  (agreementValueGST * master.paymentSchedulePercentage) / 100;
              final tdsAmount =
                  (agreementValueTds * master.paymentSchedulePercentage) / 100;

              return BookingPaymentScheduleData(
                bookingPaymentScheduleId: 0,
                type: "Stage",
                name: master.stage,
                date: null,
                paymentSchedulePercentage: master.paymentSchedulePercentage,
                paymentScheduleAmount: amount,
                paymentScheduleGSTAmount: gstAmount,
                paymentScheduleTDSAmount: tdsAmount,
                paymentCummulativePercentage:
                    master.paymentCummulativePercentage,
                ranking: index + 1,
              );
            }).toList();

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.bookingPaymentScheduleList, ...newData];

        emit(
          state.copyWith(
            bookingPaymentScheduleList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
        return true;
      },
    );
  }

  // REORDER PAYMENT SCHEDULE
  void reorderPaymentSchedule(int oldIndex, int newIndex) {
    final updatedList = List.of(state.bookingPaymentScheduleList);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    // REASSIGN RANKING SEQUENTIALLY
    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i].ranking = i + 1;
    }

    // RECALCULATE CUMULATIVE PERCENTAGE
    double runningTotal = 0;
    for (int i = 0; i < updatedList.length; i++) {
      runningTotal += updatedList[i].paymentSchedulePercentage;
      updatedList[i].paymentCummulativePercentage = runningTotal;
    }

    emit(state.copyWith(bookingPaymentScheduleList: updatedList));
  }

  //UPDATE PAYMENT SCHEDULE
  void updatePaymentScheduleList(
    List<BookingPaymentScheduleData> paymentScheduleList,
  ) {
    emit(state.copyWith(bookingPaymentScheduleList: paymentScheduleList));
  }

  // UPDATE OTHER CHARGES
  void updateOtherChargesList(List<OtherChargeModel> otherChargeList) {
    emit(state.copyWith(otherChargesList: otherChargeList));
  }

  // CLEAR PAYMENT SCHEDULE
  void clearPaymentScheduleList() {
    emit(state.copyWith(bookingPaymentScheduleList: []));
  }

  // UPDATE BOOKING
  void onUpdateBookingAmount({
    required double agreementValueWithTds,
    required double agreementValueTds,
    required double agreementValueGST,
  }) {
    final List<BookingPaymentScheduleData> newData =
        state.bookingPaymentScheduleList.map((master) {
          final amount =
              (agreementValueWithTds * master.paymentSchedulePercentage) / 100;

          final gstAmount =
              master.paymentSchedulePercentage * agreementValueGST / 100;

          final tdsAmount =
              master.paymentSchedulePercentage * agreementValueTds / 100;

          return BookingPaymentScheduleData(
            bookingPaymentScheduleId: 0,
            type: "Stage",
            name: master.name,
            date: master.date,
            paymentSchedulePercentage: master.paymentSchedulePercentage,
            paymentScheduleAmount: amount,
            paymentScheduleGSTAmount: gstAmount,
            paymentScheduleTDSAmount: tdsAmount,
            paymentCummulativePercentage: master.paymentCummulativePercentage,
            ranking: master.ranking,
          );
        }).toList();

    emit(state.copyWith(bookingPaymentScheduleList: newData));
  }

  // TOTAL CUMULATIVE PERCENTAGE GETTER
  double get totalCumulativePercentage {
    return state.bookingPaymentScheduleList.fold(
      0.0,
      (sum, item) => sum + item.paymentSchedulePercentage,
    );
  }

  // REMAINING PERCENTAGE
  double get remainingPercentage {
    final total = totalCumulativePercentage;
    return (100 - total).clamp(0, 100);
  }

  //  DELETE PAYMENT SCHEDULE
  Future deletePaymentSchedule(int index, BuildContext context) async {
    DialogHelper.showProcessingOverlay(context);

    goRouter.pop();

    final updatedList = List<BookingPaymentScheduleData>.from(
      state.bookingPaymentScheduleList,
    );

    /// REMOVE ITEM
    updatedList.removeAt(index);

    /// UPDATE RANKING
    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i].ranking = i + 1;
    }

    /// RECALCULATE CUMULATIVE PERCENTAGE
    double runningTotal = 0;

    for (int i = 0; i < updatedList.length; i++) {
      runningTotal += updatedList[i].paymentSchedulePercentage;
      updatedList[i].paymentCummulativePercentage = runningTotal;
    }

    emit(state.copyWith(bookingPaymentScheduleList: updatedList));
  }

  // EXPORT BOOKING
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _bookingRepository.exportBooking(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
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
              ? "booking_${DateTime.now()}.pdf"
              : "booking_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future generateBookingPDF(
    BuildContext context,
    BookingModel bookingModel, {
    required bool isSendEmail,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _bookingRepository.exportBooking(
      pageNumber: 1,
      pageSize: 1,
      projectId: bookingModel.projectId,
      queryParams: {
        "BookingId": bookingModel.bookingId,
        "ExportType":
            isSendEmail ? "BOOKING+FORM+PDF+MAIL" : "BOOKING+FORM+PDF",
      },
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(
          context,
          'Error',
          "An error occurred while processing your request.",
        );
      },
      (response) {
        if (isSendEmail) {
          showSuccessMessage(context, subTitle: "E-Mail sent successfully");
        } else {
          showSuccessMessage(context, subTitle: "Successfully Exported as PDF");
        }
        exportExcelOrPdfMobile(
          response["data"],
          "Booking Form - ${bookingModel.projectName} - ${bookingModel.applicantName} - ${bookingModel.flat} ${DateTime.now()}.pdf",
        );
      },
    );
  }

  Future<void> applyEnquiryFilterAndSort({
    required BuildContext context,
    required DateTime? filterStartDate,
    required DateTime? filterEndDate,
    required String filterWing,
    required String filterMobileNumber,
    required String filterFlat,
    required String filterFloor,
    required String filterSource,
    required String filterSubSource,

    required int filterAgreementValue,
    required String filterBookingType,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterStartDate: filterStartDate,
        filterEndDate: filterEndDate,
        filterWing: filterWing,
        filterMobileNumber: filterMobileNumber,
        filterFlat: filterFlat,
        filterFloor: filterFloor,
        filterSource: filterSource,
        filterSubSource: filterSubSource,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        filterAgreementValue: filterAgreementValue,
        filterBookingType: filterBookingType,
        bookingList: [],
        currentPage: 1,
      ),
    );

    // Fetch new filtered list
    await getBookingList(context, 1, getProject().projectId);
  }
}
