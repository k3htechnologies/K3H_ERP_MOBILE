import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/custom_signature_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../core/country_code.dart';

class AddInwardOutwardScreen extends StatefulWidget {
  final InwardOutwardModel? inwardOutwardModel;
  final int? index;
  const AddInwardOutwardScreen({
    super.key,
    this.inwardOutwardModel,
    this.index,
  });

  @override
  State<AddInwardOutwardScreen> createState() => _AddInwardOutwardScreenState();
}

class _AddInwardOutwardScreenState extends State<AddInwardOutwardScreen> {
  late InwardOutwardCubit _inwardOutwardCubit;
  late AuthorizationModel _routeAuthorizationModel;
  bool get _isEditMode => widget.inwardOutwardModel != null;

  late TextEditingController _documentTitleC,
      _invoiceNoC,
      _amountC,
      _chequeNumberC,
      _senderMobileNumberC,
      _senderNameC,
      _senderEmailIdC,
      _senderAddressC,
      _receiverMobileNumberC,
      _receiverNameC,
      _receiverEmailIdC,
      _receiverAddressC,
      _documentDescC,
      _receivedByC,
      _handoverToC,
      _remarkC;

  final ValueNotifier<String> _deliveryType = ValueNotifier("Others");

  final ValueNotifier<Map<String, dynamic>?> _selectedDocumentType =
      ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedDeliveryMode =
      ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedDeliveryStatus =
      ValueNotifier(null);

