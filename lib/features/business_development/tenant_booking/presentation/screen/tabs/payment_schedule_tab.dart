part of '../add_tenant_booking_screen.dart';

// ═══════════════════════ PAYMENT SCHEDULE TAB ═══════════════════════
extension _PaymentScheduleTab on _AddTenantBookingScreenState {
  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    return BlocBuilder<TenantBookingCubit, TenantBookingState>(
      builder: (context, state) {
        final list = state.bookingPaymentScheduleList;
        return Form(
          key: _paymentScheduleFormKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),
                _buildAgreementCard(),
                verticalSpacing(),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: schemeListNotifier,
                  builder: (context, schemeList, _) {
                    return ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: selectedScheme,
                      builder: (context, selectedValue, __) {
                        return CustomDropDownWidget(
                          title: "Payment Schedule Scheme",
                          isRequired: true,
                          dataList: schemeList,
                          initialValue:
                              selectedValue.isEmpty ? null : selectedValue,
                          onSelected: (value) async {
                            if (selectedScheme.value["zAttributesId"] !=
                                value["zAttributesId"]) {
                              selectedScheme.value = value;

                              if (selectedScheme.value["DisplayName"] !=
                                  'Other') {
                                isAutoPaymentSchedule
                                    .value = await _bookingCubit
                                    .getPaymentScheduleMasterList(
                                      context,
                                      1,
                                      paymentScheduleSchemeMasterId:
                                          selectedScheme.value["zAttributesId"],
                                      inventoryBuildingId:
                                          selectedScheme
                                              .value["inventoryBuildingId"],
                                      inventoryFlatFloorBasementPodiumWingId:
                                          selectedScheme
                                              .value["inventoryFlatFloorBasementPodiumWingId"],
                                      agreementValueWithoutTds:
                                          _agreementValueWithoutTdsC
                                                  .text
                                                  .isNotEmpty
                                              ? double.tryParse(
                                                    _agreementValueWithoutTdsC
                                                        .text
                                                        .trim(),
                                                  ) ??
                                                  0.0
                                              : 0.0,
                                      agreementValueGST:
                                          _agreementGstAmountNotifier.value,
                                      agreementValueTds: _tdsNotifier.value,
                                    );
                              } else {
                                _bookingCubit.clearPaymentScheduleList();
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value["zAttributesId"] == null) {
                              return "Payment Schedule Scheme is required.";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedScheme.value = {};
                            _bookingCubit.clearPaymentScheduleList();
                          },
                        );
                      },
                    );
                  },
                ),

                /// Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Schedule",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),

                    ValueListenableBuilder(
                      valueListenable: selectedScheme,
                      builder: (context, value, child) {
                        if (_bookingCubit.totalCumulativePercentage == 100) {
                          return RichText(
                            text: TextSpan(
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                              children: [
                                TextSpan(
                                  text: "Total: ",
                                  style: AppTextStyle.ts14M(),
                                ),
                                TextSpan(
                                  text:
                                      "${_bookingCubit.totalCumulativePercentage.toStringAsFixed(2)}%",
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Visibility(
                          visible:
                              (value['DisplayName'] == 'Other' &&
                                  _bookingCubit.totalCumulativePercentage !=
                                      100 &&
                                  _agreementValueNotifier.value > 0),
                          child: CustomButton(
                            leading: const Icon(Icons.add, size: 16),
                            text: "Add",
                            onPressed: _openPaymentScheduleForm,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: selectedScheme,
                  builder: (context, value, child) {
                    // HIDE WHEN SCHEME IS NOT SELECTED
                    if (selectedScheme.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // HIDE WHEN CUMULATIVE IS 100
                    if (_bookingCubit.totalCumulativePercentage >= 100) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        verticalSpacing(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                                children: [
                                  const TextSpan(text: "Total: "),
                                  TextSpan(
                                    text:
                                        "${_bookingCubit.totalCumulativePercentage.toStringAsFixed(2)}%",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                                children: [
                                  const TextSpan(text: "Missing: "),
                                  TextSpan(
                                    text:
                                        "${_bookingCubit.remainingPercentage.toStringAsFixed(2)}%",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                verticalSpacing(height: 15),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      if ((state.isLoading ?? false) &&
                          list.isEmpty &&
                          _agreementValueNotifier.value > 0) {
                        return Center(
                          child: noDataWidget(
                            message: "No payment schedules found",
                            iconSize: 200,
                          ),
                        );
                      }

                      if (list.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Payment Schedule Available",
                            iconSize: 120,
                          ),
                        );
                      }

                      return ReorderableListView.builder(
                        itemCount: list.length,
                        onReorder: (oldIndex, newIndex) {
                          _bookingCubit.reorderPaymentSchedule(
                            oldIndex,
                            newIndex,
                          );
                        },
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          String stageName =
                              (item.date != null)
                                  ? formatDateTimeAsDDMMMYYYY(item.date!)
                                  : item.name;
                          return Row(
                            key: ValueKey(stageName + index.toString()),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: CircleAvatar(
                                  maxRadius: 15,
                                  backgroundColor: AppColor.lightBlue,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: AppColor.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              horizontalSpacing(),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: commonCardDecoration(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Stage Name",
                                            value: stageName,
                                          ),

                                          Visibility(
                                            visible:
                                                !isAutoPaymentSchedule.value,
                                            child: Row(
                                              spacing: 10,
                                              children: [
                                                CustomIconButton.edit(
                                                  onPressed: () {
                                                    _openPaymentScheduleForm(
                                                      index: index,
                                                    );
                                                  },
                                                ),
                                                CustomIconButton.delete(
                                                  onPressed: () {
                                                    _showPopupToDeletePaymentSchedule(
                                                      context,
                                                      index,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Ranking",
                                            value: item.ranking.toString(),
                                          ),
                                          buildColumnTitleValue(
                                            title: "Cumulative (%)",
                                            value:
                                                "${item.paymentCummulativePercentage}",
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Percentage (%)",
                                            value:
                                                "${item.paymentSchedulePercentage}",
                                          ),
                                          buildColumnTitleValue(
                                            title: "Amount Without TDS (₹)",
                                            value:
                                                item.paymentScheduleAmount
                                                    .toIndianCurrency(),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "GST Amount (₹)",
                                            value:
                                                item.paymentScheduleGSTAmount
                                                    .toIndianCurrency(),
                                          ),
                                          buildColumnTitleValue(
                                            title: "TDS Amount (₹)",
                                            value:
                                                item.paymentScheduleTDSAmount
                                                    .toIndianCurrency(),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Total Amount With TDS (₹)",
                                            value:
                                                (item.paymentScheduleAmount +
                                                        item.paymentScheduleTDSAmount)
                                                    .toIndianCurrency(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // AGGREMENT CARD (also used by the Other Charges tab)
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
