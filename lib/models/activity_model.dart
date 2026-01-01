enum ActivityType {
  appLaunch,
  screenView,
  buttonClick,
  featureUsage,
  crashReport,
  feedbackSubmitted,
  sessionStart,
  sessionEnd,
  customEvent,
}

class TesterActivity {
  final String id;
  final String testerId;
  final ActivityType activityType;
  final String eventName;
  final Map<String, dynamic>? eventData;
  final DateTime timestamp;
  final String screenName;
  final String? featureName;
  final Duration? sessionDuration;
  final String? crashDetails;
  final String? feedbackText;

  TesterActivity({
    required this.id,
    required this.testerId,
    required this.activityType,
    required this.eventName,
    this.eventData,
    required this.timestamp,
    required this.screenName,
    this.featureName,
    this.sessionDuration,
    this.crashDetails,
    this.feedbackText,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testerId': testerId,
      'activityType': activityType.name,
      'eventName': eventName,
      'eventData': eventData,
      'timestamp': timestamp.toIso8601String(),
      'screenName': screenName,
      'featureName': featureName,
      'sessionDuration': sessionDuration?.inSeconds,
      'crashDetails': crashDetails,
      'feedbackText': feedbackText,
    };
  }

  factory TesterActivity.fromJson(Map<String, dynamic> json) {
    return TesterActivity(
      id: json['id'],
      testerId: json['testerId'],
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
      ),
      eventName: json['eventName'],
      eventData: json['eventData'],
      timestamp: DateTime.parse(json['timestamp']),
      screenName: json['screenName'],
      featureName: json['featureName'],
      sessionDuration: json['sessionDuration'] != null
          ? Duration(seconds: json['sessionDuration'])
          : null,
      crashDetails: json['crashDetails'],
      feedbackText: json['feedbackText'],
    );
  }
}