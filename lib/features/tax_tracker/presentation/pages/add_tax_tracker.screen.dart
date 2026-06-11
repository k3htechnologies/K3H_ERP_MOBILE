import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTaxTrackerScreen extends StatefulWidget {
  const AddTaxTrackerScreen({super.key});

  @override
  State<AddTaxTrackerScreen> createState() => _AddTaxTrackerScreenState();
}

class _AddTaxTrackerScreenState extends State<AddTaxTrackerScreen> {
  late EmployeeMasterCubit _employeeMasterCubit;
  late TextEditingController _companyNameC,
      _financialYearC,
      _responsiblePersonC,
      _authorityC;

  List<Map<String, dynamic>> _selectedDepartment = [];
  DateTime? _noticeDate;
  DateTime? _dueDate;

  MultiFilePickerModel selectedNoticeDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedReplyDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = BlocProvider.of<EmployeeMasterCubit>(context);
    initializeControllers();
  }

  void initializeControllers() {
    _companyNameC = TextEditingController();
    _financialYearC = TextEditingController();
    _responsiblePersonC = TextEditingController();
    _authorityC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _companyNameC.dispose();
    _financialYearC.dispose();
    _responsiblePersonC.dispose();
    _authorityC.dispose();
  }

  // FETCH DEPARTMENTS
  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getDepartmentList(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final departmentList = _employeeMasterCubit.state.departmentList;

      final totalCount = _employeeMasterCubit.state.departmentTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final dept in departmentList) {
        uniqueFiltered[dept.departmentMasterId] = {
          "zAttributesId": dept.departmentMasterId,
          "DisplayName": dept.departmentName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.departmentTotalCount;

    final currentLoadedCount = _employeeMasterCubit.state.departmentList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getDepartmentList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final updatedList = _employeeMasterCubit.state.departmentList;

    final Map<int, Map<String, dynamic>> uniqueDepartments = {};

    for (final dept in updatedList) {
      uniqueDepartments[dept.departmentMasterId] = {
        "zAttributesId": dept.departmentMasterId,
        "DisplayName": dept.departmentName,
      };
    }

    return {
      "itemList": uniqueDepartments.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDepartments.length,
    };
  }

  void _verifyAndSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Add Income Tax",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(height: 12.0),
                    CustomTextField(
                      isRequired: true,
                      title: "Company Name",
                      hint: "Enter Company Name",
                      textController: _companyNameC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Company Name is required';
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
                          return 'Financial Year is required';
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Department",
                      isRequired: true,
                      isMultiSelect: false,
                      dataList: [],
                      onSelected: (value) {
                        _selectedDepartment = value;
                      },
                      dataFetchCallBack: _fetchDepartment,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Department is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Responsible Person",
                      hint: "Enter Responsible Person",
                      textController: _responsiblePersonC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Responsible Person is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notice Information",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(height: 12.0),
                    CustomDropDownWidget(
                      title: "Notice Type",
                      hintText: "Select Notice Type",
                      isRequired: true,
                      dataList: [],
                      onSelected: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice Type is required';
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Notice U/S",
                      hintText: "Select Notice U/S",
                      isRequired: true,
                      dataList: [],
                      onSelected: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice U/S is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Authority",
                      hint: "Enter Authority",
                      textController: _authorityC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Authority is required';
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
                          return 'Authority is required';
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Due Date",
                      hint: "Select Due Date",
                      isRequired: true,
                      initialDate: _dueDate,
                      setValue: (value) => _dueDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Due Date is required';
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Notice Status",
                      hintText: "Select Notice Status",
                      isRequired: true,
                      dataList: [],
                      onSelected: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Notice Status is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Document Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(height: 12.0),
                    CustomMultiFilePicker(
                      title: "Notice Document",
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
                          return "Notice Document is required";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Notice Document",
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
                          return "Notice Document is required";
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
