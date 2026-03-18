import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/cubit/bank_list_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BankListScreen extends StatefulWidget {
  const BankListScreen({super.key});

  @override
  State<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends State<BankListScreen> {
  // CUBIT
  late BankListMasterCubit _bankListMasterCubit;

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
    _bankListMasterCubit = context.read<BankListMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.bankListMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _bankListMasterCubit.getBankList(context, 1, 15);
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
          !(_bankListMasterCubit.state.isLoading ?? false) &&
          _bankListMasterCubit.state.bankList.length <
              _bankListMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _bankListMasterCubit.getBankList(
            context,
            _bankListMasterCubit.state.currentPage + 1,
            15,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: "Bank List Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _bankListMasterCubit.searchBank(context, value);
        },
        textController: _searchC,
        searchHintText: "Search By Bank Name",
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _bankListMasterCubit.searchBank(context, "");
        },
        child: BlocBuilder<BankListMasterCubit, BankListMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.bankList.isEmpty) {
              return Center(child: loader());
            }
            if (state.bankList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(message: "No Banks List Found"),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.bankList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.bankList.length) {
                  return state.bankList.length < state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var bank = state.bankList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Container(
                    decoration: commonCardDecoration(),
                    child: Text(
                      bank.bankNameWithCode,
                      style: AppTextStyle.ts14SB(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
