import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:meta/meta.dart';

part 'payment_schedule_summary_state.dart';

class PaymentScheduleSummaryCubit extends Cubit<PaymentScheduleSummaryState> {
  PaymentScheduleSummaryCubit() : super(PaymentScheduleSummaryState.initial());

  // <---- ON TAB CHANGED ---->
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

}
