import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/wing_form_detail_model.dart';

class BuildingFormDataModel {
  int totalWings = 0;
  int totalPodium = 0;
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

  List<WingFormDetailModel> wings = [];
}
