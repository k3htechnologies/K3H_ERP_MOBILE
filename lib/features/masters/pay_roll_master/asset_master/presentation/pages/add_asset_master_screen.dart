import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddAssetMasterScreen extends StatefulWidget {
  final AssetMasterModel? asset;
  final int index;
  const AddAssetMasterScreen({super.key, this.asset, this.index = 0});

  @override
  State<AddAssetMasterScreen> createState() => _AddAssetMasterScreenState();
}

class _AddAssetMasterScreenState extends State<AddAssetMasterScreen> {
  // CUBIT
  late AssetMasterCubit _assetMasterCubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _assetNameC;
  late TextEditingController _assetCodeC;
  late TextEditingController _assetTypeC;
  late TextEditingController _assetModelC;
  late TextEditingController _assetBrandC;
  late TextEditingController _serialNumberC;
  late TextEditingController _supplierNameC;
  late TextEditingController _assetCostC;

  // DATE PICKERS
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiryDate;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // FILE VARIABLES
  MultiFilePickerModel assetInvoiceFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  bool get _isEditMode => widget.asset != null;

  @override
  void initState() {
    super.initState();
    _assetMasterCubit = context.read<AssetMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _initializeTextEditingControllers();
    if (widget.asset != null) {
      _populateFormFields(widget.asset!);
    }
  }

  @override
  void dispose() {
    _disposeTextEditingControllers();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _assetNameC = TextEditingController();
    _assetCodeC = TextEditingController();
    _assetTypeC = TextEditingController();
    _assetModelC = TextEditingController();
    _assetBrandC = TextEditingController();
    _serialNumberC = TextEditingController();
    _supplierNameC = TextEditingController();
    _assetCostC = TextEditingController();
  }

  void _disposeTextEditingControllers() {
    _assetNameC.dispose();
    _assetCodeC.dispose();
    _assetTypeC.dispose();
    _assetModelC.dispose();
    _assetBrandC.dispose();
    _serialNumberC.dispose();
    _supplierNameC.dispose();
    _assetCostC.dispose();
  }

  void _populateFormFields(AssetMasterModel asset) {
    _assetNameC.text = asset.assetName;
    _assetCodeC.text = asset.assetCode;
    _assetTypeC.text = asset.assetType;
    _assetModelC.text = asset.assetModel;
    _assetBrandC.text = asset.assetBrand;
    _serialNumberC.text = asset.serialNumber;
    _supplierNameC.text = asset.supplierName;
    _assetCostC.text = asset.assetCost.toString();
    _purchaseDate = asset.purchaseDate;
    _warrantyExpiryDate = asset.warrantyExpiryDate;
    assetInvoiceFile.fileNameList =
        asset.assetInvoiceURL == "" ? [] : asset.assetInvoiceURL.split(",");
    assetInvoiceFile.fileBytesList = List.generate(
      assetInvoiceFile.fileNameList.length,
      (_) => Uint8List(0),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_purchaseDate == null) {
      showErrorMessage(context, 'Error', 'Purchase Date is required');
      return;
    }

    if (_isEditMode && widget.asset != null) {
      _assetMasterCubit.updateAsset(
        index: widget.index,
        context: context,
        assetMasterId: widget.asset!.assetMasterId,
        uniqueKey: widget.asset!.uniquekey,
        assetName: _assetNameC.text.trim(),
        assetCode: _assetCodeC.text.trim(),
        assetType: _assetTypeC.text.trim(),
        assetModel: _assetModelC.text.trim(),
        assetBrand: _assetBrandC.text.trim(),
        serialNumber: _serialNumberC.text.trim(),
        supplierName: _supplierNameC.text.trim(),
        assetPurchaseDate: _purchaseDate!,
        assetCost: _assetCostC.text.trim(),
        warrantyDate: _warrantyExpiryDate,
        assetInvoiceFile: assetInvoiceFile,
      );
    } else {
      _assetMasterCubit.addAsset(
        context: context,
        assetName: _assetNameC.text.trim(),
        assetCode: _assetCodeC.text.trim(),
        assetType: _assetTypeC.text.trim(),
        assetModel: _assetModelC.text.trim(),
        assetBrand: _assetBrandC.text.trim(),
        serialNumber: _serialNumberC.text.trim(),
        supplierName: _supplierNameC.text.trim(),
        assetPurchaseDate: _purchaseDate!,
        assetCost: _assetCostC.text.trim(),
        warrantyDate: _warrantyExpiryDate,
        assetInvoiceFile: assetInvoiceFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Asset Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Asset" : "Add Asset",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: 'Asset Name',
                      textController: _assetNameC,
                      hint: "Enter Asset Name",
                      inputFormatterList: InputValidator.textOnly(100),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Asset Code',
                      textController: _assetCodeC,
                      hint: "Enter Asset Code",
                      inputFormatterList: InputValidator.textDigit(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Code is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Asset Type',
                      textController: _assetTypeC,
                      hint: "Enter Asset Type",
                      inputFormatterList: InputValidator.textOnly(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Type is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Asset Brand',
                      textController: _assetBrandC,
                      hint: "Enter Asset Brand",
                      inputFormatterList: InputValidator.textOnly(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Brand is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Asset Model',
                      textController: _assetModelC,
                      hint: "Enter Asset Model",
                      inputFormatterList: InputValidator.textDigit(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Model is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Serial Number',
                      textController: _serialNumberC,
                      hint: "Enter Serial Number",
                      inputFormatterList: InputValidator.textDigit(100),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Serial Number is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Supplier Name',
                      textController: _supplierNameC,
                      hint: "Enter Supplier Name",
                      inputFormatterList: InputValidator.textOnly(100),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Supplier Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: 'Purchase Date',
                      initialDate: _purchaseDate,
                      isRequired: true,
                      setValue: (date) {
                        setState(() {
                          _purchaseDate = date;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Purchase Date is required";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: 'Warranty Expiry Date',
                      isRequired: true,
                      initialDate: _warrantyExpiryDate,
                      startDate: _purchaseDate,
                      setValue: (date) {
                        setState(() {
                          _warrantyExpiryDate = date;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Warranty Date is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Asset Cost',
                      textController: _assetCostC,
                      hint: "Enter Asset Cost",
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatterList: InputValidator.decimal(2),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Asset Cost is required";
                        }
                        final cost = double.tryParse(value);
                        if (cost == null || cost < 0) {
                          return "Please enter a valid cost";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      initialFileList: assetInvoiceFile.fileNameList,
                      title: "Upload Asset Invoice",
                      isRequired: true,
                      onFilePickedCallback: (fileByteList, fileNameList) {
                        assetInvoiceFile.fileBytesList = fileByteList;
                        assetInvoiceFile.fileNameList = fileNameList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedUrl,
                      ) {
                        assetInvoiceFile.fileBytesList = fileBytesList;
                        assetInvoiceFile.fileNameList = fileNameList;
                        assetInvoiceFile.deletedFileList = deletedUrl;
                      },
                      validator: (value){
                        if (assetInvoiceFile.fileNameList.isEmpty) {
                          return "Please upload at least one file";
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update Asset" : "Add Asset",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
