import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LitigationViewScreen extends StatefulWidget {
  final LitigationModel litigationModel;

  const LitigationViewScreen({super.key, required this.litigationModel});

  @override
  State<LitigationViewScreen> createState() => _LitigationViewScreenState();
}

class _LitigationViewScreenState extends State<LitigationViewScreen>
    with TickerProviderStateMixin {
  late LitigationCubit _litigationCubit;
  late TabController _tabController;

  // 🔹 Separate scroll controllers
  late ScrollController _hearingScrollController;
  late ScrollController _documentScrollController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _litigationCubit = context.read<LitigationCubit>();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    _hearingScrollController =
        ScrollController()..addListener(_onHearingScroll);

    _documentScrollController =
        ScrollController()..addListener(_onDocumentScroll);

    _litigationCubit.getLitigationList(context: context, pageNumber: 1);
  }

  // 🔹 TAB CHANGE HANDLER
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _litigationCubit.changeTab(_tabController.index);

      switch (_tabController.index) {
        case 1:
          _litigationCubit.clearHearingData();
          _litigationCubit.getLitigationHearingList(
            context: context,
            pageNumber: 1,
            litigationId: widget.litigationModel.litigationId,
          );
          break;

        case 2:
          _litigationCubit.clearDocumentData();
          _litigationCubit.getLitigationDocumentList(
            context: context,
            pageNumber: 1,
            litigationId: widget.litigationModel.litigationId,
          );
          break;
      }
    }
  }

  // 🔹 HEARING PAGINATION
  void _onHearingScroll() {
    if (_hearingScrollController.position.pixels >=
            _hearingScrollController.position.maxScrollExtent - 100 &&
        !_litigationCubit.state.isLoading! &&
        _litigationCubit.state.litigationHearingList.length <
            _litigationCubit.state.hearingTotalRecords) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _litigationCubit.getLitigationHearingList(
          context: context,
          pageNumber: _litigationCubit.state.hearingCurrentPage + 1,
          litigationId: widget.litigationModel.litigationId,
        );
      });
    }
  }

  // 🔹 DOCUMENT PAGINATION (placeholder)
  void _onDocumentScroll() {
    // Add document pagination later
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hearingScrollController.dispose();
    _documentScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Litigation",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildLitigationTabBar(),
            verticalSpacing(),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _buildOverviewTab(widget.litigationModel),
                  _buildHearingTab(),
                  _buildDocumentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== OVERVIEW TAB =====================
  Widget _buildOverviewTab(LitigationModel litigation) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Case Details", style: AppTextStyle.ts16SB()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Case Title",
                        value: litigation.title,
                      ),
                      buildColumnTitleValue(
                        title: "Case Number",
                        value: litigation.caseNumber,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Case Type",
                        value: litigation.caseType,
                      ),
                      buildColumnTitleValue(
                        title: "Case Status",
                        value: litigation.status,
                        valueTextStyle: AppTextStyle.ts14B(
                          color:
                              (litigation.status.toLowerCase() == 'open' ||
                                      litigation.status.toLowerCase() ==
                                          'reopen')
                                  ? AppColor.green
                                  : AppColor.red,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Project",
                        value: litigation.projectName,
                      ),
                      buildColumnTitleValue(
                        title: "Date Of Filling",
                        value: formatDateTimeAsDDMMMYYYY(
                          litigation.dateOfFilling,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Case Brief",
                        value: litigation.caseBrief,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Remark",
                        value: litigation.remark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Court Details", style: AppTextStyle.ts16SB()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Court Title",
                        value: litigation.courtType,
                      ),
                      buildColumnTitleValue(
                        title: "Court Name",
                        value: litigation.courtName,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Court Location",
                        value: litigation.courtLocation,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Parties Details", style: AppTextStyle.ts16SB()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Plaintiff",
                        value: litigation.plantiff,
                      ),
                      buildColumnTitleValue(
                        title: "Assigned Representative",
                        value: litigation.assignedRepresentative,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Defendant",
                        value: litigation.defendant,
                      ),
                      buildColumnTitleValue(
                        title: "Opposite Representative",
                        value: litigation.opposingRepresentative,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Action Details", style: AppTextStyle.ts16SB()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Created By",
                        value: litigation.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          litigation.createdDate,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Modified By",
                        value: litigation.modifiedBy,
                      ),
                      buildColumnTitleValue(
                        title: "Modified Date",
                        value:
                            litigation.modifiedDate != null
                                ? formatDateTimeAsDDMMMYYYY(
                                  litigation.modifiedDate!,
                                )
                                : '-',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== HEARING TAB =====================
  Widget _buildHearingTab() {
    return BlocBuilder<LitigationCubit, LitigationState>(
      builder: (context, state) {
        if (state.isLoading! && state.litigationHearingList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.litigationHearingList.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hearing History', style: AppTextStyle.ts16SB()),
                    CustomButton(
                      backgroundColor: AppColor.lightBlue,
                      leading: Icon(Icons.add),
                      textColor: AppColor.primary,
                      text: 'Add Hearing',
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      onPressed: () async {
                        await goRouter.pushNamed(
                          AppRoutes.addLitigationHearing,
                          queryParameters: {
                            'litigationId':
                                widget.litigationModel.litigationId.toString(),
                          },
                        );

                        if (context.mounted) {
                          _litigationCubit.getLitigationHearingList(
                            context: context,
                            pageNumber: 1,
                            litigationId: widget.litigationModel.litigationId,
                          );
                        }
                      },
                    ),
                  ],
                ),
                Expanded(child: Center(child: noDataWidget())),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hearing History', style: AppTextStyle.ts16SB()),
                  CustomButton(
                    backgroundColor: AppColor.lightBlue,
                    leading: Icon(Icons.add),
                    textColor: AppColor.primary,
                    text: 'Add Hearing',
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    onPressed: () async {
                      await goRouter.pushNamed(
                        AppRoutes.addLitigationHearing,
                        queryParameters: {
                          'litigationId':
                              widget.litigationModel.litigationId.toString(),
                        },
                      );
                      if (context.mounted) {
                        _litigationCubit.getLitigationHearingList(
                          context: context,
                          pageNumber: 1,
                          litigationId: widget.litigationModel.litigationId,
                        );
                      }
                    },
                  ),
                ],
              ),
              verticalSpacing(height: 15),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: _hearingScrollController,
                  itemCount: state.litigationHearingList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.litigationHearingList.length) {
                      return state.litigationHearingList.length <
                              state.hearingTotalRecords
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }

                    final hearing = state.litigationHearingList[index];

                    return Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormatterDDMMYYYYDAY(
                                  hearing.modifiedDate ?? hearing.createdDate,
                                ),
                                style: AppTextStyle.ts14M(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              //Only Lastest Hearing can be Update and Delete but make sure Api return data by date and Time
                              if (index == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomIconButton.edit(
                                      onPressed: () async {
                                        await goRouter.pushNamed(
                                          AppRoutes.addLitigationHearing,
                                          queryParameters: {
                                            "litigationHearing":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(
                                                      hearing.toJson(),
                                                    ),
                                                  ),
                                                ),
                                            'index': index.toString(),
                                            'litigationId':
                                                widget
                                                    .litigationModel
                                                    .litigationId
                                                    .toString(),
                                          },
                                        );
                                      },
                                    ),
                                    horizontalSpacing(width: 8),
                                    CustomIconButton.delete(
                                      onPressed: () {
                                        _showPopupToDeleteHearing(
                                          context,
                                          hearing,
                                          index,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          verticalSpacing(),

                          Text(
                            hearing.remark,
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                          verticalSpacing(),
                          SizedBox(
                            width: 120,
                            child: CustomButton(
                              trailing: Icon(Icons.remove_red_eye_outlined),
                              text: "Document",
                              titleTextStyle: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),

                              backgroundColor: AppColor.white,
                              borderColor: AppColor.primary,
                              onPressed: () {
                                if (hearing.hearingAttachementUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    hearing.hearingAttachementUrl.split(","),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== DOCUMENT TAB =====================
  Widget _buildDocumentTab() {
    return BlocBuilder<LitigationCubit, LitigationState>(
      builder: (context, state) {
        if (state.isLoading! && state.litigationDocumentList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.litigationDocumentList.isEmpty) {
          return noDataWidget();
        }

        return ListView.builder(
          controller: _documentScrollController,
          itemCount: state.litigationDocumentList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.litigationDocumentList.length) {
              return state.litigationDocumentList.length <
                      state.documentTotalRecords
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final hearing = state.litigationDocumentList[index];

            return ListTile(
              title: Text(hearing.documentName),
              subtitle: Text(hearing.documentUrl.toString()),
            );
          },
        );
      },
    );
  }

  // ===================== TAB BAR =====================
  Widget _buildLitigationTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Hearing"),
              Tab(text: "Document"),
            ],
          ),
        ),
      ),
    );
  }

  // DELETE DOCUMENT FROM CATEGORY
  Future<void> _showPopupToDeleteHearing(
    BuildContext context,
    LitigationHearingModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a hearing?',
      'Deleting this hearing will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _litigationCubit.deleteLitigationHearing(
        index,
        obj,
        widget.litigationModel.litigationId,
        context,
      );
    }
  }
}
