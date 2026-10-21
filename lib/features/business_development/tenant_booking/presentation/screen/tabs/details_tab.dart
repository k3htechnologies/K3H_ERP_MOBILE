part of '../add_tenant_booking_screen.dart';

extension _DetailsTab on _AddTenantBookingScreenState {
  Widget _buildDetails() {
    return Form(
      key: _detailsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                BlocConsumer<TenantBookingCubit, TenantBookingState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    final tenant =
                        state.tenantList.isNotEmpty
                            ? state.tenantList.first
                            : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: commonCardDecoration(),
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: _selectedBuildingNotifier,
                                builder: (context, selectedBuilding, child) {
                                  return CustomMultipleSelectPopup(
                                    title: "Building",
                                    isReadOnly: isTenantEditMode,
                                    isRequired: true,
                                    isMultiSelect: false,
                                    initialValue: selectedBuilding,
                                    hintText: "Select Building",
                                    dataList: const [],
                                    onClear: () {
                                      _selectedBuildingNotifier.value = [];
                                    },
                                    onSelected: (value) async {
                                      _selectedBuildingNotifier.value = value;
                                      if (_tenantUniqueCodeC.text.length ==
                                          18) {
                                        _isFetchingTenant.value = true;
                                        _tenantFetchTried.value = true;
                                        await _bookingCubit.getTenantList(
                                          context: context,
                                          projectId: _project.projectId,
                                          systemGeneratedCode:
                                              _tenantUniqueCodeC.text,
                                          buildingId:
                                              value.first['zAttributesId'],
                                        );
                                        _isFetchingTenant.value = false;
                                      }
                                    },
                                    dataFetchCallBack: _fetchBuildings,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Building is required.";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              CustomTextField(
                                title: "Tenant Code",
                                isRequired: true,
                                readOnly: isTenantEditMode,
                                bottomMargin: 0,
                                inputFormatterList: [
                                  UpperCaseTextFormatter(),
                                  LengthLimitingTextInputFormatter(18),
                                ],
                                hint: "Search By Tenant Code",
                                textController: _tenantUniqueCodeC,
                                onChangeFunction: (value) {
                                  if (_debounce?.isActive ?? false) {
                                    _debounce!.cancel();
                                  }

                                  if (value.length != 18) {
                                    _bookingCubit.clearTenantList();
                                    _tenantFetchTried.value = false;
                                    _isFetchingTenant.value = false;
                                    return;
                                  }

                                  _debounce = Timer(
                                    const Duration(milliseconds: 500),
                                    () async {
                                      if (value.length == 18) {
                                        _isFetchingTenant.value = true;
                                        _tenantFetchTried.value = true;
                                        await _bookingCubit.getTenantList(
                                          context: context,
                                          projectId: _project.projectId,
                                          systemGeneratedCode: value,
                                          buildingId:
                                              _selectedBuildingNotifier
                                                  .value
                                                  .first['zAttributesId'],
                                        );
                                        _applicants.value =
                                            List<TenantApplicantData>.from(
                                              _bookingCubit
                                                  .state
                                                  .tenantList
                                                  .first
                                                  .tenantApplicantData,
                                            );
                                        _isFetchingTenant.value = false;
                                      }
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tenant Code is required.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        if (tenant != null &&
                            _selectedBuildingNotifier.value.isNotEmpty
                        //? &&
                        // (tenant.finalStage.toLowerCase() !=
                        //         'booking done'
                        // ||
                        // _isEditMode
                        // )
                        ) ...[
                          SectionCard(
                            title: "Existing Unit Details",
                            titleTextColor: AppColor.darkBlue29,
                            headerBackgroundColor: AppColor.darkBlue29
                                .withValues(alpha: 0.1),
                            children: [
                              Row(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Tenant Code",
                                    value: tenant.systemGeneratedCode,
                                  ),
                                  buildColumnTitleValue(
                                    title: "Unit / Annexure / Survey Number",
                                    value: tenant.unitAnnexureSurveyNumber,
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Unit Type",
                                    value: tenant.unitType,
                                  ),
                                  buildColumnTitleValue(
                                    title: "Unit Configuration",
                                    value: tenant.unitConfiguration,
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Unit Carpet Area (SqFt)",
                                    value:
                                        tenant.unitCarpetAreaSqFt.addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Unit Facing",
                                    value: tenant.unitFacing,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SectionCard(
                            title: 'Eligibility Details in Carpet Area (SqFt)',
                            titleTextColor: AppColor.brown,
                            headerBackgroundColor: AppColor.lightYellow,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Extra Free Carpet Area Offered (%)",
                                    value:
                                        tenant.extraFreeCarpetAreaOfferedPercent
                                            .addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Free MOFA Carpet Area (SqFt)",
                                    value:
                                        tenant.freeMOFACarpetAreaSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Existing Terrace Area (SqFt)",
                                    value:
                                        tenant.existingTerraceAreaSqFt
                                            .addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title:
                                        "New Eligibility MOFA Carpet Area (SqFt)",
                                    value:
                                        tenant.newEligibilityMOFACarpetAreaSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title:
                                        "New Eligibility RERA Carpet Area (SqFt)",
                                    value:
                                        tenant.newEligibilityRERACarpetAreaSqFt
                                            .addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "(A) Area Against Terrace (SqFt)",
                                    value:
                                        tenant.areaAgainstTerraceSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title: "MOFA Carpet Area Purchased (SqFt)",
                                    value:
                                        tenant.mofaCarpetAreaPurchasedSqFt
                                            .addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "RERA Carpet Area Purchased (SqFt)",
                                    value:
                                        tenant.reraCarpetAreaPurchasedSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title: "(B) Deck Area (SqFt)",
                                    value: tenant.deckAreaSqFt.addCommas(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total New MOFA Carpet Area (SqFt)",
                                    value:
                                        tenant.totalNewMOFACarpetAreaSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  buildColumnTitleValue(
                                    title:
                                        "(C) Total New RERA Carpet Area (SqFt)",
                                    value:
                                        tenant.totalNewRERACarpetAreaSqFt
                                            .addCommas(),
                                  ),
                                ],
                              ),
                              buildRowWrapper(
                                child: buildColumnTitleValue(
                                  title:
                                      "Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)",
                                  value:
                                      (tenant.totalNewRERACarpetAreaSqFt +
                                              tenant.deckAreaSqFt +
                                              tenant.areaAgainstTerraceSqFt)
                                          .addCommas(),
                                ),
                              ),
                              buildRowWrapper(
                                child: buildColumnTitleValue(
                                  title: "Remark",
                                  value: tenant.remark,
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<List<TenantApplicantData>>(
                            valueListenable: _applicants,
                            builder: (context, applicants, child) {
                              if (applicants.isEmpty) {
                                return SizedBox.shrink();
                              }
                              return SectionCard(
                                title: "Applicant Details",
                                maxContentHeight: 350,
                                headerBackgroundColor: AppColor.lightYellowBg2,
                                titleTextColor: AppColor.brownYellowText,
                                border: Border.all(
                                  color: AppColor.grey.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                children:
                                    applicants
                                        .map(_buildApplicantCard)
                                        .toList(),
                              );
                            },
                          ),
                        ] else if (_tenantUniqueCodeC.text.trim().length ==
                                18 &&
                            (_isFetchingTenant.value ||
                                (_debounce?.isActive ?? false) ||
                                state.isLoading == true)) ...[
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.lightBlue,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.primary,
                                width: .5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                horizontalSpacing(width: 10),
                                Text(
                                  "Fetching tenant...",
                                  style: AppTextStyle.ts14M(),
                                ),
                              ],
                            ),
                          ),
                          verticalSpacing(),
                        ] else if (tenant != null &&
                            _selectedBuildingNotifier.value.isNotEmpty
                        //? &&
                        // tenant.finalStage.toLowerCase() ==
                        // 'booking done'
                        ) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.error,
                                width: .5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Booking already done for this tenant",
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ] else if (_tenantUniqueCodeC.text.trim().length ==
                                18 &&
                            _tenantFetchTried.value &&
                            tenant == null &&
                            !(_isFetchingTenant.value ||
                                (_debounce?.isActive ?? false) ||
                                state.isLoading == true)) ...[
                          verticalSpacing(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.error,
                                width: .5,
                              ),
                            ),
                            child: Text(
                              "No Tenant details found for this Tenant Code",
                              style: AppTextStyle.ts14M(color: AppColor.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ] else ...[
                          SizedBox.shrink(),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),

            ValueListenableBuilder(
              valueListenable: _isRERA,
              builder: (_, value, __) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.grey10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.grey2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      InkWell(
                        onTap: () {
                          _isRERA.value = true;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration:
                              _isRERA.value
                                  ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColor.grey30),
                                  )
                                  : null,
                          alignment: Alignment.center,
                          child: Text(
                            "RERA",
                            style:
                                _isRERA.value
                                    ? AppTextStyle.ts12SB(
                                      color: AppColor.primary,
                                    )
                                    : AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _isRERA.value = false;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          alignment: Alignment.center,
                          decoration:
                              !_isRERA.value
                                  ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColor.grey30),
                                  )
                                  : null,
                          child: Text(
                            "MOFA",
                            style:
                                !_isRERA.value
                                    ? AppTextStyle.ts12SB(
                                      color: AppColor.primary,
                                    )
                                    : AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            verticalSpacing(height: 16),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  CustomTextField(
                    key: const ValueKey("permanent_address"),
                    title: "Permanent Address",
                    isRequired: true,
                    hint: "Enter Permanent Address",
                    minLines: 3,
                    maxLines: 3,
                    textController: _permanentAddressC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Permanent Address is required.";
                      }
                      if (value.trim().length < 25) {
                        return "Permanent Address must be at least 25 characters";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "Communication Address",
                    key: const ValueKey("communication_address"),
                    isRequired: true,
                    minLines: 3,
                    maxLines: 3,
                    hint: "Enter Communication Address",
                    textController: _communicationAddressC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Communication Address is required.";
                      }
                      if (value.trim().length < 25) {
                        return "Communication Address must be at least 25 characters";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            infoCard(title: "Project Details", [
              {
                "title": "Building Number",
                "value":
                    widget.inventoryObject?[0]["buildingNumber"] ??
                    widget.tenantBookingModel?.buildingNumber,
              },
              {
                "title": "Wing",
                "value":
                    widget.inventoryObject?[0]["wing"] ??
                    widget.tenantBookingModel?.wing,
              },
              {
                "title": "Floor",
                "value":
                    widget.inventoryObject?[0]["floor"] ??
                    widget.tenantBookingModel?.floor,
              },
              {
                "title": "Unit No",
                "value":
                    widget.inventoryObject?[0]["flat"] ??
                    widget.tenantBookingModel?.flat,
              },
              {
                "title": "Flat Type",
                "value":
                    widget.inventoryObject?[0]["flatType"] ??
                    widget.tenantBookingModel?.flatType,
              },
              {
                "title": "Flat Configuration",
                "value":
                    widget.inventoryObject?[0]["flatConfiguration"] ??
                    widget.tenantBookingModel?.flatConfiguration,
              },
              {
                "title": "RERA Carpet Area (SqFt)",
                "value":
                    widget.inventoryObject?[0]["reraCarpetAreaSqFt"]
                        .toString() ??
                    widget.tenantBookingModel?.reraCarpetAreaSqFt.toString(),
              },
              {
                "title": "Adjust Purchase Area (SqFt)",
                "value":
                    _bookingCubit.state.tenantList.isNotEmpty
                        ? _bookingCubit.state.tenantList.first.inventoryFlatData
                            .fold(
                              (0.0),
                              (a, b) => (a + b.adjustPurchaseAreaSqFt),
                            )
                            .toString()
                        : "-",
              },
            ]),
            verticalSpacing(height: 12),
            Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Agreement Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  CustomTextField(
                    title: "Agreement Value (With TDS)",
                    hint: "Enter Agreement Value (with TDS)",
                    prefixType: CustomTextFieldPrefix.rupees,
                    isRequired: true,
                    textController: _agreementValueWithTdsC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatterList: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,16}(\.\d{0,2})?'),
                      ),
                    ],
                    onChangeFunction: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      _agreementValueNotifier.value = parsed;
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agreement Value (with TDS) is required.";
                      }

                      final parsed = double.tryParse(value.trim());

                      if (parsed == null) {
                        return "Invalid amount";
                      }

                      if (parsed <= 0) {
                        return "Amount must be greater than 0";
                      }

                      return null;
                    },
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _tdsNotifier,
                    builder: (_, tds, __) {
                      return CustomTextField(
                        readOnly: true,
                        title: "TDS",
                        prefixType: CustomTextFieldPrefix.rupees,
                        hint: "TDS",
                        textController: _tdsC,
                      );
                    },
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _withoutTdsNotifier,
                    builder: (_, value, __) {
                      return CustomTextField(
                        readOnly: true,
                        title: "Agreement Value (Without TDS)",
                        hint: "Agreement Value (without TDS)",
                        textController: _agreementValueWithoutTdsC,
                        prefixType: CustomTextFieldPrefix.rupees,
                        onChangeFunction: (value) {
                          _bookingCubit.onUpdateBookingAmount(
                            agreementValueWithTds:
                                _agreementValueWithoutTdsC.text.isNotEmpty
                                    ? double.tryParse(
                                          _agreementValueWithoutTdsC.text
                                              .trim(),
                                        ) ??
                                        0.0
                                    : 0.0,
                            agreementValueGST:
                                _agreementGstAmountNotifier.value,
                            agreementValueTds: _tdsNotifier.value,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            verticalSpacing(height: 8),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tax Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Column(
                    children: [
                      CustomTextField(
                        isRequired: true,
                        title: "Agreement GST",
                        prefixType: CustomTextFieldPrefix.percentage,
                        hint: "Enter Agreement GST Percentage",
                        textController: _agreementGstPercentageC,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatterList: InputValidator.percentage(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Agreement GST Percentage is required.";
                          }

                          final parsed = double.tryParse(value);

                          if (parsed == null || parsed < 0) {
                            return "Invalid percentage";
                          }

                          return null;
                        },
                        onChangeFunction: (value) {
                          _calculateGst();
                          _bookingCubit.onUpdateBookingAmount(
                            agreementValueWithTds:
                                _agreementValueWithoutTdsC.text.isNotEmpty
                                    ? double.tryParse(
                                          _agreementValueWithoutTdsC.text
                                              .trim(),
                                        ) ??
                                        0.0
                                    : 0.0,
                            agreementValueGST:
                                _agreementGstAmountNotifier.value,
                            agreementValueTds: _tdsNotifier.value,
                          );
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _agreementGstAmountNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Agreement GST Amount",
                            hint: "Agreement GST Amount",
                            textController: _agreementGstAmountC,
                            prefixType: CustomTextFieldPrefix.rupees,
                          );
                        },
                      ),
                      CustomTextField(
                        isRequired: true,
                        title: "Stamp Duty",
                        hint: "Enter Stamp Duty Percentage",
                        prefixType: CustomTextFieldPrefix.percentage,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatterList: InputValidator.percentage(),
                        textController: _stampDutyPercentageC,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Stamp Duty Percentage is required.";
                          }
                          return null;
                        },
                        onChangeFunction: (value) {
                          _calculateStampDuty();
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _stampDutyAmountNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Stamp Duty Amount",
                            hint: "Stamp Duty Amount",
                            textController: _stampDutyAmountC,
                            prefixType: CustomTextFieldPrefix.rupees,
                          );
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _registrationFeesNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Registration Fees",
                            hint: "Registration Fees",
                            textController: _registrationFeesC,
                            prefixType: CustomTextFieldPrefix.rupees,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            (!_isEditMode || widget.tenantBookingModel!.parkingData.isEmpty)
                ? SizedBox.shrink()
                : Container(
                  height: 350,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Parking Details",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount:
                              widget.tenantBookingModel!.parkingData.length,
                          itemBuilder: (_, index) {
                            final parking =
                                widget.tenantBookingModel!.parkingData[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Parking Number",
                                        value: parking.parkingNumber,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Building",
                                        value: parking.buildingNumber,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Wing",
                                        value: parking.wing,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Floor",
                                        value: parking.floor,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Category",
                                        value: parking.parkingCategory,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Type",
                                        value: parking.parkingType,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "EV Charging",
                                        value:
                                            parking.isEVChargingAvailable
                                                ? "Yes"
                                                : "No",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Other Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  BlocBuilder<TenantBookingCubit, TenantBookingState>(
                    bloc: _bookingCubit,
                    builder: (context, state) {
                      return ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedParkingNotifier,
                        builder: (context, selectedBuilding, child) {
                          return CustomMultipleSelectPopup(
                            title: "Parking",
                            hintText: "Select Parking",
                            isMultiSelect: true,
                            initialValue: selectedBuilding,
                            dataList: const [],
                            onSelected: (value) async {
                              _selectedParkingNotifier.value = value;
                              if (value.isNotEmpty &&
                                  value.first['zAttributesId'] != null &&
                                  mounted) {
                                final newBuildingId =
                                    value.first['zAttributesId'] as int;
                                if (_lastFetchedBuildingId != newBuildingId) {
                                  _lastFetchedBuildingId = newBuildingId;
                                  await _bookingCubit.getParkingList(
                                    context,
                                    1,
                                    _project.projectId,
                                    displayParkingId:
                                        _isEditMode
                                            ? widget
                                                .tenantBookingModel!
                                                .parkingId
                                            : null,
                                  );
                                }
                              } else if (mounted) {
                                _lastFetchedBuildingId = null;
                              }
                            },
                            dataFetchCallBack: _fetchParking,
                          );
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: "Number Of Parking",
                    textController: _noOfParkingC,
                    keyboardType: TextInputType.number,
                    hint: "Enter Number Of Parking",
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedHandOverType,
                    builder: (context, selectedHandOverType, child) {
                      return CustomDropDownWidget(
                        title: "Handover Type",
                        hintText: "Select Handover Type",
                        isRequired: true,
                        initialValue: selectedHandOverType,
                        dataList: handOverTypeList,
                        onSelected: (value) {
                          _selectedHandOverType.value = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Handover Type is required.";
                          }
                          return null;
                        },
                        onValueClear: () => _selectedHandOverType.value = null,
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedExpectedRegistrationDate,
                    builder: (
                      context,
                      selectedExpectedRegistrationDate,
                      child,
                    ) {
                      return CustomDatePicker(
                        title: "Expected Registration Date",
                        isRequired: true,
                        initialDate: selectedExpectedRegistrationDate,
                        setValue: (value) {
                          _selectedExpectedRegistrationDate.value = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Expected Registration Date is required.";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedFundingSource,
                    builder: (context, selectedFundingSource, child) {
                      return CustomDropDownWidget(
                        title: "Source Of Funding",
                        hintText: "Select Source Of Funding",
                        isRequired: true,
                        initialValue: selectedFundingSource,
                        dataList: fundingSourceList,
                        onSelected: (value) {
                          _selectedFundingSource.value = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Funding Source is required.";
                          }
                          return null;
                        },
                        onValueClear: () => _selectedFundingSource.value = null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(TenantApplicantData applicant) {
    return infoCard(
      bgColor: AppColor.white,
      borderColor: AppColor.primary,
      titleWidget: Row(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              applicant.applicantName,
              style: AppTextStyle.ts14M(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          horizontalSpacing(),
          _buildApplicantTypeWidget(applicant.applicantType),
        ],
      ),
      [
        {
          "title": "Mobile Number",
          "value": applicant.applicantMobileNumber,
          "widget": CustomClickToContactText(
            countryCode: applicant.applicantMobileNumberCountryCode,
            value: applicant.applicantMobileNumber,
            type: ContactType.phone,
          ),
        },
        {
          "title": "E-Mail ID",
          "value": applicant.applicantEmailId,
          "widget": CustomClickToContactText(
            value: applicant.applicantEmailId,
            type: ContactType.email,
          ),
        },
        {"title": "Aadhaar Card No.", "value": applicant.aadharCardNumber},
        _docEntry(context, "Aadhaar Card", applicant.aadharCardURL),
        {"title": "PAN Card No.", "value": applicant.panNumber},
        _docEntry(context, "PAN Card", applicant.panCardURL),
        {
          "title": "Driving License No.",
          "value": applicant.drivingLicenseNumber,
        },
        _docEntry(context, "Driving License", applicant.drivingLicenseURL),
        {"title": "Voting ID No.", "value": applicant.votingIdNumber},
        _docEntry(context, "Voting ID", applicant.votingIdURL),
        {"title": "Passport No.", "value": applicant.passportNumber},
        _docEntry(context, "Passport", applicant.passportURL),
        {"title": "GST No.", "value": applicant.gstNumber},
        _docEntry(context, "GST Certificate", applicant.gstNumberURL),
        _docEntry(context, "Profile Photo", applicant.photoURL),
        {"title": "Bank Name", "value": applicant.bankName},
        {"title": "Account No.", "value": applicant.accountNumber},
        {"title": "IFSC", "value": applicant.ifscCode},
      ],
    );
  }

  Map<String, dynamic> _docEntry(
    BuildContext context,
    String title,
    String url,
  ) {
    return {
      "title": title,
      "value": url,
      "widget": CustomButton.documentOutline(
        onPressed: () {
          if (url.isNotEmpty) {
            showFilePreviewDialog(context, title: title, url.split(","));
          }
        },
        isDisable: url.isEmpty,
      ),
    };
  }

  Widget _buildApplicantTypeWidget(String type) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            type.toLowerCase() == "applicant"
                ? AppColor.lightBlue
                : AppColor.purple.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: AppTextStyle.ts12M(
          color:
              type.toLowerCase() == "applicant"
                  ? AppColor.primary
                  : AppColor.purple,
        ),
      ),
    );
  }
}
