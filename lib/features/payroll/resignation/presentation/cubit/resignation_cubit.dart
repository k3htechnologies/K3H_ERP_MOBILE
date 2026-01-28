import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/repository/resignation.repository.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_state.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:bloc/bloc.dart';

class ResignationCubit extends Cubit<ResignationState> {
  ResignationCubit() : super(ResignationState.initial());

  //REPOSITORY
  final ResignationRepository _resignationRepository =
      serviceLocator<ResignationRepository>();

  // <---- GET RESIGNATION LIST ---->
  Future getResignationList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    var result = await _resignationRepository.getResignationList(
      pageNumber: pageNumber,
      pageSize: 10,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ResignationModel> newData = List<ResignationModel>.from(
          response['data'] ?? [],
        );

        final List<ResignationModel> updatedList =
            pageNumber == 1 ? newData : [...state.resignationList, ...newData];
        emit(
          state.copyWith(
            resignationList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
