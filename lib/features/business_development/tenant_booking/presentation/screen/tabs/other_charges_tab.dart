part of '../add_tenant_booking_screen.dart';

extension _OtherChargesTab on _AddTenantBookingScreenState {
  Widget _buildOtherCharges() {
    return Form(
      key: _otherChargesFormKey,
      child: BlocBuilder<TenantBookingCubit, TenantBookingState>(
        builder: (context, state) {
          if (_agreementValueNotifier.value == 0) {
            return Center(
              child: noDataWidget(message: "No Other Charges Found"),
            );
          }
          return Column(
            children: [
              verticalSpacing(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  spacing: 10,
                  children: [
                    _buildAgreementCard(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Do Other Charges Apply?",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),

                        ValueListenableBuilder<bool>(
                          valueListenable: _isOtherChargeApplicable,
                          builder: (context, isApplicable, child) {
                            return ToggleButtons(
                              isSelected: [isApplicable, !isApplicable],
                              onPressed: (index) {
                                _isOtherChargeApplicable.value = index == 0;
                                if (_isOtherChargeApplicable.value) {
                                  _bookingCubit.getOtherChargesList(
                                    context,
                                    1,
                                    _project.projectId,
                                    widget.inventoryObject?[0]["reraCarpetAreaSqFt"] ??
                                        widget
                                            .tenantBookingModel
                                            ?.reraCarpetAreaSqFt,
                                  );
                                } else {
                                  _bookingCubit.updateOtherChargesList([]);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              constraints: const BoxConstraints(
                                minHeight: 35,
                                minWidth: 50,
                              ),
                              selectedColor: AppColor.white,
                              fillColor: AppColor.primary,
                              color: Colors.black,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("Yes"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("No"),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              verticalSpacing(),

              ValueListenableBuilder(
                valueListenable: _isOtherChargeApplicable,
                builder: (context, isOcApplicable, child) {
                  if (!isOcApplicable &&
                      ((state.isLoading == false) &&
                          state.otherChargesList.isEmpty)) {
                    return Expanded(
                      child: Center(
                        child: noDataWidget(
                          iconSize: 120,
                          message: "No Other Charges Found",
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shrinkWrap: true,
                      itemCount: state.otherChargesList.length,
                      itemBuilder: (_, index) {
                        final oc = state.otherChargesList[index];

                        return Container(
                          decoration: commonCardDecoration(),
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(oc.chargeName, style: AppTextStyle.ts14M()),
                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Calculated On",
                                    value: oc.calculatedOn,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Amount (₹)",
                                    value: oc.value.toIndianCurrency(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "GST(%)",
                                    value: "${oc.gstPercentage} %",
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "GST Value (₹)",
                                    value: oc.gstValue.toIndianCurrency(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total Value (₹)",
                                    value:
                                        (oc.value + oc.gstValue)
                                            .toIndianCurrency(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAgreementCard() {
    double agreementValueWithTds =
        double.tryParse(
          _agreementValueWithTdsC.text.trim().replaceAll(',', ''),
        ) ??
        0.0;

    double agreementGstAmount =
        double.tryParse(_agreementGstAmountC.text.trim().replaceAll(',', '')) ??
        0.0;

    double tdsAmount =
        double.tryParse(_tdsC.text.trim().replaceAll(',', '')) ?? 0.0;

    return infoCard(title: "Agreement Details", [
      {
        "title": "Agreement Value (With TDS) (₹)",
        "value": agreementValueWithTds.toIndianCurrency(),
      },
      {
        "title": "Agreement GST Amount (₹)",
        "value": agreementGstAmount.toIndianCurrency(),
      },
      {"title": "TDS Amount(₹)", "value": tdsAmount.toIndianCurrency()},
    ]);
  }
}
