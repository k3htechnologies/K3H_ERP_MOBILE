import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_setup/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/company_setup/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/model/notice_section.model.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/repository/notice_section.repository.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/model/tax_tracker.model.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTaxTrackerScreen extends StatefulWidget {
  final TaxTrackerModel? taxTrackerModel;
  final int index;
  const AddTaxTrackerScreen({super.key, this.taxTrackerModel, this.index = 0});

  @override
  State<AddTaxTrackerScreen> createState() => _AddTaxTrackerScreenState();
}

class _AddTaxTrackerScreenState extends State<AddTaxTrackerScreen> {
  // CUBIT
  late TaxTrackerCubit _taxTrackerCubit;
  late EmployeeMasterCubit _employeeMasterCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final NoticeSectionMasterRepository _noticeSectionMasterRepository =
      serviceLocator<NoticeSectionMasterRepository>();

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameC,
      _financialYearC,
      _responsiblePersonC,
      _authorityC,
      _noticeTitleC,
      _noticeDescriptionC,
      _officerNameC,
      _divisionalAddressC;

  MultiFilePickerModel selectedNoticeDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedCompany = [];
  List<Map<String, dynamic>> _selectedResponsiblePerson = [];
  List<Map<String, dynamic>> _selectedNoticeUS = [];

  final ValueNotifier<Map<String, dynamic>?> _selectedAuthorityType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedGovernmentCompliance =
      ValueNotifier(null);

  DateTime? _noticeDate;
  DateTime? _dueDate;

