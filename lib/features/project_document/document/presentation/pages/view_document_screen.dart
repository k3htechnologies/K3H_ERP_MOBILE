import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';

class ViewDocumentScreen extends StatefulWidget {
  final int projectDocumentId;
  const ViewDocumentScreen({super.key, required this.projectDocumentId});

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  //CUBIT
  late DocumentCubit _documentCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _documentCubit = context.read<DocumentCubit>();
    _documentCubit.getProjectDocumentList(
      context: context,
      pageNumber: 1,
      projectDocumentId: widget.projectDocumentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
