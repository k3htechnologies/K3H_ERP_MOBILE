import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_data.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddBookingPaymentScheduleScreen extends StatefulWidget {
  final int inventoryBuildingId;
  final int inventoryFlatFloorBasementPodiumWingId;
  final double agreementValueWithoutTDS;
  final double agreementValueGST;
  final double agreementValueTds;
  final int? index;

  const AddBookingPaymentScheduleScreen({
    super.key,
    required this.inventoryBuildingId,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.agreementValueWithoutTDS,
    required this.agreementValueGST,
    required this.agreementValueTds,
    this.index,
  });

  @override
  State<AddBookingPaymentScheduleScreen> createState() =>
      _AddBookingPaymentScheduleScreenState();
}

class _AddBookingPaymentScheduleScreenState
    extends State<AddBookingPaymentScheduleScreen>
    with SingleTickerProviderStateMixin {
  late BookingCubit _bookingCubit;

  final _formKey = GlobalKey<FormState>();

  final BookingRepository _bookingRepository =
      serviceLocator<BookingRepository>();

  final TextEditingController _percentageC = TextEditingController();
  final TextEditingController _otherStageC = TextEditingController();

  final ValueNotifier<Map<String, dynamic>?> _selectedStage = ValueNotifier(
    null,
  );
  late List<Map<String, dynamic>> stageList;
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);

  late TabController _tabController;

  bool get _isEditMode => widget.index != null;
  List<String> tabs = ['Date', 'Stage'];
  @override
  void initState() {
    super.initState();
    _bookingCubit = context.read<BookingCubit>();
    stageList = [];
    if (_isEditMode) {
      initEditMode();
    } else {
      _fetchStages();
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  void initEditMode() async {
    await _fetchStages();

    _prefillData();
  }

  void _prefillData() {
    if (!_isEditMode) return;
    final data = _bookingCubit.state.bookingPaymentScheduleList[widget.index!];

    _percentageC.text = data.paymentSchedulePercentage.toString();

    /// SELECT TAB
    if (data.type == "Date") {
      _tabController.index = 0;
      _selectedDate.value = data.date;
    } else {
      _tabController.index = 1;

      _selectedStage.value = stageList.firstWhere(
        (item) =>
            item['DisplayName'].toString().toLowerCase() ==
            data.name.toLowerCase(),
      );

      if (data.name == "Other") {
        _otherStageC.text = data.name;
      }
    }
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

    final schedules = List<BookingPaymentScheduleData>.from(
      _bookingCubit.state.bookingPaymentScheduleList,
    );

    /// CHECK TOTAL PERCENTAGE
    final currentTotal = _bookingCubit.totalCumulativePercentage;

    double newTotal;

    if (_isEditMode) {
      final oldPercentage =
          _bookingCubit
              .state
              .bookingPaymentScheduleList[widget.index!]
              .paymentSchedulePercentage;

      newTotal = currentTotal - oldPercentage + percentage;
    } else {
      newTotal = currentTotal + percentage;
    }

    if (newTotal > 100) {
      showErrorMessage(
        context,
        "Invalid Percentage",
        "Total percentage cannot exceed 100%. Current total would be ${newTotal.toStringAsFixed(2)}%",
      );
      return;
    }

    /// DUPLICATE DATE CHECK
    if (isDateTab) {
      final alreadyExists = schedules.any(
        (e) =>
            e.type == "Date" &&
            e.date == _selectedDate.value &&
            schedules.indexOf(e) != widget.index,
      );

      if (alreadyExists) {
        showErrorMessage(
          context,
          "",
          "A payment schedule with this date already exists",
        );
        return;
      }
    }

    /// DUPLICATE STAGE CHECK
    if (!isDateTab) {
      final selectedStageName = _selectedStage.value?["DisplayName"] ?? "";

      final alreadyExists = schedules.any(
        (e) =>
            e.type == "Stage" &&
            e.name.toLowerCase() == selectedStageName.toLowerCase() &&
            schedules.indexOf(e) != widget.index,
      );

      if (alreadyExists) {
        showErrorMessage(context, "", "This stage is already added.");
        return;
      }
    }

    /// CALCULATIONS
    final amount = (widget.agreementValueWithoutTDS * percentage) / 100;
    final gstAmount = (widget.agreementValueGST * percentage) / 100;
    final tdsAmount = (widget.agreementValueTds * percentage) / 100;

    final ranking =
        _isEditMode ? schedules[widget.index!].ranking : schedules.length + 1;

    final cumulativePercentage =
        schedules
            .map((e) => e.paymentSchedulePercentage)
            .fold(0.0, (a, b) => a + b) +
        percentage;

    final model = BookingPaymentScheduleData(
      bookingPaymentScheduleId: 0,
      type: isDateTab ? "Date" : "Stage",
      name:
          isDateTab
              ? _selectedDate.value!.toIso8601String().split("T")[0]
              : (_selectedStage.value?["DisplayName"] == "Other"
                  ? _otherStageC.text.trim()
                  : _selectedStage.value?["DisplayName"] ?? "Stage"),
      date: isDateTab ? _selectedDate.value : null,
      paymentSchedulePercentage: percentage,
      paymentCummulativePercentage: cumulativePercentage,
      paymentScheduleAmount: amount,
      paymentScheduleGSTAmount: gstAmount,
      paymentScheduleTDSAmount: tdsAmount,
      ranking: ranking,
    );

    /// ADD / EDIT LOGIC
    if (_isEditMode) {
      schedules[widget.index!] = model;
    } else {
      schedules.add(model);
    }

    /// RECALCULATE CUMULATIVE
    double runningTotal = 0;

    for (int i = 0; i < schedules.length; i++) {
      runningTotal += schedules[i].paymentSchedulePercentage;

      schedules[i] = schedules[i].copyWith(
        paymentCummulativePercentage: runningTotal,
      );
    }

    /// UPDATE CUBIT
    _bookingCubit.updatePaymentScheduleList(schedules);

    Navigator.pop(context);
  }

  /// FETCH STAGES
  Future<void> _fetchStages() async {
    final result = await _bookingRepository.getPaymentScheduleStagesList(
      pageNumber: 1,
      pageSize: 15,
      projectId: getProject().projectId,
      inventoryBuildingId: widget.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          widget.inventoryFlatFloorBasementPodiumWingId,
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

  /// PERCENTAGE FIELD
  Widget _percentageField() {
    return CustomTextField(
      title: "Percentage (%)",
      isRequired: true,
      hint: "Enter Percentage",
      textController: _percentageC,
      inputFormatterList: InputValidator.percentage(),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Percentage is required";
        }

        final percent = double.tryParse(value);

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
        ValueListenableBuilder(
          valueListenable: _selectedDate,
          builder: (context, value, child) {
            return CustomDatePicker(
              title: "Date",
              isRequired: true,
              initialDate: value,
              setValue: (value) => _selectedDate.value = value,
              validator: (value) {
                if (value == null) {
                  return "Date is required";
                }
                return null;
              },
            );
          },
        ),
        _percentageField(),
      ],
    );
  }

  /// STAGE TAB
  Widget _stageTab() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _selectedStage,
          builder: (context, value, child) {
            return CustomDropDownWidget(
              title: "Stages",
              isRequired: true,
              hintText: "Select Stage",
              initialValue: value,
              dataList: stageList,
              onValueClear: () => _selectedStage.value = null,
              onSelected: (value) => _selectedStage.value = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Stage is required";
                }
                return null;
              },
            );
          },
        ),

        ValueListenableBuilder(
          valueListenable: _selectedStage,
          builder: (context, selectedStage, _) {
            if (selectedStage != null &&
                selectedStage.isNotEmpty &&
                selectedStage['DisplayName'] == "Other") {
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 40,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      labelColor: AppColor.primary,
                      unselectedLabelColor: AppColor.grey,
                      indicator: BoxDecoration(
                        color: AppColor.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle: AppTextStyle.ts14M(),
                      unselectedLabelStyle: AppTextStyle.ts14M(),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      onTap: (index) {
                        if (_isEditMode) return;

                        if (index == 0) {
                          _selectedStage.value = {};
                        } else {
                          _selectedDate.value = null;
                        }
                      },
                      tabs:
                          tabs.map((title) {
                            return Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.grey.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(title),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// TAB VIEW
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
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
