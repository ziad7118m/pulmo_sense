class AboutDiseaseContent {
  final String heroDescription;
  final String overview;
  final List<String> watchFor;
  final List<String> reduceRisk;
  final List<String> urgentHelp;
  final String sources;

  const AboutDiseaseContent({
    required this.heroDescription,
    required this.overview,
    required this.watchFor,
    required this.reduceRisk,
    required this.urgentHelp,
    required this.sources,
  });

  factory AboutDiseaseContent.from({
    required String title,
    required String description,
  }) {
    final key = title.toLowerCase();

    if (key.contains('covid')) {
      return AboutDiseaseContent(
        heroDescription: description,
        overview:
            'This page gives a clear, easy-to-scan summary of COVID-19 and common warning signs. It is designed to support understanding and preparation—not to replace medical advice.',
        watchFor: const [
          'New or worsening breathing difficulty',
          'Persistent cough or chest discomfort',
          'Unusual fatigue or reduced exercise tolerance',
        ],
        reduceRisk: const [
          'Avoid smoke exposure and improve indoor air quality',
          'Follow your care plan and prescribed medications (if any)',
          'Keep vaccinations and checkups up to date',
        ],
        urgentHelp: const [
          'Severe shortness of breath, blue lips/face, or confusion',
          'Chest pain that is intense or persistent',
          'Symptoms that escalate quickly or feel alarming',
        ],
        sources:
            'For official health guidance, check WHO and CDC resources. If you have symptoms or concerns, contact a clinician.',
      );
    }

    if (key.contains('asthma')) {
      return AboutDiseaseContent(
        heroDescription: description,
        overview:
            'Asthma is a chronic condition that narrows the airways and can make breathing harder. Symptoms may come and go, and triggers differ from person to person.',
        watchFor: const [
          'Wheezing, chest tightness, or shortness of breath',
          'Night cough or symptoms after exercise',
          'Frequent flare-ups after dust, smoke, or cold air exposure',
        ],
        reduceRisk: const [
          'Use inhalers exactly as prescribed',
          'Avoid known triggers such as smoke, dust, and strong odors',
          'Keep follow-up visits and monitor symptoms regularly',
        ],
        urgentHelp: const [
          'Severe breathing difficulty not relieved by rescue medication',
          'Trouble speaking because of shortness of breath',
          'Blue lips, faintness, or fast worsening symptoms',
        ],
        sources:
            'Trusted guidance can be found through WHO, CDC, and your treating respiratory specialist.',
      );
    }

    if (key.contains('pneumonia')) {
      return AboutDiseaseContent(
        heroDescription: description,
        overview:
            'Pneumonia is an infection that inflames the air sacs in one or both lungs. It can range from mild to severe depending on age, immunity, and the cause of infection.',
        watchFor: const [
          'Fever with cough and mucus production',
          'Breathing difficulty or rapid breathing',
          'Chest pain that worsens with deep breaths or coughing',
        ],
        reduceRisk: const [
          'Rest, hydrate well, and follow prescribed treatment',
          'Avoid smoking and secondhand smoke exposure',
          'Stay up to date with recommended vaccinations',
        ],
        urgentHelp: const [
          'Confusion, low oxygen symptoms, or severe breathlessness',
          'High fever that does not improve or worsens quickly',
          'Unable to drink fluids or marked weakness',
        ],
        sources:
            'Use reputable sources such as WHO, CDC, and local health authorities for updated pneumonia guidance.',
      );
    }

    if (key.contains('lung cancer')) {
      return AboutDiseaseContent(
        heroDescription: description,
        overview:
            'Lung cancer develops when abnormal cells grow uncontrollably in lung tissue. Early detection is important because symptoms may be mild at first.',
        watchFor: const [
          'Persistent cough that changes or does not improve',
          'Unexplained weight loss, fatigue, or coughing blood',
          'Chest pain or repeated chest infections',
        ],
        reduceRisk: const [
          'Avoid smoking and secondhand smoke exposure',
          'Follow screening advice if you are in a high-risk group',
          'Keep regular appointments and report new symptoms early',
        ],
        urgentHelp: const [
          'Coughing significant blood or severe chest pain',
          'Rapid decline in breathing ability',
          'New confusion or severe weakness',
        ],
        sources:
            'Refer to WHO, CDC, and cancer center guidance for accurate information and screening advice.',
      );
    }

    return AboutDiseaseContent(
      heroDescription: description,
      overview:
          'This page gives a clear, easy-to-scan summary. It is designed to support understanding and preparation—not to replace medical advice.',
      watchFor: const [
        'New or worsening breathing difficulty',
        'Persistent cough or chest discomfort',
        'Unusual fatigue or reduced exercise tolerance',
      ],
      reduceRisk: const [
        'Avoid smoke exposure and improve indoor air quality',
        'Follow your care plan and prescribed medications (if any)',
        'Keep vaccinations and checkups up to date',
      ],
      urgentHelp: const [
        'Severe shortness of breath, blue lips/face, or confusion',
        'Chest pain that is intense or persistent',
        'Symptoms that escalate quickly or feel alarming',
      ],
      sources:
          'For official health guidance, check WHO, CDC, and local healthcare resources. If symptoms worsen, contact a clinician.',
    );
  }
}
