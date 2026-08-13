import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/cubit/flat_handover_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddFlatHandoverScreen extends StatefulWidget {
  final PayTrackBookingFilesModel? flatHandoverDocument;
  final int? index;
  const AddFlatHandoverScreen({
    super.key,
    this.flatHandoverDocument,
    this.index,
  });

  @override
  State<AddFlatHandoverScreen> createState() => _AddFlatHandoverScreenState();
}

class _AddFlatHandoverScreenState extends State<AddFlatHandoverScreen> {
  late FlatHandoverCubit _flatHandoverCubit;
  late TextEditingController _fileNameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MultiFilePickerModel flatHandoverDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();

    _flatHandoverCubit = context.read<FlatHandoverCubit>();

    _fileNameController = TextEditingController(
      text: widget.flatHandoverDocument?.fileName ?? "",
    );

    if (widget.flatHandoverDocument != null &&
        widget.flatHandoverDocument!.payTrackBookingFilesUrl.isNotEmpty) {
      flatHandoverDocument.fileNameList.add(
        widget.flatHandoverDocument!.payTrackBookingFilesUrl,
      );

      flatHandoverDocument.fileNameList =
          widget.flatHandoverDocument!.payTrackBookingFilesUrl.isEmpty
              ? []
              : widget.flatHandoverDocument!.payTrackBookingFilesUrl.split(",");
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Update Flat Handover",
        authorization: AuthorizationModel(),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: commonCardDecoration(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                textController: _fileNameController,
                title: "File Name",
                hint: "File Name",
                isRequired: true,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "File Name is required";
                  }
                  return null;
                },
              ),
              verticalSpacing(),
              CustomMultiFilePicker(
                title: "File",
                isRequired: true,
                filePickType: FilePickType.both,
                initialFileList: flatHandoverDocument.fileNameList,

                onFilePickedCallback: (bytesList, fileNameList) {
                  flatHandoverDocument.fileNameList = fileNameList;
                  flatHandoverDocument.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  flatHandoverDocument.fileNameList = fileNameList;
                  flatHandoverDocument.fileBytesList = fileBytesList;
                  flatHandoverDocument.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if (fileList == null || fileList.isEmpty) {
                    return "File is required";
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
            text: "Update",
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              _flatHandoverCubit.updateFlatHandoverFile(
                context: context,
                payTrackBookingFilesId:
                    widget.flatHandoverDocument!.payTrackBookingFilesId,
                projectId: widget.flatHandoverDocument!.projectId,
                bookingId: widget.flatHandoverDocument!.bookingId,
                fileName: _fileNameController.text.trim(),
                flatHandoverDocuments: flatHandoverDocument,
                uniqueKey: widget.flatHandoverDocument!.uniquekey,
                index: widget.index!,
              );
            },
          ),
        ),
      ),
    );
  }
}
