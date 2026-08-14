import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:k3h_erp_app/core/cubit/no_internet_connection_state.dart';

class InternetCubit extends Cubit<InternetState> {
  StreamSubscription? _subscription;

  InternetCubit() : super(InternetInitial()) {
    checkInternet();
    _listenInternetChanges();
  }

  Future<void> checkInternet() async {
    final isConnected = await InternetConnection().hasInternetAccess;

    if (isConnected) {
      emit(InternetConnected());
    } else {
      emit(InternetDisconnected());
    }
  }

  void _listenInternetChanges() {
    _subscription = InternetConnection().onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        emit(InternetConnected());
      } else {
        emit(InternetDisconnected());
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
