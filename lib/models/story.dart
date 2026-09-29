class StoryArchive {
  const StoryArchive({required this.schema, required this.stories});

  final String schema;
  final List<Story> stories;

  factory StoryArchive.fromJson(Map<String, dynamic> json) {
    if (json['schema'] != 'buriad-archive/1') {
      throw const FormatException('Аман зохиолын schema дэмжигдэхгүй байна.');
    }
    final rawStories = json['stories'];
    if (rawStories is! List) {
      throw const FormatException('stories талбар жагсаалт байх ёстой.');
    }
    return StoryArchive(
      schema: json['schema'] as String,
      stories: rawStories
          .map((item) => Story.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
    );
  }
}

class Story {
  const Story({
    required this.id,
    required this.title,
    required this.genre,
    required this.audio,
    required this.narrator,
    required this.rights,
    required this.transcript,
    required this.segments,
    required this.notes,
    required this.performer,
    required this.sourceUrl,
  });

  final String id;
  final ParallelText title;
  final String genre;
  final StoryAudio audio;
  final Narrator narrator;
  final StoryRights rights;
  final TranscriptCredit transcript;
  final List<StorySegment> segments;
  final String notes;
  final String performer;
  final String sourceUrl;

  factory Story.fromJson(Map<String, dynamic> json) {
    const genres = {'үлгэр', 'домог', 'түүх', 'өгүүллэг', 'дуу'};
    final genre = _text(json, 'genre');
    if (!genres.contains(genre)) {
      throw const FormatException('genre талбарын утга буруу байна.');
    }
    final rawSegments = json['segments'];
    if (rawSegments is! List) {
      throw const FormatException('segments талбар жагсаалт байх ёстой.');
    }
    return Story(
      id: _text(json, 'id'),
      title: ParallelText.fromJson(_map(json, 'title')),
      genre: genre,
      audio: StoryAudio.fromJson(_map(json, 'audio')),
      narrator: Narrator.fromJson(_map(json, 'narrator')),
      rights: StoryRights.fromJson(_map(json, 'rights')),
      transcript: TranscriptCredit.fromJson(_map(json, 'transcript')),
      segments: rawSegments
          .map(
            (item) =>
                StorySegment.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
      notes: _text(json, 'notes'),
      performer: _optionalText(json, 'performer'),
      sourceUrl: _optionalText(json, 'sourceUrl'),
    );
  }
}

class ParallelText {
  const ParallelText({required this.buriad, required this.mongolian});

  final String buriad;
  final String mongolian;

  factory ParallelText.fromJson(Map<String, dynamic> json) =>
      ParallelText(buriad: _text(json, 'b'), mongolian: _text(json, 'm'));
}

class StoryAudio {
  const StoryAudio({
    required this.app,
    required this.master,
    required this.duration,
    required this.recordedAt,
    required this.recordedIn,
    required this.recordedBy,
    required this.equipment,
  });

  final String app;
  final String master;
  final double duration;
  final String recordedAt;
  final String recordedIn;
  final String recordedBy;
  final String equipment;

  factory StoryAudio.fromJson(Map<String, dynamic> json) => StoryAudio(
    app: _text(json, 'app'),
    master: _text(json, 'master'),
    duration: _number(json, 'duration'),
    recordedAt: _text(json, 'recordedAt'),
    recordedIn: _text(json, 'recordedIn'),
    recordedBy: _text(json, 'recordedBy'),
    equipment: _text(json, 'equipment'),
  );
}

class Narrator {
  const Narrator({
    required this.name,
    required this.birthYear,
    required this.birthplace,
    required this.dialect,
  });

  final String name;
  final int? birthYear;
  final String birthplace;
  final String dialect;

  factory Narrator.fromJson(Map<String, dynamic> json) {
    final dialect = _text(json, 'dialect');
    const dialects = {'хори', 'ага', 'сартуул', 'тэмдэглээгүй'};
    if (!dialects.contains(dialect)) {
      throw const FormatException('Өгүүлэгчийн dialect талбар буруу байна.');
    }
    final year = json['birthYear'];
    if (year != null && year is! int) {
      throw const FormatException('birthYear бүхэл тоо байх ёстой.');
    }
    return Narrator(
      name: _text(json, 'name'),
      birthYear: year as int?,
      birthplace: _text(json, 'birthplace'),
      dialect: dialect,
    );
  }
}

class StoryRights {
  const StoryRights({
    required this.consentOn,
    required this.consentForm,
    required this.publicInApp,
    required this.openToResearchers,
    required this.aiTrainingAllowed,
    required this.nameCredited,
    required this.withdrawableBy,
    required this.license,
    required this.tkLabels,
  });

  final String consentOn;
  final String consentForm;
  final bool publicInApp;
  final bool openToResearchers;
  final bool aiTrainingAllowed;
  final bool nameCredited;
  final String withdrawableBy;
  final String license;
  final List<String> tkLabels;

  factory StoryRights.fromJson(Map<String, dynamic> json) => StoryRights(
    consentOn: _text(json, 'consentOn'),
    consentForm: _text(json, 'consentForm'),
    publicInApp: _boolean(json, 'publicInApp'),
    openToResearchers: _boolean(json, 'openToResearchers'),
    aiTrainingAllowed: _boolean(json, 'aiTrainingAllowed'),
    nameCredited: _boolean(json, 'nameCredited'),
    withdrawableBy: _text(json, 'withdrawableBy'),
    license: _text(json, 'license'),
    tkLabels: _stringList(json, 'tkLabels'),
  );
}

class TranscriptCredit {
  const TranscriptCredit({
    required this.by,
    required this.date,
    required this.verifiedBy,
  });

  final String by;
  final String date;
  final String verifiedBy;

  factory TranscriptCredit.fromJson(Map<String, dynamic> json) =>
      TranscriptCredit(
        by: _text(json, 'by'),
        date: _text(json, 'date'),
        verifiedBy: _text(json, 'verifiedBy'),
      );
}

class StorySegment {
  const StorySegment({
    required this.start,
    required this.end,
    required this.text,
  });

  final double start;
  final double end;
  final ParallelText text;

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    final start = _number(json, 'start');
    final end = _number(json, 'end');
    if (start < 0 || end < start) {
      throw const FormatException('Хэсгийн хугацаа буруу байна.');
    }
    return StorySegment(
      start: start,
      end: end,
      text: ParallelText.fromJson(json),
    );
  }
}

Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('$key талбар объект байх ёстой.');
  }
  return Map<String, dynamic>.from(value);
}

String _text(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('$key талбар тэмдэгт мөр байх ёстой.');
  }
  return value.trim();
}

String _optionalText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return '';
  if (value is! String) {
    throw FormatException('$key талбар тэмдэгт мөр байх ёстой.');
  }
  return value.trim();
}

double _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('$key талбар тоо байх ёстой.');
  }
  return value.toDouble();
}

bool _boolean(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('$key талбар үнэн эсвэл худал байх ёстой.');
  }
  return value;
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('$key талбар тэмдэгт мөрийн жагсаалт байх ёстой.');
  }
  return value.cast<String>();
}
