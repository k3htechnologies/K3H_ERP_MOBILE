import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/presentation/cubit/payment_schedule_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
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
  List<Map<String, dynamic>> _selectedStage = [];
  // CONTROLLERS
  late TextEditingController _percentageController;
  // EDIT MODE CHECK
  bool get _isEditMode => widget.paymentScheduleMaster != null;

  @override
  void initState() {
    super.initState();
    _paymentScheduleCubit = context.read<PaymentScheduleCubit>();
    _percentageController = TextEditingController();
    if (_isEditMode) {
      _populateData();
    }
  }

  void _populateData() {
    final model = widget.paymentScheduleMaster!;

    _selectedStage = [
      {"zAttributesId": 0, "DisplayName": model.stage},
    ];

    _percentageController.text = model.paymentSchedulePercentage.toString();
  }

  // FETCH STAGES FOR DROPDOWN

  Future<Map<String, dynamic>> fetchStages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _bookingRepository.getPaymentScheduleStagesList(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: getProject().projectId,
      inventoryBuildingId:
          _paymentScheduleCubit.state.selectedScheme!.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          _paymentScheduleCubit
              .state
              .selectedScheme!
              .inventoryFlatFloorBasementPodiumWingId,
      queryParams: value != null && value.isNotEmpty ? {"Stage": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final stagesList = response['data'] as List<dynamic>? ?? [];

        return {
          "itemList": List.generate(stagesList.length, (index) {
            final stage = stagesList[index] as Map<String, dynamic>;

            return {
              "zAttributesId": index + 1,
              "DisplayName": stage["Stages"] ?? "",
            };
          }),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final percentage = double.tryParse(_percentageController.text) ?? 0;

    if (_isEditMode) {
      _paymentScheduleCubit.updatePaymentScheduleMaster(
        context: context,
        index: widget.index!,
        stage: _selectedStage.first["DisplayName"] ?? "",
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
        stage: _selectedStage.first["DisplayName"] ?? "",
        paymentSchedulePercentage: percentage,
        buildingId:
            _paymentScheduleCubit.state.selectedScheme!.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            _paymentScheduleCubit
                .state
                .selectedScheme!
                .inventoryFlatFloorBasementPodiumWingId,
        scheme:
            _paymentScheduleCubit
                .state
                .selectedScheme!,
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
                    /// STAGES DROPDOWN (API BASED)
                    CustomMultipleSelectPopup(
                      title: "Stages",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectedStage,
                      dataList: [],
                      onSelected: (value) {
                        _selectedStage = value;
                      },
                      dataFetchCallBack: fetchStages,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Stage is required";
                        }
                        return null;
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
                          return "Percentage is required";
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
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
