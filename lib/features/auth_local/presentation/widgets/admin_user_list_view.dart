import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/admin_user_list_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_user_list_view_data.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/pages/admin_user_details_page.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_empty_state.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_user_card.dart';
import 'package:provider/provider.dart';

typedef AdminUserLoader = Future<List<AuthUser>> Function(
  AuthController controller,
);

typedef AdminUserActionsBuilder = List<Widget> Function(
  BuildContext context,
  AuthUser user,
  AuthController controller,
);

class AdminUserListView extends StatefulWidget {
  const AdminUserListView({
    super.key,
    required this.query,
    required this.loadUsers,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.buildActions,
    this.extraFilter,
  });

  final String query;
  final AdminUserLoader loadUsers;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final AdminUserActionsBuilder buildActions;
  final bool Function(AuthUser user)? extraFilter;

  @override
  State<AdminUserListView> createState() => _AdminUserListViewState();
}

class _AdminUserListViewState extends State<AdminUserListView> {
  final AdminUserListController _listController = const AdminUserListController();
  Future<AdminUserListViewData>? _future;
  AuthController? _lastAuthController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authController = context.read<AuthController>();
    if (_future == null || !identical(_lastAuthController, authController)) {
      _lastAuthController = authController;
      _future = _load(authController);
    }
  }

  @override
  void didUpdateWidget(covariant AdminUserListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query || oldWidget.extraFilter != widget.extraFilter) {
      final authController = context.read<AuthController>();
      _future = _load(authController);
    }
  }

  Future<AdminUserListViewData> _load(AuthController controller) {
    return _listController.load(
      loadUsers: widget.loadUsers,
      authController: controller,
      query: widget.query,
      extraFilter: widget.extraFilter,
    );
  }

  Future<void> _refresh() async {
    await _listController.refresh();
    if (!mounted) return;
    setState(() {
      _future = _load(context.read<AuthController>());
    });
    await _future;
  }

  Future<void> _openDetails(AuthUser user) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUserDetailsPage(user: user),
      ),
    );

    if (!mounted || changed != true) return;
    setState(() {
      _future = _load(context.read<AuthController>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<AdminUserListViewData>(
        future: _future ?? _load(controller),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final viewData = snapshot.data ??
              const AdminUserListViewData(users: <AuthUser>[], filteredUsers: <AuthUser>[]);

          if (viewData.hasError) {
            return AdminEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load users',
              message: viewData.errorMessage!,
              actionLabel: 'Retry',
              onAction: () {
                setState(() {
                  _future = _load(controller);
                });
              },
            );
          }

          if (viewData.isEmpty) {
            return AdminEmptyState(
              icon: widget.emptyIcon,
              title: widget.emptyTitle,
              message: widget.emptyMessage,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            itemCount: viewData.filteredUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = viewData.filteredUsers[index];
              return AdminUserCard(
                user: user,
                badge: AdminRoleBadge(role: user.role),
                onTap: () => _openDetails(user),
                actions: widget.buildActions(context, user, controller),
              );
            },
          );
        },
      ),
    );
  }
}
