/// Generates a deterministic wormhole channel ID from two user IDs.
/// Sorted so both partners produce the same channel.
String generateChannelId(String userId1, String userId2) {
  final sorted = [userId1, userId2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
