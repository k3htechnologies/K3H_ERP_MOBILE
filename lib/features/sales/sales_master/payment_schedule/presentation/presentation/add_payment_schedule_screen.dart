import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/cubit/payment_schedule_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

import '../../data/model/payment_schedule.model.dart';

class AddPaymentScheduleScreen extends StatefulWidget {
  final PaymentScheduleMasterModel? paymentScheduleMaster;
  final int? index;

  const AddPaymentScheduleScreen({
    super.key,
    required this.paymentScheduleMaster,
    this.index = 0,
  });

  @override
  State<AddPaymentScheduleScreen> createState() =>
      _AddPaymentScheduleScreenState();
}

class _AddPaymentScheduleScreenState extends State<AddPaymentScheduleScreen> {
  /// CUBIT
  late PaymentScheduleCubit _paymentScheduleCubit;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  //  REPOSITORY
  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();
  // SELECTED STAGE
  final ValueNotifier<Map<String, dynamic>?> _selectedStage = ValueNotifier(
    null,
  );
  // CONTROLLERS
  late TextEditingController _percentageController;
  // EDIT MODE
  bool get _isEditMode => widget.paymentScheduleMaster != null;
  late List<Map<String, dynamic>> stageList;

  @override
  void initState() {
    super.initState();
    _paymentScheduleCubit = context.read<PaymentScheduleCubit>();
    _percentageController = TextEditingController();
    stageList = [];
    if (_isEditMode) {
      _populateData();
    } else {
      fetchStages();
    }
  }

  void _populateData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showProcessingOverlay(context);
    });
    final model = widget.paymentScheduleMaster!;
    try {
      await fetchStages();
      _percentageController.text = model.paymentSchedulePercentage.toString();

      _selectedStage.value = stageList.firstWhere(
        (item) =>
            item['DisplayName'].toString().toLowerCase() ==
            model.stage.toLowerCase(),
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  // FETCH STAGES FOR DROPDOWN

  Future<void> fetchStages() async {
    final result = await _bookingRepository.getPaymentScheduleStagesList(
      pageNumber: 1,
      pageSize: 15,
      projectId: getProject().projectId,
      inventoryBuildingId:
          _paymentScheduleCubit.state.selectedScheme!.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          _paymentScheduleCubit
              .state
              .selectedScheme!
              .inventoryFlatFloorBasementPodiumWingId,
    );

    return result.fold(
      (failure) => {"itemList": [], "totalNumberOfRecord": 0},
      (response) {
        final stagesList = response['data'] as List<dynamic>? ?? [];

        List.generate(stagesList.length, (index) {
          final stage = stagesList[index];

          if (!stageList.any((e) => e['zAttributesId'] == index + 1)) {
            stageList.add({
              "zAttributesId": index + 1,
              "DisplayName": stage["Stages"] ?? "",
            });
          }
        });
      },
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final percentage = double.tryParse(_percentageController.text) ?? 0;
    final selectedStageName = _selectedStage.value?["DisplayName"] ?? "";

    if (_isEditMode) {
      _paymentScheduleCubit.updatePaymentScheduleMaster(
        context: context,
        index: widget.index!,
        stage: selectedStageName,
        paymentSchedulePercentage: percentage,
        uniqueKey: widget.paymentScheduleMaster!.uniquekey,
        paymentScheduleMasterId:
            widget.paymentScheduleMaster!.paymentScheduleMasterId,
        buildingId:
            _paymentScheduleCubit.state.selectedScheme!.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            _paymentScheduleCubit
                .state
                .selectedScheme!
                .inventoryFlatFloorBasementPodiumWingId,
        paymentScheduleSchemeMasterId:
            _paymentScheduleCubit
                .state
                .selectedScheme!
                .paymentScheduleSchemeMasterId,
      );
    } else {
      _paymentScheduleCubit.addPaymentScheduleMaster(
        context: context,
        stage: selectedStageName,
        paymentSchedulePercentage: percentage,
        buildingId:
            _paymentScheduleCubit.state.selectedScheme!.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            _paymentScheduleCubit
                .state
                .selectedScheme!
                .inventoryFlatFloorBasementPodiumWingId,
        scheme: _paymentScheduleCubit.state.selectedScheme!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            _isEditMode ? "Update Payment Schedule" : "Add Payment Schedule",
        authorization: AuthorizationModel(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STAGES DROPDOWN
                    ValueListenableBuilder(
                      valueListenable: _selectedStage,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: "Stages",
                          hintText: "Select Stage",
                          isRequired: true,
                          initialValue: value,
                          dataList: stageList,
                          onSelected: (value) {
                            _selectedStage.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Stage is required.";
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    /// PERCENTAGE FIELD
                    CustomTextField(
                      textController: _percentageController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      isRequired: true,
                      hint: "Enter Percentage",
                      title: "Percentage ",
                      inputFormatterList: InputValidator.percentage(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Percentage is required.";
                        }

                        final number = double.tryParse(value);
                        if (number == null) {
                          return "Enter valid number";
                        }

                        if (number <= 0 || number > 100) {
                          return "Percentage must be between 1 and 100";
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
