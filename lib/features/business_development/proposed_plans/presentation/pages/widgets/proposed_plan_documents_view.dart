import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';

class ProposedPlanDocumentsView extends StatefulWidget {
  final BuildingProposedPlanDataModel? building;
  const ProposedPlanDocumentsView({super.key, this.building});
  @override
  State<ProposedPlanDocumentsView> createState() =>
      _ProposedPlanDocumentsViewState();
}

class _ProposedPlanDocumentsViewState extends State<ProposedPlanDocumentsView> {
  late final AuthorizationModel _routeAuthorizationModel;
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
  MultiFilePickerModel walkthroughViewFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedPlan] ??
        AuthorizationModel();
    _prefillDocuments();
  }

  void _prefillDocuments() {
    final building = widget.building;
    if (building == null) return;
    planFile.fileNameList =
        building.planDocumentURL.isEmpty
            ? []
            : building.planDocumentURL.split(',');
    threeDViewFile.fileNameList =
        building.threeDViewURL.isEmpty ? [] : building.threeDViewURL.split(',');
    walkthroughViewFile.fileNameList =
        building.walkthroughViewURL.isEmpty
            ? []
            : building.walkthroughViewURL.split(',');

    salesPlanFile.fileNameList =
        building.salesPlanURL.isEmpty ? [] : building.salesPlanURL.split(',');
  }

  void _updateDocumentsState() {
    final cubit = context.read<ProposedPlansCubit>();
    final formData = cubit.state.proposedPlanForm;
    formData.planFile = planFile;
    formData.threeDViewFile = threeDViewFile;
    formData.salesPlanFile = salesPlanFile;
    formData.walkthroughViewFile = walkthroughViewFile;
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
                  filePickType: FilePickType.kycDocument,
                  readOnly: !_routeAuthorizationModel.isAction,
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
                ),
                CustomMultiFilePicker(
                  initialFileList: threeDViewFile.fileNameList,
                  title: "3D View",
                  filePickType: FilePickType.kycDocument,
                  readOnly: !_routeAuthorizationModel.isAction,
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
                ),
                CustomMultiFilePicker(
                  readOnly: !_routeAuthorizationModel.isAction,
                  initialFileList: walkthroughViewFile.fileNameList,
                  title: "Walkthrough View",
                  filePickType: FilePickType.kycDocument,
                  onFilePickedCallback: (fileByteList, fileNameList) {
                    walkthroughViewFile.fileBytesList = fileByteList;
                    walkthroughViewFile.fileNameList = fileNameList;
                    _updateDocumentsState();
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedUrl,
                  ) {
                    walkthroughViewFile.fileBytesList = fileBytesList;
                    walkthroughViewFile.fileNameList = fileNameList;
                    walkthroughViewFile.deletedFileList = deletedUrl;
                    _updateDocumentsState();
                  },
                ),
                CustomMultiFilePicker(
                  initialFileList: salesPlanFile.fileNameList,
                  title: "Sales Plan",
                  filePickType: FilePickType.kycDocument,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
