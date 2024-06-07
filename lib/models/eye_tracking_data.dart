class TetrisEyeTrackingData {
  String eye_tracking_data_csv_file;
  String assigned_username;
  String? objectId;
  // DateTime? created;
  // DateTime? updated;

  TetrisEyeTrackingData({
    required this.eye_tracking_data_csv_file,
    required this.assigned_username,
    this.objectId,
    // this.created,
    // this.updated,
  });

  Map<String, Object?> toJson() => {
        'eye_tracking_data_csv_file': eye_tracking_data_csv_file,
        'assigned_username': assigned_username,
        // 'created': created,
        // 'updated': updated,
        'objectId': objectId,
      };

  static TetrisEyeTrackingData fromJson(Map<dynamic, dynamic>? json) =>
      TetrisEyeTrackingData(
        eye_tracking_data_csv_file:
            json!['eye_tracking_data_csv_file'] as String,
        assigned_username: json['assigned_username'] as String,
        objectId: json['objectId'] as String?,
        // created: json['created'] as DateTime?,
        // updated: json['updated'] as DateTime?,
      );
}
