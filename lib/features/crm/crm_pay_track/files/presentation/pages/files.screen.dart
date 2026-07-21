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
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FilesScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const FilesScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late FilesCubit _filesCubit;
  late AuthorizationModel _filesAuthorization;

  @override
  void initState() {
    super.initState();
    _filesAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.files] ??
        AuthorizationModel();
    _filesCubit = context.read<FilesCubit>();
    _filesCubit.getFilesList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      fileType: "FILES",
    );
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_filesAuthorization.isAction)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
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
              ],
            ),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<FilesCubit, FilesState>(
              builder: (context, state) {
                if (state.isLoading == true) {
                  return const Center(child: CircularProgressIndicator());
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
                  itemCount: state.payTrackBookingFileList.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final file = state.payTrackBookingFileList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            title: "Last Created By",
                            value: file.createdBy,
                          ),
                          buildRowTitleValue(
                            title: "Last Created Date",
                            value: formatDateTimeAsDDMMMYYYY(file.createdDate),
                          ),
                          if (!_filesAuthorization.isAction)
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
}
