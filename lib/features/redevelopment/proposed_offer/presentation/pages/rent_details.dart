import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class RentDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const RentDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<RentDetails> createState() => _RentDetailsState();
}

class _RentDetailsState extends State<RentDetails> {

  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _amountController;
  late TextEditingController _carpetAreaSqFtController;

  // DATE VARIABLES
  DateTime? _rentStartDate;
  DateTime? _rentEndDate;

  // DROPDOWN SELECTIONS
  Map<String, dynamic>? _selectedType;
  Map<String, dynamic>? _selectedTenure;
  Map<String, dynamic>? _selectedUnitSqFtLumsum;

  // BOOLEAN VALUES
  bool _isAdditionalRent = false;
  bool _isPayBrokerage = false;

  // DROPDOWN LISTS
  final List<Map<String, dynamic>> _typeList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Residential"},
    {"zAttributesId": 2, "DisplayName": "Commercial"},
  ];

  final List<Map<String, dynamic>> _tenureList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Tenure 1"},
    {"zAttributesId": 2, "DisplayName": "Tenure 2"},
    {"zAttributesId": 3, "DisplayName": "Tenure 3"},
    {"zAttributesId": 4, "DisplayName": "Tenure 4"},
    {"zAttributesId": 5, "DisplayName": "Tenure 5"},
  ];

  final List<Map<String, dynamic>> _unitSqFtLumsumList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Per Sq Ft"},
    {"zAttributesId": 2, "DisplayName": "Lump Sum"},
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.pullRentDetails(
        context: context,
        pageNumber: 1,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    });
  }

  void _initializeControllers() {
    _amountController = TextEditingController();
    _carpetAreaSqFtController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _carpetAreaSqFtController.dispose();
    super.dispose();
  }

  // DIALOGUE TO DELETE RENT DETAILS
  Future<void> _showPopupToDeleteRentDetails(
      BuildContext context,
      RentDetailsModel obj,
      int currentPage,
      ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a rent detail?',
      'Deleting this rent detail will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _cubit.deleteRentDetails(
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferRentDetailsId: obj.proposedOfferRentDetailsId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        pageSize: 10,
      );
    }
  }

  // API CALLS TO ADD/UPDATE RENT DETAILS
  Future<void> _addUpdateRentDetails(
      BuildContext context,
      RentDetailsModel? rentDetailsModel,
      ProposedOfferState state,
      int index,
      ) async {
    if (_formKey.currentState!.validate()) {
      rentDetailsModel != null
          ? _cubit.updateRentDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferRentDetailsId:
        rentDetailsModel.proposedOfferRentDetailsId,
        uniqueKey: rentDetailsModel.uniquekey,
        isAdditionalRent: _isAdditionalRent,
        type: _selectedType!['DisplayName'],
        tenure: _selectedTenure?['DisplayName'] ?? "",
        amount: double.parse(_amountController.text),
        unitSqFtLumsum: _selectedUnitSqFtLumsum!['DisplayName'],
        carpetAreaSqFt: double.parse(_carpetAreaSqFtController.text),
        rentStartDate: _rentStartDate!,
        rentEndDate: _rentEndDate!,
        isPayBrokerage: _isPayBrokerage,
        index: index,
      )
          : _cubit.addUpdateRentDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        isAdditionalRent: _isAdditionalRent,
        type: _selectedType!['DisplayName'],
        tenure: _selectedTenure?['DisplayName'] ?? "",
        amount: double.parse(_amountController.text),
        unitSqFtLumsum: _selectedUnitSqFtLumsum!['DisplayName'],
        carpetAreaSqFt: double.parse(_carpetAreaSqFtController.text),
        rentStartDate: _rentStartDate!,
        rentEndDate: _rentEndDate!,
        isPayBrokerage: _isPayBrokerage,
      );
    }
  }

  void _onSave({RentDetailsModel? rentDetailsModel, int? index}) {
    if (_formKey.currentState!.validate()) {
      _addUpdateRentDetails(
        context,
        rentDetailsModel,
        _cubit.state,
        index ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
