import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/offer_hardship_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/widgets/proposed_offer_info_card.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HardshipDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final String buildingName;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;
  const HardshipDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.buildingName,
    required this.onSave,
    required this.routeAuthorizationModel,
  });

  @override
  State<HardshipDetails> createState() => _HardshipDetailsState();
}

class _HardshipDetailsState extends State<HardshipDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialAmountC, _commercialAmountC, _remarkC;

  final ValueNotifier<List<ProposedOfferHardshipDetailsWithPaymentStageData>>
  _hardshipListNotifier =
      ValueNotifier<List<ProposedOfferHardshipDetailsWithPaymentStageData>>([]);

  List<ProposedOfferHardshipDetailsWithPaymentStageData> get _corpusList =>
      _hardshipListNotifier.value;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    widget.onSave(_onSave);
    _cubit.pullHardshipDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialAmountC.dispose();
    _commercialAmountC.dispose();
    _hardshipListNotifier.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAmountC = TextEditingController();
    _commercialAmountC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var corpusDetailsModel = _cubit.state.hardshipOfferDetails!;
    _residentialAmountC.text =
        corpusDetailsModel.corpusOfferedToResidentialAmount.toString();
    _commercialAmountC.text =
        corpusDetailsModel.corpusOfferedToCommercialAmount.toString();

    _hardshipListNotifier.value = List.from(
      corpusDetailsModel.proposedOfferHardshipDetailsWithPaymentStageData,
    );
    _remarkC.text = corpusDetailsModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_corpusList.isEmpty) {
        showErrorMessage(context, 'Error', 'Please add at least one hardship.');
        return;
      }
      final residentialTotal = _corpusList
          .where((h) => h.type == 'Residential')
          .fold(0.0, (sum, i) => sum + i.amount);
      if (double.parse(_residentialAmountC.text) < residentialTotal) {
        showErrorMessage(
          context,
          "Error",
          "Residential total (${residentialTotal.toIndianCurrency()}) cannot be greater than Hardship amount (${double.parse(_residentialAmountC.text).toIndianCurrency()}).",
        );
        return;
      }
      final commercialTotal = _corpusList
          .where((h) => h.type == 'Commercial')
          .fold(0.0, (sum, i) => sum + i.amount);
      if (double.parse(_commercialAmountC.text) < commercialTotal) {
        showErrorMessage(
          context,
          "Error",
          "Commercial total (${commercialTotal.toIndianCurrency()}) cannot be greater than Hardship amount (${double.parse(_commercialAmountC.text).toIndianCurrency()}).",
        );
        return;
      }
      _cubit.addUpdateHardshipDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        hardshipOfferedToResidentialAmount: double.parse(
          _residentialAmountC.text,
        ),
        hardshipOfferedToCommercialAmount: double.parse(
          _commercialAmountC.text,
        ),
        paymentStageList: _corpusList,
        remark: _remarkC.text.trim(),
      );
    }
  }

  // HANDLE AMOUNT CHANGE
  void _handleResidentialAmountChange(double value) {
    final newList = List<ProposedOfferHardshipDetailsWithPaymentStageData>.from(
      _corpusList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Residential') {
        newList[i] = ProposedOfferHardshipDetailsWithPaymentStageData(
          proposedOfferHardshipDetailsWithPaymentStageId:
              newList[i].proposedOfferHardshipDetailsWithPaymentStageId,
          uniquekey: newList[i].uniquekey,
          buildingId: newList[i].buildingId,
          projectId: newList[i].projectId,
          type: newList[i].type,
          stage: newList[i].stage,
          stagePercentage: newList[i].stagePercentage,
          amount: value * (newList[i].stagePercentage / 100),
          createdById: newList[i].createdById,
          createdBy: newList[i].createdBy,
          createdDate: newList[i].createdDate,
          modifiedById: newList[i].modifiedById,
          modifiedBy: newList[i].modifiedBy,
          modifiedDate: newList[i].modifiedDate,
          unitSqFtLumsum: '',
          carpetAreaSqFt: 0,
        );
      }
    }
    _hardshipListNotifier.value = newList;
  }

  // HANDLE AMOUNT CHANGE
  void _handleCommercialAmountChange(double value) {
    final newList = List<ProposedOfferHardshipDetailsWithPaymentStageData>.from(
      _corpusList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Commercial') {
        newList[i] = ProposedOfferHardshipDetailsWithPaymentStageData(
          proposedOfferHardshipDetailsWithPaymentStageId:
              newList[i].proposedOfferHardshipDetailsWithPaymentStageId,
          uniquekey: newList[i].uniquekey,
          buildingId: newList[i].buildingId,
          projectId: newList[i].projectId,
          type: newList[i].type,
          stage: newList[i].stage,
          stagePercentage: newList[i].stagePercentage,
          amount: value * (newList[i].stagePercentage / 100),
          createdById: newList[i].createdById,
          createdBy: newList[i].createdBy,
          createdDate: newList[i].createdDate,
          modifiedById: newList[i].modifiedById,
          modifiedBy: newList[i].modifiedBy,
          modifiedDate: newList[i].modifiedDate,
          unitSqFtLumsum: '',
          carpetAreaSqFt: 0,
        );
      }
    }
    _hardshipListNotifier.value = newList;
  }

  Future<void> _showPopupToDeleteHardshipData() async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Are sure you want delete hardship amount?',
      'Deleting this hardship will permanently remove all associated data.',
      deleteButtonTxt: 'Delete All',
    );
    if (result && context.mounted) {
      _cubit.deleteHardshipDetails(
        // ignore: use_build_context_synchronously
        context: context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    }
  }

  Future<void> _showPopupToDeleteHardship(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a hardship payment stage?',
      'Deleting this hardship payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final newList =
          List<ProposedOfferHardshipDetailsWithPaymentStageData>.from(
            _corpusList,
          );
      newList.removeAt(index);
      _hardshipListNotifier.value = newList;
      // ignore: use_build_context_synchronously
      showSuccessMessage(context, subTitle: 'Hardship Payment Stage Removed');
    }
  }

  void _showGeneratePDFConfirmation({
    required HardshipOfferDetailsModel hardshipDetailsModel,
  }) async {
    final generatePDf = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are sure you want generate hardship?',
      message: 'Once the hardship is generated, it cannot be deleted',
      confirmText: "Generate",
    );
    if (generatePDf && mounted) {
      _cubit.generateProposedOffer(
        context,
        buildingId: hardshipDetailsModel.buildingId,
        projectId: hardshipDetailsModel.projectId,
        chargeType: 'Hardship',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.hardshipOfferDetails != null) {
            fillData();
          } else {
            _residentialAmountC.clear();
            _commercialAmountC.clear();
            _hardshipListNotifier.value = [];
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
                                svgIcon: AppAssets.hardshipDetailsIcon,
                                title: "Hardship Offer Details",
                              ),
                            ),
                            CustomIconButton.delete(
                              isDisabled:
                                  (state.hardshipOfferDetails == null ||
                                      disableAction),
                              onPressed: _showPopupToDeleteHardshipData,
                            ),
                          ],
                        ),
                        verticalSpacing(height: 15),
                        Text(
                          "Hardship Offer Amount Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder<
                          List<ProposedOfferHardshipDetailsWithPaymentStageData>
                        >(
                          valueListenable: _hardshipListNotifier,
                          builder: (context, corpusList, _) {
                            final isResidentialReadOnly = corpusList.any(
                              (item) =>
                                  (item.type).toLowerCase().trim() ==
                                  'residential',
                            );
                            final isCommercialReadOnly = corpusList.any(
                              (item) =>
                                  (item.type).toLowerCase().trim() ==
                                  'commercial',
                            );
                            return Column(
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: _hardshipListNotifier,
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        CustomTextField(
                                          title:
                                              "Residential Hardship Amount (₹)",
                                          isRequired: true,
                                          hint:
                                              "Enter Residential Hardship Amount (₹)",
                                          textController: _residentialAmountC,
                                          keyboardType: TextInputType.number,
                                          readOnly:
                                              (isResidentialReadOnly ||
                                                  disableAction),
                                          inputFormatterList:
                                              inputFormatterListForDecimalValuesFixedToTwo(
                                                10,
                                              ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return "Residential amount is required";
                                            }
                                            if (double.parse(value) < 0) {
                                              return "Amount should be positive";
                                            }
                                            return null;
                                          },
                                          onChangeFunction: (value) {
                                            _handleResidentialAmountChange(
                                              double.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                        CustomTextField(
                                          title:
                                              "Commercial Hardship Amount (₹)",
                                          isRequired: true,
                                          hint:
                                              "Enter Commercial Hardship Amount (₹)",
                                          textController: _commercialAmountC,
                                          keyboardType: TextInputType.number,
                                          readOnly:
                                              (isCommercialReadOnly ||
                                                  disableAction),
                                          inputFormatterList:
                                              inputFormatterListForDecimalValuesFixedToTwo(
                                                10,
                                              ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return "Commercial amount is required";
                                            }
                                            if (double.parse(value) < 0) {
                                              return "Amount should be positive";
                                            }
                                            return null;
                                          },
                                          onChangeFunction: (value) {
                                            _handleCommercialAmountChange(
                                              double.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                CustomTextField(
                                  title: "Remark",
                                  readOnly: disableAction,
                                  hint: "Enter Remark",
                                  textController: _remarkC,
                                  maxLines: 3,
                                  minLines: 3,
                                ),
                              ],
                            );
                          },
                        ),

                        // LITIGATION DETAILS SECTION
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hardship Offer List',
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Row(
                                  spacing: 12,
                                  children: [
                                    CustomIconButton.add(
                                      isDisabled: disableAction,
                                      onPressed: () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        final result = await goRouter.pushNamed(
                                          AppRoutes.addUpdateHardshipDetails,
                                          extra: _corpusList,
                                          queryParameters: {
                                            'projectId': Uri.encodeComponent(
                                              EncryptionManager.encryptData(
                                                widget.projectId.toString(),
                                              ),
                                            ),
                                            'buildingId': Uri.encodeComponent(
                                              EncryptionManager.encryptData(
                                                widget.buildingId.toString(),
                                              ),
                                            ),
                                            'residentialAmount':
                                                Uri.encodeComponent(
                                                  EncryptionManager.encryptData(
                                                    _residentialAmountC.text
                                                        .toString(),
                                                  ),
                                                ),
                                            'commercialAmount':
                                                Uri.encodeComponent(
                                                  EncryptionManager.encryptData(
                                                    _commercialAmountC.text
                                                        .toString(),
                                                  ),
                                                ),
                                            'buildingName': Uri.encodeComponent(
                                              EncryptionManager.encryptData(
                                                widget.buildingName,
                                              ),
                                            ),
                                          },
                                        );
                                        if (result != null &&
                                            result
                                                is List<
                                                  ProposedOfferHardshipDetailsWithPaymentStageData
                                                >) {
                                          _hardshipListNotifier.value = [];
                                          _hardshipListNotifier.value = result;
                                        }
                                      },
                                    ),
                                    CustomButton(
                                      isDisable:
                                          disableAction ||
                                          state.hardshipOfferDetails == null,
                                      text: "Generate",
                                      onPressed: () {
                                        _showGeneratePDFConfirmation(
                                          hardshipDetailsModel:
                                              state.hardshipOfferDetails!,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            verticalSpacing(height: 20),
                            ValueListenableBuilder<
                              List<
                                ProposedOfferHardshipDetailsWithPaymentStageData
                              >
                            >(
                              valueListenable: _hardshipListNotifier,
                              builder: (context, hardshipList, _) {
                                if (hardshipList.isNotEmpty) {
                                  return Column(
                                    children: List.generate(hardshipList.length, (
                                      index,
                                    ) {
                                      final corpus = hardshipList[index];

                                      return ProposedOfferInfoCard(
                                        title: corpus.stage,
                                        tag: corpus.type,
                                        disable: disableAction,
                                        onEdit: () async {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          final result = await goRouter.pushNamed(
                                            AppRoutes.addUpdateHardshipDetails,
                                            extra: _corpusList,
                                            queryParameters: {
                                              'hardship': Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(corpus.toJson()),
                                                ),
                                              ),
                                              'index': index.toString(),
                                              'projectId': Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  widget.projectId.toString(),
                                                ),
                                              ),
                                              'buildingId': Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  widget.buildingId.toString(),
                                                ),
                                              ),
                                              'residentialAmount':
                                                  Uri.encodeComponent(
                                                    EncryptionManager.encryptData(
                                                      _residentialAmountC.text
                                                          .toString(),
                                                    ),
                                                  ),
                                              'commercialAmount':
                                                  Uri.encodeComponent(
                                                    EncryptionManager.encryptData(
                                                      _commercialAmountC.text
                                                          .toString(),
                                                    ),
                                                  ),
                                              'buildingName': Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  widget.buildingName,
                                                ),
                                              ),
                                            },
                                          );
                                          if (result != null &&
                                              result
                                                  is List<
                                                    ProposedOfferHardshipDetailsWithPaymentStageData
                                                  >) {
                                            _hardshipListNotifier.value =
                                                result;
                                          }
                                        },
                                        onDelete: () {
                                          _showPopupToDeleteHardship(index);
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
                                                  title: "Percentage",
                                                  value:
                                                      "${corpus.stagePercentage.toStringAsFixed(2)}%",
                                                ),
                                                buildColumnTitleValue(
                                                  title: "Amount",
                                                  value:
                                                      (corpus.amount)
                                                          .toIndianCurrency(),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              spacing: 10,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildColumnTitleValue(
                                                  title: "Unit / SqFt / Lumsum",
                                                  value: corpus.unitSqFtLumsum,
                                                ),
                                                buildColumnTitleValue(
                                                  title: "Carpet Area\n(SqFt)",
                                                  value:
                                                      corpus.carpetAreaSqFt
                                                          .addCommas(),
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
                                        message: 'No Hardship Details Found',
                                        iconSize: 100,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
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
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: state.hardshipOfferDetails?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            state.hardshipOfferDetails?.createdDate,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.hardshipOfferDetails?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.hardshipOfferDetails?.modifiedDate,
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