  final ValueNotifier<CountryCode> _selectedSenderCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  final ValueNotifier<CountryCode> _selectedReceiverCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  DateTime? _date, _invoiceDate, _handoverDate;

  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedAcknowlegementSignatureFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );

  MultiFilePickerModel selectedAcknowledgementFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get selectedEmployees => _selectedEmployeeNotifier.value
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  @override
  void initState() {
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();

    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .inwardOutwardAcknowledgement] ??
        AuthorizationModel();
    _initializeTextEditingControllers();

    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

    if (_isEditMode) {
      _populateFormFields();
    } else {
      _date = DateTime.now();
    }

    super.initState();
  }

  @override
  void dispose() {
    _documentTitleC.dispose();
    _invoiceNoC.dispose();
    _amountC.dispose();
    _chequeNumberC.dispose();
    _senderMobileNumberC.dispose();
    _senderNameC.dispose();
    _senderEmailIdC.dispose();
    _senderAddressC.dispose();
    _receiverMobileNumberC.dispose();
    _receiverNameC.dispose();
    _receiverEmailIdC.dispose();
    _receiverAddressC.dispose();
    _documentDescC.dispose();
    _receivedByC.dispose();
    _handoverToC.dispose();
    _remarkC.dispose();

    _deliveryType.dispose();
    _selectedDocumentType.dispose();
    _selectedDeliveryMode.dispose();
    _selectedDeliveryStatus.dispose();
    _selectedSenderCountry.dispose();
    _selectedReceiverCountry.dispose();
    _selectedEmployeeNotifier.dispose();

    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _documentTitleC = TextEditingController();
    _invoiceNoC = TextEditingController();
    _amountC = TextEditingController();
    _chequeNumberC = TextEditingController();

    _senderMobileNumberC = TextEditingController();
    _senderNameC = TextEditingController();
    _senderEmailIdC = TextEditingController();
    _senderAddressC = TextEditingController();

    _receiverMobileNumberC = TextEditingController();
    _receiverNameC = TextEditingController();
    _receiverEmailIdC = TextEditingController();
    _receiverAddressC = TextEditingController();

    _documentDescC = TextEditingController();
    _receivedByC = TextEditingController();
    _handoverToC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _populateFormFields() {
    final data = widget.inwardOutwardModel!;

    // DETAILS
    _deliveryType.value =
        data.deliveryType.isNotEmpty ? data.deliveryType : "Others";

    _selectedDocumentType.value = inwardOutwardDocumentType.firstWhere(
      (e) => e["DisplayName"] == data.documentType,
      orElse: () => <String, dynamic>{},
    );

    _documentTitleC.text = data.documentTitle;
    _date = data.inwardOutwardDate;
    if (data.invoiceNumber != "0") _invoiceNoC.text = data.invoiceNumber;
    _invoiceDate = data.invoiceDate;
    _amountC.text = data.amount != 0 ? data.amount.toString() : "";

    if (data.chequeNumber.isNotEmpty) {
      _chequeNumberC.text = data.chequeNumber;
    }

    // SENDER
    _senderMobileNumberC.text = data.senderMobileNumber;
    _senderNameC.text = data.senderName;
    _senderEmailIdC.text = data.senderEmailId;
    _senderAddressC.text = data.senderAddress;

    // RECEIVER
    _receiverMobileNumberC.text = data.receiverMobileNumber;
    _receiverNameC.text = data.receiverName;
    _receiverEmailIdC.text = data.receiverEmailId;
    _receiverAddressC.text = data.receiverAddress;

    // DOCUMENT
    _documentDescC.text = data.documentDescription;

    selectedDocumentFile.fileNameList =
        data.documentURL.isNotEmpty ? data.documentURL.split(",") : [];

    // ASSIGN EMPLOYEE
    if (data.employeeId.toString().isNotEmpty) {
      final employeeIdsRaw = data.employeeId.toString();
      final employeeNamesRaw = data.employeeNames;

      final employeeIds =
          employeeIdsRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList();

      final employeeNames =
          employeeNamesRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final maxLength =
          employeeIds.length < employeeNames.length
              ? employeeIds.length
              : employeeNames.length;

      _selectedEmployeeNotifier.value = List.generate(maxLength, (index) {
        return {
          "zAttributesId": employeeIds[index],
          "DisplayName": employeeNames[index],
        };
      });
    }

    // DELIVERY
    _selectedDeliveryMode.value = inwardOutwardDeliveryMode.firstWhere(
      (e) => e["DisplayName"] == data.deliveryMode,
      orElse: () => <String, dynamic>{},
    );

    _selectedDeliveryStatus.value = inwardOutwardDeliveryStatus.firstWhere(
      (e) => e["DisplayName"] == data.deliveryStatus,
      orElse: () => <String, dynamic>{},
    );

    // ACKNOWLEDGEMENT
    _receivedByC.text = data.acknowledgementBy;
    _handoverToC.text = data.handOverTo;
    _handoverDate = data.handOverDate;
    _remarkC.text = data.acknowledgementRemark;

    selectedAcknowlegementSignatureFile.fileNameList =
        data.acknowledgementSignatureURL.isNotEmpty
            ? data.acknowledgementSignatureURL.split(",")
            : [];

    selectedAcknowledgementFile.fileNameList =
        data.acknowledgementURL.isNotEmpty
            ? data.acknowledgementURL.split(",")
            : [];

    if (data.senderMobileNumberCountryCode.isNotEmpty) {
      _selectedSenderCountry.value = countryList.firstWhere(
        (e) => e.code == data.senderMobileNumberCountryCode,
        orElse:
            () => CountryCode(
              name: "India",
              code: "+91",
              countryCode: "IN",
              mobileLength: 10,
              regex: RegExp(r'^[6-9]\d{9}$'),
            ),
      );
    }
    if (data.receiverMobileNumberCountryCode.isNotEmpty) {
      _selectedReceiverCountry.value = countryList.firstWhere(
        (e) => e.code == data.receiverMobileNumberCountryCode,
        orElse:
            () => CountryCode(
              name: "India",
              code: "+91",
              countryCode: "IN",
              mobileLength: 10,
              regex: RegExp(r'^[6-9]\d{9}$'),
            ),
      );
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      final inwardOutward = widget.inwardOutwardModel!;

      _inwardOutwardCubit.updateInwardOutward(
        context: context,
        inwardOutwardId: inwardOutward.inwardOutwardId,
        uniqueKey: inwardOutward.uniqueKey,
        index: widget.index!,
        deliveryType: _deliveryType.value,
        inwardOutwardDate: inwardOutward.inwardOutwardDate.toIso8601String(),
        invoiceNumber: _invoiceNoC.text.trim(),
        invoiceDate: _invoiceDate?.toIso8601String() ?? "",
        senderName: _senderNameC.text.trim(),
        senderAddress: _senderAddressC.text.trim(),
        senderMobileNumberCountryCode: _selectedSenderCountry.value.code,
        senderMobileNumber: _senderMobileNumberC.text.trim(),
        senderEmailId: _senderEmailIdC.text.trim(),
        receiverName: _receiverNameC.text.trim(),
        receiverAddress: _receiverAddressC.text.trim(),
        receiverMobileNumberCountryCode: _selectedReceiverCountry.value.code,
        receiverMobileNumber: _receiverMobileNumberC.text.trim(),
        receiverEmailId: _receiverEmailIdC.text.trim(),
        documentURL: selectedDocumentFile,
        employeeId: selectedEmployees,
        documentType: _selectedDocumentType.value?['DisplayName'] ?? '',
        acknowledgementSignature: selectedAcknowlegementSignatureFile,
        acknowledgementBy: _receivedByC.text.trim(),
        handOverTo: _handoverToC.text.trim(),
        handOverDate: _handoverDate?.toIso8601String() ?? "",
        chequeNumber: _chequeNumberC.text.trim(),
        documentTitle: _documentTitleC.text.trim(),
        documentDescription: _documentDescC.text.trim(),
        amount: double.tryParse(_amountC.text.trim()) ?? 0.0,
        deliveryMode: _selectedDeliveryMode.value?['DisplayName'] ?? "",
        deliveryStatus: _selectedDeliveryStatus.value?['DisplayName'] ?? "",
        acknowledgementURL: selectedAcknowledgementFile,
        acknowledgementRemark: _remarkC.text.trim(),
      );
    } else {
      _inwardOutwardCubit.addInwardOutward(
        context: context,
        deliveryType: _deliveryType.value,
        inwardOutwardDate:
            _date?.toIso8601String() ?? DateTime.now().toIso8601String(),
        invoiceNumber: _invoiceNoC.text.trim(),
        invoiceDate: _invoiceDate?.toIso8601String() ?? "",
        senderName: _senderNameC.text.trim(),
        senderAddress: _senderAddressC.text.trim(),
        senderMobileNumber: _senderMobileNumberC.text.trim(),
        senderEmailId: _senderEmailIdC.text.trim(),
        receiverName: _receiverNameC.text.trim(),
        receiverAddress: _receiverAddressC.text.trim(),
        receiverMobileNumber: _receiverMobileNumberC.text.trim(),
        receiverEmailId: _receiverEmailIdC.text.trim(),
        documentURL: selectedDocumentFile,
        employeeId: selectedEmployees,
        documentType: _selectedDocumentType.value?['DisplayName'] ?? '',
        acknowledgementSignature: selectedAcknowlegementSignatureFile,
        acknowledgementBy: _receivedByC.text.trim(),
        handOverTo: _handoverToC.text.trim(),
        handOverDate: _handoverDate?.toIso8601String() ?? "",
        chequeNumber: _chequeNumberC.text.trim(),
        documentTitle: _documentTitleC.text.trim(),
        documentDescription: _documentDescC.text.trim(),
        amount: double.tryParse(_amountC.text.trim()) ?? 0.0,
        deliveryMode: _selectedDeliveryMode.value?['DisplayName'] ?? "",
        deliveryStatus: _selectedDeliveryStatus.value?['DisplayName'] ?? "",
        acknowledgementURL: selectedAcknowledgementFile,
        acknowledgementRemark: _remarkC.text.trim(),
        senderMobileNumberCountryCode: _selectedSenderCountry.value.code,
        receiverMobileNumberCountryCode: _selectedReceiverCountry.value.code,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inward Outward",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Inward Outward" : "Add Inward Outward",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              _card("Basic Details", [
                Text(
                  'Delivery Type',
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _deliveryType,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: 'Others',
                          // ignore: deprecated_member_use
                          groupValue: value,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            if (val == null) return;
                            _deliveryType.value = val;
                            _chequeNumberC.clear();
                          },
                        ),
                        Text("Others", style: AppTextStyle.ts14M()),

                        const SizedBox(width: 16),

                        Radio<String>(
                          value: 'Cheque',
                          // ignore: deprecated_member_use
                          groupValue: value,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            if (val == null) return;
                            _deliveryType.value = val;
                            _chequeNumberC.clear();
                          },
                        ),
                        Text("Cheque", style: AppTextStyle.ts14M()),
                      ],
                    );
                  },
                ),
                verticalSpacing(),
                ValueListenableBuilder(
                  valueListenable: _selectedDocumentType,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "Document Type",
                      hintText: "Select Document Type",
                      initialValue: value,
                      isRequired: true,
                      dataList: inwardOutwardDocumentType,
                      onSelected: (value) {
                        _selectedDocumentType.value = value;
                      },
                      onValueClear: () {
                        _selectedDocumentType.value = null;
                      },
                      validator: (value) {
                        if (value == null || value.toString().trim().isEmpty) {
                          return "Document Type is required";
                        }
                        return null;
                      },
                    );
                  },
                ),
                CustomTextField(
                  textController: _documentTitleC,
                  title: "Document Title",
                  isRequired: true,
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  hint: "Enter Document Title",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Document Title is required";
                    }
                    return null;
                  },
                ),
                CustomDatePicker(
                  title: "Date",
                  initialDate: _date,
                  readOnly: true,
                  setValue: (value) {
                    _date = value;
                  },
                  isRequired: true,
                ),
                ValueListenableBuilder(
                  valueListenable: _deliveryType,
                  builder: (context, value, child) {
                    final isOther = value.toLowerCase() == 'others';
                    return Column(
                      children: [
                        CustomTextField(
                          textController: _invoiceNoC,
                          title: "Invoice Number",
                          isRequired: !isOther,
                          hint: "Enter Invoice Number",
                          inputFormatterList: InputValidator.digit(15),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                !InputValidator.isValidInvoiceNumber(
                                  value.trim(),
                                )) {
                              return "Invoice Number cannot be zero.";
                            }
                            if (isOther) return null;

                            if (value == null || value.trim().isEmpty) {
                              return "Invoice Number is required";
                            }

                            return null;
                          },
                        ),
                        CustomDatePicker(
                          title: "Invoice Date",
                          initialDate: _invoiceDate,
                          endDate: DateTime.now(),
                          setValue: (value) {
                            _invoiceDate = value;
                          },
                          isRequired: !isOther,
                          validator: (value) {
                            if (isOther) return null;
                            if (value == null) {
                              return 'Invoice Date is required';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          textController: _amountC,
                          title: "Amount (₹)",
                          isRequired: !isOther,
                          hint: "Enter Amount",
                          keyboardType: TextInputType.numberWithOptions(),
                          inputFormatterList: InputValidator.digitWithDecimal(
                            maxDigitsBeforeDecimal: 15,
                            decimalPlaces: 2,
                          ),
                          validator: (value) {
                            if (isOther) return null;

                            if (value == null || value.trim().isEmpty) {
                              return "Amount is required";
                            }
                            return null;
                          },
                        ),
                        Builder(
                          builder: (context) {
                            if (isOther) {
                              return SizedBox.shrink();
                            }
                            return CustomTextField(
                              textController: _chequeNumberC,
                              title: "Cheque No",
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              inputFormatterList: InputValidator.digit(6),
                              hint: "Enter Cheque No",
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Cheque No is required";
                                }
                                if (value.trim().isNotEmpty &&
                                    !InputValidator.isValidChequeNumber(
                                      value.trim(),
                                    )) {
                                  return "Cheque Number cannot be zero.";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ]),
              _card("Sender Details", [
                ValueListenableBuilder(
                  valueListenable: _selectedSenderCountry,
                  builder: (context, value, child) {
                    return CustomTextField(
                      textController: _senderMobileNumberC,
                      title: "Mobile No.",
                      isRequired: true,
                      hint: "Enter Sender Mobile No.",
                      showCountryDropdown: true,
                      keyboardType: TextInputType.number,
                      selectedCountry: value,
                      onChangeFunction: (v) async {
                        final country = _selectedSenderCountry.value;
                        if (country.mobileLength == v.length) {
                          final senderDetails = await _inwardOutwardCubit
                              .fetchSenderReceiverByMobile(v);
                          if (senderDetails.isNotEmpty) {
                            _senderNameC.text = senderDetails.first.name;
                            _senderEmailIdC.text = senderDetails.first.emailId;
                            _senderAddressC.text = senderDetails.first.address;
                          } else {
                            _senderNameC.clear();
                            _senderEmailIdC.clear();
                            _senderAddressC.clear();
                          }
                        }
                      },
                      onCountryChanged: (country) {
                        if (country == null) return;

                        _selectedSenderCountry.value = country;
                      },
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(value.mobileLength),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        final mobile = value?.trim() ?? "";
                        final country = _selectedSenderCountry.value;
                        if (value == null || value.isEmpty) {
                          return "Sender Mobile Number is required";
                        }
                        if (mobile.isNotEmpty) {
                          // LENGTH AND REGEX VALIDATION
                          if ((mobile.length != country.mobileLength) ||
                              country.regex != null &&
                                  !country.regex!.hasMatch(mobile)) {
                            return "Invalid Sender Mobile Number";
                          }
                          if (_receiverMobileNumberC.text.trim() == mobile) {
                            return "Sender and Receiver mobile numbers should not be the same.";
                          }
                        }

                        return null;
                      },
                    );
                  },
                ),
                CustomTextField(
                  textController: _senderNameC,
                  title: "Name",
                  isRequired: true,
                  hint: "Enter Sender Name",
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Sender Name is required";
                    }
                    if (_receiverNameC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver names should not be the same.";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _senderEmailIdC,
                  title: "Email-Id",
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  hint: "Enter Sender Email-Id",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Sender Email-Id is required";
                    }
                    if (!InputValidator.isValidEmail(value)) {
                      return "Sender Invalid Email Id";
                    }
                    if (_receiverEmailIdC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver Email-Ids should not be the same.";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _senderAddressC,
                  title: "Address",
                  isRequired: true,
                  hint: "Enter Sender Address",
                  inputFormatterList: [LengthLimitingTextInputFormatter(100)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Sender Address is required";
                    }
                    if (_receiverAddressC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver addresses should not be the same.";
                    }
                    return null;
                  },
                ),
              ]),
              _card("Receiver Details", [
                ValueListenableBuilder(
                  valueListenable: _selectedReceiverCountry,
                  builder: (context, value, child) {
                    return CustomTextField(
                      textController: _receiverMobileNumberC,
                      title: "Mobile No.",
                      isRequired: true,
                      hint: "Enter Receiver Mobile No.",
                      keyboardType: TextInputType.number,
                      showCountryDropdown: true,
                      selectedCountry: value,
                      onCountryChanged: (country) {
                        if (country == null) return;
                        _selectedReceiverCountry.value = country;
                      },
                      onChangeFunction: (v) async {
                        final country = _selectedSenderCountry.value;
                        if (country.mobileLength == v.length) {
                          final receiverDetails = await _inwardOutwardCubit
                              .fetchSenderReceiverByMobile(v);
                          if (receiverDetails.isNotEmpty) {
                            _receiverNameC.text = receiverDetails.first.name;
                            _receiverEmailIdC.text =
                                receiverDetails.first.emailId;
                            _receiverAddressC.text =
                                receiverDetails.first.address;
                          } else {
                            _receiverNameC.clear();
                            _receiverEmailIdC.clear();
                            _receiverAddressC.clear();
                          }
                        }
                      },
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(value.mobileLength),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        final mobile = value?.trim() ?? "";
                        final country = _selectedReceiverCountry.value;
                        if (value == null || value.isEmpty) {
                          return "Receiver Mobile Number is required";
                        }
                        if (mobile.isNotEmpty) {
                          // LENGTH AND REGEX VALIDATION
                          if ((mobile.length != country.mobileLength) ||
                              country.regex != null &&
                                  !country.regex!.hasMatch(mobile)) {
                            return "Invalid Receiver Mobile Number";
                          }
                          if (_senderMobileNumberC.text.trim() == mobile) {
                            return "Sender and Receiver mobile numbers should not be the same.";
                          }
                        }
                        return null;
                      },
                    );
                  },
                ),
                CustomTextField(
                  textController: _receiverNameC,
                  title: "Name",
                  isRequired: true,
                  hint: "Enter Receiver Name",
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Receiver Name is required";
                    }
                    if (_senderNameC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver names should not be the same.";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _receiverEmailIdC,
                  title: "Email-Id",
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  hint: "Enter Receiver Email-Id",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Receiver Email-Id is required";
                    }
                    if (!InputValidator.isValidEmail(value)) {
                      return "Receiver Invalid Email Id";
                    }
                    if (_senderEmailIdC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver Email-Ids should not be the same.";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _receiverAddressC,
                  title: "Address",
                  isRequired: true,
                  hint: "Enter Receiver Address",
                  inputFormatterList: [LengthLimitingTextInputFormatter(100)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Receiver Address is required";
                    }
                    if (_senderAddressC.text.trim().toLowerCase() ==
                        value.trim().toLowerCase()) {
                      return "Sender and Receiver addresses should not be the same.";
                    }
                    return null;
                  },
                ),
              ]),
              _card("Document Details", [
                CustomMultiFilePicker(
                  title: "Document",
                  isRequired: true,
                  maxFiles: 5,
                  filePickType: FilePickType.both,
                  initialFileList: selectedDocumentFile.fileNameList,

                  onFilePickedCallback: (bytesList, fileNameList) {
                    selectedDocumentFile.fileNameList = fileNameList;
                    selectedDocumentFile.fileBytesList = bytesList;
                  },

                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                  ) {
                    selectedDocumentFile.fileNameList = fileNameList;
                    selectedDocumentFile.fileBytesList = fileBytesList;
                    selectedDocumentFile.deletedFileList = deletedFile;
                  },

                  validator: (fileList) {
                    if (fileList == null || fileList.isEmpty) {
                      return "Document is required";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  textController: _documentDescC,
                  title: "Document Description",
                  isRequired: true,
                  hint: "Enter Document Description",
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (value) {
                    if (value == null || value.toString().trim().isEmpty) {
                      return "Document Description is required";
                    }
                    return null;
                  },
                ),
              ]),
              _card("Assign To", [
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedEmployeeNotifier,
                  builder: (context, selectedEmployee, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomMultipleSelectPopup(
                          title: 'Assign Employee',
                          isRequired: true,
                          hintText: "Select Employee",
                          isMultiSelect: true,
                          initialValue: selectedEmployee,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedEmployeeNotifier.value = value;
                          },
                          dataFetchCallBack: _inwardOutwardCubit.fetchEmployees,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Assign Employee is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),
              ]),
              if (_routeAuthorizationModel.isAction) ...[
                _card("Delivery Details", [
                  ValueListenableBuilder(
                    valueListenable: _selectedDeliveryMode,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: "Delivery Mode",
                        hintText: "Select Delivery Mode",
                        initialValue: value,
                        dataList: inwardOutwardDeliveryMode,
                        onSelected: (value) {
                          _selectedDeliveryMode.value = value;
                        },
                        onValueClear: () {
                          _selectedDeliveryMode.value = null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedDeliveryStatus,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: "Delivery Status",
                        hintText: "Select Delivery Status",
                        initialValue: value,
                        dataList: inwardOutwardDeliveryStatus,
                        onSelected: (value) {
                          _selectedDeliveryStatus.value = value;
                        },
                        onValueClear: () {
                          _selectedDeliveryStatus.value = null;
                        },
                      );
                    },
                  ),
                ]),
                _card("Acknowledgement", [
                  CustomTextField(
                    title: 'Acknowledged By',
                    textController: _receivedByC,
                    hint: "Enter Acknowledged By",
                    inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  ),
                  CustomSignatureWidget(
                    title: "Acknowledger's Signature",
                    initialFileList:
                        selectedAcknowlegementSignatureFile.fileNameList,
                    onSignatureSaved: (bytes, fileName) {
                      selectedAcknowlegementSignatureFile.fileBytesList = [
                        bytes,
                      ];
                      selectedAcknowlegementSignatureFile.fileNameList = [
                        fileName,
                      ];
                    },
                    onSignatureDelete: (bytes, fileName, deletedUrl) {
                      selectedAcknowlegementSignatureFile.deletedFileList =
                          deletedUrl;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Attachment",
                    filePickType: FilePickType.both,
                    initialFileList: selectedAcknowledgementFile.fileNameList,

                    onFilePickedCallback: (bytesList, fileNameList) {
                      selectedAcknowledgementFile.fileNameList = fileNameList;
                      selectedAcknowledgementFile.fileBytesList = bytesList;
                    },

                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deletedFile,
                    ) {
                      selectedAcknowledgementFile.fileNameList = fileNameList;
                      selectedAcknowledgementFile.fileBytesList = fileBytesList;
                      selectedAcknowledgementFile.deletedFileList = deletedFile;
                    },
                  ),
                  CustomTextField(
                    title: 'Handover To',
                    textController: _handoverToC,
                    inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                    hint: "Enter Name",
                  ),
                  CustomDatePicker(
                    title: "Handover Date",
                    initialDate: _handoverDate,
                    setValue: (value) {
                      _handoverDate = value;
                    },
                  ),
                  CustomTextField(
                    title: 'Remark',
                    textController: _remarkC,
                    inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                    hint: "Enter Remark",
                    maxLines: 3,
                    minLines: 3,
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }

  // HELPER
  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
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
}
