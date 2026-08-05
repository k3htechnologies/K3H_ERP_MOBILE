import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FilesScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? bookingApprovalStatus;
  const FilesScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.bookingApprovalStatus,
  });

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late FilesCubit _filesCubit;
  late AuthorizationModel _filesAuthorization;
  late TextEditingController _searchTextC;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filesAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.files] ??
        AuthorizationModel();
    _filesCubit = context.read<FilesCubit>();
    _searchTextC = TextEditingController();
    _filesCubit.getFilesList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      fileType: "FILES",
    );
    _onScroll();
  }

  Future<void> _showPopupToDeleteFiles(
    BuildContext context,
    PayTrackBookingFilesModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a File?',
      'Deleting this file will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _filesCubit.deletePayTrackBookingFilesBookingFile(index, obj, context);
    }
  }

  @override
  void dispose() {
    _searchTextC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_filesCubit.state.isLoading ?? false) &&
          _filesCubit.state.payTrackBookingFileList.length <
              _filesCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _filesCubit.getFilesList(
            context: context,
            pageNumber: _filesCubit.state.currentPage + 1,
            projectId: widget.projectId,
            bookingId: widget.bookingId,
            fileType: "FILES",
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesCubit, FilesState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: loader());
        }
        final bool isBookingCancelledOrRefund =
            widget.bookingApprovalStatus?.toUpperCase() == "CANCEL" ||
            widget.bookingApprovalStatus?.toUpperCase() == "REFUND";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            if (_filesAuthorization.isAction && !isBookingCancelledOrRefund)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomButton(
                      text: "Add",
                      onPressed: () {
                        goRouter.pushNamed(
                          AppRoutes.addFiles,
                          extra: {
                            'bookingId': widget.bookingId,
                            'projectId': widget.projectId,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            verticalSpacing(),
            Expanded(
              child: BlocBuilder<FilesCubit, FilesState>(
                builder: (context, state) {
                  if (state.isLoading == true &&
                      state.payTrackBookingFileList.isEmpty) {
                    return Center(child: loader());
                  }

                  if (state.payTrackBookingFileList.isEmpty) {
                    return Center(
                      child: noDataWidget(
                        message: "No Files Found",
                        iconSize: 180,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount:
                        state.payTrackBookingFileList.length +
                        (state.payTrackBookingFileList.length <
                                state.totalNumberOfRecord
                            ? 1
                            : 0),
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      if (index == state.payTrackBookingFileList.length) {
                        return state.payTrackBookingFileList.length <
                                state.totalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final file = state.payTrackBookingFileList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_filesAuthorization.isAction)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () async {
                                      await goRouter.pushNamed(
                                        AppRoutes.addFiles,
                                        extra: {
                                          'bookingId': widget.bookingId,
                                          'projectId': widget.projectId,
                                          'file': file,
                                          'index': index,
                                          'isEdit': true,
                                        },
                                      );
                                    },
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    onPressed: () {
                                      _showPopupToDeleteFiles(
                                        context,
                                        file,
                                        state.currentPage,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ),

                            buildRowTitleValue(
                              title: "File Name",
                              value: file.payTrackBookingFilesUrl,
                              customValueWidget: DocumentPreviewText(
                                title: file.fileName,
                                text: file.fileName,
                                fileUrl: file.payTrackBookingFilesUrl,
                              ),
                            ),
                            buildRowTitleValue(
                              title: "Last Modified By",
                              value: file.createdBy,
                            ),
                            buildRowTitleValue(
                              title: "Last Modified Date",
                              value: formatDate(file.createdDate),
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
        );
      },
    );
  }

  Widget buildRowTitleValueNormal({
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(title, style: AppTextStyle.ts14R(color: Colors.grey)),
        ),
        const Text(":", style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(width: 20),
        Expanded(child: Text(value, style: AppTextStyle.ts14M())),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchWidget(
              hintText: "Search by File Name",
              onSubmit: (value) {
                _filesCubit.resetSearch();
                _filesCubit.searchFiles(
                  context,
                  widget.projectId,
                  widget.bookingId,
                  value,
                  "FILES",
                );
              },
              textController: _searchTextC,
            ),
          ),
        ],
      ),
    );
  }
}
