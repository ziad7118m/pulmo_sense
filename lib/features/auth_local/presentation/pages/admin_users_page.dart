import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/admin_users_page_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_search_field.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_user_list_view.dart';
import 'package:provider/provider.dart';

class AdminUsersPage extends StatefulWidget {
  final AdminUsersKind kind;

  const AdminUsersPage({super.key, required this.kind});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  late final AdminUsersPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = AdminUsersPageController();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    _pageController.setQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authController = context.watch<AuthController>();

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.kind.title),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? const [Color(0xFF10243D), Color(0xFF15375E)]
                          : const [Color(0xFFE6F3FF), Color(0xFFF4F9FF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pageController.heroTitle(widget.kind),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _pageController.heroSubtitle(widget.kind),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Connected to the live admin API for this queue.',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AdminSearchField(controller: _searchController),
                      if (_pageController.showRoleFilter(widget.kind, isApiMode: authController.isApiMode)) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: AdminUsersRoleScope.values.map((scope) {
                              final selected = scope == _pageController.roleScope;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(scope.label),
                                  selected: selected,
                                  onSelected: (_) => _pageController.setRoleScope(scope),
                                  selectedColor: scheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    side: BorderSide(color: scheme.outlineVariant.withOpacity(0.8)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AdminUserListView(
                  query: _pageController.query,
                  loadUsers: widget.kind.loadUsers,
                  emptyIcon: widget.kind.emptyIcon,
                  emptyTitle: widget.kind.emptyTitle,
                  emptyMessage: widget.kind.emptyMessage,
                  extraFilter: (user) => _pageController.matchesRoleScope(
                    user,
                    widget.kind,
                    isApiMode: authController.isApiMode,
                  ),
                  buildActions: (context, user, controller) => _pageController.buildActions(
                    context,
                    kind: widget.kind,
                    user: user,
                    authController: controller,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
