import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
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
    };

    if (state.filterByApplicantName.isNotEmpty) {
      queryParams["ApplicantName"] = state.filterByApplicantName;
    } else if (state.searchText.isNotEmpty) {
      queryParams["ApplicantName"] = state.searchText;
    }

    if (state.filterByMobileNumber.isNotEmpty) {
      queryParams["ApplicantMobileNumber"] = state.filterByMobileNumber;
    }

    if (state.filterByWing.isNotEmpty) {
      queryParams["Wing"] = state.filterByWing;
    }

    if (state.filterByUnit.isNotEmpty) {
      queryParams["Flat"] = state.filterByUnit;
    }

    if (state.filterByFloor.isNotEmpty) {
      queryParams["Floor"] = state.filterByFloor;
    }
    if (state.isFinalRegistrationCompleted != null) {
      queryParams["IsFinalRegistrationCompleted"] =
          state.isFinalRegistrationCompleted! ? "true" : "false";
    }
    if (state.filterByConfiguration.isNotEmpty) {
      queryParams["Configuration"] = state.filterByConfiguration;
    }
    if (state.filterByAgreementValue.isNotEmpty) {
      queryParams["AgreementValue"] = state.filterByAgreementValue;
    }
    if (state.filterByBookingType.isNotEmpty) {
      queryParams["BookingType"] = state.filterByBookingType;
    }
    if (state.filterByFromDate != null) {
      queryParams["FromDate"] = state.filterByFromDate!.toIso8601String();
    }

    if (state.filterByToDate != null) {
      queryParams["ToDate"] = state.filterByToDate!.toIso8601String();
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
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        PayTrackCubit();
        emit(state.copyWith(isLoading: false, payTrackList: []));
      });
      return;
    }
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
            payTrackList: list,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future searchPayTrack(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, payTrackList: []));
    await getPayTrackList(context, 1, projectId);
  }

  Future applyChannelPartnerFilterAndSort({
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
          filterByApplicantName: "",
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
          filterByApplicantName: applicantName ?? state.filterByApplicantName,
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

  Future getPayTrackCallLog(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        PayTrackCubit();
        emit(state.copyWith(isLoading: false, payTrackList: []));
      });
      return;
    }
    Map<String, dynamic> queryParams = {"BookingId": bookingId};

    var result = await _payTrackRepository.getPayTrackCallLog(
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
        emit(
          state.copyWith(
            payTrackCallLogList: response['data'] as List<PayTrackCallLogModel>,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }
}
