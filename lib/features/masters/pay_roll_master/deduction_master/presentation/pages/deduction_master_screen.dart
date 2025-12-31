import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class DeductionMasterScreen extends StatefulWidget {
  const DeductionMasterScreen({super.key});

  @override
  State<DeductionMasterScreen> createState() => _DeductionMasterScreenState();
}

class _DeductionMasterScreenState extends State<DeductionMasterScreen> {
  // CUBIT
  late DeductionMasterCubit _deductionMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _deductionMasterCubit = context.read<DeductionMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.deductionMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _deductionMasterCubit.getDeductionList(
      context: context,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_deductionMasterCubit.state.isLoading ?? false) &&
          _deductionMasterCubit.state.deductionList.length <
              _deductionMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _deductionMasterCubit.getDeductionList(
            context: context,
            pageNumber: _deductionMasterCubit.state.currentPage + 1,
            pageSize: 10,
          );
        });
      }
    });
  }

  // <---- DELETE ASSET MAPPING ---->
  Future<void> _showPopupToDeleteAssetMappingMaster(
      BuildContext context,
      DeductionMasterModel obj,
      int currentPage,
      int index,
      ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Asset Mapping?',
      'Deleting this Asset Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _deductionMasterCubit.deleteDeduction(currentPage, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Deduction",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _deductionMasterCubit.searchAssetMapping(value, context);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _deductionMasterCubit.exportExcelPdf(context, value);
        },
      ),
    );
  }
}
