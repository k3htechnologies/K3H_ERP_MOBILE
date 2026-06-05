// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/speech_to_text/speech_to_text.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTicketScreen extends StatefulWidget {
  final TicketModel? ticket;
  const AddTicketScreen({super.key, required this.ticket});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  late TicketCubit _ticketCubit;
  late ValueNotifier<Map<String, dynamic>?> selectedPlatformType;
  late ValueNotifier<Map<String, dynamic>?> selectedModuleType;

  late TextEditingController _descriptionC, _remarkC;
  MultiFilePickerModel selectedDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late ValueNotifier<String?> selectedPriority;

  //EDIT MODE
  bool get _isEditMode => widget.ticket != null;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ticketCubit = context.read<TicketCubit>();
    selectedPlatformType = ValueNotifier(null);
    selectedModuleType = ValueNotifier(null);
    _descriptionC = TextEditingController();
    _remarkC = TextEditingController();
    selectedPriority = ValueNotifier<String?>(null);
    if (_isEditMode) {
      _prefillTicketMaster(widget.ticket!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectedPlatformType.dispose();
    selectedModuleType.dispose();
    _descriptionC.dispose();
    _remarkC.dispose();
    selectedPriority.dispose();
  }

  void _prefillTicketMaster(TicketModel ticketModel) {
    selectedPlatformType.value = platformTypeList.firstWhere(
      (e) => e['DisplayName'] == ticketModel.platform,
    );
    selectedModuleType.value = moduleTypeList.firstWhere(
      (e) => e['DisplayName'] == ticketModel.module,
    );
    selectedDocument.fileNameList =
        ticketModel.attachmentUrl.isEmpty
            ? []
            : ticketModel.attachmentUrl.split(",");

    selectedPriority.value =
        ticketModel.priority.isEmpty ? null : ticketModel.priority;
    _descriptionC.text = ticketModel.ticketDescription;
    _remarkC.text = ticketModel.ticketRemark;
  }

  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String platformTypeValue =
        selectedPlatformType.value?["zAttributesId"] == null
            ? ""
            : selectedPlatformType.value!["DisplayName"];
    final String moduleTypeValue =
        selectedModuleType.value?["zAttributesId"] == null
            ? ""
            : selectedModuleType.value!["DisplayName"];

    if (!_isEditMode && widget.ticket == null) {
      _ticketCubit.addTask(
        context,
        platform: platformTypeValue,
        module: moduleTypeValue,
        ticketDescription: _descriptionC.text.trim(),
        priority: selectedPriority.value!,
        ticketRemark: _remarkC.text.trim(),
        documnetURL: selectedDocument,
      );
    } else {
      _ticketCubit.updateTask(
        context,
        ticketId: widget.ticket!.ticketId,
        uniquekey: widget.ticket!.uniquekey,
        platform: platformTypeValue,
        module: moduleTypeValue,
        ticketDescription: _descriptionC.text.trim(),
        priority: selectedPriority.value!,
        ticketRemark: _remarkC.text.trim(),
        documnetURL: selectedDocument,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Ticket" : "Add Ticket",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? "Update Ticket" : "Add Ticket",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: selectedPlatformType,
                      builder: (context, platformValue, child) {
                        return CustomDropDownWidget(
                          title: "Platform",
                          hintText: "Select Platform",
                          isRequired: true,
                          initialValue: platformValue,
                          dataList: platformTypeList,
                          onSelected: (value) {
                            selectedPlatformType.value = value;
                          },
                          validator: (value) {
                            if ((value == null ||
                                value['zAttributesId'] == -1)) {
                              return "Platform is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedPlatformType.value = null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedModuleType,
                      builder: (context, moduleValue, child) {
                        return CustomDropDownWidget(
                          title: "Module",
                          hintText: "Select Module",
                          isRequired: true,
                          initialValue: moduleValue,
                          dataList: moduleTypeList,
                          onSelected: (value) {
                            selectedModuleType.value = value;
                          },
                          validator: (value) {
                            if ((value == null ||
                                value['zAttributesId'] == -1)) {
                              return "Module is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedModuleType.value = null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Description",
                      hint: "Enter Description",
                      minLines: 3,
                      maxLines: 10,
                      isRequired: true,
                      textController: _descriptionC,
                      suffixWidget: SpeechToTextIcon(controller: _descriptionC),
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(500),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Description is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Upload Document",
                      isRequired: true,
                      initialFileList: selectedDocument.fileNameList,
                      onFilePickedCallback: (bytes, fileName) {
                        selectedDocument.fileBytesList = bytes;
                        selectedDocument.fileNameList = fileName;
                      },
                      onFileDeleteCallback: (bytes, fileName, deletedFiles) {
                        selectedDocument.fileBytesList = bytes;
                        selectedDocument.fileNameList = fileName;
                        selectedDocument.deletedFileList = deletedFiles;
                      },
                      validator: (fileList) {
                        if (fileList == null || fileList.isEmpty) {
                          return "Document is required";
                        }
                        return null;
                      },
                    ),
                    FormField<String>(
                      validator: (_) {
                        if (selectedPriority.value == null) {
                          return "Priority is required";
                        }
                        return null;
                      },
                      builder: (field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Set Priority", style: AppTextStyle.ts14M()),

                            ValueListenableBuilder(
                              valueListenable: selectedPriority,
                              builder: (context, value, child) {
                                return Row(
                                  children: [
                                    _priorityRadio("High", value, field),
                                    const SizedBox(width: 16),
                                    _priorityRadio("Medium", value, field),
                                    const SizedBox(width: 16),
                                    _priorityRadio("Low", value, field),
                                  ],
                                );
                              },
                            ),

                            field.hasError
                                ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 6.0,
                                    top: 4.0,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColor.error,
                                        size: 14,
                                      ),
                                      horizontalSpacing(width: 5),
                                      Flexible(
                                        child: Text(
                                          field.errorText ?? '',
                                          style: AppTextStyle.ts12R(
                                            color: AppColor.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox(height: 18),
                          ],
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      minLines: 3,
                      maxLines: 10,
                      isRequired: true,
                      textController: _remarkC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(500),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Remark is required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            onPressed: _verifyAndSubmitForm,
          ),
        ),
      ),
    );
  }

  Widget _priorityRadio(
    String priority,
    String? selectedValue,
    FormFieldState<String> field,
  ) {
    return InkWell(
      onTap: () {
        selectedPriority.value = priority;
        field.didChange(priority);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: priority,
            groupValue: selectedValue,
            onChanged: (value) {
              selectedPriority.value = value;
              field.didChange(value);
            },
          ),
          Text(priority, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }
}
