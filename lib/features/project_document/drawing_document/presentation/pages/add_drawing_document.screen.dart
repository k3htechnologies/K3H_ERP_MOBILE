import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/cubit/drawing_document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDrawingDocumentScreen extends StatefulWidget {
  final DrawingDocumentModel? drawingDocumentModel;
  final int index;
  final bool isEdit;
  const AddDrawingDocumentScreen({
    super.key,
    this.drawingDocumentModel,
    required this.index,
    required this.isEdit,
  });

  @override
  State<AddDrawingDocumentScreen> createState() =>
      _AddDrawingDocumentScreenState();
}

class _AddDrawingDocumentScreenState extends State<AddDrawingDocumentScreen> {
  //CUBIT
  late DrawingDocumentCubit _drawingDocumentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentNameC, _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // FILE VARIABLES
  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedDocumentDWGFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  //EDIT MODE
  bool get _isEditMode => widget.isEdit;

  DateTime? revisionDate;

  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();

  late final ValueNotifier<List<Map<String, dynamic>>> _selectedFloorNotifier;
  final ValueNotifier<Map<String, dynamic>?> _selectedStatus = ValueNotifier(
    null,
  );
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _drawingDocumentCubit = context.read<DrawingDocumentCubit>();
    _selectedFloorNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.drawingDocumentModel!);
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _documentNameC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // PREFILL FORM
  void _prefillForm(DrawingDocumentModel document) {
    _documentNameC.text = document.drawingDocumentName;
    if (document.drawingDocumentStatus.isNotEmpty) {
      final matchedStatus = drawingStatusTypeList.firstWhere(
        (status) => status['DisplayName'] == document.drawingDocumentStatus,
        orElse: () => drawingStatusTypeList.first,
      );

      _selectedStatus.value = matchedStatus;
    }
    if (document.inventoryFloorId > 0) {
      _selectedFloorNotifier.value = [
        {
          "zAttributesId": document.inventoryFloorId,
          "DisplayName": document.floor,
        },
      ];
    }

    selectedDocumentFile.fileNameList =
        document.drawingDocumentUrl.isEmpty
            ? []
            : document.drawingDocumentUrl.split(",");
    selectedDocumentDWGFile.fileNameList =
        document.drawingDocumentDwgurl.isEmpty
            ? []
            : document.drawingDocumentDwgurl.split(",");
    revisionDate = document.drawingDocumentRevisionDate;

    _remarkC.text =
        document.drawingDocumentRemark.isNotEmpty
            ? document.drawingDocumentRemark
            : "";
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!widget.isEdit) {
      _drawingDocumentCubit.addSubDrawingDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.drawingDocumentModel!.uniquekey,
        drawingDocumentId: widget.drawingDocumentModel!.drawingDocumentId,
        drawingDocumentCategoryId:
            widget.drawingDocumentModel!.drawingDocumentCategoryId,
        drawingDocumentRevisionDate: revisionDate,
        drawingDocumentRemark: _remarkC.text.trim(),
        drawingDocumentName: widget.drawingDocumentModel!.drawingDocumentName,
        documents: selectedDocumentFile,
        documentDWG: selectedDocumentDWGFile,
      );
    } else {
      _drawingDocumentCubit.updateSubDrawingDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.drawingDocumentModel!.uniquekey,
        drawingDocumentName: widget.drawingDocumentModel!.drawingDocumentName,
        drawingDocumentId: widget.drawingDocumentModel!.drawingDocumentId,
        drawingDocumentCategoryId:
            widget.drawingDocumentModel!.drawingDocumentCategoryId,
        documents: selectedDocumentFile,
        documentDWG: selectedDocumentDWGFile,
        drawingDocumentStatus: _selectedStatus.value?["DisplayName"],
        inventoryFloorId: _selectedFloorNotifier.value.first["DisplayName"],
        drawingDocumentRevisionDate: revisionDate,
        drawingDocumentRemark: _remarkC.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _documentNameC.dispose();
    _remarkC.dispose();
    _selectedFloorNotifier.dispose();
    _selectedStatus.dispose();
  }

  // FETCH FLOORS
  Future<Map<String, dynamic>> _fetchFloors(
    int pageNumber, {
    String? value,
    required int projectId,
    required int? inventoryFlatId,
  }) async {
    final result = await _inventoryRepository.getPaginatedFloors(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: projectId,
      queryParams: {
        if (value != null && value.isNotEmpty) "Floor": value,
        "ApprovalStatus": "APPROVED",
      },
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final flats = response['data'] as List<PaginatedFloorModel>;

        return {
          "itemList":
              flats.map((floor) {
                return {
                  "zAttributesId": floor.inventoryFloorId,
                  "DisplayName":
                      "${floor.buildingNumber} - ${floor.wing} - ${floor.floor}",
                  "paginatedFloorModel": floor,
                };
              }).toList(),

          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Drawing Document",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Drawing Document" : "Add Drawing Document",
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
                    if (_isEditMode) ...[
                      CustomTextField(
                        title: "Document Name",
                        hint: "Enter Document Name",
                        isRequired: true,
                        readOnly: true,
                        textController: _documentNameC,
                      ),
                    ],

                    ValueListenableBuilder(
                      valueListenable: _selectedFloorNotifier,
                      builder: (context, selectedFloor, child) {
                        return CustomMultipleSelectPopup(
                          initialValue: selectedFloor,
                          isRequired: true,
                          title: "Floor",
                          hintText: "Select Floor",

                          dataFetchCallBack: (pageNumber, {String? value}) {
                            return _fetchFloors(
                              pageNumber,
                              value: value,
                              projectId: widget.drawingDocumentModel!.projectId,
                              inventoryFlatId: null,
                            );
                          },

                          isMultiSelect: false,
                          dataList: [],

                          onSelected: (value) {
                            _selectedFloorNotifier.value = value;
                          },
                          onClear: () {
                            _selectedFloorNotifier.value = [];
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Floor is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Status",
                      dataList: drawingStatusTypeList,
                      initialValue: _selectedStatus.value,
                      hintText: "Select Status",
                      isRequired: true,
                      onSelected: (value) {
                        _selectedStatus.value = value;
                      },
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return "Status is required.";
                        }
                        return null;
                      },
                      onValueClear: () {
                        _selectedStatus.value = null;
                      },
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 5,
                      title: "Files (.PDF)",
                      filePickType: FilePickType.document,
                      isRequired: true,
                      initialFileList: selectedDocumentFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedDocumentFile.fileNameList = fileNameList;
                        selectedDocumentFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedDocumentFile.fileNameList = fileNameList;
                        selectedDocumentFile.fileBytesList = fileBytesList;
                        selectedDocumentFile.deletedFileList = deletedFile;
                      },
                      validator: (value) {
                        if ((value == null || value.isEmpty)) {
                          return "File is required.";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 5,
                      title: "Files (.DWG)",
                      filePickType: FilePickType.drawingDocument,
                      initialFileList: selectedDocumentDWGFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedDocumentDWGFile.fileNameList = fileNameList;
                        selectedDocumentDWGFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedDocumentDWGFile.fileNameList = fileNameList;
                        selectedDocumentDWGFile.fileBytesList = fileBytesList;
                        selectedDocumentDWGFile.deletedFileList = deletedFile;
                      },
                    ),
                    CustomDatePicker(
                      title: "Revision Date",
                      initialDate: revisionDate,
                      setValue: (value) => revisionDate = value,
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      minLines: 3,
                      maxLines: 10,
                      textController: _remarkC,
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
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 16,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
