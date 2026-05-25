import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddFlatSpecificationRemarkScreen extends StatefulWidget {
  const AddFlatSpecificationRemarkScreen({super.key});

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
  }

  @override
  void dispose() {
    super.dispose();
    _remarkC.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    final booking = _requestManagementCubit.state.bookingData;

    if (booking == null) return;

    _requestManagementCubit.addFlatAlterationRequest(
      context: context,
      projectId: booking.projectId,
      bookingId: booking.bookingId,
      uniquekey: booking.uniquekey,
      flatAlterationRemark: _remarkC.text.trim(),
      proofDocumentFile: prrofOfDocumentFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Flat Alteration Request",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultiFilePicker(
                      title: "Proof Of Document",
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
                    ),
                    CustomTextField(
                      textController: _remarkC,
                      title: "Remark",
                      hint: "Enter Remark",
                      minLines: 3,
                      maxLines: 10,
                      isRequired: true,
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
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [CustomButton(text: "Add", onPressed: _submitForm)],
            ),
          ),
        ],
      ),
    );
  }
}
