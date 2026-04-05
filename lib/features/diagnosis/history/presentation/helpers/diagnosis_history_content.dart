import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/stethoscope_doctor_history_scope.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/pages/record_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/pages/stethoscope_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/pages/xray_screen.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisHistoryEmptyContent {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;

  const DiagnosisHistoryEmptyContent({
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
    required this.icon,
  });
}

class DiagnosisHistoryContentResolver {
  static DiagnosisHistoryEmptyContent emptyState({
    required BuildContext context,
    required DiagnosisKind kind,
    required bool isDoctor,
    required StethoscopeDoctorHistoryScope stethoscopeScope,
  }) {
    switch (kind) {
      case DiagnosisKind.record:
        return DiagnosisHistoryEmptyContent(
          title: 'No recordings yet',
          message: 'Start a recording to see your results saved here.',
          actionText: 'Start recording',
          icon: Icons.mic_rounded,
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecordScreen(isDoctor: isDoctor),
              ),
            );
          },
        );
      case DiagnosisKind.stethoscope:
        if (isDoctor) {
          switch (stethoscopeScope) {
            case StethoscopeDoctorHistoryScope.doctorPersonal:
              return DiagnosisHistoryEmptyContent(
                title: 'No personal stethoscope recordings yet',
                message:
                    'Record or upload stethoscope audio and save it to your account.',
                actionText: 'Add audio',
                icon: Icons.medical_services_rounded,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StethoscopeScreen(isDoctor: true),
                    ),
                  );
                },
              );
            case StethoscopeDoctorHistoryScope.doctorPatients:
              return DiagnosisHistoryEmptyContent(
                title: 'No patient stethoscope recordings yet',
                message:
                    'Record stethoscope audio for patients to see them listed here.',
                actionText: 'Add audio',
                icon: Icons.medical_services_rounded,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StethoscopeScreen(isDoctor: true),
                    ),
                  );
                },
              );
            case StethoscopeDoctorHistoryScope.all:
              return DiagnosisHistoryEmptyContent(
                title: 'No stethoscope audio yet',
                message:
                    'Record or upload stethoscope audio to save results in your history.',
                actionText: 'Add audio',
                icon: Icons.medical_services_rounded,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StethoscopeScreen(isDoctor: true),
                    ),
                  );
                },
              );
          }
        }

        return const DiagnosisHistoryEmptyContent(
          title: 'No stethoscope recordings.',
          message:
              'No stethoscope recordings found. You need to visit a doctor who has the stethoscope device to add one to your account.',
          actionText: null,
          onAction: null,
          icon: Icons.medical_services_rounded,
        );
      case DiagnosisKind.xray:
        return DiagnosisHistoryEmptyContent(
          title: 'No X-ray history yet',
          message:
              'Upload an X-ray to generate a diagnosis and save it here.',
          actionText: 'Upload X-ray',
          icon: Icons.image_rounded,
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => XRayScreen(isDoctor: isDoctor),
              ),
            );
          },
        );
    }
  }
}
