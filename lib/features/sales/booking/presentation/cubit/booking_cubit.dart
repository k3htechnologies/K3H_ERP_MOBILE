import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingState.initial());

  // REPOSITORIES
  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
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
}
