import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'enquiry_state.dart';

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryState.initial());

  // REPOSITORIES
  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();

  // <---- GET ENQUIRY LIST ---->
  Future getEnquiryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"ApplicantName": state.searchText};
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
        emit(
          state.copyWith(
            enquiryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addUpdateEnquiry({
    required BuildContext context,

    int? index,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _enquiryRepository.addUpdateEnquiry(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final newItem = response['data'][0] as EnquiryModel;

        List<EnquiryModel> updatedList = List.from(state.enquiryList);

        if (index != null) {
          updatedList[index] = newItem;
        }

        emit(
          state.copyWith(
            enquiryList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );

        showSuccessMessage(
          context,
          subTitle:
              index != null
                  ? 'Enquiry Updated Successfully'
                  : 'Enquiry Added Successfully',
        );
      },
    );
  }
}
