import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import 'app_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_updateStatus);
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  int _locationToIndex(String location) {
    return switch (location) {
      String s when s.startsWith(AppRoutes.dashboard) => 0,
      String s when s.startsWith(AppRoutes.transactions) => 1,
      String s when s.startsWith(AppRoutes.reports) => 2,
      String s when s.startsWith(AppRoutes.settings) => 3,
      _ => 0,
    };
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
      case 1:
        context.go(AppRoutes.transactions);
      case 2:
        context.go(AppRoutes.reports);
      case 3:
        context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isOffline ? 28 : 0,
            color: Colors.orange.shade800,
            child: _isOffline
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Sem conexão',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: currentIndex < 2
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.addTransaction),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTap(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.dashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: AppStrings.transactions,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: AppStrings.reports,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: AppStrings.settings,
            ),
          ],
        ),
      ),
    );
  }
}
