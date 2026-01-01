import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tester_analytics/models/activity_model.dart';
import 'package:tester_analytics/models/tester_model.dart';
import 'package:uuid/uuid.dart';

class FirebaseAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collections
  static const String testersCollection = 'testers';
  static const String activitiesCollection = 'tester_activities';
  static const String sessionsCollection = 'sessions';

  // Register a new tester
  Future<void> registerTester({
    required String email,
    required String name,
    required String testerGroup,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final testerId = _uuid.v4();
      final tester = Tester(
        id: testerId,
        email: email,
        name: name,
        deviceId: deviceInfo['deviceId'] ?? 'unknown',
        deviceModel: deviceInfo['deviceModel'] ?? 'unknown',
        osVersion: deviceInfo['osVersion'] ?? 'unknown',
        appVersion: deviceInfo['appVersion'] ?? 'unknown',
        testerGroup: testerGroup,
      );

      await _firestore
          .collection(testersCollection)
          .doc(testerId)
          .set(tester.toJson());

      // Log registration activity
      await logActivity(
        testerId: testerId,
        activityType: ActivityType.appLaunch,
        eventName: 'tester_registered',
        screenName: 'registration',
        eventData: {'testerGroup': testerGroup, 'deviceInfo': deviceInfo},
      );
    } catch (e) {
      print('Error registering tester: $e');
      rethrow;
    }
  }

  // Log tester activity
  Future<void> logActivity({
    required String testerId,
    required ActivityType activityType,
    required String eventName,
    required String screenName,
    Map<String, dynamic>? eventData,
    String? featureName,
    Duration? sessionDuration,
    String? crashDetails,
    String? feedbackText,
  }) async {
    try {
      final activityId = _uuid.v4();
      final activity = TesterActivity(
        id: activityId,
        testerId: testerId,
        activityType: activityType,
        eventName: eventName,
        eventData: eventData,
        timestamp: DateTime.now(),
        screenName: screenName,
        featureName: featureName,
        sessionDuration: sessionDuration,
        crashDetails: crashDetails,
        feedbackText: feedbackText,
      );

      await _firestore
          .collection(activitiesCollection)
          .doc(activityId)
          .set(activity.toJson());

      // Update tester's last active timestamp
      await _firestore.collection(testersCollection).doc(testerId).update({
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Get all testers
  Future<List<Tester>> getAllTesters() async {
    try {
      final snapshot = await _firestore
          .collection(testersCollection)
          .orderBy('joinedDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Tester.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting testers: $e');
      return [];
    }
  }

  // Get tester activities
  Future<List<TesterActivity>> getTesterActivities(String testerId) async {
    try {
      final snapshot = await _firestore
          .collection(activitiesCollection)
          .where('testerId', isEqualTo: testerId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => TesterActivity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting activities: $e');
      return [];
    }
  }

  // Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    try {
      final testers = await getAllTesters();
      final activitiesSnapshot = await _firestore
          .collection(activitiesCollection)
          .where(
            'timestamp',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 7)),
          )
          .get();

      final activities = activitiesSnapshot.docs
          .map((doc) => TesterActivity.fromJson(doc.data()))
          .toList();

      // Calculate metrics
      final activeTesters = testers.where((t) => t.isActive).length;
      final totalSessions = activities
          .where((a) => a.activityType == ActivityType.sessionStart)
          .length;

      final crashCount = activities
          .where((a) => a.activityType == ActivityType.crashReport)
          .length;

      final feedbackCount = activities
          .where((a) => a.activityType == ActivityType.feedbackSubmitted)
          .length;

      // Group activities by type
      final Map<ActivityType, int> activityCounts = {};
      for (var activity in activities) {
        activityCounts.update(
          activity.activityType,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      return {
        'totalTesters': testers.length,
        'activeTesters': activeTesters,
        'totalSessions': totalSessions,
        'crashCount': crashCount,
        'feedbackCount': feedbackCount,
        'activityCounts': activityCounts,
        'testersByGroup': _groupTestersByGroup(testers),
      };
    } catch (e) {
      print('Error getting analytics summary: $e');
      return {};
    }
  }

  Map<String, int> _groupTestersByGroup(List<Tester> testers) {
    final Map<String, int> groups = {};
    for (var tester in testers) {
      groups.update(
        tester.testerGroup,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return groups;
  }

  // Submit feedback
  Future<void> submitFeedback({
    required String testerId,
    required String feedback,
    required String screenName,
    int rating = 5,
  }) async {
    await logActivity(
      testerId: testerId,
      activityType: ActivityType.feedbackSubmitted,
      eventName: 'feedback_submitted',
      screenName: screenName,
      eventData: {'rating': rating},
      feedbackText: feedback,
    );
  }

  // Report crash
  Future<void> reportCrash({
    required String testerId,
    required String error,
    required String stackTrace,
    required String screenName,
  }) async {
    await logActivity(
      testerId: testerId,
      activityType: ActivityType.crashReport,
      eventName: 'crash_reported',
      screenName: screenName,
      crashDetails: '$error\n$stackTrace',
    );
  }
}
