import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  final bool? isLoading;
  final StateType? stateType;

  const BaseState({this.isLoading, this.stateType});
}

enum StateType {
  initial,
  sendOTP,
  companyPartnerLoading,
  employeeMasterListState,
  employeeMasterModuleAccessState,
  // <---- SALES ---->
  channelPartnerBookingState,
  // CALL TRACKER
  callingData,
  callLog,
}
