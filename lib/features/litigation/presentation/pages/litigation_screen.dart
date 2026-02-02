import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/features/litigation/presentation/cubit/litigation_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LitigationScreen extends StatefulWidget {
  const LitigationScreen({super.key});

  @override
  State<LitigationScreen> createState() => _LitigationScreenState();
}

class _LitigationScreenState extends State<LitigationScreen> {
  //CUBIT
  late LitigationCubit _litigationCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.litigation] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _litigationCubit.getLitigationList(context: context, pageNumber: 1);
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_litigationCubit.state.isLoading ?? false) &&
          _litigationCubit.state.litigationList.length <
              _litigationCubit.state.litigationTotalRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _litigationCubit.getLitigationList(
            context: context,
            pageNumber: _litigationCubit.state.litigationCurrentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Litigation Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addLitigation);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _litigationCubit.exportExcelPdf(context, value);
        },
        onProjectChangeCallback: (value) {
          _litigationCubit.getLitigationList(context: context, pageNumber: 1);
        },
        onSearchSubmit: (value) {
          // _litigationCubit.searchShift(value, context);
        },
      ),
      body: BlocBuilder<LitigationCubit, LitigationState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.litigationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.litigationList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.litigationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.litigationList.length) {
                return state.litigationList.length <
                        state.litigationTotalRecords
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var litigation = state.litigationList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewLitigation,
                                queryParameters: {
                                  "litigation": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(litigation.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                litigation.title,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        if (!litigation.isDelete)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addLitigation,
                                    queryParameters: {
                                      "litigation": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(litigation.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              CustomIconButton.delete(onPressed: () {}),
                            ],
                          ),
                      ],
                    ),
                    verticalSpacing(height: 10),
                    buildRowTitleValue(
                      title: "Case Number",
                      value: litigation.caseNumber,
                    ),
                    buildRowTitleValue(
                      title: "Status",
                      value: litigation.status,
                    ),
                    buildRowTitleValue(
                      title: "Case Type",
                      value: litigation.caseType,
                    ),
                    buildRowTitleValue(
                      title: "Project",
                      value: litigation.projectName,
                    ),
                    buildRowTitleValue(
                      title: "Date Off Filling",
                      value: formatDateTimeAsDDMMMYYYY(
                        litigation.dateOfFilling!,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Next Hearing Date",
                      value:
                          litigation.hearingDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                litigation.hearingDate!,
                              )
                              : '-',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
