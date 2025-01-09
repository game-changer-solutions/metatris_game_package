import 'dart:io';
import 'sessions.dart';

class Game {
  int? game;
  List<Session>? sessions;
  String? resultId;
  File? eyeTrackingData;

  Game({
    required this.game,
    required this.sessions,
    required this.resultId,
    this.eyeTrackingData,
  });

  Map<String, Object?> toJson() => {
        'game': game,
        'sessions': sessions!.map((e) => e.toJson()).toList(),
        'result': resultId,
      };

  static Game fromJson(Map<dynamic, dynamic>? json) => Game(
        game: json!['game'],
        sessions: (json['sessions'] as List<dynamic>)
            .map((e) => Session.fromJson(e))
            .toList(),
        resultId: json['result'],
      );
}
