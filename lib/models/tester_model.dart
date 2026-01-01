class Tester {
  final String id;
  final String email;
  final String name;
  final DateTime joinedDate;
  final String deviceId;
  final String deviceModel;
  final String osVersion;
  final String appVersion;
  final String testerGroup; // Alpha, Beta, etc.
  final bool isActive;
  final DateTime? lastActive;

  Tester({
    required this.id,
    required this.email,
    required this.name,
    DateTime? joinedDate,
    required this.deviceId,
    required this.deviceModel,
    required this.osVersion,
    required this.appVersion,
    required this.testerGroup,
    this.isActive = true,
    this.lastActive,
  }) : joinedDate = joinedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'joinedDate': joinedDate.toIso8601String(),
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'testerGroup': testerGroup,
      'isActive': isActive,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  factory Tester.fromJson(Map<String, dynamic> json) {
    return Tester(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      joinedDate: DateTime.parse(json['joinedDate']),
      deviceId: json['deviceId'],
      deviceModel: json['deviceModel'],
      osVersion: json['osVersion'],
      appVersion: json['appVersion'],
      testerGroup: json['testerGroup'],
      isActive: json['isActive'],
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive']) 
          : null,
    );
  }
}