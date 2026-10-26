part of '../add_tenant_booking_screen.dart';

extension _DetailsTab on _AddTenantBookingScreenState {
  static const int _tenantCodeLength = 18;

  // INVENTORY OBJ
  dynamic _inv(String key) => widget.inventoryObject?.firstOrNull?[key];

  num get _projectReraCarpetArea =>
      _inv("reraCarpetAreaSqFt") ??
      (widget.tenantBookingModel?.reraCarpetAreaSqFt ?? 0);

  Widget _infoRow(List<Widget> children) => Row(
    spacing: 10,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );

  List<Widget> _pairRows(List<(String, String)> items) => [
    for (var i = 0; i < items.length; i += 2)
      _infoRow([
        for (final e in items.skip(i).take(2))
          buildColumnTitleValue(title: e.$1, value: e.$2),
      ]),
  ];

  Widget _sectionContainer({
    required String title,
    required List<Widget> children,
    EdgeInsets margin = const EdgeInsets.only(bottom: 10),
  }) {
    return Container(
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.all(16),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          ...children,
        ],
      ),
    );
  }

  String? _requiredValidator(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  String? _addressValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return "$label is required.";
    if (value.trim().length < 25) {
      return "$label must be at least 25 characters";
    }
    return null;
  }

  void _updateBookingAmount() {
    _bookingCubit.onUpdateBookingAmount(
      agreementValueWithTds:
          double.tryParse(_agreementValueWithoutTdsC.text.trim()) ?? 0.0,
      agreementValueGST: _agreementGstAmountNotifier.value,
      agreementValueTds: _tdsNotifier.value,
    );
  }

  Future<void> _fetchTenant(String code) async {
    final building = _selectedBuildingNotifier.value;
    if (building.isEmpty || code.length != _tenantCodeLength) return;

    _isFetchingTenant.value = true;
    _tenantFetchTried.value = true;
    try {
      await _bookingCubit.getTenantList(
        context: context,
        projectId: _project.projectId,
        systemGeneratedCode: code,
        buildingId: building.first['zAttributesId'],
        projectReraCarpetArea: _projectReraCarpetArea.toDouble(),
      );

      if (!mounted) return;

      final list = _bookingCubit.state.tenantList;
      _applicants.value =
          list.isNotEmpty
              ? List<TenantApplicantData>.from(list.first.tenantApplicantData)
              : <TenantApplicantData>[];
    } finally {
      if (mounted) _isFetchingTenant.value = false;
    }
  }

  void _onTenantCodeChanged(String value) {
    _debounce?.cancel();

    if (value.length != _tenantCodeLength) {
      _bookingCubit.clearTenantList();
      _applicants.value = <TenantApplicantData>[];
      _tenantFetchTried.value = false;
      _isFetchingTenant.value = false;
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchTenant(value),
    );
  }

  // DETAILS COMPONENT
  Widget _buildDetails() {
    return Form(
      key: _detailsFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<TenantBookingCubit, TenantBookingState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTenantLookupCard(),
                    _buildTenantResult(state),
                  ],
                );
              },
            ),
            _buildReraMofaToggle(),
            verticalSpacing(height: 16),
            _buildAddressCard(),
            _buildProjectDetails(),
            verticalSpacing(height: 12),
            _buildAgreementCard(),
            verticalSpacing(height: 8),
            _buildTaxCard(),
            _buildParkingCard(),
            _buildOtherDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantLookupCard() {
    return Container(
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
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
                onClear: () => _selectedBuildingNotifier.value = [],
                onSelected: (value) async {
                  _selectedBuildingNotifier.value = value;
                  await _fetchTenant(_tenantUniqueCodeC.text);
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
              LengthLimitingTextInputFormatter(_tenantCodeLength),
            ],
            hint: "Search By Tenant Code",
            textController: _tenantUniqueCodeC,
            onChangeFunction: _onTenantCodeChanged,
            validator:
                (value) =>
                    (value == null || value.isEmpty)
                        ? 'Tenant Code is required.'
                        : null,
          ),
        ],
      ),
    );
  }

  /// DECIDE BETWEEN : NOTHING / LOADING / TENANT DETAILS / NOT FOUND.
  Widget _buildTenantResult(TenantBookingState state) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _selectedBuildingNotifier,
        _isFetchingTenant,
        _tenantFetchTried,
        _tenantUniqueCodeC,
      ]),
      builder: (context, _) {
        final tenant = state.tenantList.firstOrNull;
        final hasBuilding = _selectedBuildingNotifier.value.isNotEmpty;
        final codeReady =
            _tenantUniqueCodeC.text.trim().length == _tenantCodeLength;
        final isLoading = _isFetchingTenant.value || state.isLoading == true;

        if (codeReady && isLoading) return _buildFetchingCard();

        if (tenant != null && hasBuilding) {
          return _buildTenantDetails(tenant);
        }

        if (codeReady && _tenantFetchTried.value) {
          return _buildNotFoundCard();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFetchingCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.lightBlue,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.primary, width: .5),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              horizontalSpacing(width: 10),
              Text("Fetching tenant...", style: AppTextStyle.ts14M()),
            ],
          ),
        ),
        verticalSpacing(),
      ],
    );
  }

  Widget _buildNotFoundCard() {
    return Column(
      children: [
        verticalSpacing(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColor.lightRed,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.error, width: .5),
          ),
          child: Text(
            "No Tenant details found for this Tenant Code",
            style: AppTextStyle.ts14M(color: AppColor.error),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTenantDetails(TenantModel tenant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExistingUnitCard(tenant),
        _buildEligibilityCard(tenant),
        _buildApplicantsSection(),
      ],
    );
  }

  Widget _buildExistingUnitCard(TenantModel tenant) {
    return SectionCard(
      title: "Existing Unit Details",
      titleTextColor: AppColor.darkBlue29,
      headerBackgroundColor: AppColor.darkBlue29.withValues(alpha: 0.1),
      children: _pairRows([
        ("Tenant Code", tenant.systemGeneratedCode),
        ("Unit / Annexure / Survey Number", tenant.unitAnnexureSurveyNumber),
        ("Unit Type", tenant.unitType),
        ("Unit Configuration", tenant.unitConfiguration),
        ("Unit Carpet Area (SqFt)", tenant.unitCarpetAreaSqFt.addCommas()),
        ("Unit Facing", tenant.unitFacing),
      ]),
    );
  }

  Widget _buildEligibilityCard(TenantModel tenant) {
    final total =
        tenant.totalNewRERACarpetAreaSqFt +
        tenant.deckAreaSqFt +
        tenant.areaAgainstTerraceSqFt;

    return SectionCard(
      title: 'Eligibility Details in Carpet Area (SqFt)',
      titleTextColor: AppColor.brown,
      headerBackgroundColor: AppColor.lightYellow,
      children: [
        ..._pairRows([
          (
            "Extra Free Carpet Area Offered (%)",
            tenant.extraFreeCarpetAreaOfferedPercent.addCommas(),
          ),
          (
            "Free MOFA Carpet Area (SqFt)",
            tenant.freeMOFACarpetAreaSqFt.addCommas(),
          ),
          (
            "Existing Terrace Area (SqFt)",
            tenant.existingTerraceAreaSqFt.addCommas(),
          ),
          (
            "New Eligibility MOFA Carpet Area (SqFt)",
            tenant.newEligibilityMOFACarpetAreaSqFt.addCommas(),
          ),
          (
            "New Eligibility RERA Carpet Area (SqFt)",
            tenant.newEligibilityRERACarpetAreaSqFt.addCommas(),
          ),
          (
            "(A) Area Against Terrace (SqFt)",
            tenant.areaAgainstTerraceSqFt.addCommas(),
          ),
          (
            "MOFA Carpet Area Purchased (SqFt)",
            tenant.mofaCarpetAreaPurchasedSqFt.addCommas(),
          ),
          (
            "RERA Carpet Area Purchased (SqFt)",
            tenant.reraCarpetAreaPurchasedSqFt.addCommas(),
          ),
          ("(B) Deck Area (SqFt)", tenant.deckAreaSqFt.addCommas()),
          (
            "Total New MOFA Carpet Area (SqFt)",
            tenant.totalNewMOFACarpetAreaSqFt.addCommas(),
          ),
          (
            "(C) Total New RERA Carpet Area (SqFt)",
            tenant.totalNewRERACarpetAreaSqFt.addCommas(),
          ),
        ]),
        buildRowWrapper(
          child: buildColumnTitleValue(
            title:
                "Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)",
            value: total.addCommas(),
          ),
        ),
        buildRowWrapper(
          child: buildColumnTitleValue(title: "Remark", value: tenant.remark),
        ),
      ],
    );
  }

  Widget _buildApplicantsSection() {
    return ValueListenableBuilder<List<TenantApplicantData>>(
      valueListenable: _applicants,
      builder: (context, applicants, child) {
        if (applicants.isEmpty) return const SizedBox.shrink();
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
                  .map((applicant) => ApplicantCard(tenantApplicant: applicant))
                  .toList(),
        );
      },
    );
  }

  Widget _buildReraMofaToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isRERA,
      builder: (_, isRera, __) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.grey10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey2),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              _buildToggleOption(
                label: "RERA",
                selected: isRera,
                onTap: () => _isRERA.value = true,
              ),
              _buildToggleOption(
                label: "MOFA",
                selected: !isRera,
                onTap: () => _isRERA.value = false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        alignment: Alignment.center,
        decoration:
            selected
                ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.grey30),
                )
                : null,
        child: Text(
          label,
          style:
              selected
                  ? AppTextStyle.ts12SB(color: AppColor.primary)
                  : AppTextStyle.ts12M(color: AppColor.grey),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return _sectionContainer(
      title: "Address Details",
      children: [
        CustomTextField(
          key: const ValueKey("permanent_address"),
          title: "Permanent Address",
          isRequired: true,
          hint: "Enter Permanent Address",
          minLines: 3,
          maxLines: 3,
          textController: _permanentAddressC,
          validator: (v) => _addressValidator(v, "Permanent Address"),
        ),
        CustomTextField(
          key: const ValueKey("communication_address"),
          title: "Communication Address",
          isRequired: true,
          minLines: 3,
          maxLines: 3,
          hint: "Enter Communication Address",
          textController: _communicationAddressC,
          validator: (v) => _addressValidator(v, "Communication Address"),
        ),
      ],
    );
  }

  Widget _buildProjectDetails() {
    final model = widget.tenantBookingModel;

    return BlocBuilder<TenantBookingCubit, TenantBookingState>(
      bloc: _bookingCubit,
      buildWhen: (p, c) => p.tenantList != c.tenantList,
      builder: (context, state) {
        return infoCard(title: "Project Details", [
          {
            "title": "Building Number",
            "value": _inv("buildingNumber") ?? model?.buildingNumber,
          },
          {"title": "Wing", "value": _inv("wing") ?? model?.wing},
          {"title": "Floor", "value": _inv("floor") ?? model?.floor},
          {"title": "Unit No", "value": _inv("flat") ?? model?.flat},
          {"title": "Flat Type", "value": _inv("flatType") ?? model?.flatType},
          {
            "title": "Flat Configuration",
            "value": _inv("flatConfiguration") ?? model?.flatConfiguration,
          },
          {
            "title": "RERA Carpet Area (SqFt)",
            "value":
                ((_inv("reraCarpetAreaSqFt") ?? model?.reraCarpetAreaSqFt)
                        as num)
                    .addCommas(),
          },
          {
            "title": "Adjust Purchase Area (SqFt)",
            "value":
                ((_inv("adjustPurchaseArea") ?? model?.adjustPurchaseAreaSqFt)
                        as num)
                    .addCommas(),
          },
        ]);
      },
    );
  }

  Widget _buildAgreementCard() {
    return _sectionContainer(
      title: "Agreement Details",
      children: [
        CustomTextField(
          title: "Agreement Value (With TDS)",
          hint: "Enter Agreement Value (with TDS)",
          prefixType: CustomTextFieldPrefix.rupees,
          isRequired: true,
          textController: _agreementValueWithTdsC,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatterList: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,16}(\.\d{0,2})?')),
          ],
          onChangeFunction: (value) {
            _agreementValueNotifier.value = double.tryParse(value) ?? 0.0;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Agreement Value (with TDS) is required.";
            }
            return null;
          },
        ),
        ValueListenableBuilder<double>(
          valueListenable: _tdsNotifier,
          builder:
              (_, __, ___) => CustomTextField(
                readOnly: true,
                title: "TDS",
                prefixType: CustomTextFieldPrefix.rupees,
                hint: "TDS",
                textController: _tdsC,
              ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _withoutTdsNotifier,
          builder:
              (_, __, ___) => CustomTextField(
                readOnly: true,
                title: "Agreement Value (Without TDS)",
                hint: "Agreement Value (without TDS)",
                textController: _agreementValueWithoutTdsC,
                prefixType: CustomTextFieldPrefix.rupees,
                onChangeFunction: (_) => _updateBookingAmount(),
              ),
        ),
      ],
    );
  }

  Widget _buildTaxCard() {
    return _sectionContainer(
      title: "Tax Details",
      children: [
        CustomTextField(
          isRequired: true,
          title: "Agreement GST",
          prefixType: CustomTextFieldPrefix.percentage,
          hint: "Enter Agreement GST Percentage",
          textController: _agreementGstPercentageC,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatterList: InputValidator.percentage(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Agreement GST Percentage is required.";
            }
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) return "Invalid percentage";
            return null;
          },
          onChangeFunction: (_) {
            _calculateGst();
            _updateBookingAmount();
          },
        ),
        _readOnlyAmountField(
          notifier: _agreementGstAmountNotifier,
          title: "Agreement GST Amount",
          controller: _agreementGstAmountC,
        ),
        CustomTextField(
          isRequired: true,
          title: "Stamp Duty",
          hint: "Enter Stamp Duty Percentage",
          prefixType: CustomTextFieldPrefix.percentage,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatterList: InputValidator.percentage(),
          textController: _stampDutyPercentageC,
          validator:
              (v) =>
                  _requiredValidator(v, "Stamp Duty Percentage is required."),
          onChangeFunction: (_) => _calculateStampDuty(),
        ),
        _readOnlyAmountField(
          notifier: _stampDutyAmountNotifier,
          title: "Stamp Duty Amount",
          controller: _stampDutyAmountC,
        ),
        _readOnlyAmountField(
          notifier: _registrationFeesNotifier,
          title: "Registration Fees",
          controller: _registrationFeesC,
        ),
      ],
    );
  }

  Widget _readOnlyAmountField({
    required ValueListenable<double> notifier,
    required String title,
    required TextEditingController controller,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder:
          (_, __, ___) => CustomTextField(
            readOnly: true,
            title: title,
            hint: title,
            textController: controller,
            prefixType: CustomTextFieldPrefix.rupees,
          ),
    );
  }

  Widget _buildParkingCard() {
    final parkingData = widget.tenantBookingModel?.parkingData;
    if (!_isEditMode || parkingData == null || parkingData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 350,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              itemCount: parkingData.length,
              itemBuilder: (_, index) => _buildParkingItem(parkingData[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingItem(ParkingModel parking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primary, width: .3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 10,
        children: _pairRows([
          ("Parking Number", parking.parkingNumber),
          ("Building", parking.buildingNumber),
          ("Wing", parking.wing),
          ("Floor", parking.floor),
          ("Category", parking.parkingCategory),
          ("Type", parking.parkingType),
          ("EV Charging", parking.isEVChargingAvailable ? "Yes" : "No"),
        ]),
      ),
    );
  }

  Widget _buildOtherDetailsCard() {
    return _sectionContainer(
      title: "Other Details",
      children: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _selectedParkingNotifier,
          builder: (context, selectedParking, child) {
            return CustomMultipleSelectPopup(
              title: "Parking",
              hintText: "Select Parking",
              isMultiSelect: true,
              initialValue: selectedParking,
              dataList: const [],
              onSelected: _onParkingSelected,
              dataFetchCallBack: _fetchParking,
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
          builder: (context, selected, child) {
            return CustomDropDownWidget(
              title: "Handover Type",
              hintText: "Select Handover Type",
              isRequired: true,
              initialValue: selected,
              dataList: handOverTypeList,
              onSelected: (value) => _selectedHandOverType.value = value,
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? "Handover Type is required."
                          : null,
              onValueClear: () => _selectedHandOverType.value = null,
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _selectedExpectedRegistrationDate,
          builder: (context, selectedDate, child) {
            return CustomDatePicker(
              title: "Expected Registration Date",
              isRequired: true,
              initialDate: selectedDate,
              setValue:
                  (value) => _selectedExpectedRegistrationDate.value = value,
              validator:
                  (v) =>
                      v == null
                          ? "Expected Registration Date is required."
                          : null,
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _selectedFundingSource,
          builder: (context, selected, child) {
            return CustomDropDownWidget(
              title: "Source Of Funding",
              hintText: "Select Source Of Funding",
              isRequired: true,
              initialValue: selected,
              dataList: fundingSourceList,
              onSelected: (value) => _selectedFundingSource.value = value,
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? "Funding Source is required."
                          : null,
              onValueClear: () => _selectedFundingSource.value = null,
            );
          },
        ),
      ],
    );
  }

  Future<void> _onParkingSelected(List<Map<String, dynamic>> value) async {
    _selectedParkingNotifier.value = value;
    if (!mounted) return;

    final newBuildingId =
        value.isNotEmpty ? value.first['zAttributesId'] as int? : null;

    if (newBuildingId == null) {
      _lastFetchedBuildingId = null;
      return;
    }

    if (_lastFetchedBuildingId != newBuildingId) {
      _lastFetchedBuildingId = newBuildingId;
      await _bookingCubit.getParkingList(
        context,
        1,
        _project.projectId,
        displayParkingId:
            _isEditMode ? widget.tenantBookingModel!.parkingId : null,
      );
    }
  }
}
