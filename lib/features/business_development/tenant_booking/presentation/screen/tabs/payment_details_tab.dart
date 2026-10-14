part of '../add_tenant_booking_screen.dart';

// ═══════════════════════════ PAYMENT DETAILS TAB ═══════════════════════════
extension _PaymentDetailsTab on _AddTenantBookingScreenState {
  // PAYMENTS DETAILS
  Widget _buildPaymentDetails() {
    return Form(
      key: _paymentDetailsFormKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Payment Details",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Booking Amount (₹)",
                      hint: "Enter Booking Amount",
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: _bookingAmountC,
                    ),
                    CustomTextField(
                      title: "Cheque/ RTGS No.",
                      hint: "Enter Cheque/ RTGS No.",
                      textController: _chequeNoC,
                    ),
                    CustomDatePicker(
                      title: "Cheque/ RTGS Date",
                      initialDate: _selectedChequeDate,
                      setValue: (value) {
                        _selectedChequeDate = value;
                      },
                    ),
                    // BANK MULTI SELECT
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedBankNotifier,
                      builder: (context, selectedBanks, child) {
                        return CustomMultipleSelectPopup(
                          title: "Bank",
                          isMultiSelect: false,
                          initialValue: selectedBanks,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedBankNotifier.value =
                                value
                                    .map((e) => Map<String, dynamic>.from(e))
                                    .toList();
                          },
                          dataFetchCallBack: _fetchBanks,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
