import 'sessions.dart';
import 'package:collection/collection.dart';

class Game {
  int? game;
  List<Session>? sessions;
  String? resultId;
  int? eyeTrackingFileId;

  double? avgCd9;
  double? avgColTransitions;
  double? avgCumulativeWells;
  double? avgDeepWells;
  double? avgDeltaMaxHeight;
  double? avgDeltaPits;
  double? avgDropLatency;
  double? avgIndicator;
  double? avgInitLatency;
  double? avgJaggedness;
  double? avgLandingHeight;
  double? avgLat;
  double? avgLumpedPits;
  double? avgMatches;
  double? avgMaxHeight;
  double? avgMaxWell;
  double? avgMaxDiffs;
  double? avgMeanHeight;
  double? avgMinHeight;
  double? avgMinRotDiff;
  double? avgMinTransDiff;
  double? avgPatternDiv;
  double? avgPitDepth;
  double? avgPitRows;
  double? avgPits;
  double? avgUserDropRatio;
  double? avgRespLatency;
  double? avgRotations;
  double? avgRowTransitions;
  double? avgTotalMoves;
  double? avgWeightedCells;
  double? avgWells;
  int? elapsedTime;
  int? finalScore;
  int? levelReached;
  int? totalLinesCleared;
  int? totalTetrises;

  Game({
    required this.game,
    required this.sessions,
    required this.resultId,
    this.eyeTrackingFileId,
    this.avgCd9,
    this.avgColTransitions,
    this.avgCumulativeWells,
    this.avgDeepWells,
    this.avgDeltaMaxHeight,
    this.avgDeltaPits,
    this.avgDropLatency,
    this.avgIndicator,
    this.avgInitLatency,
    this.avgJaggedness,
    this.avgLandingHeight,
    this.avgLat,
    this.avgLumpedPits,
    this.avgMatches,
    this.avgMaxHeight,
    this.avgMaxWell,
    this.avgMaxDiffs,
    this.avgMeanHeight,
    this.avgMinHeight,
    this.avgMinRotDiff,
    this.avgMinTransDiff,
    this.avgPatternDiv,
    this.avgPitDepth,
    this.avgPitRows,
    this.avgPits,
    this.avgUserDropRatio,
    this.avgRespLatency,
    this.avgRotations,
    this.avgRowTransitions,
    this.avgTotalMoves,
    this.avgWeightedCells,
    this.avgWells,
    this.elapsedTime,
    this.finalScore,
    this.levelReached,
    this.totalLinesCleared,
    this.totalTetrises,
  }) {
    _calculateDrivenVariables();
  }

  void _calculateDrivenVariables() {
    avgCd9 ??= sessions!.map((e) => e.cd_9 ?? 0).toList().average;
    avgColTransitions ??=
        sessions!.map((e) => e.column_transitions ?? 0).toList().average;
    avgCumulativeWells ??=
        sessions!.map((e) => e.cumulative_wells ?? 0).toList().average;
    avgDeepWells ??= sessions!.map((e) => e.deep_wells ?? 0).toList().average;
    avgDeltaMaxHeight ??=
        sessions!.map((e) => e.delta_max_height ?? 0).toList().average;
    avgDeltaPits ??= sessions!.map((e) => e.delta_pits ?? 0).toList().average;
    avgDropLatency ??=
        sessions!.map((e) => e.drop_latency ?? 0).toList().average;
    avgIndicator ??=
        sessions!.map((e) => e.indicator_value ?? 0).toList().average;
    avgInitLatency ??=
        sessions!.map((e) => e.initial_latency ?? 0).toList().average;
    avgJaggedness ??= sessions!.map((e) => e.jaggedness ?? 0).toList().average;
    avgLandingHeight ??=
        sessions!.map((e) => e.landing_height ?? 0).toList().average;
    avgLat ??= sessions!.map((e) => e.avg_lat ?? 0).toList().average;
    avgLumpedPits ??= sessions!.map((e) => e.lumped_pits ?? 0).toList().average;
    avgMatches ??= sessions!.map((e) => e.matches ?? 0).toList().average;
    avgMaxHeight ??= sessions!.map((e) => e.max_height ?? 0).toList().average;
    avgMaxWell ??= sessions!.map((e) => e.max_well ?? 0).toList().average;
    avgMaxDiffs ??=
        sessions!.map((e) => e.maximum_differences ?? 0).toList().average;
    avgMeanHeight ??= sessions!.map((e) => e.mean_height ?? 0).toList().average;
    avgMinHeight ??= sessions!.map((e) => e.min_height ?? 0).toList().average;
    avgMinRotDiff ??= sessions!
        .map((e) => e.minimum_rotation_difference ?? 0)
        .toList()
        .average;
    avgMinTransDiff ??= sessions!
        .map((e) => e.minimum_translation_difference ?? 0)
        .toList()
        .average;
    avgPatternDiv ??= sessions!.map((e) => e.pattern_div ?? 0).toList().average;
    avgPitDepth ??= sessions!.map((e) => e.pit_depth ?? 0).toList().average;
    avgPitRows ??= sessions!.map((e) => e.pit_rows ?? 0).toList().average;
    avgPits ??= sessions!.map((e) => e.pits ?? 0).toList().average;
    avgUserDropRatio ??=
        sessions!.map((e) => e.proportion_of_user_drops ?? 0).toList().average;
    avgRespLatency ??=
        sessions!.map((e) => e.response_latency ?? 0).toList().average;
    avgRotations ??= sessions!.map((e) => e.rotations ?? 0).toList().average;
    avgRowTransitions ??=
        sessions!.map((e) => e.row_transitions ?? 0).toList().average;
    avgTotalMoves ??=
        sessions!.map((e) => e.total_movements ?? 0).toList().average;
    avgWeightedCells ??=
        sessions!.map((e) => e.weighted_cells ?? 0).toList().average;
    avgWells ??= sessions!.map((e) => e.wells ?? 0).toList().average;

    elapsedTime ??= sessions?.lastOrNull?.timestamp ?? 0;
    finalScore ??= sessions?.lastOrNull?.score ?? 0;
    levelReached ??= sessions?.lastOrNull?.level ?? 0;
    totalLinesCleared ??= sessions?.lastOrNull?.lines ?? 0;
    totalTetrises ??= sessions?.lastOrNull?.tetrises ?? 0;
  }

