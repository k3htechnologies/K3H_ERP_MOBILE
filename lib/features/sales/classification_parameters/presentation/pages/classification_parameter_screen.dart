import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/model/classification_paramerter.model.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/presentation/cubit/classification_parameters_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ClassificationParameterScreen extends StatefulWidget {
  const ClassificationParameterScreen({super.key});

  @override
  State<ClassificationParameterScreen> createState() =>
      _ClassificationParameterScreenState();
}

class _ClassificationParameterScreenState
    extends State<ClassificationParameterScreen> {
  // CUBIT
  late ClassificationParametersCubit _classificationParametersCubit;

  // AUTHORIZATION MODEL
  late AuthorizationModel _routhAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT SELECTION
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _classificationParametersCubit =
        context.read<ClassificationParametersCubit>();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .classificationParameter] ??
        AuthorizationModel();

    // SET PROJECT ID
    _project = getProject();
    _onScroll();
    // GET API CALL
    _classificationParametersCubit.getClassificationParametersList(
      context,
      1,
      _project.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_classificationParametersCubit.state.isLoading! &&
          _classificationParametersCubit
                  .state
                  .classificationParameterList
                  .length <
              _classificationParametersCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _classificationParametersCubit.getClassificationParametersList(
            context,
            _classificationParametersCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  // <---- DELETE CLASSIFICATION PARAMETER ---->
  Future<void> _showPopupToDeleteClassificationParameter(
    BuildContext context,
    ClassificationParameterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a classification parameter ?',
      'Deleting this classification parameter will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _classificationParametersCubit.deleteClassificationParameters(
        context: context,
        classificationParameterId: obj.classificationParameterId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        index: index,
        projectId: _project.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Classification Parameters",
        isMenuButton: true,
        authorization: _routhAuthorizationModel,
        onProjectChangeCallback: (value) {
          _project = value;
          _classificationParametersCubit.getClassificationParametersList(
            context,
            1,
            value.projectId,
          );
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please select a project");
            return;
          }
          if (_classificationParametersCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _classificationParametersCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: _routhAuthorizationModel.isAction,
            child: Container(
              width: 120,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: CustomButton(
                leading: Icon(Icons.add, color: AppColor.white, size: 18),
                text: "Add",
                onPressed: () async {
                  if (_project.projectId == 0) {
                    showErrorMessage(
                      context,
                      "Error",
                      "Please select a project",
                    );
                    return;
                  }
                  await goRouter.pushNamed(
                    AppRoutes.addClassificationParameter,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<
              ClassificationParametersCubit,
              ClassificationParametersState
            >(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.classificationParameterList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.classificationParameterList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No Classification Parameters Data Found",
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount:
                      _classificationParametersCubit
                          .state
                          .classificationParameterList
                          .length +
                      1,
                  itemBuilder: (context, int index) {
                    if (index == state.classificationParameterList.length) {
                      return state.classificationParameterList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var classificationParameter =
                        state.classificationParameterList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: commonCardDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "${classificationParameter.minBudget} Min Budget (In CR)",
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _routhAuthorizationModel.isAction,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomIconButton.edit(
                                      onPressed: () async {
                                        goRouter.pushNamed(
                                          AppRoutes.addClassificationParameter,
                                          queryParameters: {
                                            "classificationParameter":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(
                                                      classificationParameter
                                                          .toJson(),
                                                    ),
                                                  ),
                                                ),
                                            'index': index.toString(),
                                          },
                                        );
                                      },
                                    ),
                                    horizontalSpacing(),
                                    CustomIconButton.delete(
                                      onPressed: () {
                                        _showPopupToDeleteClassificationParameter(
                                          context,
                                          classificationParameter,
                                          state.currentPage,
                                          index,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          buildRowTitleValue(
                            title: "Possession Type",
                            value: classificationParameter.possessionType,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Requirement",
                            value: classificationParameter.requirement,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Requirement Type",
                            value: classificationParameter.requirementType,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Location",
                            value: classificationParameter.villageName,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Timeline",
                            value: classificationParameter.timeLine,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Created By",
                            value: classificationParameter.createdBy,
                          ),
                          buildRowTitleValue(
                            title: "Created Date",
                            value: formatDate(
                              classificationParameter.createdDate,
                            ),
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Modified By",
                            value:
                                classificationParameter.modifiedBy.isNotEmpty
                                    ? classificationParameter.modifiedBy
                                    : "-",
                          ),
                          buildRowTitleValue(
                            title: "Modified Date",
                            value:
                                classificationParameter.modifiedDate != null
                                    ? formatDate(
                                      classificationParameter.modifiedDate,
                                    )
                                    : "-",
                            singleLine: false,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
