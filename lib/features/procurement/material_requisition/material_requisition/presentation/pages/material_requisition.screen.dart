import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
    _materialRequisitionCubit.getMaterialRequisitionList(
      context,
      1,
      _project.projectId,
    );
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
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          // _materialRequisitionCubit.(context, "", _project.projectId);
        },
        child: BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) &&
                state.materialRequisitionList.isEmpty) {
              return Center(child: loader());
            }
            if (state.materialRequisitionList.isEmpty) {
              return Center(
                child: noDataWidget(message: "No Material Data Found"),
              );
            }
            return SizedBox();
            // return ListView.builder(
            //   controller: scrollController,
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //   itemCount: _enquiryCubit.state.materialRequisitionList.length + 1,
            //   itemBuilder: (context, index) {
            //     if (index == state.materialRequisitionList.length) {
            //       return state.materialRequisitionList.length < state.totalNumberOfRecord
            //           ? Padding(
            //             padding: const EdgeInsets.all(16),
            //             child: Center(child: CircularProgressIndicator()),
            //           )
            //           : const SizedBox.shrink();
            //     }
            //     var enquiry = state.materialRequisitionList[index];
            //     return Container(
            //       margin: EdgeInsets.only(bottom: 10),
            //       padding: EdgeInsets.all(12),
            //       decoration: commonCardDecoration(),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             children: [
            //               Expanded(
            //                 child: GestureDetector(
            //                   onTap: () async {
            //                     /// CLEAR PREVIOUS OVERVIEW DATA
            //                     await _enquiryCubit.clearCurrentEnquiry();

            //                     ///  CLEAR PREVIOUS FOLLOWUP DATA
            //                     await _enquiryCubit.clearEnquiryFollowUp();

            //                     await goRouter.pushNamed(
            //                       AppRoutes.viewEnquiry,
            //                       queryParameters: {
            //                         "enquiryId": Uri.encodeQueryComponent(
            //                           EncryptionManager.encryptData(
            //                             enquiry.enquiryId.toString(),
            //                           ),
            //                         ),
            //                       },
            //                     );
            //                   },
            //                   child: Text(
            //                     enquiry.name,
            //                     style: AppTextStyle.ts14M(
            //                       color: AppColor.primary,
            //                     ).copyWith(
            //                       decoration: TextDecoration.underline,
            //                       decorationColor: AppColor.primary,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               horizontalSpacing(),
            //               CustomIconButton(
            //                 onPressed: () {
            //                   openWhatsApp(phoneNumber: enquiry.mobileNumber);
            //                 },
            //                 icon: SvgPicture.asset(
            //                   AppAssets.whatsAppIcon,
            //                   height: 16,
            //                   width: 16,
            //                 ),
            //               ),
            //               horizontalSpacing(),
            //               if (_routeAuthorizationModel.isAction) ...[
            //                 if (!closedStatuses.contains(
            //                   enquiry.finalStage.toLowerCase(),
            //                 )) ...[
            //                   CustomIconButton.edit(
            //                     onPressed: () {
            //                       goRouter.pushNamed(
            //                         AppRoutes.addEnquiry,
            //                         queryParameters: {
            //                           "enquiry": Uri.encodeQueryComponent(
            //                             EncryptionManager.encryptData(
            //                               jsonEncode(enquiry.toJson()),
            //                             ),
            //                           ),
            //                           'index': index.toString(),
            //                         },
            //                       );
            //                     },
            //                   ),
            //                   horizontalSpacing(),
            //                 ],
            //                 CustomIconButton.delete(
            //                   isDisabled:
            //                       (enquiry.nextFollowUpDate != null ||
            //                           [
            //                             'booking done',
            //                             'cancelled',
            //                             'lost',
            //                           ].contains(
            //                             enquiry.finalStage.toLowerCase(),
            //                           )),
            //                   onPressed: () {
            //                     _showPopupToDeleteEnquiry(
            //                       context: context,
            //                       enquiryModel: enquiry,
            //                       index: index,
            //                     );
            //                   },
            //                 ),
            //               ],
            //             ],
            //           ),
            //           buildRowTitleValue(
            //             title: "Enquiry Code  ",
            //             value: enquiry.systemGeneratedCode,
            //           ),
            //           buildRowTitleValue(
            //             title: "Mobile Number",
            //             value: enquiry.mobileNumber,
            //             customValueWidget: CustomClickToContactText(
            //               value: enquiry.mobileNumber,
            //             ),
            //           ),
            //           buildRowTitleValue(
            //             title: "Enquiry Follow Up Days",
            //             value: getFollowUpStatus(enquiry.nextFollowUpDate),
            //             singleLine: false,
            //           ),
            //           buildRowTitleValue(
            //             title: "Next Follow-Up Date",
            //             value:
            //                 enquiry.nextFollowUpDate != null
            //                     ? formatDateTimeAsDDMMMYYYY(
            //                       enquiry.nextFollowUpDate!,
            //                     )
            //                     : "-",
            //             singleLine: false,
            //           ),
            //           buildRowTitleValue(
            //             title: "Requirement",
            //             value: enquiry.requirement,
            //             singleLine: false,
            //           ),
            //           if (enquiry.finalStage.isNotEmpty)
            //             buildRowTitleValue(
            //               title: "Stage",
            //               value: enquiry.finalStage,
            //               customValueWidget: statusWidget(enquiry.finalStage),
            //             ),
            //         ],
            //       ),
            //     );
            //   },
            // );
          },
        ),
      ),
    );
  }
}
