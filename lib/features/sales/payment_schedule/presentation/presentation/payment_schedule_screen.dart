import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_cubit.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

class PaymentScheduleScreen extends StatefulWidget {
  const PaymentScheduleScreen({super.key});

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  late PaymentScheduleSchemeCubit _schemeCubit;

  final ValueNotifier<List<Map<String, dynamic>>> _selectedSchemeNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _schemeCubit = PaymentScheduleSchemeCubit();
    // Optionally preload first page
    _schemeCubit.getPaymentScheduleSchemeList(context, 1);
  }

  // ------------------- FETCH SCHEME -------------------
  Future<Map<String, dynamic>> _fetchPaymentScheduleScheme(
    int pageNumber, {
    String? value,
  }) async {
    final pageSize = 15;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final filtered =
          _schemeCubit.state.paymentScheduleSchemeList
              .where(
                (scheme) =>
                    scheme.paymentScheduleSchemeName?.toLowerCase().contains(
                      value.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();

      return {
        "itemList":
            filtered
                .map(
                  (scheme) => {
                    "PaymentScheduleSchemeMasterId":
                        scheme.paymentScheduleSchemeMasterId,
                    "PaymentScheduleScheme": scheme.paymentScheduleSchemeName,
                  },
                )
                .toList(),
        "totalNumberOfRecord": filtered.length,
      };
    }

    // LOAD FROM API IF NEEDED
    final currentCount = _schemeCubit.state.paymentScheduleSchemeList.length;
    final totalCount = _schemeCubit.state.totalNumberOfRecord;

    if (currentCount == 0 || currentCount < totalCount) {
      await _schemeCubit.getPaymentScheduleSchemeList(context, pageNumber);
    }

    // RETURN LIST DIRECTLY
    return {
      "itemList":
          _schemeCubit.state.paymentScheduleSchemeList
              .map(
                (scheme) => {
                  "PaymentScheduleSchemeMasterId":
                      scheme.paymentScheduleSchemeMasterId,
                  "PaymentScheduleScheme": scheme.paymentScheduleSchemeName,
                },
              )
              .toList(),
      "totalNumberOfRecord":
          totalCount > 0
              ? totalCount
              : _schemeCubit.state.paymentScheduleSchemeList.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _selectedSchemeNotifier,
          builder: (context, selectedScheme, child) {
            return CustomMultipleSelectPopup(
              title: "Select Scheme",
              isRequired: true,
              isMultiSelect: false,
              initialValue: selectedScheme,
              dataFetchCallBack: _fetchPaymentScheduleScheme,
              onSelected: (value) {
                _selectedSchemeNotifier.value = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Payment Schedule Scheme is required";
                }
                return null;
              },
            );
          },
        ),
      ),
    );
  }
}
