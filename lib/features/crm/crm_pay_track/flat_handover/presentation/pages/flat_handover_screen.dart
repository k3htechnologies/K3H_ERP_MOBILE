import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FlatHandoverScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const FlatHandoverScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<FlatHandoverScreen> createState() => _FlatHandoverScreenState();
}

class _FlatHandoverScreenState extends State<FlatHandoverScreen> {
  late FilesCubit _filesCubit;

  @override
  void initState() {
    super.initState();
    _filesCubit = context.read<FilesCubit>();
    _filesCubit.getFilesList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      fileType: "HANDOVER",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: "Add",
                onPressed: () {
                  goRouter.pushNamed(AppRoutes.addFlatHandoverDocuments);
                },
              ),
            ],
          ),
          verticalSpacing(),
          BlocBuilder<FilesCubit, FilesState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) &&
                  state.payTrackBookingFileList.isEmpty) {
                return Expanded(
                  child: Center(child: noDataWidget(iconSize: 180.0)),
                );
              }
              return ListView.builder(
                itemCount: state.payTrackBookingFileList.length,
                itemBuilder: (context, index) {
                  return Container();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
