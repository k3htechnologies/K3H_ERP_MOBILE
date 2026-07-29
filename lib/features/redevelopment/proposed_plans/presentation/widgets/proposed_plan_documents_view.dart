import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';

class ProposedPlanDocumentsView extends StatefulWidget {
  final dynamic building;

  const ProposedPlanDocumentsView({super.key, this.building});

  @override
  State<ProposedPlanDocumentsView> createState() =>
      _ProposedPlanDocumentsViewState();
}

class _ProposedPlanDocumentsViewState extends State<ProposedPlanDocumentsView> {
  MultiFilePickerModel planFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel threeDViewFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel salesPlanFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();
    _prefillDocuments();
  }

  void _prefillDocuments() {
    final building = widget.building;

    if (building == null) return;

    // Plan Document
    if (building.planDocumentURL != null &&
        building.planDocumentURL.toString().isNotEmpty) {
      planFile.fileNameList = [building.planDocumentURL.toString()];

      planFile.fileBytesList = [];
    }

    // 3D View
    if (building.threeDViewURL != null &&
        building.threeDViewURL.toString().isNotEmpty) {
      threeDViewFile.fileNameList = [building.threeDViewURL.toString()];

      threeDViewFile.fileBytesList = [];
    }

    // Sales Plan
    if (building.salesPlanURL != null &&
        building.salesPlanURL.toString().isNotEmpty) {
      salesPlanFile.fileNameList = [building.salesPlanURL.toString()];

      salesPlanFile.fileBytesList = [];
    }
  }

  void _updateDocumentsState() {
    final cubit = context.read<ProposedPlansCubit>();

    final formData = cubit.state.buildingForm;

    formData.planFile = planFile;

    formData.threeDViewFile = threeDViewFile;
    formData.salesPlanFile = salesPlanFile;

    cubit.updateBuildingForm(formData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "Document Uploads",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                CustomMultiFilePicker(
                  initialFileList: planFile.fileNameList,
                  title: "Plan",
                  onFilePickedCallback: (fileByteList, fileNameList) {
                    planFile.fileBytesList = fileByteList;
                    planFile.fileNameList = fileNameList;
                    _updateDocumentsState();
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedUrl,
                  ) {
                    planFile.fileBytesList = fileBytesList;
                    planFile.fileNameList = fileNameList;
                    planFile.deletedFileList = deletedUrl;
                    _updateDocumentsState();
                  },
                  validator: (file) {
                    if (file == null || file.isEmpty) {
                      return "Plan File required";
                    }
                    return null;
                  },
                ),
                CustomMultiFilePicker(
                  initialFileList: threeDViewFile.fileNameList,
                  title: "3D View",
                  onFilePickedCallback: (fileByteList, fileNameList) {
                    threeDViewFile.fileBytesList = fileByteList;
                    threeDViewFile.fileNameList = fileNameList;
                    _updateDocumentsState();
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedUrl,
                  ) {
                    threeDViewFile.fileBytesList = fileBytesList;
                    threeDViewFile.fileNameList = fileNameList;
                    threeDViewFile.deletedFileList = deletedUrl;
                    _updateDocumentsState();
                  },
                  validator: (file) {
                    if (file == null || file.isEmpty) {
                      return "Plan File required";
                    }
                    return null;
                  },
                ),
                CustomMultiFilePicker(
                  initialFileList: salesPlanFile.fileNameList,
                  title: "Sales Plan Document",
                  onFilePickedCallback: (fileByteList, fileNameList) {
                    salesPlanFile.fileBytesList = fileByteList;
                    salesPlanFile.fileNameList = fileNameList;
                    _updateDocumentsState();
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedUrl,
                  ) {
                    salesPlanFile.fileBytesList = fileBytesList;
                    salesPlanFile.fileNameList = fileNameList;
                    salesPlanFile.deletedFileList = deletedUrl;
                    _updateDocumentsState();
                  },
                  validator: (file) {
                    if (file == null || file.isEmpty) {
                      return "Plan File required";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
