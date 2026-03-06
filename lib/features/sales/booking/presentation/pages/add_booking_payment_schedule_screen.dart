import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddBookingPaymentScheduleScreen extends StatefulWidget {
  final int inventoryBuildingId;
  final int inventoryFlatFloorBasementPodiumWingId;
  final double agreementValue;
  final double agreementValueGST;
  final double agreementValueTds;
  final List<BookingPaymentScheduleData> currentSchedulesList;
  final BookingPaymentScheduleData? currentSchedules;

  const AddBookingPaymentScheduleScreen({
    super.key,
    required this.inventoryBuildingId,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.agreementValue,
    required this.agreementValueGST,
    required this.agreementValueTds,
    this.currentSchedulesList = const [],
    this.currentSchedules,
  });

  @override
  State<AddBookingPaymentScheduleScreen> createState() =>
      _AddBookingPaymentScheduleScreenState();
}

class _AddBookingPaymentScheduleScreenState
    extends State<AddBookingPaymentScheduleScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();

  final TextEditingController _percentageC = TextEditingController();
  final TextEditingController _otherStageC = TextEditingController();

  final ValueNotifier<List<Map<String, dynamic>>?> _selectedStage =
      ValueNotifier(null);

  DateTime? date;

  late TabController _tabController;

  bool get _isEditMode => widget.currentSchedules != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _percentageC.dispose();
    _otherStageC.dispose();
    _selectedStage.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// SAVE FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final percentage = double.parse(_percentageC.text);
    final isDateTab = _tabController.index == 0;

    /// 🚫 DUPLICATE DATE CHECK
    if (isDateTab) {
      final selectedDate = DateFormat("dd-MM-yyyy").format(date!);

      final alreadyExists = widget.currentSchedulesList.any(
        (e) =>
            e.type == "Date" &&
            DateFormat("dd-MM-yyyy").format(e.date!) == selectedDate,
      );

      if (alreadyExists) {
        showErrorMessage(
          context,
          "Duplicate Date",
          "This date is already added.",
        );
        return;
      }
    }

    /// 🚫 DUPLICATE STAGE CHECK
    if (!isDateTab) {
      final selectedStageName =
          _selectedStage.value?.first["DisplayName"] ?? "";

      final alreadyExists = widget.currentSchedulesList.any(
        (e) =>
            e.type == "Stage" &&
            e.name.toLowerCase() == selectedStageName.toLowerCase(),
      );

      if (alreadyExists) {
        showErrorMessage(
          context,
          "Duplicate Stage",
          "This stage is already added.",
        );
        return;
      }
    }

    final cumulativePercentage =
        widget.currentSchedulesList
            .map((e) => e.paymentSchedulePercentage)
            .fold(0.0, (a, b) => a + b) +
        percentage;

    final ranking = widget.currentSchedulesList.length + 1;

    final amount = (widget.agreementValue * percentage) / 100;
    final gstAmount = (widget.agreementValueGST * percentage) / 100;
    final tdsAmount = (widget.agreementValueTds * percentage) / 100;

    final model = BookingPaymentScheduleData(
      bookingPaymentScheduleId: 0,
      type: isDateTab ? "Date" : "Stage",
      name:
          isDateTab
              ? DateFormat("dd-MM-yyyy").format(date!)
              : (_selectedStage.value?.first["DisplayName"] ?? "Stage"),
      date: isDateTab ? date : null,
      paymentSchedulePercentage: percentage,
      paymentCummulativePercentage: cumulativePercentage,
      paymentScheduleAmount: amount,
      paymentScheduleGSTAmount: gstAmount,
      paymentScheduleTDSAmount: tdsAmount,
      ranking: ranking,
    );

    Navigator.pop(context, model);
  }

  /// FETCH STAGES
  Future<Map<String, dynamic>> fetchStages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _bookingRepository.getPaymentScheduleStagesList(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: getProject().projectId,
      inventoryBuildingId: widget.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          widget.inventoryFlatFloorBasementPodiumWingId,
      queryParams: value != null && value.isNotEmpty ? {"Stage": value} : {},
    );

    return result.fold(
      (failure) => {"itemList": [], "totalNumberOfRecord": 0},
      (response) {
        final stagesList = response['data'] as List<dynamic>? ?? [];

        return {
          "itemList": List.generate(stagesList.length, (index) {
            final stage = stagesList[index];

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

  /// PERCENTAGE FIELD
  Widget _percentageField() {
    return CustomTextField(
      title: "Percentage (%)",
      isRequired: true,
      hint: "Enter Percentage",
      textController: _percentageC,
      inputFormatterList: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Percentage is required";
        }
        final percent = int.tryParse(value);
        if (percent == null || percent <= 0 || percent > 100) {
          return "Enter valid percentage";
        }
        return null;
      },
    );
  }

  /// DATE TAB
  Widget _dateTab() {
    return Column(
      children: [
        CustomDatePicker(
          title: "Date",
          isRequired: true,
          initialDate: date,
          setValue: (value) => date = value,
        ),
        _percentageField(),
      ],
    );
  }

  /// STAGE TAB
  Widget _stageTab() {
    return Column(
      children: [
        CustomMultipleSelectPopup(
          title: "Stages",
          isRequired: true,
          isMultiSelect: false,
          initialValue: _selectedStage.value,
          dataList: [],
          onSelected: (value) => _selectedStage.value = value,
          dataFetchCallBack: fetchStages,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Stage is required";
            }
            return null;
          },
        ),

        ValueListenableBuilder(
          valueListenable: _selectedStage,
          builder: (context, selectedStage, _) {
            if (selectedStage?.first['DisplayName'] == "Other") {
              return Column(
                children: [
                  CustomTextField(
                    title: "Other Stage",
                    isRequired: true,
                    hint: "Enter Stage",
                    textController: _otherStageC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Other Stage is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        _percentageField(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Payment Schedule",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: commonCardDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// TAB BAR
                Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false, // important
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    tabs: const [Tab(text: "Date"), Tab(text: "Stage")],
                  ),
                ),
                const SizedBox(height: 20),

                /// TAB VIEW
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_dateTab(), _stageTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// BUTTON
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
