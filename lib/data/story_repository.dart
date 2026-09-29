import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/story.dart';

class StoryRepository {
  StoryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<Story>> loadPublicStories() async {
    final source = await _bundle.loadString('assets/data/stories.json');
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Аман зохиолын JSON объект байх ёстой.');
    }
    final archive = StoryArchive.fromJson(Map<String, dynamic>.from(decoded));
    return archive.stories
        .where((story) => story.rights.publicInApp)
        .toList(growable: false);
  }
}
