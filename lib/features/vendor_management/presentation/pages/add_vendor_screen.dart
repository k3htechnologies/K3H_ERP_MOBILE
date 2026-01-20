// ignore_for_file: deprecated_member_use

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor_add/vendor_add_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddVendorScreen extends StatefulWidget {
  final VendorModel? vendor;
  final int? index;
  const AddVendorScreen({super.key, required this.vendor, this.index});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  // CUBIT
  late VendorAddCubit _vendorAddCubit;

  // FORM KEYS (one per section)
  final _formKeys = [
    GlobalKey<FormState>(), // BASIC DETAILS
    GlobalKey<FormState>(), // GOVERNMENT IDENTIFIERS
    GlobalKey<FormState>(), // ADDRESS
  ];

  // TEXT EDITING CONTROLLERS
  late TextEditingController nameC,
      companyNameC,
      mobileC,
      emailC,
      aadhaarC,
      panC,
      gstC,
      addressC,
      searchC;

  // COMPANY TYPE DROPDOWN
  List<Map<String, dynamic>> companyTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "LLP"},
    {"zAttributesId": 2, "DisplayName": "Private Limited Company"},
    {"zAttributesId": 3, "DisplayName": "Proprietorship"},
  ];

  // DROPDOWN VARIABLES
  late Map<String, dynamic> selectedCompanyType;

  // STRINGS TO STORE THE PICKED FILE PATH
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

  // LOCATION MASTER IDS
  String countryMasterId = '1';
  String stateMasterId = '';
  String districtMasterId = '';
  String cityMasterId = '';

  // TAB CHANGE VARIABLE
  int selectedTab = 0;

  // MATERIAL LIST
  List<Map<String, dynamic>> materialList = [];
  // THIS LIST IS JUST MADE TO SELECT THE SUB MATERIALS

  List<SubMaterialModel> subMaterialListForSelection = [];
  ValueNotifier<List<SubMaterialModel>> subMaterialListForSelectionWithSearch =
      ValueNotifier([]);

  Map<int, List<SubMaterialModel>> materialMap = {};

  @override
  void initState() {
    super.initState();
    _vendorAddCubit = context.read<VendorAddCubit>();
    initializeTextEditingControllers();
    initializeDropdown();
    getMaterialList();
    if (widget.vendor != null) {
      prefillVendorDetails(widget.vendor!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    disposeControllers();
    subMaterialListForSelectionWithSearch.dispose();
  }

  // --------------------------- DISPOSE CONTROLLERS --------------------------- //
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
  }

  // --------------------------- INITIALIZATION METHODS --------------------------- //
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
  }

  // INITIALIZE DROPDOWN VARIABLES
  void initializeDropdown() {
    selectedCompanyType = companyTypeList[0];
  }

  // --------------------------- FETCHING METHODS --------------------------- //
  Future<void> getMaterialList() async {
    var response = await _vendorAddCubit.getMaterialSubMaterialUOMMaster(
      context,
    );
    materialMap = await compute(
      (s) =>
          groupBy(s as List<SubMaterialModel>, (obj) => obj.materialMasterId),
      response["MaterialMasterSubMaterialMasterData"],
    );
    materialList = [
      {'zAttributesId': -1, 'DisplayName': 'Select Material'},
      ...materialMap.keys.map(
        (e) => {
          'zAttributesId': materialMap[e]!.first.materialMasterId,
          'DisplayName': materialMap[e]!.first.materialName,
        },
      ),
    ];
  }

  // --------------------------- PREFILL METHODS --------------------------- //
  Future prefillVendorDetails(VendorModel vendor) async {
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

    selectedCompanyType = companyTypeList.firstWhere(
      (element) => element['DisplayName'] == vendor.companyType,
      orElse: () => companyTypeList.first,
    );

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

    subMaterialListForSelection = vendor.submaterialList;
    subMaterialListForSelectionWithSearch.value = List.from(
      vendor.submaterialList,
    );
  }

  // --------------------------- SHOW DIALOG METHODS --------------------------- //
  Future showDialogToAddMaterialSubMaterialForVendor() async {
    final initialValue =
        subMaterialListForSelection.map((subMaterial) {
          return {
            'zAttributesId': subMaterial.subMaterialMasterId,
            'DisplayName': subMaterial.subMaterialName,
            'materialMasterId': subMaterial.materialMasterId,
            'materialName': subMaterial.materialName,
          };
        }).toList();

    final selectedItems = await CustomMultipleSelectPopup.showBottomSheet(
      context: context,
      title: "Add Materials and Sub-Materials",
      dataList: null, // Don't pass dataList, fetch from API instead
      initialValue: initialValue,
      isMultiSelect: true,
      dataFetchCallBack: (pageNumber, {String? value}) async {
        final response = await _vendorAddCubit.getMaterialSubMaterialUOMMaster(
          context,
        );

        if (!response["isSuccess"]) {
          return {
            'itemList': <Map<String, dynamic>>[],
            'totalNumberOfRecord': 0,
          };
        }

        final allSubMaterials =
            response["MaterialMasterSubMaterialMasterData"]
                as List<SubMaterialModel>;

        List<Map<String, dynamic>> dataList =
            allSubMaterials.map((subMaterial) {
              return {
                'zAttributesId': subMaterial.subMaterialMasterId,
                'DisplayName':
                    '${subMaterial.materialName} - ${subMaterial.subMaterialName}',
                'materialMasterId': subMaterial.materialMasterId,
                'materialName': subMaterial.materialName,
              };
            }).toList();

        // APPLY FILTER IF PROVIDED
        if (value != null && value.isNotEmpty) {
          dataList =
              dataList.where((item) {
                final displayName =
                    (item['DisplayName'] ?? '').toString().toLowerCase();
                return displayName.contains(value.toLowerCase());
              }).toList();
        }

        return {'itemList': dataList, 'totalNumberOfRecord': dataList.length};
      },
    );

    if (selectedItems != null) {
      final response = await _vendorAddCubit.getMaterialSubMaterialUOMMaster(
        // ignore: use_build_context_synchronously
        context,
      );

      if (response["isSuccess"]) {
        final allSubMaterials =
            response["MaterialMasterSubMaterialMasterData"]
                as List<SubMaterialModel>;

        // Convert selected items back to SubMaterialModel format
        final selectedSubMaterials = <SubMaterialModel>[];
        for (var selectedItem in selectedItems) {
          final materialId = selectedItem['materialMasterId'] as int;
          final subMaterialId = selectedItem['zAttributesId'] as int;

          // Find the SubMaterialModel from the API response
          final subMaterial = allSubMaterials.firstWhere(
            (s) =>
                s.subMaterialMasterId == subMaterialId &&
                s.materialMasterId == materialId,
            orElse: () {
              final sameMaterialSubMaterial = allSubMaterials.firstWhere(
                (s) => s.materialMasterId == materialId,
                orElse:
                    () => SubMaterialModel(
                      materialMasterId: materialId,
                      materialName: selectedItem['materialName'] ?? '',
                      subMaterialMasterId: subMaterialId,
                      subMaterialName: selectedItem['DisplayName'] ?? '',
                      materialMasterIdIdRef: materialId,
                      uomMasterId: 0,
                      uomCode: '',
                      uom: '',
                    ),
              );
              return SubMaterialModel(
                materialMasterId: materialId,
                materialName: selectedItem['materialName'] ?? '',
                subMaterialMasterId: subMaterialId,
                subMaterialName: selectedItem['DisplayName'] ?? '',
                materialMasterIdIdRef: materialId,
                uomMasterId: sameMaterialSubMaterial.uomMasterId,
                uomCode: sameMaterialSubMaterial.uomCode,
                uom: sameMaterialSubMaterial.uom,
              );
            },
          );
          selectedSubMaterials.add(subMaterial);
        }

        // UPDATE SELECTED LIST
        setState(() {
          subMaterialListForSelection = selectedSubMaterials;
          _searchMaterial();
        });
      }
    }
  }

  void _searchMaterial() {
    if (searchC.text.trim().isEmpty) {
      subMaterialListForSelectionWithSearch.value = List.from(
        subMaterialListForSelection,
      );
    } else {
      subMaterialListForSelectionWithSearch.value =
          subMaterialListForSelection
              .where(
                (element) => element.materialName.toLowerCase().contains(
                  searchC.text.trim().toLowerCase(),
                ),
              )
              .toList();
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildBasicDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildGovernmentIdentifiersSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildAddressSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            ..._buildMaterialAndContractSectionSlivers(),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: SizedBox(height: 50)), // padding bottom
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: widget.vendor == null ? 'Add Vendor' : 'Update Vendor',
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  // BUILD SECTION CONTAINER
  Widget _buildSectionContainer(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  // BUILD SECTION HEADER
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTextStyle.ts16R(color: AppColor.black)),
    );
  }

  // BUILD BASIC DETAILS SECTION
  Widget _buildBasicDetailsSection() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Details'),
          CustomTextField(
            inputFormatterList: InputValidator.textOnly(50),
            textController: nameC,
            title: "Vendor Name",
            isRequired: true,
            hint: "Enter Vendor Name",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Vendor Name is required";
              }
              return null;
            },
          ),
          CustomDropDownWidget(
            title: "Company Type",
            initialValue: selectedCompanyType,
            isRequired: true,
            dataList: companyTypeList,
            onSelected: (value) {
              selectedCompanyType = value;
            },
            validator: (value) {
              if (value == null || value['zAttributesId'] == -1) {
                return 'Company Type is required';
              }
              return null;
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
                return "Company Name is required";
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Mobile Number',
            hint: "Enter Mobile Number",
            isRequired: true,
            textController: mobileC,
            inputFormatterList: InputValidator.digit(10),
            prefixWidget: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  const Text("+91"),
                  VerticalDivider(
                    color: AppColor.black,
                    thickness: 0.5,
                    width: 15,
                    indent: 5,
                    endIndent: 5,
                  ),
                ],
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Mobile Number is required";
              }
              if (value.length != 10) {
                return "Mobile Number is invalid";
              }
              return null;
            },
          ),
          CustomTextField(
            textController: emailC,
            title: "E-mail ID",
            hint: "Enter E-mail ID",
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Email Id is required";
              }
              if (!InputValidator.isValidEmail(value)) {
                return "Invalid email address";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // BUILD GOVERNMENT IDENTIFIERS SECTION
  Widget _buildGovernmentIdentifiersSection() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Government Identifiers'),
          CustomTextField(
            inputFormatterList: InputValidator.aadharNumberInputFormatter(),
            textController: aadhaarC,
            title: "Aadhaar Card Number",
            hint: "Enter Aadhaar Card Number",
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Aadhaar Card number is required";
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
            title: "Upload Aadhaar Card",
            isRequired: true,
            onFilePickedCallback: (bytesList, fileList) {
              aadhaarCard.fileBytesList = bytesList;
              aadhaarCard.fileNameList = fileList;
            },
            validator: (file) {
              if (file == null || file.isEmpty) {
                return "Aadhaar Card required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNamelist, deletedFiles) {
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
                return "PAN Number is required";
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
            title: "Upload PAN Card",
            isRequired: true,
            onFilePickedCallback: (bytesList, filesList) {
              panCard.fileBytesList = bytesList;
              panCard.fileNameList = filesList;
            },
            validator: (file) {
              if (file == null || file.isEmpty) {
                return "Pan Card required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFiles) {
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
                return 'GST number is required';
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
            title: "Upload GST Certificate",
            isRequired: true,
            onFilePickedCallback: (fileByteList, fileNameList) {
              gstCertificate.fileBytesList = fileByteList;
              gstCertificate.fileNameList = fileNameList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedUrl) {
              gstCertificate.fileBytesList = fileBytesList;
              gstCertificate.fileNameList = fileNameList;
              gstCertificate.deletedFileList = deletedUrl;
            },
            validator: (file) {
              if (file == null || file.isEmpty) {
                return "GST Certificate required";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // BUILD ADDRESS SECTION
  Widget _buildAddressSection() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Address Details'),
          CustomTextField(
            textController: addressC,
            title: "Address",
            hint: "Enter Full Address",
            isRequired: true,
            inputFormatterList: [LengthLimitingTextInputFormatter(500)],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Address is required";
              }
              return null;
            },
          ),
          AddressWidget(
            formKey: _formKeys[2],
            incomingStateId: widget.vendor?.stateMasterId,
            incomingDistrictId: widget.vendor?.districtMasterId,
            incomingCityId: widget.vendor?.cityMasterId,
            stateChange: (selectedState) {
              stateMasterId = selectedState['zAttributesId'].toString();
            },
            districtChange: (selectedDistrict) {
              districtMasterId = selectedDistrict['zAttributesId'].toString();
            },
            cityChange: (selectedCity) {
              cityMasterId = selectedCity['zAttributesId'].toString();
            },
          ),
        ],
      ),
    );
  }

  // BUILD MATERIAL AND CONTRACT SECTION SLIVERS
  List<Widget> _buildMaterialAndContractSectionSlivers() {
    return [
      SliverToBoxAdapter(
        child: _buildSectionContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionHeader('Material And Contract Management'),
              verticalSpacing(),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Select:", style: AppTextStyle.ts14M()),
                    ),

                    // MATERIAL
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Row(
                          children: [
                            Radio<int>(
                              value: 0,
                              groupValue: selectedTab,
                              onChanged: (value) {
                                setState(() {
                                  selectedTab = value!;
                                });
                              },
                              activeColor: AppColor.info,
                              visualDensity: VisualDensity.compact,
                            ),
                            Text("Material", style: AppTextStyle.ts14M()),
                          ],
                        ),
                      ),
                    ),

                    // CONTRACT
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: selectedTab,
                              onChanged: (value) {
                                setState(() {
                                  selectedTab = value!;
                                });
                              },
                              activeColor: AppColor.info,
                              visualDensity: VisualDensity.compact,
                            ),
                            Text("Contract", style: AppTextStyle.ts14M()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 4,
                    child: CustomTextField(
                      hint: "Search Material",
                      textController: searchC,
                      onChangeFunction: (value) {
                        _searchMaterial();
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () async {
                        await showDialogToAddMaterialSubMaterialForVendor();
                      },
                      child: SizedBox(
                        height: 40,
                        child: Text(
                          'Select Material',
                          style: AppTextStyle.ts14M(color: AppColor.info),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ValueListenableBuilder<List<SubMaterialModel>>(
        valueListenable: subMaterialListForSelectionWithSearch,
        builder: (context, value, child) {
          if (value.isEmpty) {
            return SliverToBoxAdapter(child: SizedBox());
          }

          // Use for-loop grouping logic as provided
          final materialWidgets = <Widget>[];
          int index = 0;
          while (index < value.length) {
            final currentItem = value[index];

            // Build children by grouping items with the same materialMasterId
            final itemWidgets = <Widget>[];
            do {
              itemWidgets.add(
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        horizontalSpacing(width: 5),
                        SvgPicture.asset(
                          AppAssets.subMaterialSubSubmodule,
                          height: 18,
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: Text(
                            value[index].subMaterialName,
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              // If the next item exists and belongs to the same group, process it.
              if ((index + 1) < value.length &&
                  value[index].materialMasterId ==
                      value[index + 1].materialMasterId) {
                index++;
              } else {
                break;
              }
            } while (true);

            materialWidgets.add(
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColor.lightBlue,
                    ),
                    child: ExpansionTile(
                      minTileHeight: 50,
                      tilePadding: const EdgeInsets.only(left: 8, right: 10),
                      childrenPadding: EdgeInsets.zero,
                      title: SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            horizontalSpacing(width: 5),
                            SvgPicture.asset(
                              AppAssets.materialSubSubmodule,
                              height: 18,
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: Text(
                                currentItem.materialName,
                                style: AppTextStyle.ts16R(color: AppColor.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: itemWidgets,
                    ),
                  ),
                ),
              ),
            );

            index++; // Move to next group
          }

          return SliverList(delegate: SliverChildListDelegate(materialWidgets));
        },
      ),
    ];
  }

  // --------------------------- SUBMIT HANDLER --------------------------- //

  void _handleSubmit() {
    final isBasicValid = _formKeys[0].currentState?.validate() ?? false;
    final isGovValid = _formKeys[1].currentState?.validate() ?? false;
    final isAddressValid = _formKeys[2].currentState?.validate() ?? false;

    if (!isBasicValid || !isGovValid || !isAddressValid) {
      return;
    }

    if (subMaterialListForSelection.isEmpty) {
      showErrorMessage(context, 'Selection Error', "Please select a material");
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
      _vendorAddCubit.addVendor(
        context: context,
        companyName: companyNameC.value.text,
        companyType: selectedCompanyType["DisplayName"],
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
      );
    } else {
      _vendorAddCubit.updateVendor(
        index: widget.index ?? 0,
        vendor: widget.vendor,
        context: context,
        companyName: companyNameC.value.text,
        companyType: selectedCompanyType["DisplayName"],
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
      );
    }
  }
}
