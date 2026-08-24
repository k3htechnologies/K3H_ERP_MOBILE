import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddInvoiceScreen extends StatefulWidget {
  final String systemgeneratedCode;
  final GRNModel? grn;
  const AddInvoiceScreen({
    super.key,
    required this.systemgeneratedCode,
    this.grn,
  });

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late InvoiceCubit _invoiceCubit;
  late ProjectModel _selectedProject;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberC, _invoiceAmountC, _remarkC;
  DateTime? _invoiceDate, _dueDate;

  // FILE VARIABLES
  MultiFilePickerModel selectedInvoiceFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPerformanceReportFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedMeasurementReportFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();
    _invoiceCubit = context.read<InvoiceCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _selectedProject = getProject();
    _initializeTextEditingController();
  }

  void initOverview() async {
    final overview =
        _materialRequisitionCubit.state.materialRequisitionOverview;

    if (overview == null) return;

    await _invoiceCubit.getInvoice(
      projectId: overview.projectId,
      materialRequisitionId: overview.materialRequisitionId,
      uniqueKey: overview.uniquekey,
      context: context,
    );
  }

  @override
  void dispose() {
    // CONTROLLERS
    _invoiceNumberC.dispose();
    _invoiceAmountC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _invoiceNumberC = TextEditingController();
    _invoiceAmountC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final materialOverview =
        _materialRequisitionCubit.state.materialRequisitionOverview;

    if (materialOverview == null) {
      showErrorMessage(
        context,
        "Error",
        "Material requisition details not found",
      );
      return;
    }
    _invoiceCubit.addInvoice(
      context: context,
      projectId: _selectedProject.projectId,
      materialRequisitionId: materialOverview.materialRequisitionId,
      uniqueKey: materialOverview.uniquekey,
      invoiceNumber: _invoiceNumberC.text,
      invoiceAmount: _invoiceAmountC.text,
      invoiceDate: _invoiceDate?.toIso8601String() ?? "",
      dueDate: _dueDate?.toIso8601String() ?? "",
      remarks: _remarkC.text,
      materialRequisitionGRNId: widget.grn!.materialRequisitionGrnId,
      uploadInvoicePhoto: selectedInvoiceFile,
      performaInvoicePhoto: selectedPerformanceReportFile,
      measurementReportPhoto: selectedMeasurementReportFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Invoice",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.systemgeneratedCode,
              style: AppTextStyle.ts16M(color: AppColor.primary),
            ),
            verticalSpacing(),
            BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state.isLoading ?? true) {
                  return Center(child: loader());
                }
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightBluebg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.0),
                        blurRadius: 0,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildRow(
                              "Date",
                              formatDateTimeAsDDMMMYYYY(
                                widget.grn!.createdDate,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildRow(
                              "Vehicle No.",
                              widget.grn!.vehicleNumber,
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRow("Challan No.", widget.grn!.challanNumber),
                        ],
                      ),
                      verticalSpacing(height: 16.h),
                      ListView.builder(
                        itemCount:
                            widget
                                .grn
                                ?.materialRequisitionDetailGrnData
                                .length ??
                            0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final material =
                              widget
                                  .grn!
                                  .materialRequisitionDetailGrnData[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightGreyBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                width: 0.1,
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildRow(
                                    "Material",
                                    material.materialName,
                                  ),
                                ),
                                Expanded(
                                  child: _buildRow(
                                    "Sub-Material",
                                    material.subMaterialName,
                                  ),
                                ),
                                Expanded(
                                  child: _buildRow(
                                    "Quantity",
                                    material.materialQuantity.toString(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            verticalSpacing(height: 20.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invoice Details",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                  verticalSpacing(height: 4.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          title: "Invoice No.",
                          hint: "Enter Invoice No.",
                          isRequired: true,
                          textController: _invoiceNumberC,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Invoice No. is required";
                            }
                            return null;
                          },
                        ),
                        CustomDatePicker(
                          isRequired: true,
                          title: "Invoice Date",
                          hint: "Set Invoice Date",
                          setValue: (value) => _invoiceDate = value,
                          validator: (value) {
                            if (value == null) {
                              return 'Invoice Date is required';
                            }

                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Invoice Amount",
                          hint: "Enter Invoice Amount",
                          isRequired: true,
                          textController: _invoiceAmountC,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Invoice Amount is required";
                            }
                            return null;
                          },
                        ),
                        CustomDatePicker(
                          isRequired: true,
                          title: "Due Date",
                          hint: "Set Due Date",
                          setValue: (value) => _dueDate = value,
                          validator: (value) {
                            if (value == null) {
                              return "Due Date is required";
                            }
                            return null;
                          },
                        ),
                        CustomMultiFilePicker(
                          maxFiles: 5,
                          title: "Upload Invoice",
                          isRequired: true,
                          initialFileList: selectedInvoiceFile.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedInvoiceFile.fileNameList = fileNameList;
                            selectedInvoiceFile.fileBytesList = bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedInvoiceFile.fileNameList = fileNameList;
                            selectedInvoiceFile.fileBytesList = fileBytesList;
                            selectedInvoiceFile.deletedFileList = deletedFile;
                          },
                          validator: (fileList) {
                            if ((fileList == null || fileList.isEmpty)) {
                              return "Invoice document is required";
                            }
                            return null;
                          },
                        ),
                        CustomMultiFilePicker(
                          maxFiles: 5,
                          title: "Performance Report",
                          isRequired: false,
                          initialFileList:
                              selectedPerformanceReportFile.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedPerformanceReportFile.fileNameList =
                                fileNameList;
                            selectedPerformanceReportFile.fileBytesList =
                                bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedPerformanceReportFile.fileNameList =
                                fileNameList;
                            selectedPerformanceReportFile.fileBytesList =
                                fileBytesList;
                            selectedPerformanceReportFile.deletedFileList =
                                deletedFile;
                          },
                        ),
                        CustomMultiFilePicker(
                          maxFiles: 5,
                          title: "Measurement Report",
                          isRequired: false,
                          initialFileList:
                              selectedMeasurementReportFile.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedMeasurementReportFile.fileNameList =
                                fileNameList;
                            selectedMeasurementReportFile.fileBytesList =
                                bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedMeasurementReportFile.fileNameList =
                                fileNameList;
                            selectedMeasurementReportFile.fileBytesList =
                                fileBytesList;
                            selectedMeasurementReportFile.deletedFileList =
                                deletedFile;
                          },
                        ),
                        CustomTextField(
                          title: "Remark",
                          hint: "Enter Remark",
                          isRequired: false,
                          textController: _remarkC,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 70,
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: CustomButton(text: "Save", onPressed: _saveForm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        verticalSpacing(height: 6.0),
        Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
      ],
    );
  }
}
