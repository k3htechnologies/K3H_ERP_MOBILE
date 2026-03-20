import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_closure.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_state.dart';
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
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LitigationViewScreen extends StatefulWidget {
  final LitigationModel litigationModel;
  final int index;

  const LitigationViewScreen({
    super.key,
    required this.litigationModel,
    required this.index,
  });

  @override
  State<LitigationViewScreen> createState() => _LitigationViewScreenState();
}

class _LitigationViewScreenState extends State<LitigationViewScreen>
    with TickerProviderStateMixin {
  /// ---------------- CUBIT ----------------
  late LitigationCubit _litigationCubit;

  /// ---------------- TAB CONTROLLER ----------------
  late TabController _tabController;

  /// ---------------- SCROLL CONTROLLERS ----------------
  late ScrollController _hearingScrollController;
  late ScrollController _documentScrollController;

  /// ---------------- DOCUMENT FORM CONTROLLERS ----------------
  late TextEditingController _documentNameC;

  /// Multi file picker model for document upload/update
  MultiFilePickerModel litigationDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  /// Debounce to prevent multiple pagination API calls
  Timer? _hearingDebounce;
  Timer? _documentDebounce;

  /// Common form key used in dialogs
  final _formKey = GlobalKey<FormState>();
  final _formKeyDocument = GlobalKey<FormState>();

  /// ---------------- CLOSURE FORM STATE ----------------
  DateTime? closureDate;
  late TextEditingController _remarkC;
  late TextEditingController _conclusionC;

  /// File picker model for closure attachments
  MultiFilePickerModel closureFiles = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();

    _litigationCubit = context.read<LitigationCubit>();
    _documentNameC = TextEditingController();
    _remarkC = TextEditingController();
    _conclusionC = TextEditingController();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    _onScroll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hearingScrollController.dispose();
    _documentScrollController.dispose();
    _remarkC.dispose();
    _conclusionC.dispose();
    _documentDebounce?.cancel();
    _hearingDebounce?.cancel();
    super.dispose();
  }

  // TAB CHANGE HANDLER
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _litigationCubit.changeTab(_tabController.index);

      switch (_tabController.index) {
        case 1:
          _litigationCubit.getLitigationHearingList(
            context: context,
            pageNumber: 1,
            litigationId: widget.litigationModel.litigationId,
          );
          break;

        case 2:
          _litigationCubit.getLitigationDocumentList(
            context: context,
            pageNumber: 1,
            litigationId: widget.litigationModel.litigationId,
          );
          break;
      }
    }
  }

  // PAGINATION
  void _onScroll() {
    _onHearingScroll();
    _onDocumentScroll();
  }

  // HEARING PAGINATION
  void _onHearingScroll() {
    _hearingScrollController = ScrollController();
    _hearingScrollController.addListener(() {
      if (_hearingScrollController.position.pixels >=
              _hearingScrollController.position.maxScrollExtent - 100 &&
          !(_litigationCubit.state.isLoading ?? false) &&
          _litigationCubit.state.litigationHearingList.length <
              _litigationCubit.state.hearingTotalRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_hearingDebounce?.isActive ?? false) _hearingDebounce?.cancel();
        _hearingDebounce = Timer(const Duration(milliseconds: 300), () {
          _litigationCubit.getLitigationHearingList(
            context: context,
            pageNumber: _litigationCubit.state.hearingCurrentPage + 1,
            litigationId: widget.litigationModel.litigationId,
          );
        });
      }
    });
  }

  // DOCUMENT PAGINATION
  void _onDocumentScroll() {
    _documentScrollController = ScrollController();
    _documentScrollController.addListener(() {
      if (_documentScrollController.position.pixels >=
              _documentScrollController.position.maxScrollExtent - 100 &&
          !(_litigationCubit.state.isLoading ?? false) &&
          _litigationCubit.state.litigationDocumentList.length <
              _litigationCubit.state.documentTotalRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_documentDebounce?.isActive ?? false) _documentDebounce?.cancel();
        _documentDebounce = Timer(const Duration(milliseconds: 300), () {
          _litigationCubit.getLitigationDocumentList(
            context: context,
            pageNumber: _litigationCubit.state.documentCurrentPage + 1,
            litigationId: widget.litigationModel.litigationId,
          );
        });
      }
    });
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
                  _buildOverviewTab(),
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
  Widget _buildOverviewTab() {
    return BlocBuilder<LitigationCubit, LitigationState>(
      builder: (context, state) {
        final litigation = state.litigationList[widget.index];

        final status = litigation.status.toLowerCase();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                /// ================= CASE DETAILS =================
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
                            title: "Case / Petiton / Dispute Number",
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
                    ],
                  ),
                ),

                /// ================= COURT DETAILS =================
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

                /// ================= PARTIES DETAILS =================
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
                            title: "Defendant / Opposite Party / Respondent",
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

                /// ================= CLOSURE LIST =================
                if (litigation.litigationClosureData.isNotEmpty)
                  _buildClosureCardList(),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Case Brief / Petition / Suit",
                        style: AppTextStyle.ts16SB(),
                      ),
                      Text(litigation.caseBrief, style: AppTextStyle.ts14M()),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Case Remarks / Comments",
                        style: AppTextStyle.ts16SB(),
                      ),
                      Text(litigation.remark, style: AppTextStyle.ts14M()),
                    ],
                  ),
                ),

                /// ================= ACTION DETAILS =================
                actionCardWidget(
                  createdBy: litigation.createdBy,
                  createdDate: litigation.createdDate,
                  modifiedBy: litigation.modifiedBy,
                  modifiedDate: litigation.modifiedDate,
                ),

                /// ================= CLOSE / REOPEN BUTTON =================
                CustomButton(
                  text: status == 'closed' ? "Reopen" : "Close Case",
                  onPressed: () async {
                    if (status == 'open') {
                      _showClosurePopup();
                    } else if (status == 'closed') {
                      _showPopupToReopenLitigation(context);
                    } else if (status == 'reopen') {
                      _showClosurePopup();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BUILD CLOSURE LIST
  Widget _buildClosureCardList() {
    return BlocBuilder<LitigationCubit, LitigationState>(
      builder: (context, state) {
        // get the current litigation from state
        final litigation = state.litigationList[widget.index];
        final closureList = litigation.litigationClosureData;
        return Container(
          padding: EdgeInsets.all(16),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Closure Details", style: AppTextStyle.ts16SB()),
              SizedBox(height: 10),

              ...closureList.asMap().entries.map((entry) {
                final index = entry.key;
                final closure = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildClosureCard(closure, index, litigation.status),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // BUILD CLOSURE CARD
  Widget _buildClosureCard(
    LitigationClosureModel closure,
    int index,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primary, width: .3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                  text: "Closure Date : ",
                  children: [
                    TextSpan(
                      style: AppTextStyle.ts14M(color: AppColor.black),
                      text: formatDateTimeAsDDMMMYYYY(closure.closureDate),
                    ),
                  ],
                ),
              ),
              // only latest litigation can be edit
              if (status.toLowerCase() != 'reopen' && index == 0)
                CustomIconButton.edit(
                  onPressed: () {
                    _prefillClosureDate(closure: closure);
                    _showClosurePopup(closure: closure, index: index);
                  },
                ),
            ],
          ),

          Row(
            children: [
              buildColumnTitleValue(title: "Remark", value: closure.remark),
            ],
          ),

          Row(
            children: [
              buildColumnTitleValue(
                title: "Conclusion",
                value: closure.conclusion,
              ),
            ],
          ),
          Row(
            children: [
              CustomButton.documentOutline(
                onPressed: () {
                  if (closure.closureAttachementUrl.isNotEmpty) {
                    showFilePreviewDialog(
                      context,
                      closure.closureAttachementUrl.split(","),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== HEARING TAB =====================
  Widget _buildHearingTab() {
    return BlocBuilder<LitigationCubit, LitigationState>(
      builder: (context, state) {
        if (state.isLoading! && state.litigationHearingList.isEmpty) {
          return Center(child: loader());
        }

        final litigation = state.litigationList[widget.index];

        final status = litigation.status.toLowerCase();

        if (state.litigationHearingList.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hearing History', style: AppTextStyle.ts16SB()),
                    if (status != "closed")
                      CustomButton(
                        backgroundColor: AppColor.lightBlue,
                        leading: Icon(Icons.add),
                        textColor: AppColor.primary,
                        text: 'Add Hearing',
                        padding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        onPressed: () async {
                          await goRouter.pushNamed(
                            AppRoutes.addLitigationHearing,
                            queryParameters: {
                              'litigationId':
                                  widget.litigationModel.litigationId
                                      .toString(),
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
                Expanded(
                  child: Center(
                    child: noDataWidget(message: "No hearing history found"),
                  ),
                ),
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
                          ? Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }

                    final hearing = state.litigationHearingList[index];
                    final status = state.litigationList[widget.index].status;
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hearing.createdBy,
                                    style: AppTextStyle.ts14M(),
                                  ),
                                  Text(
                                    dateFormatterDDMMYYYYDAY(
                                      hearing.hearingDate,
                                    ),
                                    style: AppTextStyle.ts12SB(
                                      color: AppColor.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              //Only Lastest Hearing can be Update and Delete but make sure Api return data by date and Time
                              if (index == 0 &&
                                  status.toLowerCase() != 'closed')
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
                          verticalSpacing(height: 5),
                          Text(
                            hearing.remark,
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                          verticalSpacing(),
                          Row(
                            children: [
                              CustomButton.documentOutline(
                                onPressed: () {
                                  if (hearing
                                      .hearingAttachementUrl
                                      .isNotEmpty) {
                                    showFilePreviewDialog(
                                      context,
                                      hearing.hearingAttachementUrl.split(","),
                                    );
                                  }
                                },
                              ),
                            ],
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
        // Find the current litigation from state using its ID
        final litigation = state.litigationList[widget.index];

        final status = litigation.status.toLowerCase();

        if (state.isLoading! && state.litigationDocumentList.isEmpty) {
          return Center(child: loader());
        }

        if (state.litigationDocumentList.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              children: [
                if (status != "closed")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Uploaded Documents", style: AppTextStyle.ts16SB()),
                      CustomIconButton(
                        onPressed: () async {
                          await _showPopUpToAddUpdateDocument();
                          if (context.mounted) {
                            _litigationCubit.getLitigationDocumentList(
                              context: context,
                              pageNumber: 1,
                              litigationId: widget.litigationModel.litigationId,
                            );
                          }
                        },
                        backgroundColor: AppColor.primary,
                        icon: Icon(Icons.add, color: AppColor.white, size: 16),
                      ),
                    ],
                  ),
                Expanded(
                  child: Center(
                    child: noDataWidget(
                      message: "No Litigation Documents Data Found",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              if (status != "closed")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Uploaded Documents", style: AppTextStyle.ts16SB()),
                    CustomIconButton(
                      onPressed: () async {
                        await _showPopUpToAddUpdateDocument();
                        if (context.mounted) {
                          _litigationCubit.getLitigationDocumentList(
                            context: context,
                            pageNumber: 1,
                            litigationId: widget.litigationModel.litigationId,
                          );
                        }
                      },
                      backgroundColor: AppColor.primary,
                      icon: Icon(Icons.add, color: AppColor.white, size: 16),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  controller: _documentScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.litigationDocumentList.length + 1,
                  itemBuilder: (context, index) {
                    // Pagination loader
                    if (index == state.litigationDocumentList.length) {
                      return state.litigationDocumentList.length <
                              state.documentTotalRecords
                          ? Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }

                    final document = state.litigationDocumentList[index];

                    return _buildContainer(
                      litigationDocModel: document,
                      index: index,
                      status: litigation.status,
                      onViewTab: () {
                        if (document.documentUrl.isNotEmpty) {
                          showFilePreviewDialog(
                            context,
                            document.documentUrl.split(","),
                          );
                        }
                      },
                      onDeleteTab: () {
                        _showPopupToDeleteDocument(context, document, index);
                      },
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

  // BUILD COMMON CONTAINER
  Widget _buildContainer({
    required LitigationDocumentModel litigationDocModel,
    required int index,
    required String status,
    required VoidCallback onViewTab,
    required VoidCallback onDeleteTab,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.0),
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.0),
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
              border: Border(bottom: BorderSide(color: AppColor.lightBlue)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        litigationDocModel.documentName,
                        style: AppTextStyle.ts16M(color: AppColor.black),
                      ),
                    ),
                    CustomIconButton(
                      backgroundColor: AppColor.lightBlue,
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        size: 16,
                        color: AppColor.primary,
                      ),
                      onPressed: onViewTab,
                    ),
                    // Edit/Delete buttons only if litigation is not closed
                    if (status.toLowerCase() != 'closed')
                      Row(
                        children: [
                          horizontalSpacing(),
                          CustomIconButton.edit(
                            onPressed: () async {
                              _showPopUpToAddUpdateDocument(
                                documentModel: litigationDocModel,
                                index: index,
                              );
                            },
                          ),
                          horizontalSpacing(),
                          CustomIconButton.delete(onPressed: onDeleteTab),
                        ],
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildRowTitleValue(
                        title: "Document Count",
                        value:
                            (litigationDocModel.documentUrl)
                                .split(",")
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .length
                                .toString(),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Uploaded By",
                      value: litigationDocModel.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Uploaded Date",
                      value: formatDate(litigationDocModel.createdDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===================== TAB BAR =====================
  Widget _buildLitigationTabBar() {
    return ChipStyleTabBar(
      controller: _tabController,
      tabs: ["Overview", "Hearing", "Document"],
    );
  }

  // DELETE HEARING
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

  // DELETE DOCUMENT
  Future<void> _showPopupToDeleteDocument(
    BuildContext context,
    LitigationDocumentModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a litigation document?',
      'Deleting this litigation document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _litigationCubit.deleteLitigationDocument(index, obj, context);
    }
  }

  // PREFILL DOCUMENT DETAILS
  void _prefillDocumentDetails(LitigationDocumentModel documentModel) {
    _documentNameC.text = documentModel.documentName;
    litigationDocument.fileBytesList = [];
    litigationDocument.deletedFileList = "";
    litigationDocument.fileNameList =
        documentModel.documentUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  // ADD/UPDATE DOCUMENT
  Future<void> _showPopUpToAddUpdateDocument({
    LitigationDocumentModel? documentModel,
    int? index,
  }) async {
    if (documentModel != null) {
      _prefillDocumentDetails(documentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      documentModel != null
          ? 'Update Litigation Document'
          : 'Add Litigation Document',
      Form(
        key: _formKeyDocument,
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            children: [
              CustomTextField(
                title: "Document Name",
                hint: "Enter Document Name",
                textController: _documentNameC,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Document Name is required";
                  }
                  if (value.length < 3) {
                    return "Document Name must be at least 3 characters long";
                  }
                  return null;
                },
              ),
              CustomMultiFilePicker(
                title: "Files",
                initialFileList: litigationDocument.fileNameList,
                maxFiles: 5,
                onFilePickedCallback: (bytesList, fileNameList) {
                  litigationDocument.fileNameList = fileNameList;
                  litigationDocument.fileBytesList = bytesList;
                },
                isRequired: true,
                onFileDeleteCallback: (fileBytesList, fileNameList, deleted) {
                  litigationDocument.fileBytesList = fileBytesList;
                  litigationDocument.fileNameList = fileNameList;
                  litigationDocument.deletedFileList = deleted;
                  print("delete: ${litigationDocument.deletedFileList}");
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "File is required.";
                  }
                  return null;
                },
              ),
              Spacer(),
              Container(
                height: 70,
                padding: EdgeInsets.all(16),
                child: CustomButton(
                  text:
                      documentModel != null
                          ? "Update Document"
                          : "Add Document",
                  onPressed: () {
                    _submitForm(documentModel: documentModel, index: index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _clearDialogueToAddUpdateDocument();
  }

  // SUBMIT DOCUMENT
  void _submitForm({LitigationDocumentModel? documentModel, int? index}) {
    if (!_formKeyDocument.currentState!.validate()) {
      return;
    }
    var body = {
      "LitigationDocumentId":
          documentModel == null
              ? 0.toString()
              : documentModel.litigationDocumentId.toString(),
      if (documentModel != null) "Uniquekey": documentModel.uniquekey,
      "ProjectId": getProject().projectId.toString(),
      "LitigationId": widget.litigationModel.litigationId.toString(),
      "DocumentName": _documentNameC.text.trim(),
      "RemoveDocumentURL": litigationDocument.deletedFileList,
    };
    if (documentModel != null) {
      //Update
      _litigationCubit.updateLitigationDocument(
        context: context,
        index: index!,
        body: body,
        litigationDocument: litigationDocument,
      );
    } else {
      _litigationCubit.addLitigationDocument(
        context: context,
        body: body,
        litigationDocument: litigationDocument,
      );
    }
  }

  // CLEAR DOCUMENT FORM
  void _clearDialogueToAddUpdateDocument() {
    _documentNameC.clear();
    litigationDocument.fileBytesList.clear();
    litigationDocument.fileNameList.clear();
    litigationDocument.deletedFileList = "";
  }

  // PREFILL CLOSURE DATE
  Future<void> _prefillClosureDate({LitigationClosureModel? closure}) async {
    if (closure != null) {
      closureDate = closure.closureDate;
      _remarkC.text = closure.remark;
      _conclusionC.text = closure.conclusion;

      closureFiles.fileBytesList = [];
      closureFiles.deletedFileList = "";
      closureFiles.fileNameList =
          closure.closureAttachementUrl
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    }
  }

  // ADD/UPDATE CLOSURE
  Future<void> _showClosurePopup({
    LitigationClosureModel? closure,
    int? index,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Close Case", style: AppTextStyle.ts16SB()),
                    ),
                    verticalSpacing(height: 16),

                    // Scrollable Form Fields
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Closure Date
                            CustomDatePicker(
                              title: "Closure Date",
                              isRequired: true,
                              initialDate: closureDate,
                              startDate: DateTime.now(),
                              setValue: (value) => closureDate = value,
                              validator: (value) {
                                if (value == null) {
                                  return "Closure Date is required";
                                }
                                return null;
                              },
                            ),

                            /// FILES
                            CustomMultiFilePicker(
                              title: "Files",
                              isRequired: true,
                              maxFiles: 5,
                              initialFileList: closureFiles.fileNameList,
                              onFilePickedCallback: (bytes, names) {
                                closureFiles.fileBytesList = bytes;
                                closureFiles.fileNameList = names;
                              },
                              onFileDeleteCallback: (bytes, names, deleted) {
                                closureFiles.fileBytesList = bytes;
                                closureFiles.fileNameList = names;
                                closureFiles.deletedFileList = deleted;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "File is required";
                                }
                                return null;
                              },
                            ),

                            /// Remark
                            CustomTextField(
                              title: "Remarks",
                              isRequired: true,
                              hint: "Enter remarks",
                              textController: _remarkC,
                              maxLines: 3,
                              minLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Remarks is required";
                                }
                                return null;
                              },
                            ),

                            /// Conclusion
                            CustomTextField(
                              title: "Conclusion",
                              hint: "Enter conclusion",
                              textController: _conclusionC,
                              isRequired: true,
                              maxLines: 3,
                              minLines: 3,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? "Conclusion required"
                                          : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    verticalSpacing(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton.cancelOutline(
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: CustomButton(
                            text: closure != null ? "Update" : "Close",
                            onPressed: () => _submitClosure(index: index),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _clearClosureForm();
  }

  // SUBMIT CLOSURE
  void _submitClosure({int? index}) {
    final state = context.read<LitigationCubit>().state;

    if (!_formKey.currentState!.validate()) return;

    final isEdit = index != null;

    var body = {
      "LitigationClosureId":
          isEdit
              ? state
                  .litigationList[widget.index]
                  .litigationClosureData[index]
                  .litigationClosureId
                  .toString()
              : "0",
      if (isEdit)
        "Uniquekey":
            state
                .litigationList[widget.index]
                .litigationClosureData[index]
                .uniquekey,
      "ProjectId": getProject().projectId.toString(),
      "LitigationId": widget.litigationModel.litigationId.toString(),
      "ClosureDate": closureDate!.toIso8601String(),
      "Remark": _remarkC.text.trim(),
      "Conclusion": _conclusionC.text.trim(),
    };

    if (isEdit) {
      _litigationCubit.updateLitigationClosure(
        context: context,
        closureIndex: index,
        body: body,
        litigationClosureDocuments: closureFiles,
        litigationIndex: widget.index,
      );
    } else {
      _litigationCubit.addLitigationClosure(
        context: context,
        body: body,
        litigationClosureDocuments: closureFiles,
        litigationIndex: widget.index,
      );
    }
  }

  /// CLEAR CLOSURE FORM
  void _clearClosureForm() {
    _remarkC.clear();
    _conclusionC.clear();
    closureDate = null;
    closureFiles.fileBytesList.clear();
    closureFiles.fileNameList.clear();
    closureFiles.deletedFileList = "";
  }

  // REOPEN CONFIRMATION
  Future<void> _showPopupToReopenLitigation(BuildContext context) async {
    final shouldDelete = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Reopen Litigation',
      message: 'Are you sure you want to Reopen?',
      confirmText: "Reopen",
    );

    if (shouldDelete && context.mounted) {
      _litigationCubit.updateLitigationReopen(
        context: context,
        litigationId: widget.litigationModel.litigationId,
        projectId: getProject().projectId,
        uniqueKey: widget.litigationModel.uniquekey,
        litigationIndex: widget.index,
      );
    }
  }
}
