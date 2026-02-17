import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

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
    final Map<String, dynamic>? queryParams = (searchQuery != null && searchQuery.isNotEmpty)
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
}
