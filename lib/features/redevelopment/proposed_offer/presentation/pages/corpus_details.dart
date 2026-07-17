import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/corpus_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HardshipDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  const HardshipDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
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
  _corpusListNotifier =
      ValueNotifier<List<ProposedOfferHardshipDetailsWithPaymentStageData>>([]);

  List<ProposedOfferHardshipDetailsWithPaymentStageData> get _corpusList =>
      _corpusListNotifier.value;

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
    _corpusListNotifier.dispose();
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
    var corpusDetailsModel = _cubit.state.corpusDetails!;
    _residentialAmountC.text =
        corpusDetailsModel.corpusOfferedToResidentialAmount.toString();
    _commercialAmountC.text =
        corpusDetailsModel.corpusOfferedToCommercialAmount.toString();

    _corpusListNotifier.value = List.from(
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
      _cubit.addUpdateHardshipDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        corpusOfferedToResidentialAmount: double.parse(
          _residentialAmountC.text,
        ),
        corpusOfferedToCommercialAmount: double.parse(_commercialAmountC.text),
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
    _corpusListNotifier.value = newList;
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
    _corpusListNotifier.value = newList;
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
      _corpusListNotifier.value = newList;
      // ignore: use_build_context_synchronously
      showSuccessMessage(context, subTitle: 'Hardship Payment Stage Removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.corpusDetails != null) {
            fillData();
          } else {
            _residentialAmountC.clear();
            _commercialAmountC.clear();
            _corpusListNotifier.value = [];
            _remarkC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
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
                          child: ProposedOfferTile(
                            icon: AppAssets.corpusDetailsIcon,
                            title: "Hardship Details",
                          ),
                        ),
                        CustomIconButton.delete(
                          isDisabled: state.corpusDetails == null,
                          onPressed: _showPopupToDeleteHardshipData,
                        ),
                      ],
                    ),
                    verticalSpacing(height: 15),
                    Text(
                      "Hardship Amount Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<
                      List<ProposedOfferHardshipDetailsWithPaymentStageData>
                    >(
                      valueListenable: _corpusListNotifier,
                      builder: (context, corpusList, _) {
                        final isResidentialReadOnly = corpusList.any(
                          (item) =>
                              (item.type).toLowerCase().trim() == 'residential',
                        );
                        final isCommercialReadOnly = corpusList.any(
                          (item) =>
                              (item.type).toLowerCase().trim() == 'commercial',
                        );
                        return Column(
                          children: [
                            CustomTextField(
                              title: "Residential Hardship Amount (₹)",
                              isRequired: true,
                              hint: "Enter Residential Hardship Amount (₹)",
                              textController: _residentialAmountC,
                              keyboardType: TextInputType.number,
                              readOnly: isResidentialReadOnly,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    10,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                              title: "Commercial Hardship Amount (₹)",
                              isRequired: true,
                              hint: "Enter Commercial Hardship Amount (₹)",
                              textController: _commercialAmountC,
                              keyboardType: TextInputType.number,
                              readOnly: isCommercialReadOnly,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    10,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                            CustomTextField(
                              title: "Remark",
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
                              'Hardship List',
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            CustomIconButton.add(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
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
                                    'residentialAmount': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        _residentialAmountC.text.toString(),
                                      ),
                                    ),
                                    'commercialAmount': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        _commercialAmountC.text.toString(),
                                      ),
                                    ),
                                  },
                                );
                                if (result != null &&
                                    result
                                        is List<
                                          ProposedOfferHardshipDetailsWithPaymentStageData
                                        >) {
                                  _corpusListNotifier.value = result;
                                }
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        ValueListenableBuilder<
                          List<ProposedOfferHardshipDetailsWithPaymentStageData>
                        >(
                          valueListenable: _corpusListNotifier,
                          builder: (context, corpusList, _) {
                            if (corpusList.isNotEmpty) {
                              return Column(
                                children: List.generate(corpusList.length, (
                                  index,
                                ) {
                                  final corpus = corpusList[index];

                                  return CommonInfoCard(
                                    title: corpus.stage,
                                    tag: corpus.type,
                                    onEdit: () async {
                                      if (!_formKey.currentState!.validate()) {
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
                                        },
                                      );
                                      if (result != null &&
                                          result
                                              is List<
                                                ProposedOfferHardshipDetailsWithPaymentStageData
                                              >) {
                                        _corpusListNotifier.value = result;
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
                                              title: "Unit / Sq Ft / Lumsum",
                                              value: corpus.unitSqFtLumsum,
                                            ),
                                            buildColumnTitleValue(
                                              title: "Carpet Area\n(Sq Ft)",
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
          );
        },
      ),
    );
  }
}
