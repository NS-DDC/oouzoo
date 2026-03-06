class UserProfileModel {
  final int id;
  final String uuid;
  final String nickname;
  final String planetName;
  final String? fcmToken;
  final String? partnerFcm;
  final String? partnerUuid;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.uuid,
    required this.nickname,
    required this.planetName,
    this.fcmToken,
    this.partnerFcm,
    this.partnerUuid,
    required this.createdAt,
  });

  bool get isPaired => partnerFcm != null;

  /// Partner identifier for channel generation.
  /// Uses stable UUID if available, falls back to FCM for legacy pairings.
  String? get channelPartnerId => partnerUuid ?? partnerFcm;

  factory UserProfileModel.fromMap(Map<String, dynamic> map) =>
      UserProfileModel(
        id: map['id'] as int,
        uuid: (map['uuid'] as String?) ?? '',
        nickname: map['nickname'] as String,
        planetName: map['planet_name'] as String,
        fcmToken: map['fcm_token'] as String?,
        partnerFcm: map['partner_fcm'] as String?,
        partnerUuid: map['partner_uuid'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'uuid': uuid,
        'nickname': nickname,
        'planet_name': planetName,
        'fcm_token': fcmToken,
        'partner_fcm': partnerFcm,
        'partner_uuid': partnerUuid,
        'created_at': createdAt.toIso8601String(),
      };

  UserProfileModel copyWith({
    String? uuid,
    String? nickname,
    String? planetName,
    String? fcmToken,
    String? partnerFcm,
    String? partnerUuid,
  }) =>
      UserProfileModel(
        id: id,
        uuid: uuid ?? this.uuid,
        nickname: nickname ?? this.nickname,
        planetName: planetName ?? this.planetName,
        fcmToken: fcmToken ?? this.fcmToken,
        partnerFcm: partnerFcm ?? this.partnerFcm,
        partnerUuid: partnerUuid ?? this.partnerUuid,
        createdAt: createdAt,
      );
}
