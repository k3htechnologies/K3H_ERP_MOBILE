// ignore_for_file: deprecated_member_use
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddVendorScreen extends StatefulWidget {
  final VendorModel? vendor;
  final int? index;
  const AddVendorScreen({super.key, required this.vendor, this.index});
  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen>
    with SingleTickerProviderStateMixin {
  late VendorCubit _vendorCubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC,
      companyNameC,
      mobileC,
      emailC,
      aadhaarC,
      panC,
      gstC,
      addressC,
      searchC,
      contractSearchC;
  final ValueNotifier<Map<String, dynamic>?> selectedVendorType = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> selectedCompanyType =
      ValueNotifier(null);
  MultiFilePickerModel aadhaarCard = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel panCard = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel gstCertificate = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  String countryMasterId = '1';
  String stateMasterId = '';
  String districtMasterId = '';
  String cityMasterId = '';
  late final TabController _tabController;
  List<SubMaterialModel> allSubMaterialList = [];
  final ValueNotifier<List<SubMaterialModel>> filteredMaterialList =
      ValueNotifier([]);
  final ValueNotifier<Set<int>> selectedMaterialIds = ValueNotifier({});
  List<SubMaterialModel> subMaterialListForSelection = [];
  ValueNotifier<CountryCode> selectedMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  final ValueNotifier<bool> _isMobileNumberAlreadyExist = ValueNotifier(false);
  bool get _isEditMode => widget.vendor != null;
  @override
  void initState() {
    super.initState();
    _vendorCubit = context.read<VendorCubit>();
    _tabController = TabController(length: 2, vsync: this);
    initializeTextEditingControllers();
    getMaterialList();
    if (_isEditMode) {
      _populateFormFields(widget.vendor!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    disposeControllers();
    filteredMaterialList.dispose();
    selectedMaterialIds.dispose();
    _tabController.dispose();
  }

  void disposeControllers() {
    nameC.dispose();
    mobileC.dispose();
    emailC.dispose();
    aadhaarC.dispose();
    panC.dispose();
    gstC.dispose();
    addressC.dispose();
    companyNameC.dispose();
    searchC.dispose();
    contractSearchC.dispose();
  }

  void initializeTextEditingControllers() {
    nameC = TextEditingController();
    companyNameC = TextEditingController();
    mobileC = TextEditingController();
    emailC = TextEditingController();
    aadhaarC = TextEditingController();
    panC = TextEditingController();
    gstC = TextEditingController();
    addressC = TextEditingController();
    searchC = TextEditingController();
    contractSearchC = TextEditingController();
  }

  Future<void> getMaterialList() async {
    final response = await _vendorCubit.getMaterialSubMaterialUOMMaster(
      context,
    );
    if (!mounted) return;
    final subMaterials =
        (response["MaterialMasterSubMaterialMasterData"]
            as List<SubMaterialModel>?) ??
        [];
    await compute(
      (s) => groupBy(s, (obj) => obj.materialMasterId),
      subMaterials,
    );
    if (!mounted) return;
    allSubMaterialList = subMaterials;
    filteredMaterialList.value = List.from(allSubMaterialList);
    _vendorCubit.closeLoader();
  }

  Future _populateFormFields(VendorModel vendor) async {
    nameC.text = vendor.vendorName;
    companyNameC.text = vendor.companyName;
    mobileC.text = vendor.mobileNumber;
    emailC.text = vendor.emailId;
    aadhaarC.text = vendor.aadharCardNumber;
    panC.text = vendor.panCardNumber;
    gstC.text = vendor.gstNumber;
    addressC.text = vendor.address;
    countryMasterId = vendor.countryMasterId.toString();
    stateMasterId = vendor.stateMasterId.toString();
    districtMasterId = vendor.districtMasterId.toString();
    cityMasterId = vendor.cityMasterId.toString();
    selectedCompanyType.value = firmTypeList.firstWhere(
      (element) => element['DisplayName'] == vendor.companyType,
      orElse: () => firmTypeList.first,
    );
    selectedVendorType.value = vendorTypeList.firstWhere(
      (element) => element['DisplayName'] == vendor.vendorType,
      orElse: () => vendorTypeList.first,
    );
    if (vendor.mobileNumberCountryCode.isNotEmpty) {
      selectedMobileNoCountry.value = countryList.firstWhere(
        (e) => e.code == vendor.mobileNumberCountryCode,
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
    aadhaarCard.fileNameList =
        vendor.aadharCardUrl == "" ? [] : vendor.aadharCardUrl.split(",");
    aadhaarCard.fileBytesList = List.generate(
      aadhaarCard.fileNameList.length,
      (_) => Uint8List(0),
    );
    panCard.fileNameList =
        vendor.panCardUrl == "" ? [] : vendor.panCardUrl.split(",");
    panCard.fileBytesList = List.generate(
      panCard.fileNameList.length,
      (_) => Uint8List(0),
    );
    gstCertificate.fileNameList =
        vendor.gstCertificateUrl == ""
            ? []
            : vendor.gstCertificateUrl.split(",");
    gstCertificate.fileBytesList = List.generate(
      gstCertificate.fileNameList.length,
      (_) => Uint8List(0),
    );
    subMaterialListForSelection = List.from(vendor.submaterialList);
    selectedMaterialIds.value =
        subMaterialListForSelection.map((e) => e.subMaterialMasterId).toSet();
  }

  void _searchMaterialList() {
    final query = searchC.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredMaterialList.value = List.from(allSubMaterialList);
    } else {
      filteredMaterialList.value =
          allSubMaterialList.where((item) {
            return item.subMaterialName.toLowerCase().contains(query) ||
                item.materialName.toLowerCase().contains(query);
          }).toList();
    }
  }

  void _toggleMaterialSelection(SubMaterialModel item) {
    final ids = Set<int>.from(selectedMaterialIds.value);
    if (ids.contains(item.subMaterialMasterId)) {
      ids.remove(item.subMaterialMasterId);
      subMaterialListForSelection.removeWhere(
        (e) => e.subMaterialMasterId == item.subMaterialMasterId,
      );
    } else {
      ids.add(item.subMaterialMasterId);
      subMaterialListForSelection.add(item);
    }
    selectedMaterialIds.value = ids;
  }

  void _saveForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (subMaterialListForSelection.isEmpty) {
      showErrorMessage(
        context,
        'Error',
        "Please select at least one material.",
      );
      return;
    }
    String selectedSubMaterialCommaSeperatedIds = '';
    for (var item in subMaterialListForSelection) {
      selectedSubMaterialCommaSeperatedIds +=
          "${item.subMaterialMasterId.toString()},";
    }
    selectedSubMaterialCommaSeperatedIds = selectedSubMaterialCommaSeperatedIds
        .substring(0, selectedSubMaterialCommaSeperatedIds.length - 1);
    if (widget.vendor == null) {
      _vendorCubit.addVendor(
        context: context,
        companyName: companyNameC.value.text,
        companyType: selectedCompanyType.value?["DisplayName"],
        vendorName: nameC.value.text,
        mobileNumber: mobileC.value.text,
        emailId: emailC.value.text,
        aadharCardNumber: aadhaarC.value.text,
        panCardNumber: panC.value.text,
        gstNumber: gstC.value.text,
        address: addressC.value.text,
        countryMasterId: countryMasterId,
        stateMasterId: stateMasterId,
        districtMasterId: districtMasterId,
        cityMasterId: cityMasterId,
        subMaterialIds: selectedSubMaterialCommaSeperatedIds,
        contractIds: '',
        aadharCard: aadhaarCard,
        panCard: panCard,
        gstCertificate: gstCertificate,
        vendorType: selectedVendorType.value?['DisplayName'],
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
      );
    } else {
      _vendorCubit.updateVendor(
        index: widget.index ?? 0,
        vendorId: widget.vendor!.vendorId,
        uniquekey: widget.vendor!.uniquekey,
        context: context,
        companyName: companyNameC.value.text,
        companyType: selectedCompanyType.value?["DisplayName"],
        vendorName: nameC.value.text,
        vendorType: selectedVendorType.value?['DisplayName'],
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
        mobileNumber: mobileC.value.text,
        emailId: emailC.value.text,
        aadharCardNumber: aadhaarC.value.text,
        panCardNumber: panC.value.text,
        gstNumber: gstC.value.text,
        address: addressC.value.text,
        countryMasterId: countryMasterId,
        stateMasterId: stateMasterId,
        districtMasterId: districtMasterId,
        cityMasterId: cityMasterId,
        subMaterialIds: selectedSubMaterialCommaSeperatedIds,
        contractIds: '',
        aadharCard: aadhaarCard,
        panCard: panCard,
        gstCertificate: gstCertificate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Vendor Management",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              children: [
                _card("Basic Details", [
                  ValueListenableBuilder(
                    valueListenable: selectedVendorType,
                    builder: (context, selectedVendorT, child) {
                      return CustomDropDownWidget(
                        key: ValueKey(
                          'type_${selectedVendorT?['zAttributesId'] ?? ""}',
                        ),
                        title: "Vendor Type",
                        hintText: "Select Vendor Type",
                        initialValue: selectedVendorT,
                        isRequired: true,
                        dataList: vendorTypeList,
                        onSelected: (value) {
                          selectedVendorType.value = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vendor Type is required.';
                          }
                          return null;
                        },
                        onValueClear: () {
                          selectedVendorType.value = null;
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    inputFormatterList: InputValidator.textOnly(50),
                    textController: nameC,
                    title: "Vendor Name",
                    isRequired: true,
                    hint: "Enter Vendor Name",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vendor Name is required.";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedCompanyType,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: "Company Type",
                        hintText: "Select Company Type",
                        initialValue: selectedCompanyType.value,
                        isRequired: true,
                        dataList: firmTypeList,
                        onSelected: (value) {
                          selectedCompanyType.value = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Company Type is required.';
                          }
                          return null;
                        },
                        onValueClear: () {
                          selectedCompanyType.value = null;
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: "Company Name",
                    hint: "Enter Company Name",
                    inputFormatterList: InputValidator.textDigit(50),
                    isRequired: true,
                    textController: companyNameC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Company Name is required.";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedMobileNoCountry,
                    builder: (context, value, child) {
                      return CustomTextField(
                        title: 'Mobile Number',
                        hint: "Enter Mobile Number",
                        isRequired: true,
                        textController: mobileC,
                        showCountryDropdown: true,
                        readOnly: _isEditMode,
                        keyboardType: TextInputType.number,
                        selectedCountry: value,
                        onCountryChanged: (country) {
                          if (country == null) return;
                          selectedMobileNoCountry.value = country;
                        },
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(value.mobileLength),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          final mobile = value?.trim() ?? "";
                          final country = selectedMobileNoCountry.value;
                          if (value == null || value.isEmpty) {
                            return "Mobile Number is required.";
                          }
                          if (mobile.isNotEmpty) {
                            if ((mobile.length != country.mobileLength) ||
                                country.regex != null &&
                                    !country.regex!.hasMatch(mobile)) {
                              return "Invalid Mobile Number";
                            }
                            if (_isMobileNumberAlreadyExist.value) {
                              return "Mobile number already exists";
                            }
                          }
                          return null;
                        },
                        onChangeFunction: (value) async {
                          final country = selectedMobileNoCountry.value;
                          if (value.isNotEmpty &&
                              country.mobileLength == value.length) {
                            _isMobileNumberAlreadyExist.value =
                                (await _vendorCubit.fetchVendorByMobile(
                                  value,
                                )).isNotEmpty;
                          } else {
                            _isMobileNumberAlreadyExist.value = false;
                          }
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    textController: emailC,
                    title: "E-mail ID",
                    hint: "Enter E-mail ID",
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email Id is required.";
                      }
                      if (!InputValidator.isValidEmail(value)) {
                        return "Invalid email address";
                      }
                      return null;
                    },
                  ),
                ]),
                _card("Government Identifiers", [
                  CustomTextField(
                    inputFormatterList:
                        InputValidator.aadhaarNumberInputFormatter(),
                    textController: aadhaarC,
                    title: "Aadhaar Card Number",
                    hint: "Enter Aadhaar Card Number",
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Aadhaar Card number is required.";
                      }
                      if (!InputValidator.isValidAadharNumber(value)) {
                        return "Invalid Aadhaar Card Number";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    maxFiles: 3,
                    initialFileList: aadhaarCard.fileNameList,
                    filePickType: FilePickType.kycDocument,
                    title: "Aadhaar Card",
                    isRequired: true,
                    onFilePickedCallback: (bytesList, fileList) {
                      aadhaarCard.fileBytesList = bytesList;
                      aadhaarCard.fileNameList = fileList;
                    },
                    validator: (file) {
                      if (file == null || file.isEmpty) {
                        return "Aadhaar Card file required.";
                      }
                      return null;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNamelist,
                      deletedFiles,
                    ) {
                      aadhaarCard.fileBytesList = fileBytesList;
                      aadhaarCard.fileNameList = fileNamelist;
                      aadhaarCard.deletedFileList = deletedFiles;
                    },
                  ),
                  CustomTextField(
                    inputFormatterList: InputValidator.panInputFormatters(),
                    textController: panC,
                    title: "PAN Card Number",
                    hint: "Enter PAN Card Number",
                    isRequired: true,
                    validator: (value) {
                      if ((value == null || value.trim().isEmpty)) {
                        return "PAN Number is required.";
                      }
                      if (value.trim().isNotEmpty &&
                          !InputValidator.isValidPAN(value)) {
                        return "Invalid PAN Number";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    maxFiles: 3,
                    initialFileList: panCard.fileNameList,
                    title: "PAN Card",
                    filePickType: FilePickType.kycDocument,
                    isRequired: true,
                    onFilePickedCallback: (bytesList, filesList) {
                      panCard.fileBytesList = bytesList;
                      panCard.fileNameList = filesList;
                    },
                    validator: (file) {
                      if (file == null || file.isEmpty) {
                        return "Pan Card file required.";
                      }
                      return null;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deletedFiles,
                    ) {
                      panCard.fileBytesList = fileBytesList;
                      panCard.fileNameList = fileNameList;
                      panCard.deletedFileList = deletedFiles;
                    },
                  ),
                  CustomTextField(
                    inputFormatterList: InputValidator.gstInputFormatters(),
                    textController: gstC,
                    title: "GST Number",
                    hint: "Enter GST Number",
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'GST number is required.';
                      }
                      if (!InputValidator.isValidGST(value)) {
                        return 'Enter a valid GST number';
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    maxFiles: 3,
                    initialFileList: gstCertificate.fileNameList,
                    filePickType: FilePickType.kycDocument,
                    title: "GST Certificate",
                    isRequired: true,
                    onFilePickedCallback: (fileByteList, fileNameList) {
                      gstCertificate.fileBytesList = fileByteList;
                      gstCertificate.fileNameList = fileNameList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deletedUrl,
                    ) {
                      gstCertificate.fileBytesList = fileBytesList;
                      gstCertificate.fileNameList = fileNameList;
                      gstCertificate.deletedFileList = deletedUrl;
                    },
                    validator: (file) {
                      if (file == null || file.isEmpty) {
                        return "GST Certificate file required.";
                      }
                      return null;
                    },
                  ),
                ]),
                _card("Address Details", [
                  CustomTextField(
                    textController: addressC,
                    title: "Address",
                    hint: "Enter Address",
                    minLines: 3,
                    maxLines: 3,
                    isRequired: true,
                    inputFormatterList: [LengthLimitingTextInputFormatter(500)],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Address is required.";
                      }
                      if (value.length < 25) {
                        return "Address must be at least 25 characters long.";
                      }
                      return null;
                    },
                  ),
                  AddressWidget(
                    formKey: _formKey,
                    incomingCountryId: widget.vendor?.countryMasterId ?? 1,
                    incomingStateId: widget.vendor?.stateMasterId,
                    incomingDistrictId: widget.vendor?.districtMasterId,
                    incomingCityId: widget.vendor?.cityMasterId,
                    countryChange: (selectedCountry) {
                      countryMasterId =
                          selectedCountry['zAttributesId'].toString();
                    },
                    stateChange: (selectedState) {
                      stateMasterId = selectedState['zAttributesId'].toString();
                    },
                    districtChange: (selectedDistrict) {
                      districtMasterId =
                          selectedDistrict['zAttributesId'].toString();
                    },
                    cityChange: (selectedCity) {
                      cityMasterId = selectedCity['zAttributesId'].toString();
                    },
                  ),
                ]),
                _card('Material and Contract Management', [
                  ChipStyleTabBar(
                    controller: _tabController,
                    tabs: ['Material', 'Contract'],
                    style: ChipTabBarStyle.underline,
                  ),
                  verticalSpacing(),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMaterialTabContent(),
                        _buildContractTabContent(),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              widget.vendor != null ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? 'Update' : 'Add',
            onPressed: _saveForm,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTabContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchWidget(
            textController: searchC,
            hintText: "Search By Material Name",
            onSubmit: (v) {
              _searchMaterialList();
            },
          ),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<VendorCubit, VendorState>(
              builder: (context, state) {
                return ValueListenableBuilder<List<SubMaterialModel>>(
                  valueListenable: filteredMaterialList,
                  builder: (context, list, child) {
                    if (state.isLoading ?? false) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: noDataWidget(
                          message: 'No data found',
                          iconSize: 120,
                        ),
                      );
                    }
                    return ValueListenableBuilder<Set<int>>(
                      valueListenable: selectedMaterialIds,
                      builder: (context, selectedIds, _) {
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: list.length,
                          separatorBuilder:
                              (_, __) => verticalSpacing(height: 8),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final isSelected = selectedIds.contains(
                              item.subMaterialMasterId,
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.subMaterialName,
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black,
                                          ),
                                        ),
                                        Text(
                                          item.materialName,
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        () => _toggleMaterialSelection(item),
                                    icon: Icon(
                                      isSelected
                                          ? Icons.delete_outline
                                          : Icons.add,
                                      size: 18,
                                      color:
                                          isSelected
                                              ? Colors.red
                                              : AppColor.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractTabContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IgnorePointer(
            child: SearchWidget(
              hintText: "Search By Contract Name",
              textController: contractSearchC,
              onSubmit: (value) {},
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Contract management coming soon',
                style: AppTextStyle.ts14R(color: AppColor.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
