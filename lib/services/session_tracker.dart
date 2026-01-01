import 'dart:async';
import 'package:tester_analytics/models/activity_model.dart';

import '../services/firebase_service.dart';

class SessionTracker {
  final FirebaseAnalyticsService _analyticsService;
  Timer? _sessionTimer;
  DateTime? _sessionStartTime;
  String? _currentTesterId;
  bool _isSessionActive = false;

  SessionTracker(this._analyticsService);

  // Start a new session
  Future<void> startSession(String testerId) async {
    if (_isSessionActive) {
      await endSession();
    }

    _currentTesterId = testerId;
    _sessionStartTime = DateTime.now();
    _isSessionActive = true;

    await _analyticsService.logActivity(
      testerId: testerId,
      activityType: ActivityType.sessionStart,
      eventName: 'session_started',
      screenName: 'app_launch',
      eventData: {'startTime': _sessionStartTime!.toIso8601String()},
    );
  }

  // End current session
  Future<void> endSession() async {
    if (!_isSessionActive || _currentTesterId == null) return;

    _sessionTimer?.cancel();
    _sessionTimer = null;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    await _analyticsService.logActivity(
      testerId: _currentTesterId!,
      activityType: ActivityType.sessionEnd,
      eventName: 'session_ended',
      screenName: 'app_close',
      eventData: {
        'startTime': _sessionStartTime!.toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
      },
      sessionDuration: sessionDuration,
    );

    _isSessionActive = false;
    _currentTesterId = null;
    _sessionStartTime = null;
  }

  // Track screen views
  Future<void> trackScreenView({
    required String testerId,
    required String screenName,
    Map<String, dynamic>? screenData,
  }) async {
    await _analyticsService.logActivity(
      testerId: testerId,
      activityType: ActivityType.screenView,
      eventName: 'screen_view',
      screenName: screenName,
      eventData: screenData,
    );
  }

  // Track button clicks
  Future<void> trackButtonClick({
    required String testerId,
    required String buttonId,
    required String screenName,
    Map<String, dynamic>? eventData,
  }) async {
    await _analyticsService.logActivity(
      testerId: testerId,
      activityType: ActivityType.buttonClick,
      eventName: 'button_click',
      screenName: screenName,
      eventData: {'buttonId': buttonId, ...?eventData},
    );
  }

  // Track feature usage
  Future<void> trackFeatureUsage({
    required String testerId,
    required String featureName,
    required String screenName,
    Map<String, dynamic>? usageData,
  }) async {
    await _analyticsService.logActivity(
      testerId: testerId,
      activityType: ActivityType.featureUsage,
      eventName: 'feature_used',
      screenName: screenName,
      featureName: featureName,
      eventData: usageData,
    );
  }

  void dispose() {
    _sessionTimer?.cancel();
    endSession();
  }
}