  Map<String, Object?> toJson() => {
        'game': game,
        'sessions': sessions!.map((e) => e.toJson()).toList(),
        'result': resultId,
        'eyeTracking': eyeTrackingFileId,
        'avgCd9': avgCd9,
        'avgColTransitions': avgColTransitions,
        'avgCumulativeWells': avgCumulativeWells,
        'avgDeepWells': avgDeepWells,
        'avgDeltaMaxHeight': avgDeltaMaxHeight,
        'avgDeltaPits': avgDeltaPits,
        'avgDropLatency': avgDropLatency,
        'avgIndicator': avgIndicator,
        'avgInitLatency': avgInitLatency,
        'avgJaggedness': avgJaggedness,
        'avgLandingHeight': avgLandingHeight,
        'avgLat': avgLat,
        'avgLumpedPits': avgLumpedPits,
        'avgMatches': avgMatches,
        'avgMaxHeight': avgMaxHeight,
        'avgMaxWell': avgMaxWell,
        'avgMaxDiffs': avgMaxDiffs,
        'avgMeanHeight': avgMeanHeight,
        'avgMinHeight': avgMinHeight,
        'avgMinRotDiff': avgMinRotDiff,
        'avgMinTransDiff': avgMinTransDiff,
        'avgPatternDiv': avgPatternDiv,
        'avgPitDepth': avgPitDepth,
        'avgPitRows': avgPitRows,
        'avgPits': avgPits,
        'avgUserDropRatio': avgUserDropRatio,
        'avgRespLatency': avgRespLatency,
        'avgRotations': avgRotations,
        'avgRowTransitions': avgRowTransitions,
        'avgTotalMoves': avgTotalMoves,
        'avgWeightedCells': avgWeightedCells,
        'avgWells': avgWells,
        'elapsedTime': elapsedTime,
        'finalScore': finalScore,
        'levelReached': levelReached,
        'totalLinesCleared': totalLinesCleared,
        'totalTetrises': totalTetrises,
      };

  static Game fromJson(Map<dynamic, dynamic>? json) => Game(
        game: json!['game'],
        sessions: (json['sessions'] as List<dynamic>)
            .map((e) => Session.fromJson(e))
            .toList(),
        resultId: json['result'],
        avgCd9: json['avgCd9'],
        avgColTransitions: json['avgColTransitions'],
        avgCumulativeWells: json['avgCumulativeWells'],
        avgDeepWells: json['avgDeepWells'],
        avgDeltaMaxHeight: json['avgDeltaMaxHeight'],
        avgDeltaPits: json['avgDeltaPits'],
        avgDropLatency: json['avgDropLatency'],
        avgIndicator: json['avgIndicator'],
        avgInitLatency: json['avgInitLatency'],
        avgJaggedness: json['avgJaggedness'],
        avgLandingHeight: json['avgLandingHeight'],
        avgLat: json['avgLat'],
        avgLumpedPits: json['avgLumpedPits'],
        avgMatches: json['avgMatches'],
        avgMaxHeight: json['avgMaxHeight'],
        avgMaxWell: json['avgMaxWell'],
        avgMaxDiffs: json['avgMaxDiffs'],
        avgMeanHeight: json['avgMeanHeight'],
        avgMinHeight: json['avgMinHeight'],
        avgMinRotDiff: json['avgMinRotDiff'],
        avgMinTransDiff: json['avgMinTransDiff'],
        avgPatternDiv: json['avgPatternDiv'],
        avgPitDepth: json['avgPitDepth'],
        avgPitRows: json['avgPitRows'],
        avgPits: json['avgPits'],
        avgUserDropRatio: json['avgUserDropRatio'],
        avgRespLatency: json['avgRespLatency'],
        avgRotations: json['avgRotations'],
        avgRowTransitions: json['avgRowTransitions'],
        avgTotalMoves: json['avgTotalMoves'],
        avgWeightedCells: json['avgWeightedCells'],
        avgWells: json['avgWells'],
        elapsedTime: json['elapsedTime'],
        finalScore: json['finalScore'],
        levelReached: json['levelReached'],
        totalLinesCleared: json['totalLinesCleared'],
        totalTetrises: json['totalTetrises'],
      );
}
