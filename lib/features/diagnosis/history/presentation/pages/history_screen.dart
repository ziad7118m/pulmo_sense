import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/controllers/diagnosis_history_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/helpers/diagnosis_history_content.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/diagnosis_history_view_data.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/stethoscope_doctor_history_scope.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/widgets/diagnosis_history_collection.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/widgets/diagnosis_history_item_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:provider/provider.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  final DiagnosisKind kind;
  final bool isDoctor;
  final StethoscopeDoctorHistoryScope stethoscopeScope;

  const DiagnosisHistoryScreen({
    super.key,
    required this.kind,
    this.isDoctor = true,
    this.stethoscopeScope = StethoscopeDoctorHistoryScope.all,
  });

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  bool _isSyncingRemote = false;
  bool _didRequestInitialSync = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestInitialSync) return;
    _didRequestInitialSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncRemoteIfNeeded(showLoader: true);
    });
  }

  Future<void> _syncRemoteIfNeeded({required bool showLoader}) async {
    final repository = context.read<DiagnosisHistoryRepository>();
    if (!repository.supportsRemoteSync(widget.kind)) {
      return;
    }

    if (showLoader && mounted) {
      setState(() => _isSyncingRemote = true);
    }

    final auth = context.read<AuthController>();
    final currentUserId = (auth.currentUser?.id ?? '').trim();

    await repository.syncRemoteHistoryByKind(
      widget.kind,
      userId: currentUserId.isEmpty ? null : currentUserId,
    );

    if (!mounted) return;
    setState(() => _isSyncingRemote = false);
  }

  Future<void> _refresh() async {
    await _syncRemoteIfNeeded(showLoader: false);
    if (!mounted) return;
    setState(() {});
  }

  DiagnosisHistoryViewData _viewData(BuildContext context) {
    final controller = DiagnosisHistoryController(
      context.read<DiagnosisHistoryRepository>(),
    );

    return controller.buildViewData(
      kind: widget.kind,
      isDoctor: widget.isDoctor,
      stethoscopeScope: widget.stethoscopeScope,
    );
  }

  Widget _loadingState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final content = DiagnosisHistoryContentResolver.emptyState(
      context: context,
      kind: widget.kind,
      isDoctor: widget.isDoctor,
      stethoscopeScope: widget.stethoscopeScope,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: EmptyStateCard(
            icon: content.icon,
            title: content.title,
            message: content.message,
            actionText: content.actionText,
            onAction: content.onAction,
          ),
        ),
      ],
    );
  }

  String? _ownerUserIdForItem(DiagnosisItem item) {
    if (widget.kind != DiagnosisKind.stethoscope || !widget.isDoctor) {
      return null;
    }

    final targetId = (item.targetPatientId ?? '').trim();
    return targetId.isEmpty ? null : targetId;
  }

  Widget _historyCard(BuildContext context, DiagnosisItem item) {
    return DiagnosisHistoryItemCard(
      kind: widget.kind,
      isDoctor: widget.isDoctor,
      item: item,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosisDetailsScreen(
              kind: widget.kind,
              item: item,
              ownerUserId: _ownerUserIdForItem(item),
              allowDelete: false,
            ),
          ),
        );
      },
    );
  }

  Widget _mobile(BuildContext context, DiagnosisHistoryViewData viewData) {
    if (_isSyncingRemote && viewData.isEmpty) return _loadingState(context);
    if (viewData.isEmpty) return _emptyState(context);

    return DiagnosisHistoryCollection.list(
      items: viewData.items,
      itemBuilder: (context, index) => _historyCard(context, viewData.items[index]),
    );
  }

  Widget _grid(BuildContext context, DiagnosisHistoryViewData viewData, int columns) {
    if (_isSyncingRemote && viewData.isEmpty) return _loadingState(context);
    if (viewData.isEmpty) return _emptyState(context);

    return DiagnosisHistoryCollection.grid(
      items: viewData.items,
      columns: columns,
      itemBuilder: (context, index) => _historyCard(context, viewData.items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewData = _viewData(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: viewData.title,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ResponsiveShell(
            mobile: _mobile(context, viewData),
            tablet: _grid(context, viewData, 2),
            desktop: _grid(context, viewData, 3),
          ),
        ),
      ),
    );
  }
}
