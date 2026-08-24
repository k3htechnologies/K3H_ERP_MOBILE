import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddFlatSpecificationRemarkScreen extends StatefulWidget {
  final FlatAlterationRequestsModel? remark;
  const AddFlatSpecificationRemarkScreen({super.key, this.remark});

  @override
  State<AddFlatSpecificationRemarkScreen> createState() =>
      _AddFlatSpecificationRemarkScreenState();
}

class _AddFlatSpecificationRemarkScreenState
    extends State<AddFlatSpecificationRemarkScreen> {
  late RequestManagementCubit _requestManagementCubit;
  late TextEditingController _remarkC;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MultiFilePickerModel prrofOfDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();

    _requestManagementCubit = context.read<RequestManagementCubit>();
    _remarkC = TextEditingController();

    if (widget.remark != null) {
      _remarkC.text = widget.remark!.flatAlterationRemark;

      if (widget.remark!.proofOfDocumentUrl.isNotEmpty) {
        prrofOfDocumentFile.fileNameList = [widget.remark!.proofOfDocumentUrl];
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _remarkC.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final booking = _requestManagementCubit.state.bookingData;
    if (booking == null) return;

    if (widget.remark == null) {
      _requestManagementCubit.addFlatAlterationRequest(
        context: context,
        projectId: booking.projectId,
        bookingId: booking.bookingId,
        flatAlterationRemark: _remarkC.text.trim(),
        proofDocumentFile: prrofOfDocumentFile,
      );
    } else {
      _requestManagementCubit.updateFlatAlterationRequest(
        context: context,
        flatAlterationRequestId: widget.remark!.flatAlterationRequestId,
        projectId: widget.remark!.projectId,
        bookingId: widget.remark!.bookingId,
        uniquekey: widget.remark!.uniqueKey,
        flatAlterationRemark: _remarkC.text.trim(),
        proofDocumentFile: prrofOfDocumentFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Unit / Modulation / Customization",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.remark == null
                  ? "Add Unit / Modulation / Customization"
                  : "Update Unit / Modulation / Customization",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultiFilePicker(
                      title: "Proof Of Document",
                      isRequired: true,
                      filePickType: FilePickType.kycDocument,
                      initialFileList: prrofOfDocumentFile.fileNameList,
                      initialFileBytes: prrofOfDocumentFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        prrofOfDocumentFile.fileNameList = fileNameList;
                        prrofOfDocumentFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        prrofOfDocumentFile.fileBytesList = fileBytesList;
                        prrofOfDocumentFile.fileNameList = fileNameList;
                        prrofOfDocumentFile.deletedFileList = deleted;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Proof Of Document is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _remarkC,
                      title: "Unit / Modulation / Customization Remark",
                      hint: "Enter Unit / Modulation / Customization Remark",
                      minLines: 3,
                      maxLines: 10,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Unit / Modulation / Customization Remark is required";
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
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: widget.remark == null ? "Add" : "Update",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
