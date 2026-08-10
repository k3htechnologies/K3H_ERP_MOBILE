import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/bank_guarantee_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BankGuaranteeDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;

  const BankGuaranteeDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });

  @override
  State<BankGuaranteeDetails> createState() => _BankGuaranteeDetailsState();
}

class _BankGuaranteeDetailsState extends State<BankGuaranteeDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _accountHolderNameC,
      _remarkC,
      _stageController,
      _bankGuaranteeAmountController,
      _amountController;

  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  final ValueNotifier<
    List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  >
  _bankGuaranteeListNotifier = ValueNotifier<
    List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  >([]);

  List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  get _bankGuaranteeList => _bankGuaranteeListNotifier.value;

  final ValueNotifier<Map<String, dynamic>?> _selectedBankGuaranteeType =
      ValueNotifier(null);
  final GlobalKey<FormState> _shiftingFormKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isRelease = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    widget.onSave(_onSave);
    _cubit.pullBankGuaranteeDetails(
      context: context,
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _accountHolderNameC.dispose();
    _stageController.dispose();
    _bankGuaranteeAmountController.dispose();
    _amountController.dispose();
    _bankGuaranteeListNotifier.dispose();
    _selectedBankGuaranteeType.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _accountHolderNameC = TextEditingController();
    _stageController = TextEditingController();
    _bankGuaranteeAmountController = TextEditingController();
    _amountController = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var bankGuaranteeDetailsModel = _cubit.state.bankGuaranteeDetails!;
    _bankGuaranteeAmountController.text =
        bankGuaranteeDetailsModel.bankGuaranteeAmount.toString();
    _accountHolderNameC.text =
        bankGuaranteeDetailsModel.accountHolderName.toString();

    _bankGuaranteeListNotifier.value = List.from(
      bankGuaranteeDetailsModel
          .proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    );
    _remarkC.text = bankGuaranteeDetailsModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_bankGuaranteeList.isEmpty) {
        showErrorMessage(
          context,
          'Error',
          'Please add atleast one Bank Guarantee List',
        );
        return;
      }
      var invalidAmount = isInvalidBankGuaranteeEntry();
      if (invalidAmount != null) {
        showErrorMessage(context, "Error", invalidAmount);
        return;
      }
      _cubit.addUpdateBankGuarantee(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        bankGuaranteeAmount:
            double.tryParse(_bankGuaranteeAmountController.text) ?? 0,
        accountHolderName: _accountHolderNameC.text.trim(),
        remark: _remarkC.text.trim(),
        proposedOfferBankGuaranteeDetailsId:
            _cubit
                .state
                .bankGuaranteeDetails
                ?.proposedOfferBankGuaranteeDetailsId ??
            0,
        uniqueKey: _cubit.state.bankGuaranteeDetails?.uniquekey ?? '',
        proposedOfferBankGuaranteeDetailsWithPaymentStageData:
            _bankGuaranteeList,
      );
    }
  }

  // PREFILL DIALOG
  void _prefillDialog(
    ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel bankGuarantee,
  ) {
    _stageController.text = bankGuarantee.stage;
    _amountController.text = bankGuarantee.amount.toString();
    _isRelease.value = bankGuarantee.isRelease;
  }

  // CLEAR DIALOG
  void _clearDialog() {
    _selectedBankGuaranteeType.value = null;
    _isRelease.value = false;
    _stageController.clear();
    _amountController.clear();
  }

  // SHOW SHIFTING BOTTOM SHEET
  Future<void> _showBankGuaranteeBottomSheet({
    ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel? shifting,
    int? index,
  }) async {
    if (shifting != null) {
      _prefillDialog(shifting);
    } else {
      _clearDialog();
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Bank Guarantee Details",
      contentWidget: Form(
        key: _shiftingFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// STAGE
            CustomTextField(
              title: "Stage",
              isRequired: true,
              hint: "Enter Stage",
              textController: _stageController,
              inputFormatterList: [LengthLimitingTextInputFormatter(150)],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Stage is required";
                }
                return null;
              },
            ),

            /// AMOUNT
            CustomTextField(
              title: "Amount (₹)",
              hint: "Enter Amount",
              isRequired: true,
              textController: _amountController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Amount is required";
                }

                return null;
              },
            ),
            ValueListenableBuilder(
              valueListenable: _isRelease,
              builder: (context, isRelease, child) {
                return CustomCheckBox(
                  title: 'Is Release',
                  isSelected: isRelease,
                  onChanged: (check) {
                    _isRelease.value = check;
                  },
                );
              },
            ),
            verticalSpacing(height: 25),
          ],
        ),
      ),
      bottomActions: CustomButton(
        text: "Save",
        onPressed: () {
          if (_shiftingFormKey.currentState!.validate()) {
            final newList = List<
              ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel
            >.from(_bankGuaranteeList);
            if (shifting == null) {
              newList.add(
                ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
                  proposedOfferBankGuaranteeDetailsWithPaymentStageId: 0,
                  uniquekey: '',
                  buildingId: widget.buildingId,
                  projectId: widget.projectId,
                  stage: _stageController.text,
                  amount: double.parse(_amountController.text),
                  createdById: 1,
                  createdBy: '',
                  createdDate: DateTime.now(),
                  modifiedById: 0,
                  modifiedBy: '',
                  modifiedDate: null,
                  isRelease: _isRelease.value,
                ),
              );
            } else {
              newList[index!] =
                  ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
                    proposedOfferBankGuaranteeDetailsWithPaymentStageId:
                        shifting
                            .proposedOfferBankGuaranteeDetailsWithPaymentStageId,
                    uniquekey: shifting.uniquekey,
                    buildingId: shifting.buildingId,
                    projectId: shifting.projectId,
                    stage: _stageController.text,
                    amount: double.parse(_amountController.text),
                    createdById: shifting.createdById,
                    createdBy: shifting.createdBy,
                    createdDate: shifting.createdDate,
                    modifiedById: shifting.modifiedById,
                    modifiedBy: shifting.modifiedBy,
                    modifiedDate: shifting.modifiedDate,
                    isRelease: _isRelease.value,
                  );
            }

            _bankGuaranteeListNotifier.value = newList;
            goRouter.pop();
          }
        },
      ),
    );
  }

  Future<void> _showPopupToDeleteBankGuaranteeData() async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Are sure you want delete Bank Guarantee Amount?',
      'Deleting this Bank Guarantee will permanently remove all associated data.',
      deleteButtonTxt: 'Delete All',
    );
    if (result && context.mounted) {
      _cubit.deleteBankGuaranteeDetails(
        // ignore: use_build_context_synchronously
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
      );
    }
  }

  Future<void> _showPopupToDeleteBankGuarantee(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Bank Guarantee payment stage ?',
      'Deleting this Bank Guarantee payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final newList =
          List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>.from(
            _bankGuaranteeList,
          );
      newList.removeAt(index);
      _bankGuaranteeListNotifier.value = newList;
      showSuccessMessage(
        // ignore: use_build_context_synchronously
        context,
        subTitle: 'Bank Guarantee Payment Stage Removed',
      );
    }
  }

  String? isInvalidBankGuaranteeEntry() {
    final releaseAmount = _bankGuaranteeList
        .where((b) => b.isRelease == true)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final nonReleaseAmount = _bankGuaranteeList
        .where((b) => b.isRelease == false)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final actualAmount =
        double.tryParse(_bankGuaranteeAmountController.text) ?? 0;
    if (releaseAmount != actualAmount) {
      return "Release Amount (${releaseAmount.toIndianCurrency()}) must match Bank Guarantee Amount (${actualAmount.toIndianCurrency()}).";
    }
    if (nonReleaseAmount != actualAmount) {
      return "Non-Release Amount (${nonReleaseAmount.toIndianCurrency()}) must match Bank Guarantee Amount (${actualAmount.toIndianCurrency()}).";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.bankGuaranteeDetails != null) {
            fillData();
          } else {
            _accountHolderNameC.clear();
            _selectedBankGuaranteeType.value = null;
            _bankGuaranteeListNotifier.value = [];
            _stageController.clear();
            _bankGuaranteeAmountController.clear();
            _amountController.clear();
            _remarkC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CardHeaderTile(
                                svgIcon: AppAssets.bankGuaranteeIcon,
                                title: "Bank Guarantee Amount Details",
                              ),
                            ),
                            CustomIconButton.delete(
                              isDisabled:
                                  (state.bankGuaranteeDetails == null ||
                                      disableAction),
                              onPressed: _showPopupToDeleteBankGuaranteeData,
                            ),
                          ],
                        ),

                        verticalSpacing(),
                        ValueListenableBuilder(
                          valueListenable: _bankGuaranteeListNotifier,
                          builder: (context, bankGuaranteeListNotifier, child) {
                            return CustomTextField(
                              title: "Bank Guarantee Amount (₹)",
                              hint: "Enter Bank Guarantee Amount",
                              isRequired: true,

                              textController: _bankGuaranteeAmountController,
                              keyboardType: TextInputType.number,
                              readOnly:
                                  (bankGuaranteeListNotifier.isNotEmpty ||
                                      disableAction),
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    10,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Bank Guarantee Amount is required";
                                }

                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          title: "Account Holder Name",
                          hint: "Enter Account Holder Name",
                          isRequired: true,
                          readOnly: disableAction,
                          textController: _accountHolderNameC,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Holder Name is required";
                            }

                            return null;
                          },
                        ),

                        CustomTextField(
                          title: 'Remark',
                          hint: 'Enter Remark',
                          readOnly: disableAction,
                          textController: _remarkC,
                          minLines: 3,
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bank Guarantee List',
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            CustomIconButton.add(
                              isDisabled: disableAction,
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _showBankGuaranteeBottomSheet();
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16),
                        ValueListenableBuilder<
                          List<
                            ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel
                          >
                        >(
                          valueListenable: _bankGuaranteeListNotifier,
                          builder: (context, shiftingList, _) {
                            if (shiftingList.isNotEmpty) {
                              return Column(
                                children: List.generate(shiftingList.length, (
                                  index,
                                ) {
                                  final shifting = shiftingList[index];

                                  return ProposedOfferInfoCard(
                                    title: shifting.stage,
                                    disable: disableAction,
                                    onEdit: () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      _showBankGuaranteeBottomSheet(
                                        shifting: shifting,
                                        index: index,
                                      );
                                    },
                                    onDelete: () {
                                      _showPopupToDeleteBankGuarantee(index);
                                    },
                                    child: Column(
                                      spacing: 10,
                                      children: [
                                        Row(
                                          spacing: 10,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Amount",
                                              value:
                                                  (shifting.amount)
                                                      .toIndianCurrency(),
                                            ),
                                            buildColumnTitleValue(
                                              title: "Is Release",
                                              value:
                                                  (shifting.isRelease == true)
                                                      ? "Yes"
                                                      : "No",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: noDataWidget(
                                    iconSize: 100,
                                    message: 'No Bank Guarantee Details Found',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SectionCard(
                  title: 'Action Details',
                  titleTextColor: AppColor.black,
                  headerBackgroundColor: AppColor.grey20,
                  children: [
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: state.bankGuaranteeDetails?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            state.bankGuaranteeDetails?.createdDate,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.bankGuaranteeDetails?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.bankGuaranteeDetails?.modifiedDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
