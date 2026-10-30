import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_setup/company_master/data/model/company_document.model.dart';
import 'package:k3h_erp_app/features/masters/company_setup/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyDocumentScreen extends StatefulWidget {
  final int companyId;
  final String companyName;
  const CompanyDocumentScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<CompanyDocumentScreen> createState() => _CompanyDocumentScreenState();
}

class _CompanyDocumentScreenState extends State<CompanyDocumentScreen> {
  // CUBIT
  late CompanyMasterCubit _companyCubit;
  late AuthorizationModel _routeAuthorizationModel;

  // CONTROLLERS
  late TextEditingController _searchC; // app bar search + filter doc name
  late TextEditingController _filterFinancialYearC; // filter financial year
  final ValueNotifier<Map<String, dynamic>?> _selectedDocumentName =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedFinancialYear =
      ValueNotifier(null);
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  MultiFilePickerModel documentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _filterFinancialYearC = TextEditingController();
    _companyCubit = context.read<CompanyMasterCubit>();
    // NOTE: change to the correct route key of the company master screen
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.companyMaster] ??
        AuthorizationModel();
    _onScroll();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _debounce?.cancel();
    _searchC.dispose();
    _filterFinancialYearC.dispose();
    _selectedDocumentName.dispose();
    _selectedFinancialYear.dispose();
    _filterCount.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      final state = _companyCubit.state;
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          (state.companyDocumentList?.length ?? 0) <
              state.totalNumberOfRecordDocument) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _companyCubit.getCompanyDocumentsById(
            context,
            widget.companyId,
            pageNumber: _companyCubit.state.currentPageDocument + 1,
          );
        });
      }
    });
  }

  // CLEAR DIALOGUE
  void _clearDialogue() {
    _selectedDocumentName.value = null;
    _selectedFinancialYear.value = null;
    documentFile = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );
  }

  void _prefillDialogue(CompanyDocumentModel model) {
    _selectedDocumentName.value = companyDocumentList.firstWhere(
      (e) => e['DisplayName'] == model.documentName,
      orElse: () => companyDocumentList.first,
    );
    _selectedFinancialYear.value = financialYearList.firstWhere(
      (e) => e['DisplayName'] == model.financialYear,
      orElse: () => financialYearList.first,
    );
    documentFile.fileNameList =
        model.documentURL
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  // API CALL TO ADD / UPDATE
  void _addUpdateDocument(CompanyDocumentModel? model, int index) {
    if (_formKey.currentState!.validate()) {
      _companyCubit.addUpdateCompanyDocument(
        context: context,
        companyId: widget.companyId,
        companyDocumentId: model?.companyDocumentId ?? 0,
        uniqueKey: model?.uniquekey,
        index: model != null ? index : null,
        documentName: _selectedDocumentName.value?['DisplayName'],
        financialYear: _selectedFinancialYear.value?['DisplayName'],
        documentFile: documentFile,
      );
    }
  }

  // DIALOGUE TO ADD / UPDATE
  Future<void> _showDialogToAddUpdateDocument({
    CompanyDocumentModel? doc,
    int? index,
  }) async {
    _clearDialogue();
    if (doc != null) _prefillDialogue(doc);
    await DialogHelper.showCustomBottomSheet(
      context,
      "${doc != null ? 'Update' : 'Add'} Company Document",
      contentWidget: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder(
              valueListenable: _selectedDocumentName,
              builder: (context, value, _) {
                return CustomDropDownWidget(
                  title: "Document Name",
                  hintText: "Select Document Name",
                  isRequired: true,
                  dataList: companyDocumentList,
                  initialValue: value,
                  onSelected: (v) => _selectedDocumentName.value = v,
                  validator:
                      (v) => v == null ? "Document Name is required" : null,
                  onValueClear: () => _selectedDocumentName.value = null,
                );
              },
            ),

            ValueListenableBuilder(
              valueListenable: _selectedFinancialYear,
              builder: (context, value, _) {
                return CustomDropDownWidget(
                  title: "Financial Year",
                  hintText: "Select Financial Year",
                  isRequired: true,
                  dataList: financialYearList,
                  initialValue: value,
                  onSelected: (v) => _selectedFinancialYear.value = v,
                  validator:
                      (v) => v == null ? "Financial Year is required" : null,
                  onValueClear: () => _selectedFinancialYear.value = null,
                );
              },
            ),

            CustomMultiFilePicker(
              title: 'Files',
              isRequired: true,
              maxFiles: 5,
              filePickType: FilePickType.kycDocument,
              initialFileList: documentFile.fileNameList,
              onFilePickedCallback: (bytesList, fileNameList) {
                documentFile.fileNameList = fileNameList;
                documentFile.fileBytesList = bytesList;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Attachment* is required.";
                }
                return null;
              },
              onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
                documentFile.fileNameList = fileNameList;
                documentFile.fileBytesList = fileBytesList;
                documentFile.deletedFileList = deletedFile;
              },
            ),
            verticalSpacing(height: 16),
          ],
        ),
      ),
      bottomActions: CustomButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        leading: Icon(
          doc == null ? Icons.add : Icons.edit,
          size: 18,
          color: AppColor.white,
        ),
        text: doc == null ? 'Add' : 'Update',
        onPressed: () async {
          _addUpdateDocument(doc, index ?? 0);
        },
      ),
    );
  }

  // DIALOGUE TO DELETE
  Future<void> _showPopupToDeleteDocument(
    BuildContext context,
    CompanyDocumentModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Company Document ?',
      'Deleting this Company Document will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _companyCubit.deleteCompanyDocument(
        context: context,
        companyId: widget.companyId,
        companyDocumentId: obj.companyDocumentId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // FILTER BOTTOM SHEET
  Future<void> _showBottomSheetToFilterDocument(BuildContext context) async {
    final state = _companyCubit.state;

    _searchC.text = state.searchDocumentText;
    _filterFinancialYearC.text = state.filterByFinancialYear;

    String? selectedDirection =
        state.currentSortColumnDocument == "Document Name"
            ? state.currentSortDirectionDocument
            : null;

    final String initialName = _searchC.text;
    final String initialFinancialYear = _filterFinancialYearC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialName ||
            _filterFinancialYearC.text.trim() != initialFinancialYear ||
            selectedDirection != initialDirection;
        applyEnabled.value = manualClose;
      });
    }

    Widget sortChip(String label, String value, StateSetter innerState) {
      return GestureDetector(
        onTap: () {
          innerState(() => selectedDirection = value);
          updateApplyState(innerState);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                selectedDirection == value
                    ? AppColor.lightBlue
                    : Colors.transparent,
            border: Border.all(color: AppColor.grey, width: .5),
          ),
          child: Text(label, style: AppTextStyle.ts12R()),
        ),
      );
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Company Document",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By Document Name", style: AppTextStyle.ts14M()),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  sortChip("A-Z", "ASC", innerState),
                  horizontalSpacing(),
                  sortChip("Z-A", "DESC", innerState),
                ],
              ),
              verticalSpacing(height: 20),
              CustomTextField(
                textController: _searchC,
                hint: "Enter Document Name",
                title: "Document Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
              CustomTextField(
                textController: _filterFinancialYearC,
                hint: "Enter Financial Year",
                title: "Financial Year",
                inputFormatterList: [
                  LengthLimitingTextInputFormatter(9),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                ],
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),
      onClear: () {
        applied = true;
        _searchC.clear();
        _filterFinancialYearC.clear();
        _companyCubit.applyDocumentFilterAndSort(
          context: context,
          companyId: widget.companyId,
          documentName: '',
          financialYear: '',
          column: '',
          direction: '',
        );
      },
      onApply: () {
        applied = true;
        _companyCubit.applyDocumentFilterAndSort(
          context: context,
          companyId: widget.companyId,
          documentName: _searchC.text.trim(),
          financialYear: _filterFinancialYearC.text.trim(),
          column: selectedDirection != null ? "Document Name" : "",
          direction: selectedDirection ?? "",
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialName;
      _filterFinancialYearC.text = initialFinancialYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyMasterCubit, CompanyMasterState>(
      listener: (context, state) {
        _filterCount.value = _companyCubit.updateDocumentFilterCount(state);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: SearchWidget(
                      textController: _searchC,
                      hintText: "Search By Document Name",
                      isFilterOn: true,
                      filterCountNotifier: _filterCount,
                      onFilterTap:
                          () => _showBottomSheetToFilterDocument(context),
                      onSubmit: (value) {
                        _companyCubit.searchDocument(
                          context,
                          value,
                          widget.companyId,
                        );
                      },
                    ),
                  ),
                  CustomIconButton.add(
                    isDisabled: !_routeAuthorizationModel.isAction,
                    onPressed: () async {
                      await _showDialogToAddUpdateDocument();
                    },
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
                  builder: (context, state) {
                    final list = state.companyDocumentList ?? [];
                    if ((state.isLoading ?? true) && list.isEmpty) {
                      return Center(child: loader());
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: noDataWidget(
                          message: "No Company Document Found",
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      separatorBuilder:
                          (context, index) => verticalSpacing(height: 16),
                      itemCount: list.length + 1,
                      itemBuilder: (context, index) {
                        if (index == list.length) {
                          return list.length < state.totalNumberOfRecordDocument
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final doc = list[index];
                        return Container(
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  top: 16,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBluebg.withValues(
                                    alpha: 0.5,
                                  ),
                                  border: Border.all(color: AppColor.lightBlue),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doc.documentName,
                                        style: AppTextStyle.ts14M(),
                                      ),
                                    ),
                                    Row(
                                      spacing: 10,
                                      children: [
                                        CustomIconButton(
                                          isDisable: doc.documentURL.isEmpty,
                                          onPressed: () {
                                            showFilePreviewDialog(
                                              title: doc.documentName,
                                              context,
                                              doc.documentURL.split(","),
                                            );
                                          },
                                          backgroundColor: Colors.transparent,
                                          icon: Icon(
                                            Icons.remove_red_eye_outlined,
                                            color:
                                                doc.documentURL.isEmpty
                                                    ? AppColor.grey2
                                                    : AppColor.primary,
                                            size: 18,
                                          ),
                                        ),
                                        CustomIconButton.edit(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () {
                                            _showDialogToAddUpdateDocument(
                                              doc: doc,
                                              index: index,
                                            );
                                          },
                                        ),
                                        CustomIconButton.delete(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () {
                                            _showPopupToDeleteDocument(
                                              context,
                                              doc,
                                              index,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  bottom: 16,
                                ),
                                child: Column(
                                  children: [
                                    buildRowTitleValue(
                                      title: "Financial Year",
                                      fixesWidth: 140.w,
                                      value: doc.financialYear,
                                    ),
                                    buildRowTitleValue(
                                      title: "Document Count",
                                      fixesWidth: 140.w,
                                      value:
                                          doc.documentURL
                                              .split(',')
                                              .where((e) => e.trim().isNotEmpty)
                                              .length
                                              .toString(),
                                    ),
                                    buildRowTitleValue(
                                      title: "Modified By / Date",
                                      fixesWidth: 140.w,
                                      singleLine: false,
                                      value:
                                          doc.modifiedDate == null
                                              ? '${doc.createdBy} / ${formatDate(doc.createdDate)}'
                                              : '${doc.modifiedBy} / ${formatDate(doc.modifiedDate)}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
