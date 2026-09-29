import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/story.dart';

/// Аман зохиолын архивын эх сурвалж.
///
/// Одоогоор багцад орсон assets/data/stories.json. Хожим Supabase руу
/// шилжихэд энэ ангийг л солино.
class StoryStore {
  static const _assetPath = 'assets/data/stories.json';

  Future<StoryArchive> load() async {
    final text = await rootBundle.loadString(_assetPath);
    return StoryArchive.parse(jsonDecode(text)) ??
        const StoryArchive(schema: StoryArchive.currentSchema, stories: []);
  }
}
