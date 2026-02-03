import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  // CUBIT
  late ApprovedBankFolderCubit _approvedBankFolderCubit;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _approvedBankFolderCubit = context.read<ApprovedBankFolderCubit>();
    _onScroll();
    _approvedBankFolderCubit.getBankList(context, 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_approvedBankFolderCubit.state.isLoading! &&
          _approvedBankFolderCubit.state.bankList.length <
              _approvedBankFolderCubit.state.totalNumberOfRecordBank) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _approvedBankFolderCubit.getBankList(
            context,
            _approvedBankFolderCubit.state.currentPageBank + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Approved Bank",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<ApprovedBankFolderCubit, ApprovedBankFolderState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.bankList.isEmpty) {
            return Center(child: loader());
          }
          if (state.bankList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shrinkWrap: true,
            controller: scrollController,
            itemCount: _approvedBankFolderCubit.state.bankList.length + 1,
            itemBuilder: (_, index) {
              if (index == state.bankList.length) {
                return state.bankList.length < state.totalNumberOfRecordBank
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              final bank = state.bankList[index];
              return Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Row(
                  children: [
                    // RADIO BUTTON

                    // BANK NAME
                    Expanded(child: Text(bank.bankNameWithCode)),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(child: Container(
        height: 70,
        padding: EdgeInsets.all(16),
        child: CustomButton(
          leading: Icon(Icons.add,color: AppColor.white,size: 18,),
            text: "Add Bank", onPressed: (){}),
      )),
    );
  }
}
