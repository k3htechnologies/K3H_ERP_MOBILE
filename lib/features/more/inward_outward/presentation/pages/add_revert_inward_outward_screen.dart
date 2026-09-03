import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddRevertInwardOutwardScreen extends StatefulWidget {
  final int index;
  final int inwardOutwardId;
  final String uniquekey;
  final InwardOutwardRevertHistoryModel? revertHistoryModel;
  const AddRevertInwardOutwardScreen({
    super.key,
    required this.index,
    required this.inwardOutwardId,
    required this.uniquekey,
    this.revertHistoryModel,
  });
  @override
  State<AddRevertInwardOutwardScreen> createState() =>
      _AddRevertInwardOutwardScreenState();
}

class _AddRevertInwardOutwardScreenState
    extends State<AddRevertInwardOutwardScreen> {
  late InwardOutwardCubit _inwardOutwardCubit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _revertDate;
  late TextEditingController _remarkC;
  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  bool get _isEditMode => widget.revertHistoryModel != null;
  @override
  void initState() {
    super.initState();
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _remarkC = TextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.revertHistoryModel!);
    } else {
      _revertDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _remarkC.dispose();
    super.dispose();
  }

  void _populateFormFields(InwardOutwardRevertHistoryModel revertHistoryModel) {
    _revertDate = revertHistoryModel.revertDate;
    _remarkC.text = revertHistoryModel.revertRemark;
    selectedDocumentFile.fileNameList = revertHistoryModel.revertDocumentURL
        .split(',');
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode) {
      _inwardOutwardCubit.updateRevertInwardOutward(
        index: widget.index,
        revertDate: _revertDate!.toIso8601String(),
        revertRemark: _remarkC.text.trim(),
        revertDocumentURL: selectedDocumentFile,
        context: context,
        inwardOutwardId: widget.inwardOutwardId,
        uniqueKey: widget.revertHistoryModel!.uniqueKey,
        inwardOutwardRevertId: widget.revertHistoryModel!.inwardOutwardRevertId,
      );
    } else {
      _inwardOutwardCubit.addRevertInwardOutward(
        index: widget.index,
        revertDate: _revertDate!.toIso8601String(),
        revertRemark: _remarkC.text.trim(),
        revertDocumentURL: selectedDocumentFile,
        context: context,
        inwardOutwardId: widget.inwardOutwardId,
        uniqueKey: widget.uniquekey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Revert" : "Revert",
        authorization: AuthorizationModel(),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: commonCardDecoration(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDatePicker(
                title: "Revert Date",
                isRequired: true,
                readOnly: true,
                initialDate: _revertDate,
                startDate: DateTime.now(),
                setValue: (value) {
                  _revertDate = value;
                },
                validator: (value) {
                  if (value == null) {
                    return "Revert Date is required.";
                  }
                  return null;
                },
              ),
              CustomMultiFilePicker(
                title: "Upload Document",
                isRequired: true,
                initialFileList: selectedDocumentFile.fileNameList,
                filePickType: FilePickType.both,
                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedDocumentFile.fileBytesList = bytesList;
                  selectedDocumentFile.fileNameList = fileNameList;
                },
                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  selectedDocumentFile.fileBytesList = fileBytesList;
                  selectedDocumentFile.fileNameList = fileNameList;
                  selectedDocumentFile.deletedFileList = deletedFile;
                },
                validator: (fileList) {
                  if (fileList == null || fileList.isEmpty) {
                    return "Document is required.";
                  }
                  return null;
                },
              ),
              CustomTextField(
                title: "Remark",
                textController: _remarkC,
                hint: "Enter Remark",
                isRequired: true,
                minLines: 4,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Remark is required.";
                  }
                  return null;
                },
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
          child: CustomButton(
            leading:
                _isEditMode
                    ? Icon(Icons.edit, size: 18, color: AppColor.white)
                    : null,
            text: _isEditMode ? "Update" : "Save",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
