import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';



class SessionTracker {
  static DateTime? _start;

  static final _db = FirebaseFirestore.instance;

  /// call on AppLifecycleState.resumed
  static Future<void> startSession(String email) async {
    if (_start != null) return;


    _start = DateTime.now();

    final d = _day(_start!);

    await _db
        .collection('tester_analytics')
        .doc(email)
        .collection('days')
        .doc(d)
        .set({
      'sessions': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// call on paused / inactive / detached
  static Future<void> endSession(String email) async {


    final s = _start!;
    final e = DateTime.now();
    final d = _day(s);

    await _db
        .collection('tester_analytics')
        .doc(email)
        .collection('days')
        .doc(d)
        .set({
      'total': FieldValue.increment(e.difference(s).inSeconds),
    }, SetOptions(merge: true));
  }

  static String _day(DateTime t) =>
      '${t.year}-${t.month}-${t.day}';
}
