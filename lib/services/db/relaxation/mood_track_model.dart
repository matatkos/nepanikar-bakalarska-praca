import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/services/db/filters.dart';

part 'mood_track_model.freezed.dart';
part 'mood_track_model.g.dart';

enum Mood {
  sad,
  bad,
  okay,
  good,
  happy;

  SvgGenImage get icon {
    switch (this) {
      case Mood.sad:
        return Assets.illustrations.moods.sad5;
      case Mood.bad:
        return Assets.illustrations.moods.bad4;
      case Mood.okay:
        return Assets.illustrations.moods.okay3;
      case Mood.good:
        return Assets.illustrations.moods.good2;
      case Mood.happy:
        return Assets.illustrations.moods.happy1;
    }
  }

  String getLabel(BuildContext context) {
    // TODO: l10n
    switch (this) {
      case Mood.sad:
        return 'Mizerně';
      case Mood.bad:
        return 'Smutně';
      case Mood.okay:
        return 'Nic moc';
      case Mood.good:
        return 'Dobře';
      case Mood.happy:
        return 'Super';
    }
  }

  static Mood? fromInteger(int value) {
    final mood = Mood.values.firstWhereOrNull((mood) => mood.index == value);
    return mood;
  }
}

@freezed
class MoodTrack with _$MoodTrack {
  const factory MoodTrack({
    required Mood mood,
    // ignore: invalid_annotation_target
    @JsonKey(name: FilterKeys.date) required DateTime date,
  }) = _MoodTrack;

  const MoodTrack._();

  factory MoodTrack.fromJson(Map<String, Object?> json) => _$MoodTrackFromJson(json);
}
