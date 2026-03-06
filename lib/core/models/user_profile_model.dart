class UserProfileModel {
  final int id;
  final String nickname;
  final String planetName;
  final String? fcmToken;
  final String? partnerFcm;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.nickname,
    required this.planetName,
    this.fcmToken,
    this.partnerFcm,
    required this.createdAt,
  });

  bool get isPaired => partnerFcm != null;

  factory UserProfileModel.fromMap(Map<String, dynamic> map) =>
      UserProfileModel(
        id: map['id'] as int,
        nickname: map['nickname'] as String,
        planetName: map['planet_name'] as String,
        fcmToken: map['fcm_token'] as String?,
        partnerFcm: map['partner_fcm'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nickname': nickname,
        'planet_name': planetName,
        'fcm_token': fcmToken,
        'partner_fcm': partnerFcm,
        'created_at': createdAt.toIso8601String(),
      };

  UserProfileModel copyWith({
    String? nickname,
    String? planetName,
    String? fcmToken,
    String? partnerFcm,
  }) =>
      UserProfileModel(
        id: id,
        nickname: nickname ?? this.nickname,
        planetName: planetName ?? this.planetName,
        fcmToken: fcmToken ?? this.fcmToken,
        partnerFcm: partnerFcm ?? this.partnerFcm,
        createdAt: createdAt,
      );
}
