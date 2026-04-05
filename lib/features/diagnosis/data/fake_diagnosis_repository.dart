import 'dart:math';

import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';

class FakeDiagnosisRepository implements DiagnosisRepository {
  final _rng = Random();

  DiagnosisResult _fake() {
    final confidence = 0.55 + _rng.nextDouble() * 0.40;
    final levels = ['Low', 'Medium', 'High'];
    final riskLevel = levels[_rng.nextInt(levels.length)];

    final recs = [
      'Monitor symptoms and follow healthy breathing habits.',
      'Consider a doctor consultation and repeat the test.',
      'Seek medical attention soon and follow clinical guidance.',
    ];

    return DiagnosisResult(
      riskLevel: riskLevel,
      confidence: confidence,
      recommendation: recs[_rng.nextInt(recs.length)],
    );
  }

  Future<Result<DiagnosisResult>> _simulate(DiagnosisUploadRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(_fake());
  }

  @override
  Future<Result<DiagnosisResult>> analyzeXray(DiagnosisUploadRequest request) {
    return _simulate(request);
  }

  @override
  Future<Result<DiagnosisResult>> analyzeAudio(DiagnosisUploadRequest request) {
    return _simulate(request);
  }

  @override
  Future<Result<DiagnosisResult>> analyzeRecord(DiagnosisUploadRequest request) {
    return _simulate(request);
  }
}
