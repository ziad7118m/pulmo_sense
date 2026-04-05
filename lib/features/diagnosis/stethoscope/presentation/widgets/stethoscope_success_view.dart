import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_sent_success_card.dart';

class StethoscopeSuccessView extends StatelessWidget {
  final bool isForDoctor;
  final String targetLabel;
  final String timeLabel;
  final VoidCallback onRecordAnother;
  final VoidCallback onViewResult;

  const StethoscopeSuccessView({
    super.key,
    required this.isForDoctor,
    required this.targetLabel,
    required this.timeLabel,
    required this.onRecordAnother,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StethoscopeSentSuccessCard(
        isForDoctor: isForDoctor,
        targetLabel: targetLabel,
        timeLabel: timeLabel,
        onRecordAnother: onRecordAnother,
        onViewResult: onViewResult,
      ),
    );
  }
}
