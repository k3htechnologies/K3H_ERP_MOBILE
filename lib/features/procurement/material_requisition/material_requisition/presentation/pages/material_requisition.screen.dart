import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class MaterialRequisitonScreen extends StatefulWidget {
  const MaterialRequisitonScreen({super.key});

  @override
  State<MaterialRequisitonScreen> createState() =>
      _MaterialRequisitonScreenState();
}

class _MaterialRequisitonScreenState extends State<MaterialRequisitonScreen> {
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  // SELECTION OF PROJECT
  late ProjectModel _project;
  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialRequisition]!;
    // _materialRequisitionCubit.getMaterialRequisitionList(
    //   context,
    //   1,
    //   _selectedProject.projectId,
    // );
    _initializeTextEditingController();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Material Requisition",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {},
        onAddCallback: () {},
        onProjectChangeCallback: (value) {
          _project = value;
          _materialRequisitionCubit.getMaterialRequisitionList(
            context,
            1,
            _project.projectId,
          );
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please Select a project");
            return;
          }
          if (_materialRequisitionCubit.state.materialRequisitionList.isEmpty) {
            showErrorMessage(context, "", "No Data Found");
            return;
          }
          _materialRequisitionCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            goRouter.pushNamed(AppRoutes.materialRequisition);
          },
          child: Text(
            "MATERIAL REQUISITION SCREEN",
            style: AppTextStyle.ts16R(color: AppColor.primary),
          ),
        ),
      ),
    );
  }
}
