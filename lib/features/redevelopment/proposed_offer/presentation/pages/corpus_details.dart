import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/corpus_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CorpusDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const CorpusDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<CorpusDetails> createState() => _CorpusDetailsState();
}

class _CorpusDetailsState extends State<CorpusDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialAmountController;
  late TextEditingController _commercialAmountController;
  final List<Map<String, dynamic>> _litigationTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
  ];

  final ValueNotifier<List<ProposedOfferCorpusDetailsWithPaymentStageData>>
  _corpusListNotifier =
      ValueNotifier<List<ProposedOfferCorpusDetailsWithPaymentStageData>>([]);

  List<ProposedOfferCorpusDetailsWithPaymentStageData> get _corpusList =>
      _corpusListNotifier.value;

  // LITIGATION FORM CONTROLLERS
  final ValueNotifier<Map<String, dynamic>?> _selectedCorpusType =
      ValueNotifier<Map<String, dynamic>?>(null);
  late TextEditingController _stageController;
  late TextEditingController _stagePercentageController;
  late TextEditingController _amountController;
  final GlobalKey<FormState> _corpusFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullCorpusDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialAmountController.dispose();
    _commercialAmountController.dispose();
    _stageController.dispose();
    _stagePercentageController.dispose();
    _amountController.dispose();
    _corpusListNotifier.dispose();
    _selectedCorpusType.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAmountController = TextEditingController();
    _commercialAmountController = TextEditingController();
    _stageController = TextEditingController();
    _stagePercentageController = TextEditingController();
    _amountController = TextEditingController();
  }

  // CHECK IF AMOUNT EXCEEDS ALLOCATED LIMIT
  bool _isAmountExceedingForSelectedType(int? editIndex) {
    final selectedType = _selectedCorpusType.value;
    if (selectedType == null) return false;

    double limit = 0;
    final typeId = selectedType['zAttributesId'];

    if (typeId == 1) {
      limit = double.tryParse(_residentialAmountController.text) ?? 0;
    } else if (typeId == 2) {
      limit = double.tryParse(_commercialAmountController.text) ?? 0;
    }

    double currentAmount = double.tryParse(_amountController.text) ?? 0;
    double sum = currentAmount;

    for (int i = 0; i < _corpusList.length; i++) {
      if (editIndex != null && i == editIndex) continue;

      final item = _corpusList[i];

      if (item.type == selectedType['DisplayName']) {
        sum += item.amount;
      }
    }

    return sum > limit;
  }

  // FILL DATA
  void fillData() {
    var corpusDetailsModel = _cubit.state.corpusDetails!;
    _residentialAmountController.text =
        corpusDetailsModel.corpusOfferedToResidentialAmount.toString();
    _commercialAmountController.text =
        corpusDetailsModel.corpusOfferedToCommercialAmount.toString();

    _corpusListNotifier.value = List.from(
      corpusDetailsModel.proposedOfferCorpusDetailsWithPaymentStageData,
    );
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_corpusList.isEmpty) {
        showErrorMessage(context, 'Error', 'Please add at least one corpus.');
        return;
      }
      _cubit.addUpdateCorpusDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        corpusOfferedToResidentialAmount: double.parse(
          _residentialAmountController.text,
        ),
        corpusOfferedToCommercialAmount: double.parse(
          _commercialAmountController.text,
        ),
        paymentStageList: _corpusList,
      );
    }
  }

  // HANDLE AMOUNT CHANGE
  void _handleResidentialAmountChange(double value) {
    final newList = List<ProposedOfferCorpusDetailsWithPaymentStageData>.from(
      _corpusList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Residential') {
        newList[i] = ProposedOfferCorpusDetailsWithPaymentStageData(
          proposedOfferCorpusDetailsWithPaymentStageId:
              newList[i].proposedOfferCorpusDetailsWithPaymentStageId,
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
        );
      }
    }
    _corpusListNotifier.value = newList;
  }

  // HANDLE AMOUNT CHANGE
  void _handleCommercialAmountChange(double value) {
    final newList = List<ProposedOfferCorpusDetailsWithPaymentStageData>.from(
      _corpusList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Commercial') {
        newList[i] = ProposedOfferCorpusDetailsWithPaymentStageData(
          proposedOfferCorpusDetailsWithPaymentStageId:
              newList[i].proposedOfferCorpusDetailsWithPaymentStageId,
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
        );
      }
    }
    _corpusListNotifier.value = newList;
  }

  // PREFILL BOTTOM SHEET
  void _prefillBottomSheet(
    ProposedOfferCorpusDetailsWithPaymentStageData corpus,
  ) {
    _selectedCorpusType.value = _litigationTypeList.firstWhere(
      (e) => e['DisplayName'] == corpus.type,
      orElse: () => _litigationTypeList.first,
    );
    _stageController.text = corpus.stage;
    _stagePercentageController.text = corpus.stagePercentage.toString();
    _amountController.text = corpus.amount.toString();
  }

  // CLEAR DIALOG
  void _clearDialog() {
    _selectedCorpusType.value = null;
    _stageController.clear();
    _stagePercentageController.clear();
    _amountController.clear();
  }

  // SHOW CORPUS BOTTOM SHEET
  Future<void> _showCorpusBottomSheet({
    ProposedOfferCorpusDetailsWithPaymentStageData? corpus,
    int? index,
  }) async {
    if (corpus != null) {
      _prefillBottomSheet(corpus);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Corpus Details",
      SingleChildScrollView(
        child: ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedCorpusType,
          builder: (context, selectedCorpusType, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _corpusFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// TYPE
                    CustomDropDownWidget(
                      isRequired: true,
                      initialValue: selectedCorpusType,
                      dataList: _litigationTypeList,
                      onSelected: (value) {
                        _selectedCorpusType.value = value;
                        _amountController.text = '0.0';
                        _stagePercentageController.text = '0.0';
                      },
                      title: "Type",
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return "Type is required";
                        }
                        return null;
                      },
                      onValueClear: () {
                        selectedCorpusType = null;
                      },
                    ),

                    // STAGE
                    CustomTextField(
                      title: "Stage",
                      isRequired: true,
                      hint: "Enter Stage",
                      textController: _stageController,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Stage is required";
                        }
                        return null;
                      },
                    ),

                    // STAGE %
                    CustomTextField(
                      title: "Stage Percentage (%)",
                      isRequired: true,
                      hint: "Enter Stage Percentage",
                      textController: _stagePercentageController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(3),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Amount is required";
                        }

                        if (_isAmountExceedingForSelectedType(index)) {
                          return "Amount exceeds allocated limit";
                        }
                        return null;
                      },
                      onChangeFunction: (value) {
                        if (selectedCorpusType == null ||
                            selectedCorpusType?['zAttributesId'] == -1) {
                          return;
                        }

                        double percentage = double.tryParse(value) ?? 0;

                        if (selectedCorpusType?['zAttributesId'] == 1) {
                          _amountController.text =
                              ((double.tryParse(
                                            _residentialAmountController.text,
                                          ) ??
                                          0) *
                                      percentage /
                                      100)
                                  .toString();
                        } else if (selectedCorpusType?['zAttributesId'] == 2) {
                          _amountController.text =
                              ((double.tryParse(
                                            _commercialAmountController.text,
                                          ) ??
                                          0) *
                                      percentage /
                                      100)
                                  .toString();
                        }
                      },
                    ),

                    // AMOUNT
                    CustomTextField(
                      title: "Amount (₹)",
                      textController: _amountController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Amount is required";
                        }

                        double amount = double.tryParse(value) ?? 0;

                        if (selectedCorpusType == null ||
                            selectedCorpusType?['zAttributesId'] == -1) {
                          return "Type must be selected first";
                        }

                        if (selectedCorpusType?['zAttributesId'] == 1 &&
                            (double.tryParse(
                                      _residentialAmountController.text,
                                    ) ??
                                    0) ==
                                0) {
                          return "Residential amount is required";
                        }

                        if (selectedCorpusType?['zAttributesId'] == 2 &&
                            (double.tryParse(
                                      _commercialAmountController.text,
                                    ) ??
                                    0) ==
                                0) {
                          return "Commercial amount is required";
                        }

                        if (amount == 0) {
                          return "Amount cannot be zero";
                        }

                        return null;
                      },
                    ),

                    verticalSpacing(height: 20),

                    // SAVE BUTTON
                    CustomButton(
                      text: "Save",
                      onPressed: () {
                        if (_corpusFormKey.currentState!.validate()) {
                          if (selectedCorpusType!['zAttributesId'] == 1 &&
                              (double.tryParse(
                                        _residentialAmountController.text,
                                      ) ??
                                      0) ==
                                  0) {
                            showErrorMessage(
                              context,
                              'Error',
                              'Residential amount is required.',
                            );
                            return;
                          }

                          if (selectedCorpusType?['zAttributesId'] == 2 &&
                              (double.tryParse(
                                        _commercialAmountController.text,
                                      ) ??
                                      0) ==
                                  0) {
                            showErrorMessage(
                              context,
                              'Error',
                              'Commercial amount is required.',
                            );
                            return;
                          }

                          final newList = List<
                            ProposedOfferCorpusDetailsWithPaymentStageData
                          >.from(_corpusList);
                          if (corpus == null) {
                            newList.add(
                              ProposedOfferCorpusDetailsWithPaymentStageData(
                                proposedOfferCorpusDetailsWithPaymentStageId: 0,
                                uniquekey: '',
                                buildingId: widget.buildingId,
                                projectId: widget.projectId,
                                type: selectedCorpusType?['DisplayName'],
                                stage: _stageController.text,
                                stagePercentage: double.parse(
                                  _stagePercentageController.text,
                                ),
                                amount: double.parse(_amountController.text),
                                createdById: 1,
                                createdBy: 'Current User',
                                createdDate: DateTime.now(),
                                modifiedById: 0,
                                modifiedBy: '',
                                modifiedDate: null,
                              ),
                            );
                          } else {
                            newList[index!] =
                                ProposedOfferCorpusDetailsWithPaymentStageData(
                                  proposedOfferCorpusDetailsWithPaymentStageId:
                                      corpus
                                          .proposedOfferCorpusDetailsWithPaymentStageId,
                                  uniquekey: corpus.uniquekey,
                                  buildingId: corpus.buildingId,
                                  projectId: corpus.projectId,
                                  type: selectedCorpusType?['DisplayName'],
                                  stage: _stageController.text,
                                  stagePercentage: double.parse(
                                    _stagePercentageController.text,
                                  ),
                                  amount: double.parse(_amountController.text),
                                  createdById: corpus.createdById,
                                  createdBy: corpus.createdBy,
                                  createdDate: corpus.createdDate,
                                  modifiedById: corpus.modifiedById,
                                  modifiedBy: corpus.modifiedBy,
                                  modifiedDate: corpus.modifiedDate,
                                );
                          }

                          _corpusListNotifier.value = newList;
                          Navigator.pop(context);
                        }
                      },
                    ),
                    verticalSpacing(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    _clearDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.corpusDetails != null) {
            fillData();
          } else {
            _residentialAmountController.clear();
            _commercialAmountController.clear();
            _selectedCorpusType.value = null;
            _corpusListNotifier.value = [];
            _stageController.clear();
            _stagePercentageController.clear();
            _amountController.clear();
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
                    Text("Corpus Details", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    Text(
                      "Corpus Amount Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<
                      List<ProposedOfferCorpusDetailsWithPaymentStageData>
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
                              title: "Residential Corpus Amount (₹)",
                              isRequired: true,
                              hint: "Enter Residential Corpus Amount (₹)",
                              textController: _residentialAmountController,
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
                              title: "Commercial Corpus Amount (₹)",
                              isRequired: true,
                              hint: "Enter Commercial Corpus Amount (₹)",
                              textController: _commercialAmountController,
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
                            Text('Corpus List', style: AppTextStyle.ts16M()),
                            CustomButton(
                              onPressed: () => _showCorpusBottomSheet(),
                              text: "Add Corpus",
                              leading: Icon(Icons.add, color: AppColor.white),
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        ValueListenableBuilder<
                          List<ProposedOfferCorpusDetailsWithPaymentStageData>
                        >(
                          valueListenable: _corpusListNotifier,
                          builder: (context, corpusList, _) {
                            if (corpusList.isNotEmpty) {
                              return Column(
                                children: List.generate(corpusList.length, (
                                  index,
                                ) {
                                  final corpus = corpusList[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColor.grey.withAlpha(80),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// HEADER ROW (TYPE + ACTIONS)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                corpus.type,
                                                style: AppTextStyle.ts16M(),
                                              ),

                                              Row(
                                                children: [
                                                  CustomIconButton.edit(
                                                    onPressed: () {
                                                      _showCorpusBottomSheet(
                                                        corpus: corpus,
                                                        index: index,
                                                      );
                                                    },
                                                  ),

                                                  const SizedBox(width: 12),

                                                  CustomIconButton.delete(
                                                    onPressed: () {
                                                      final newList = List<
                                                        ProposedOfferCorpusDetailsWithPaymentStageData
                                                      >.from(corpusList);
                                                      newList.removeAt(index);
                                                      _corpusListNotifier
                                                          .value = newList;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          Divider(
                                            color: AppColor.grey.withAlpha(60),
                                          ),

                                          _buildInfoRow("Stage", corpus.stage),
                                          _buildInfoRow(
                                            "Stage %",
                                            "${corpus.stagePercentage.toStringAsFixed(2)}%",
                                          ),
                                          _buildInfoRow(
                                            "Amount",
                                            "₹${corpus.amount.toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    'No details added',
                                    style: AppTextStyle.ts16R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        verticalSpacing(height: 20),
                        CustomButton(text: "Save", onPressed: _onSave),
                        verticalSpacing(height: 20),
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

  // HELPER METHODS
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          ),
          Text(": "),
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
