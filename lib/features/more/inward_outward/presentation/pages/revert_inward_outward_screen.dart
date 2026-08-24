import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class RevertInwardOutwardScreen extends StatefulWidget {
  final int index;
  final int inwardOutwardId;
  final String uniquekey;

  const RevertInwardOutwardScreen({
    super.key,
    required this.index,
    required this.inwardOutwardId,
    required this.uniquekey,
  });

  @override
  State<RevertInwardOutwardScreen> createState() =>
      _RevertInwardOutwardScreenState();
}

class _RevertInwardOutwardScreenState extends State<RevertInwardOutwardScreen> {
  late InwardOutwardCubit _inwardOutwardCubit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime? _revertDate;

  late TextEditingController _remarkC;

  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _remarkC = TextEditingController();
  }

  @override
  void dispose() {
    _remarkC.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _inwardOutwardCubit.revertInwardOutward(
      index: widget.index,
      revertDate: _revertDate!.toIso8601String(),
      revertRemark: _remarkC.text.trim(),
      revertDocumentURL: selectedDocumentFile,
      context: context,
      inwardOutwardId: widget.inwardOutwardId,
      uniqueKey: widget.uniquekey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Revert",
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
                initialDate: _revertDate,
                startDate: DateTime.now(),
                setValue: (value) {
                  _revertDate = value;
                },
                validator: (value) {
                  if (value == null) {
                    return "Revert Date is required";
                  }
                  return null;
                },
              ),

              CustomMultiFilePicker(
                title: "Upload Document",
                isRequired: true,
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
                    return "Document is required";
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
                    return "Remark is required";
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
          child: CustomButton(text: "Save", onPressed: _saveForm),
        ),
      ),
    );
  }
}
