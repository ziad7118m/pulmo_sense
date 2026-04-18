import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/local_admin_page_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_dashboard_snapshot.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_admin_page_view_data.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/pages/admin_users_page.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_home_tile.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_insight_panel.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LocalAdminPage extends StatefulWidget {
  const LocalAdminPage({super.key});

  @override
  State<LocalAdminPage> createState() => _LocalAdminPageState();
}

class _LocalAdminPageState extends State<LocalAdminPage> {
  late final LocalAdminPageController _controller;
  late Future<LocalAdminPageViewData> _viewDataFuture;

  @override
  void initState() {
    super.initState();
    _controller = LocalAdminPageController(
      authController: context.read<AuthController>(),
    );
    _viewDataFuture = _controller.loadViewData();
  }

  Future<void> _refresh() async {
    setState(() {
      _viewDataFuture = _controller.loadViewData();
    });
    await _viewDataFuture;
  }

  Future<void> _logout(BuildContext context) async {
    await _controller.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _openUsersPage(BuildContext context, AdminUsersKind kind) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUsersPage(kind: kind)),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Back to login',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: FutureBuilder<LocalAdminPageViewData>(
          future: _viewDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final viewData = snapshot.data ?? const LocalAdminPageViewData(snapshot: AdminDashboardSnapshot());
            final tiles = _controller.buildTiles(
              data: viewData,
              onOpenUsers: (kind) => _openUsersPage(context, kind),
            );
            final insightItems = _controller.buildInsightItems(viewData);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF0C274A), Color(0xFF143A6B), Color(0xFF1C5A9A)]
                              : const [Color(0xFF9ED8FF), Color(0xFF61B5FF), Color(0xFF3488F6)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Live admin tools',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Review accounts, separate doctors from patients, and run each admin action from one place.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Use the cards below to open each queue directly. They are connected to the current backend admin endpoints.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Account queues',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 1100
                            ? 3
                            : constraints.maxWidth >= 700
                                ? 2
                                : 1;
                        final tileWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: tiles
                              .map(
                                (tile) => SizedBox(
                                  width: tileWidth,
                                  child: SizedBox(
                                    height: 180,
                                    child: AdminHomeTile(data: tile),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    AdminInsightPanel(
                      title: 'Quick snapshot',
                      subtitle: 'Counts are only for orientation. The main control happens through the queue cards above.',
                      items: insightItems,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
