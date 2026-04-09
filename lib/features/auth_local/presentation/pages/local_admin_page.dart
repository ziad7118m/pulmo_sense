import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/local_admin_page_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_dashboard_snapshot.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_admin_page_view_data.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/pages/admin_users_page.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_dashboard_stat_card.dart';
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
      articleController: context.read<ArticleController>(),
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
      MaterialPageRoute(
        builder: (_) => AdminUsersPage(kind: kind),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApiMode = _controller.isApiMode;

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
            final data = viewData.snapshot;
            final tiles = _controller.buildTiles(
              data: viewData,
              onOpenUsers: (kind) => _openUsersPage(context, kind),
            );
            final insightItems = _controller.buildInsightItems(viewData);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                            'Admin control center',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Manage access, monitor content, and keep the main workflow under control.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isApiMode
                              ? 'This backend currently exposes the pending users queue plus approve/reject actions.'
                              : 'Review each queue, open a profile, and take action with confidence.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isApiMode) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: scheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Active, disabled, rejected, doctor, and patient queues still need backend endpoints before they can be connected in the app.',
                              style: TextStyle(
                                color: scheme.onSurface,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'User overview',
                    subtitle: isApiMode
                        ? 'API-backed moderation data available right now.'
                        : 'Review how the user queues are evolving.',
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isApiMode ? 1 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isApiMode ? 2.4 : 1.3,
                    children: [
                      AdminDashboardStatCard(
                        title: 'Pending',
                        value: '${data.pending}',
                        subtitle: 'Need review',
                        icon: Icons.how_to_reg_rounded,
                        accentColor: const Color(0xFFFFA000),
                      ),
                      if (!isApiMode) ...[
                        AdminDashboardStatCard(
                          title: 'Approved',
                          value: '${data.approved}',
                          subtitle: 'Active accounts',
                          icon: Icons.verified_user_rounded,
                          accentColor: const Color(0xFF1976D2),
                        ),
                        AdminDashboardStatCard(
                          title: 'Disabled',
                          value: '${data.disabled}',
                          subtitle: 'Temporarily blocked',
                          icon: Icons.lock_outline_rounded,
                          accentColor: const Color(0xFF546E7A),
                        ),
                        AdminDashboardStatCard(
                          title: 'Rejected',
                          value: '${data.rejected}',
                          subtitle: 'Closed requests',
                          icon: Icons.block_rounded,
                          accentColor: const Color(0xFFD32F2F),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'User segments',
                    subtitle: isApiMode
                        ? 'Open the pending queue to approve or reject signup requests.'
                        : 'Open the exact queue you want to inspect next.',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isApiMode ? '${data.pending} pending users' : '${viewData.totalActiveUsers} active users',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tiles.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isApiMode ? 1 : (MediaQuery.of(context).size.width >= 760 ? 2 : 1),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isApiMode ? 2.6 : 1.45,
                    ),
                    itemBuilder: (context, index) => AdminHomeTile(data: tiles[index]),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Content insights',
                    subtitle: 'Article moderation stats available in the app.',
                  ),
                  const SizedBox(height: 12),
                  AdminInsightPanel(
                    title: 'Content insights',
                    subtitle: 'Article moderation stats available in the app.',
                    items: insightItems,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}
