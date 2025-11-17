import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class MainScreenCubit extends Cubit<Key> {
  MainScreenCubit() : super(UniqueKey());

  void rebuildChild() {
    emit(UniqueKey());
  }

}