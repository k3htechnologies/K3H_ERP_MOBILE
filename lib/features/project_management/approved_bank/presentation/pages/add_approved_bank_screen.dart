import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddApprovedBankScreen extends StatefulWidget {
  const AddApprovedBankScreen({super.key});

  @override
  State<AddApprovedBankScreen> createState() => _AddApprovedBankScreenState();
}

class _AddApprovedBankScreenState extends State<AddApprovedBankScreen> {
  // CUBIT
  late ApprovedBankFolderCubit _approvedBankFolderCubit;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // SELECTED BANKS FOR ADD API (multiple, comma-separated)
  final ValueNotifier<Set<int>> _selectedBankIds = ValueNotifier({});
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _approvedBankFolderCubit = context.read<ApprovedBankFolderCubit>();
    _project = getProject();
    _onScroll();
    _approvedBankFolderCubit.getBankList(context, 1, clearSearch: true);
  }

  @override
  void dispose() {
    _searchC.dispose();
    _debounce?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (!mounted) return;
      if (!scrollController.hasClients) return;
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_approvedBankFolderCubit.state.isLoading! &&
          _approvedBankFolderCubit.state.bankList.length <
              _approvedBankFolderCubit.state.totalNumberOfRecordBank) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          _approvedBankFolderCubit.getBankList(
            context,
            _approvedBankFolderCubit.state.currentPageBank + 1,
          );
        });
      }
    });
  }

  void _toggleBank(int bankId) {
    final updated = Set<int>.from(_selectedBankIds.value);
    if (updated.contains(bankId)) {
      updated.remove(bankId);
    } else {
      updated.add(bankId);
    }
    _selectedBankIds.value = updated; // new reference -> triggers rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Approved Bank",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SearchWidget(
              hintText: "Search By Bank Name",
              onSubmit: (value) {
                _approvedBankFolderCubit.searchBank(
                  context,
                  value,
                  _project.projectId,
                );
              },
              textController: _searchC,
            ),
          ),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<
              ApprovedBankFolderCubit,
              ApprovedBankFolderState
            >(
              builder: (context, state) {
                if ((state.isLoading ?? true) && state.bankList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.bankList.isEmpty) {
                  return Center(child: noDataWidget());
                }
                final list = state.bankList;
                final itemCount = list.length + 1;
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: itemCount,
                  itemBuilder: (_, index) {
                    if (index >= list.length) {
                      return list.length < state.totalNumberOfRecordBank
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    final bank = list[index];

                    return ValueListenableBuilder(
                      valueListenable: _selectedBankIds,
                      builder: (context, selectedBankIds, child) {
                        final isSelected = selectedBankIds.contains(
                          bank.bankListMasterId,
                        );
                        return InkWell(
                          onTap: () => _toggleBank(bank.bankListMasterId),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: commonCardDecoration(),
                            child: CustomCheckBox(
                              isSelected: isSelected,
                              title: bank.bankNameWithCode,
                              onChanged:
                                  (_) => _toggleBank(bank.bankListMasterId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(Icons.add, color: AppColor.white, size: 18),
            text: "Add Bank",
            onPressed: () {
              if (_selectedBankIds.value.isEmpty) {
                showErrorMessage(
                  context,
                  'Error',
                  'Please select at least one bank',
                );
                return;
              }
              _approvedBankFolderCubit.addApproveBankFolder(
                context: context,
                projectId: _project.projectId,
                bankListMasterId: _selectedBankIds.value.join(','),
              );
            },
          ),
        ),
      ),
    );
  }
}
