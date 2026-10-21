part of '../add_booking_screen.dart';

extension _DetailsTab on _AddBookingScreenState {
  Widget _buildDetails() {
    return Form(
      key: _detailsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  BlocConsumer<BookingCubit, BookingState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      final enquiry =
                          state.enquiryList.isNotEmpty
                              ? state.enquiryList.first
                              : null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            title: "Enquiry Code",
                            isRequired: true,
                            readOnly: _isEditMode,
                            inputFormatterList: [
                              UpperCaseTextFormatter(),
                              LengthLimitingTextInputFormatter(18),
                            ],
                            hint: "Search By Enquiry Code",
                            textController: _enquiryUniqueCodeC,
                            onChangeFunction: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }

                              if (value.length != 18) {
                                // CLEAR ANY PREVIOUS ENQUIRY RESULT AND FETCH FLAGS
                                _bookingCubit.clearEnquiryList();
                                _enquiryFetchTried.value = false;
                                _isFetchingEnquiry.value = false;
                                return;
                              }

                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () async {
                                  if (value.length == 18) {
                                    _isFetchingEnquiry.value = true;
                                    _enquiryFetchTried.value = true;
                                    await _bookingCubit.getEnquiryList(
                                      context,
                                      1,
                                      _project.projectId,
                                      value,
                                      null,
                                    );
                                    _isFetchingEnquiry.value = false;
                                  }
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enquiry Code is required.';
                              }
                              return null;
                            },
                          ),
                          if (enquiry != null &&
                              (enquiry.finalStage.toLowerCase() !=
                                      'booking done' ||
                                  _isEditMode)) ...[
                            infoCard([
                              {
                                "title": "Enquiry Code",
                                "value": enquiry.systemGeneratedCode,
                              },
                              {"title": "Name", "value": enquiry.name},
                              {
                                "title": "E-Mail ID",
                                "value": enquiry.emailId,
                                "widget": CustomClickToContactText(
                                  value: enquiry.emailId,
                                  type: ContactType.email,
                                ),
                              },
                              {
                                "title": "Nationality",
                                "value": enquiry.nationality,
                              },
                              {
                                "title": "Mobile No",
                                "value": enquiry.mobileNumber,
                                "widget": CustomClickToContactText(
                                  countryCode: enquiry.mobileNumberCountryCode,
                                  value: enquiry.mobileNumber,
                                ),
                              },
                              {"title": "Source", "value": enquiry.source},
                              {
                                "title": "Sub Source",
                                "value": enquiry.subSource,
                              },
                              {
                                "title": "Sales Advisor",
                                "value": enquiry.salesAdvisor,
                              },
                              {
                                "title": "Sourcing Manager",
                                "value": enquiry.sourcingManager,
                              },
                              {"title": "Stage", "value": enquiry.finalStage},
                              {
                                "title": "Current Location",
                                "value": enquiry.currentLocation,
                              },
                            ]),
                            Column(
                              children: [
                                if (enquiry.subSource == "Reference")
                                  infoCard([
                                    {
                                      "title": "Referral Name",
                                      "value": enquiry.referralName,
                                    },
                                    {
                                      "title": "Referral Project",
                                      "value": enquiry.referralProjectName,
                                    },
                                    {
                                      "title": "Referral Unit No",
                                      "value": enquiry.referralUnitNumber,
                                    },
                                    {
                                      "title": "Referral Unit Owner",
                                      "value": enquiry.referralUnitOwnerName,
                                    },
                                  ]),

                                if (enquiry.subSource == "Employee Reference")
                                  infoCard([
                                    {
                                      "title": "Employee Name",
                                      "value": enquiry.employeeReferenceName,
                                    },
                                    {
                                      "title": "Employee Mobile",
                                      "value":
                                          enquiry.employeeReferenceMobileNumber,
                                    },
                                  ]),

                                if (enquiry.subSource == "Loyalty")
                                  infoCard([
                                    {
                                      "title": "Existing Project",
                                      "value":
                                          enquiry.loyaltyExistingProjectName,
                                    },
                                    {
                                      "title": "Existing Unit No",
                                      "value":
                                          enquiry.loyaltyExistingUnitNumber,
                                    },
                                    {
                                      "title": "Existing Unit Owner",
                                      "value":
                                          enquiry.loyaltyExistingUnitOwnerName,
                                    },
                                  ]),
                                if (enquiry.source == "Channel Partner")
                                  infoCard([
                                    {
                                      "title": "CP Code",
                                      "value": enquiry.channelPartnerCode,
                                    },
                                    {
                                      "title": "Channel Partner",
                                      "value": enquiry.channelPartnerName,
                                    },
                                    {
                                      "title": "CP Mobile",
                                      "value":
                                          enquiry.channelPartnerMobileNumber,
                                      "widget": CustomClickToContactText(
                                        countryCode:
                                            enquiry
                                                .channelPartnerMobileNumberCountryCode,
                                        value:
                                            enquiry.channelPartnerMobileNumber,
                                      ),
                                    },
                                    {
                                      "title": "CP E-Mail ID",
                                      "value": enquiry.channelPartnerEmailId,
                                      "widget": CustomClickToContactText(
                                        value: enquiry.channelPartnerEmailId,
                                        type: ContactType.email,
                                      ),
                                    },
                                    {
                                      "title": "CP Team Member",
                                      "value":
                                          enquiry.channelPartnerTeamMemberName,
                                    },
                                    {
                                      "title": "CP Team Mobile",
                                      "value":
                                          enquiry
                                              .channelPartnerTeamMemberMobileNumber,
                                      "widget": CustomClickToContactText(
                                        countryCode:
                                            enquiry
                                                .channelPartnerTeamMemberMobileNumberCountryCode,
                                        value:
                                            enquiry
                                                .channelPartnerTeamMemberMobileNumber,
                                      ),
                                    },
                                    {
                                      "title": "CP Team E-Mail ID",
                                      "value":
                                          enquiry
                                              .channelPartnerTeamMemberEmailId,
                                      "widget": CustomClickToContactText(
                                        value:
                                            enquiry
                                                .channelPartnerTeamMemberEmailId,
                                        type: ContactType.email,
                                      ),
                                    },
                                  ]),
                              ],
                            ),
                            verticalSpacing(),
                          ] else if (_enquiryUniqueCodeC.text.trim().length ==
                                  18 &&
                              (_isFetchingEnquiry.value ||
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
                                    "Fetching enquiry...",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                ],
                              ),
                            ),
                            verticalSpacing(),
                          ] else if (enquiry != null &&
                              enquiry.finalStage.toLowerCase() ==
                                  'booking done') ...[
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
                                    "Booking already done for this enquiry",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_enquiryUniqueCodeC.text.trim().length ==
                                  18 &&
                              _enquiryFetchTried.value &&
                              enquiry == null &&
                              !(_isFetchingEnquiry.value ||
                                  (_debounce?.isActive ?? false) ||
                                  state.isLoading == true)) ...[
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
                                "No Enquiry details found for this Enquiry Code",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else ...[
                            SizedBox(),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Applicant Details",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      CustomButton(
                        leading: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColor.white,
                        ),
                        text: "Add Applicant",
                        onPressed: () async => _openApplicantForm(),
                        backgroundColor: AppColor.primary,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  ValueListenableBuilder<List<BookingApplicantData>>(
                    valueListenable: _applicants,
                    builder: (context, applicants, child) {
                      if (applicants.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              'No applicants added yet',
                              style: AppTextStyle.ts14R(color: AppColor.grey),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 450,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: applicants.length,
                          itemBuilder: (context, index) {
                            final applicant = applicants[index];

                            return ApplicantCard(
                              applicant: applicant,
                              suffixActionWidgets: Row(
                                children: [
                                  CustomIconButton.edit(
                                    onPressed:
                                        () => _openApplicantForm(
                                          applicant: applicant,
                                          index: index,
                                        ),
                                  ),
                                  horizontalSpacing(width: 8),
                                  CustomIconButton.delete(
                                    onPressed:
                                        () => _showPopupToDeleteApplicant(
                                          context,
                                          index,
                                        ),
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
                    "Address Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  CustomTextField(
                    key: const ValueKey("permanent_address"),
                    title: "Permanent Address",
                    minLines: 3,
                    maxLines: 3,
                    isRequired: true,
                    hint: "Enter Permanent Address",
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
                    widget.bookingModel!.buildingNumber,
              },
              {
                "title": "Wing",
                "value":
                    widget.inventoryObject?[0]["wing"] ??
                    widget.bookingModel!.wing,
              },
              {
                "title": "Floor",
                "value":
                    widget.inventoryObject?[0]["floor"] ??
                    widget.bookingModel!.floor,
              },
              {
                "title": "Unit No",
                "value":
                    widget.inventoryObject?[0]["flat"] ??
                    widget.bookingModel!.flat,
              },
              {
                "title": "Flat Type",
                "value":
                    widget.inventoryObject?[0]["flatType"] ??
                    widget.bookingModel!.flatType,
              },
              {
                "title": "Flat Configuration",
                "value":
                    widget.inventoryObject?[0]["flatConfiguration"] ??
                    widget.bookingModel!.flatConfiguration,
              },
              {
                "title": "RERA Carpet Area (SqFt)",
                "value":
                    widget.inventoryObject?[0]["reraCarpetAreaSqFt"]
                        .toString() ??
                    widget.bookingModel!.reraCarpetAreaSqFt.toString(),
              },
            ]),
            Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Agreement Details", style: AppTextStyle.ts16SB()),
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
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tax Details", style: AppTextStyle.ts16SB()),
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
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final enquiry =
                    state.enquiryList.isNotEmpty
                        ? state.enquiryList.first
                        : null;

                if (enquiry == null) return const SizedBox();

                return Column(
                  children: [
                    if (enquiry.subSource == "Reference")
                      commissionSection(
                        title: "Referel Details",
                        percentageTitle: "Referel",
                        amountTitle: "Referel Amount",
                        percentController: _referencePercentageC,
                        amountController: _referenceAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.subSource == "Employee Reference")
                      commissionSection(
                        title: "Employee Reference Details",
                        percentageTitle: "Employee Reference",
                        amountTitle: "Employee Reference Amount",
                        percentController: _employeeRefPercentageC,
                        amountController: _employeeRefAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.subSource == "Loyalty")
                      commissionSection(
                        title: "Loyalty Details",
                        percentageTitle: "Loyalty",
                        amountTitle: "Loyalty Amount",
                        percentController: _loyaltyPercentageC,
                        amountController: _loyaltyAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.source == "Channel Partner")
                      commissionSection(
                        title: "Brokerage Details",
                        percentageTitle: "Channel Partner Brokerage",
                        amountTitle: "Brokerage Amount",
                        percentController: _brokeragePercentageC,
                        amountController: _brokerageAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),
                  ],
                );
              },
            ),

            (!_isEditMode || widget.bookingModel!.parkingData.isEmpty)
                ? SizedBox.shrink()
                : Container(
                  height: 350,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Parking Details", style: AppTextStyle.ts16SB()),
                      verticalSpacing(),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount: widget.bookingModel!.parkingData.length,
                          itemBuilder: (_, index) {
                            final parking =
                                widget.bookingModel!.parkingData[index];
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
                  Text("Other Details", style: AppTextStyle.ts16SB()),
                  verticalSpacing(),
                  BlocBuilder<BookingCubit, BookingState>(
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
                                            ? widget.bookingModel!.parkingId
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

  // COMMISSION SECTION FOR ENQUIRY WHICH HAD SOURCE: CHANNEL PARTNER (BROKERAGE) OR SUBSOURCE: REFERENCE, EMPLOYEE REFERENCE, LOYALTY
  Widget commissionSection({
    required String title,
    required String percentageTitle,
    required String amountTitle,
    required TextEditingController percentController,
    required TextEditingController amountController,
    required ValueNotifier<double> agreementNotifier,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: agreementNotifier,
      builder: (context, agreementAmount, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateCommissionAmount(
            percentController: percentController,
            amountController: amountController,
            agreementAmount: agreementAmount,
          );
        });

        return Container(
          decoration: commonCardDecoration(),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.ts16SB()),
              verticalSpacing(),

              CustomTextField(
                title: percentageTitle,
                hint: "Enter Percentage",
                isRequired: true,
                prefixType: CustomTextFieldPrefix.percentage,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatterList: InputValidator.percentage(),
                textController: percentController,
                onChangeFunction: (value) {
                  calculateCommissionAmount(
                    percentController: percentController,
                    amountController: amountController,
                    agreementAmount: agreementAmount,
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Percentage';
                  }
                  return null;
                },
              ),

              CustomTextField(
                readOnly: true,
                isRequired: true,
                title: amountTitle,
                hint: "$title Amount",
                textController: amountController,
                prefixType: CustomTextFieldPrefix.rupees,
              ),
            ],
          ),
        );
      },
    );
  }
}
