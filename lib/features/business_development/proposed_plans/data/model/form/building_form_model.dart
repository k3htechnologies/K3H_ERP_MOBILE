import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/form/wing_detail_form_model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/proposed_plans.model.dart';

class ProposedPlanFormDataModel {
  int totalWings = 0;
  int totalPodium = 0;
  int totalParking = 0;
  int totalUnits = 0;

  int salesResidential = 0;
  int salesCommercial = 0;
  int salesVisitor = 0;

  int memberResidential = 0;
  int memberCommercial = 0;
  int memberVisitor = 0;

  String amenities = "";

  MultiFilePickerModel planFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel salesPlanFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel threeDViewFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel walkthroughViewFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  List<WingDetailFormModel> wings = [];

  ProposedPlanFormDataModel();

  factory ProposedPlanFormDataModel.fromModel(
    BuildingProposedPlanDataModel model,
  ) {
    return ProposedPlanFormDataModel()
      ..totalWings = model.totalNumberOfWing
      ..totalParking = model.totalParking
      ..totalUnits = model.totalUnits
      ..totalPodium = model.totalPodium
      ..salesResidential = model.salesResidentialParking
      ..salesCommercial = model.salesCommercialParking
      ..salesVisitor = model.salesVisitorsParking
      ..memberResidential = model.memberResidentialParking
      ..memberCommercial = model.memberCommercialParking
      ..memberVisitor = model.memberVisitorsParking
      ..amenities = model.amenities
      ..planFile = MultiFilePickerModel(
        fileBytesList: [],
        fileNameList:
            model.planDocumentURL.isNotEmpty ? [model.planDocumentURL] : [],
        deletedFileList: "",
      )
      ..salesPlanFile = MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: model.salesPlanURL.isNotEmpty ? [model.salesPlanURL] : [],
        deletedFileList: "",
      )
      ..threeDViewFile = MultiFilePickerModel(
        fileBytesList: [],
        fileNameList:
            model.threeDViewURL.isNotEmpty ? [model.threeDViewURL] : [],
        deletedFileList: "",
      )
      ..walkthroughViewFile = MultiFilePickerModel(
        fileBytesList: [],
        fileNameList:
            model.walkthroughViewURL.isNotEmpty
                ? [model.walkthroughViewURL]
                : [],
        deletedFileList: "",
      )
      ..wings =
          model.wingProposedPlanData
              .map((e) => WingDetailFormModel.fromApi(e))
              .toList();
  }
}
