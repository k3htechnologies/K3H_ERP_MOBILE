import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

class PayTrackCubit extends Cubit<PayTrackState> {
  PayTrackCubit() : super(PayTrackState.initial());
  // REPOSITORIES
  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();
  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();

  final PayTrackRepository _payTrackRepository =
      serviceLocator<PayTrackRepository>();

  Future resetOverview() async {
    emit(state.copyWith(payTrackOverview: null));
  }

  // TAB CHANGED
  void onTabChanged(
    BuildContext context,
    PayTrackTab tab, {
    int? projectId,
    int? employeeId,
  }) {
    if (tab == PayTrackTab.bankLoan && projectId != null) {
      emit(
        state.copyWith(
          payTrackList: [],
          currentPage: 1,
          totalNumberOfRecord: 0,
        ),
      );
      getPayTrackList(context, 1, projectId);
    }
  }

  Future getPayTrackList(
    BuildContext context,
    int pageNumber,
    int projectId, {
    int? bookingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        PayTrackCubit();
        emit(state.copyWith(isLoading: false, payTrackList: []));
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "BookingId": bookingId,
      "IsCheckPermission": false,
      "ApplicantName": state.searchText,
      "ApplicantMobileNumber": state.filterByMobileNumber,
      "Wing": state.filterByWing,
      "Flat": state.filterByUnit,
      "Floor": state.filterByFloor,
      "Configuration": state.filterByConfiguration,
      "AgreementValue": state.filterByAgreementValue,
      "BookingType": state.filterByBookingType,
      "FromDate": state.filterByFromDate.apiDate,
      "ToDate": state.filterByToDate.apiDate,
    };
    if (state.isFinalRegistrationCompleted != null) {
      queryParams["IsFinalRegistrationCompleted"] =
          state.isFinalRegistrationCompleted! ? "true" : "false";
    }
    var result = await _payTrackRepository.getPayTrackList(
      pageSize: 10,
      pageNumber: pageNumber,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<PayTrackModel> newList =
            response['data'] as List<PayTrackModel>;

        final updatedList =
            pageNumber == 1 ? newList : [...state.payTrackList, ...newList];

        emit(
          state.copyWith(
            payTrackList: updatedList,
            payTrackOverview: newList.isNotEmpty ? newList.first : null,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future getPayTrackListByBookingId(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"IsCheckPermission": false};
    var result = await _payTrackRepository.getPayTrackListById(
      pageSize: 10,
      pageNumber: pageNumber,
      projectId: projectId,
      bookingId: bookingId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<PayTrackModel> list =
            response['data'] as List<PayTrackModel>;

        final PayTrackModel? model = list.isNotEmpty ? list.first : null;
        emit(
          state.copyWith(
            payTrackOverview: model,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchText: "", payTrackList: [], currentPage: 1));
  }

  Future searchPayTrack(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, payTrackList: []));
    await getPayTrackList(context, 1, projectId);
  }

  Future applyPaytrackFilterAndSort({
    required BuildContext context,
    String? applicantName,
    String? mobileNumber,
    bool? isFinalRegistrationCompleted,
    String? wing,
    String? unit,
    String? floor,
    String? configuration,
    String? agreementValue,
    String? bookingType,
    DateTime? filterByFromDate,
    DateTime? filterByToDate,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByMobileNumber: "",
          isFinalRegistrationCompleted: null,
          filterByWing: "",
          filterByFloor: "",
          filterByUnit: "",
          filterByConfiguration: "",
          filterByAgreementValue: "",
          filterByBookingType: "",
          filterByFromDate: null,
          filterByToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: applicantName ?? state.searchText,
          filterByMobileNumber: mobileNumber ?? state.filterByMobileNumber,
          isFinalRegistrationCompleted:
              isFinalRegistrationCompleted ??
              state.isFinalRegistrationCompleted,
          filterByWing: wing ?? state.filterByWing,
          filterByUnit: unit ?? state.filterByUnit,
          filterByFloor: floor ?? state.filterByFloor,
          filterByConfiguration: configuration ?? state.filterByConfiguration,
          filterByAgreementValue:
              agreementValue ?? state.filterByAgreementValue,
          filterByBookingType: bookingType ?? state.filterByBookingType,
          filterByFromDate: filterByFromDate,
          filterByToDate: filterByToDate,
        ),
      );
    }
    await getPayTrackList(context, 1, getProject().projectId);
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _payTrackRepository.exportPayTrackList(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: getProject().projectId,
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
              ? "Pay Track ${DateTime.now()}.pdf"
              : "Pay Track ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  //  GET BOOKING BY ID LIST
  Future<BookingModel?> getBookingById(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId, {
    String? exportType,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "BookingId": bookingId,
      "IsCheckPermission": false,
      "ExportType": exportType,
    };

    final result = await _bookingRepository.getBookingList(
      pageNumber: pageNumber,
      pageSize: 1,
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

        emit(state.copyWith(isLoading: false, bookingData: booking));

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

    final queryParams = {"EnquiryId": enquiryId, "IsCheckPermission": false};

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

  int updatePayTrackFilterCount(PayTrackState state) {
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByMobileNumber.trim().isNotEmpty,
      state.filterByWing.trim().isNotEmpty,
      state.filterByUnit.trim().isNotEmpty,
      state.filterByFloor.trim().isNotEmpty,
      state.filterByFromDate != null,
      state.filterByToDate != null,
      state.isFinalRegistrationCompleted != null,
    ]);
  }

  Future updateRegistrationDateAndParking(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required String uniquekey,
    DateTime? finalRegistrationDate,
    required String parkingId,
    required bool isFinalRegistrationCompleted,
    required MultiFilePickerModel finalRegistrationDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, String> requestBody = {
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "Uniquekey": uniquekey,
      "ParkingId": parkingId,
      "IsFinalRegistrationCompleted": isFinalRegistrationCompleted.toString(),
      "RemoveProofOfDocumentURL": finalRegistrationDocument.deletedFileList,
    };

    if (finalRegistrationDate != null) {
      requestBody["FinalRegistrationDate"] =
          finalRegistrationDate.toIso8601String();
    }

    final List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < finalRegistrationDocument.fileNameList.length; i++) {
      if (finalRegistrationDocument.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "FinalRegistrationURL",
        "value": finalRegistrationDocument.fileBytesList[i],
        "fileName": finalRegistrationDocument.fileNameList[i],
      });
    }

    final result = await _payTrackRepository
        .updatePayTrackBookingRegistrationDateParking(
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
        getBookingById(context, 1, projectId, bookingId);
        await getPayTrackListByBookingId(context, 1, projectId, bookingId);
        goRouter.pop();
      },
    );
  }
}