  // EDIT MODE
  bool get _isEditMode => widget.taxTrackerModel != null;

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = BlocProvider.of<EmployeeMasterCubit>(context);
    _taxTrackerCubit = context.read<TaxTrackerCubit>();
    initializeControllers();
    if (_isEditMode) {
      _prefillTaxTracker(widget.taxTrackerModel!);
    }
  }

  void initializeControllers() {
    _companyNameC = TextEditingController();
    _financialYearC = TextEditingController();
    _responsiblePersonC = TextEditingController();
    _authorityC = TextEditingController();
    _noticeTitleC = TextEditingController();
    _noticeDescriptionC = TextEditingController();
    _officerNameC = TextEditingController();
    _divisionalAddressC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _companyNameC.dispose();
    _financialYearC.dispose();
    _responsiblePersonC.dispose();
    _authorityC.dispose();
    _noticeTitleC.dispose();
    _noticeDescriptionC.dispose();
    _selectedAuthorityType.dispose();
    _officerNameC.dispose();
    _divisionalAddressC.dispose();
    _selectedGovernmentCompliance.dispose();
  }

  // FETCH COMPANIES
  Future<Map<String, dynamic>> _fetchCompany(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getCompanies(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final companyList = _employeeMasterCubit.state.companyNameList;
      final totalCount = _employeeMasterCubit.state.companyNameTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final comp in companyList) {
        uniqueFiltered[comp.companyId] = {
          "zAttributesId": comp.companyId,
          "DisplayName": comp.companyName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.companyNameTotalCount;
    final currentLoadedCount =
        _employeeMasterCubit.state.companyNameList.length;

    // LOAD NEXT PAGE
    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getCompanies(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.companyNameList;

    final Map<int, Map<String, dynamic>> uniqueCompanies = {};

    for (final comp in updatedList) {
      uniqueCompanies[comp.companyId] = {
        "zAttributesId": comp.companyId,
        "DisplayName": comp.companyName,
      };
    }

    return {
      "itemList": uniqueCompanies.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueCompanies.length,
    };
  }

  // FETCH EMPLOYEES
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "IsCheckPermission": false}
              : {"IsCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                  "department": employee.department,
                  "designation": employee.designation,
                  "branch": employee.branch,
                  "reportingPerson": employee.reportPersonName,
                  "email": employee.emailId,
                  "personalNumber": employee.personalMobileNumber,
                  "joiningDate": employee.joiningDate,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH NOTICE U/S
  Future<Map<String, dynamic>> _fetchNotice(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _noticeSectionMasterRepository.pullNoticeSection(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {
                "NoticeSection": value,
                "IsCheckPermission": false,
                "GovernmentCompliance": "Income Tax",
              }
              : {
                "IsCheckPermission": false,
                "GovernmentCompliance": "Income Tax",
              },
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final notice = response['data'] as List<NoticeSectionModel>;

        return {
          "itemList":
              notice.map((notice) {
                return {
                  "zAttributesId": notice.noticeSectionMasterId,
                  "DisplayName": notice.noticeSection,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _verifyAndSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final int? noticeSectionMasterId =
        _selectedNoticeUS.isNotEmpty
            ? int.tryParse(_selectedNoticeUS.first['zAttributesId'].toString())
            : null;
    if (_isEditMode) {
      _taxTrackerCubit.updateTaxTracker(
        context: context,
        index: widget.index,
        taxTrackerId: widget.taxTrackerModel!.taxTrackerId,
        uniquekey: widget.taxTrackerModel!.uniquekey,
        governmentCompliance:
            _selectedGovernmentCompliance.value!["DisplayName"],
        companyId: int.parse(_selectedCompany[0]["zAttributesId"].toString()),
        financialYear: _financialYearC.text.trim(),
        responsiblePersonId: int.parse(
          _selectedResponsiblePerson[0]["zAttributesId"].toString(),
        ),
        noticeType: _selectedNoticeUS[0]["DisplayName"],
        noticeSectionMasterId: noticeSectionMasterId!,
        authority: _selectedAuthorityType.value?["DisplayName"],
        noticeDate: _noticeDate,
        dueDate: _dueDate,
        officerName: _officerNameC.text.trim(),
        officerAddress: _divisionalAddressC.text.trim(),
        noticeDescription: _noticeDescriptionC.text.trim(),
        requestType: "Notice",
        noticeStatus: "Reply Pending",
        noticeDocument: selectedNoticeDocumentFile,
      );
    } else {
      _taxTrackerCubit.addTaxTracker(
        context: context,
        governmentCompliance:
            _selectedGovernmentCompliance.value!["DisplayName"],
        companyId: int.parse(_selectedCompany[0]["zAttributesId"].toString()),
        financialYear: _financialYearC.text.trim(),
        responsiblePersonId: int.parse(
          _selectedResponsiblePerson[0]["zAttributesId"].toString(),
        ),
        noticeType: _selectedNoticeUS[0]["DisplayName"],
        noticeSectionMasterId: noticeSectionMasterId!,
        authority: _selectedAuthorityType.value?["DisplayName"],
        noticeDate: _noticeDate,
        dueDate: _dueDate,
        officerName: _officerNameC.text.trim(),
        officerAddress: _divisionalAddressC.text.trim(),
        noticeDescription: _noticeDescriptionC.text.trim(),
        requestType: "Notice",
        noticeStatus: "Reply Pending",
        noticeDocument: selectedNoticeDocumentFile,
      );
    }
  }

  void _prefillTaxTracker(TaxTrackerModel taxTracker) {
    _selectedGovernmentCompliance.value = taxTrackerGovernmentComplianceList
        .firstWhere(
          (item) => item["DisplayName"] == taxTracker.governmentCompliance,
          orElse: () => taxTrackerGovernmentComplianceList.first,
        );
    _selectedCompany = [
      {
        "zAttributesId": taxTracker.companyId,
        "DisplayName": taxTracker.companyName,
      },
    ];
    _financialYearC.text = taxTracker.financialYear;
    _selectedResponsiblePerson = [
      {
        "zAttributesId": taxTracker.responsiblePersonId,
        "DisplayName": taxTracker.responsiblePerson,
      },
    ];
    _noticeTitleC.text = taxTracker.noticeSection;
    _selectedNoticeUS = [
      {
        "zAttributesId": taxTracker.noticeSectionMasterId,
        "DisplayName": taxTracker.noticeSection,
      },
    ];
    _noticeDate = taxTracker.noticeDate;
    _dueDate = taxTracker.dueDate;
    _selectedAuthorityType.value = taxTrackerAuthorityType.firstWhere(
      (item) => item["DisplayName"] == taxTracker.authority,
      orElse: () => taxTrackerAuthorityType.first,
    );
    _officerNameC.text =
        taxTracker.taxTrackerDocumentDetailsData.first.officerName;
    _divisionalAddressC.text =
        taxTracker.taxTrackerDocumentDetailsData.first.officerAddress;

    selectedNoticeDocumentFile.fileNameList =
        taxTracker.taxTrackerDocumentDetailsData.first.noticeDocumentUrl.isEmpty
            ? []
            : taxTracker.taxTrackerDocumentDetailsData.first.noticeDocumentUrl
                .split(",");
    _noticeDescriptionC.text =
        taxTracker.taxTrackerDocumentDetailsData.first.noticeDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tax Tracker",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Tax Tracker" : "Add Tax Tracker",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _selectedGovernmentCompliance,
                      builder: (context, selectedGovernmentCompliance, child) {
                        return CustomDropDownWidget(
                          title: "Government Compliance",
                          hintText: "Select Government Compliance",
                          isRequired: true,
                          dataList: taxTrackerGovernmentComplianceList,
                          initialValue: selectedGovernmentCompliance,
                          onSelected: (value) {
                            _selectedGovernmentCompliance.value = value;
                          },
                          onValueClear: () {
                            _selectedGovernmentCompliance.value = null;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Government Compliance is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Company Name",
                      isMultiSelect: false,
                      isRequired: true,
                      hintText: "All Companies",
                      initialValue: _selectedCompany,
                      dataFetchCallBack: _fetchCompany,
                      dataList: [],
                      onSelected: (value) {
                        _selectedCompany = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Government Compliance is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Financial Year",
                      hint: "Enter Financial Year",
                      textController: _financialYearC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Financial Year is required.';
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Responsible Person",
                      isMultiSelect: true,
                      isRequired: true,
                      hintText: "All Responsible Person",
                      initialValue: _selectedResponsiblePerson,
                      dataFetchCallBack: _fetchEmployees,
                      dataList: [],
                      onSelected: (value) {
                        _selectedResponsiblePerson = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Responsible Person is required.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notice Information",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      isRequired: true,
                      title: "Notice Title",
                      hint: "Enter Notice Title",
                      textController: _noticeTitleC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice Title is required.';
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Notice U/S",
                      isMultiSelect: false,
                      isRequired: true,
                      hintText: "All Notice U/S",
                      initialValue: _selectedNoticeUS,
                      dataFetchCallBack: _fetchNotice,
                      dataList: [],
                      onSelected: (value) {
                        _selectedNoticeUS = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice U/S is required.';
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Notice Date",
                      hint: "Select Due Date",
                      isRequired: true,
                      initialDate: _noticeDate,
                      setValue: (value) => _noticeDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Notice Date is required.';
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Reply Due Date",
                      hint: "Select Reply Due Date",
                      isRequired: true,
                      initialDate: _dueDate,
                      setValue: (value) => _dueDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Reply Due Date is required.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Authorities Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _selectedAuthorityType,
                      builder: (context, selectedAuthorityType, child) {
                        return CustomDropDownWidget(
                          title: "Authority Type",
                          hintText: "Select Authority Type",
                          isRequired: true,
                          dataList: taxTrackerAuthorityType,
                          initialValue: selectedAuthorityType,
                          onSelected: (value) {
                            _selectedAuthorityType.value = value;
                          },
                          onValueClear: () {
                            _selectedAuthorityType.value = null;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Authority Type is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Officer Name",
                      hint: "Enter Officer Name",
                      textController: _officerNameC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Officer Name is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Divisional Address",
                      hint: "Enter Divisional Address",
                      minLines: 3,
                      maxLines: 10,
                      textController: _divisionalAddressC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Divisional Address is required.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Document Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    CustomMultiFilePicker(
                      title: "Notice Documents",
                      isRequired: true,
                      filePickType: FilePickType.both,
                      initialFileList: selectedNoticeDocumentFile.fileNameList,

                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedNoticeDocumentFile.fileNameList = fileNameList;
                        selectedNoticeDocumentFile.fileBytesList = bytesList;
                      },

                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedNoticeDocumentFile.fileNameList = fileNameList;
                        selectedNoticeDocumentFile.fileBytesList =
                            fileBytesList;
                        selectedNoticeDocumentFile.deletedFileList =
                            deletedFile;
                      },

                      validator: (fileList) {
                        if ((fileList == null || fileList.isEmpty)) {
                          return "Notice Document is required.";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Notice Description",
                      hint: "Enter Notice Description",
                      minLines: 3,
                      maxLines: 10,
                      textController: _noticeDescriptionC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice Description is required.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Save", onPressed: _verifyAndSubmit),
        ),
      ),
    );
  }
}
