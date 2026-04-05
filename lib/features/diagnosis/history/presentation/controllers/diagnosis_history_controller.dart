import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/diagnosis_history_view_data.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/stethoscope_doctor_history_scope.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisHistoryController {
  final DiagnosisHistoryRepository _historyRepository;

  const DiagnosisHistoryController(this._historyRepository);

  DiagnosisHistoryViewData buildViewData({
    required DiagnosisKind kind,
    required bool isDoctor,
    required StethoscopeDoctorHistoryScope stethoscopeScope,
  }) {
    final items = _filteredItems(
      kind: kind,
      isDoctor: isDoctor,
      stethoscopeScope: stethoscopeScope,
    );

    return DiagnosisHistoryViewData(
      title: _titleFor(
        kind: kind,
        isDoctor: isDoctor,
        stethoscopeScope: stethoscopeScope,
      ),
      items: items,
    );
  }

  List<DiagnosisItem> _filteredItems({
    required DiagnosisKind kind,
    required bool isDoctor,
    required StethoscopeDoctorHistoryScope stethoscopeScope,
  }) {
    final raw = _historyRepository.getHistoryByKind(kind);

    if (kind != DiagnosisKind.stethoscope || !isDoctor) {
      return raw;
    }

    switch (stethoscopeScope) {
      case StethoscopeDoctorHistoryScope.doctorPersonal:
        return raw.where((item) => _targetPatientId(item).isEmpty).toList();
      case StethoscopeDoctorHistoryScope.doctorPatients:
        return raw.where((item) => _targetPatientId(item).isNotEmpty).toList();
      case StethoscopeDoctorHistoryScope.all:
        return raw;
    }
  }

  String _titleFor({
    required DiagnosisKind kind,
    required bool isDoctor,
    required StethoscopeDoctorHistoryScope stethoscopeScope,
  }) {
    switch (kind) {
      case DiagnosisKind.record:
        return 'Record history';
      case DiagnosisKind.stethoscope:
        if (!isDoctor) return 'Stethoscope history';
        switch (stethoscopeScope) {
          case StethoscopeDoctorHistoryScope.doctorPersonal:
            return 'Personal stethoscope recordings';
          case StethoscopeDoctorHistoryScope.doctorPatients:
            return 'Patient stethoscope logs';
          case StethoscopeDoctorHistoryScope.all:
            return 'Stethoscope history';
        }
      case DiagnosisKind.xray:
        return 'X-ray history';
    }
  }


  String _targetPatientId(DiagnosisItem item) {
    return item.targetPatientId?.trim() ?? '';
  }

}
