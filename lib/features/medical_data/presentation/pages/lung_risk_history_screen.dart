import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/datasources/lung_risk_history_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/dtos/lung_risk_history_entry_dto.dart';

class LungRiskHistoryScreen extends StatefulWidget {
  const LungRiskHistoryScreen({super.key});

  @override
  State<LungRiskHistoryScreen> createState() => _LungRiskHistoryScreenState();
}

class _LungRiskHistoryScreenState extends State<LungRiskHistoryScreen> {
  late final LungRiskHistoryRemoteDataSource _remoteDataSource;
  late Future<List<LungRiskHistoryEntryDto>> _future;

  @override
  void initState() {
    super.initState();
    _remoteDataSource = LungRiskHistoryRemoteDataSource(AppDI.apiClient);
    _future = _load();
  }

  Future<List<LungRiskHistoryEntryDto>> _load() async {
    final result = await _remoteDataSource.fetchHistory();
    return result.when(
      success: (value) => value,
      failure: (failure) => throw failure,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Risk history',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<LungRiskHistoryEntryDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: EmptyStateCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load risk history',
                  message: _errorMessage(snapshot.error),
                  actionText: 'Try again',
                  onAction: _refresh,
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <LungRiskHistoryEntryDto>[];
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: EmptyStateCard(
                  icon: Icons.insights_outlined,
                  title: 'No risk history yet',
                  message: 'Once the backend starts returning saved lung risk runs, they will appear here.',
                  actionText: 'Refresh',
                  onAction: _refresh,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _RiskHistoryCard(entry: items[index]),
            ),
          );
        },
      ),
    );
  }

  String _errorMessage(Object? error) {
    final text = error?.toString().trim();
    if (text == null || text.isEmpty) {
      return 'Something went wrong while loading the backend history.';
    }
    return text;
  }
}

class _RiskHistoryCard extends StatelessWidget {
  final LungRiskHistoryEntryDto entry;

  const _RiskHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resultMeta = _metaFor(entry.result, scheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lung risk analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy • h:mm a').format(entry.createdAt.toLocal()),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _ResultBadge(label: entry.result, color: resultMeta.color),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ScoreTile(
                  label: 'Low',
                  value: _formatScore(entry.low),
                  icon: Icons.trending_down_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreTile(
                  label: 'Medium',
                  value: _formatScore(entry.medium),
                  icon: Icons.trending_flat_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreTile(
                  label: 'High',
                  value: _formatScore(entry.high),
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Factors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.factors
                .map(
                  (factor) => _FactorChip(
                    label: factor.key,
                    value: factor.value,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _formatScore(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  _ResultMeta _metaFor(String raw, ColorScheme scheme) {
    final value = raw.trim().toLowerCase();
    if (value == 'high') {
      return _ResultMeta(color: scheme.error);
    }
    if (value == 'medium') {
      return _ResultMeta(color: Colors.orange.shade700);
    }
    return _ResultMeta(color: Colors.green.shade700);
  }
}

class _ScoreTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ScoreTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorChip extends StatelessWidget {
  final String label;
  final int value;

  const _FactorChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ResultBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ResultMeta {
  final Color color;

  const _ResultMeta({required this.color});
}
