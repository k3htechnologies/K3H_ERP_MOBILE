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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

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
    int projectId,
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
    Map<String, dynamic> queryParams = {
      "ApplicantName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

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
        emit(
          state.copyWith(
            payTrackList: response['data'] as List<PayTrackModel>,
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

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _payTrackRepository.exportPayTrackList(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
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
