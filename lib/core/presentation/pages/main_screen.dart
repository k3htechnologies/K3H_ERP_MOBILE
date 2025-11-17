import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer.dart';

final GlobalKey<ScaffoldState> mobileScreenGlobalScaffoldKey =
GlobalKey<ScaffoldState>();

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool drawerExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mobileScreenGlobalScaffoldKey,
      body: BlocBuilder<MainScreenCubit, Key>(
        builder: (context, key) {
          return Row(
            children: [
              SizedBox.shrink(),
              Expanded(child: KeyedSubtree(key: key, child: widget.child)),
            ],
          );
        },
      ),
      drawer:sideDrawerWeb(context)
    );
  }
}