/// Аман зохиолын архивын бичлэг — үлгэр, домог, дуу.
///
/// Бүтцийн бүрэн тайлбар: docs/archive-schema.md
///
/// Энэ модель нь аппын хэрэгцээ (тоглуулах) болон архивын хэрэгцээ (хойч үед
/// хэн, хэзээ, ямар нөхцөлд бичсэнийг мэдэх) хоёуланд үйлчилнэ.
library;

/// Буриад аялгуунууд. CLAUDE.md: эдгээрийг хольж нэгтгэхгүй.
enum Dialect {
  khori('хори'),
  aga('ага'),
  sartuul('сартуул');

  const Dialect(this.label);

  final String label;

  static Dialect? parse(String? s) {
    final v = (s ?? '').trim().toLowerCase();
    for (final d in Dialect.values) {
      if (d.label == v) return d;
    }
    return null;
  }
}

/// Бичвэрийн нэг хэсэг ба түүний дуугарах хугацаа.
class Segment {
  const Segment({
    required this.start,
    required this.end,
    required this.b,
    required this.m,
  });

  /// Эхлэх, дуусах хугацаа секундээр.
  final double start;
  final double end;

  /// Буриад бичвэр ба монгол орчуулга.
  final String b;
  final String m;

  factory Segment.fromJson(Map<String, dynamic> j) => Segment(
    start: _num(j['start']),
    end: _num(j['end']),
    b: _str(j['b']),
    m: _str(j['m']),
  );

  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'b': b, 'm': m};

  bool get isValid => end > start && start >= 0 && b.isNotEmpty;

  /// Тухайн секундэд энэ хэсэг дуугарч байгаа эсэх.
  bool contains(double t) => t >= start && t < end;
}

/// Бичлэгийг ашиглах зөвшөөрөл.
///
/// Талбар бүр ярьсан хүнээс тусад нь асуусан байх ёстой. Ялангуяа
/// [aiTrainingAllowed] — «аппад тавьж болно» гэдэг нь «загвар сургаж болно»
/// гэсэн үг биш.
class Rights {
  const Rights({
    this.consentOn = '',
    this.consentForm = '',
    this.publicInApp = false,
    this.openToResearchers = false,
    this.aiTrainingAllowed = false,
    this.nameCredited = false,
    this.withdrawableBy = '',
    this.license = '',
    this.tkLabels = const [],
  });

  final String consentOn;
  final String consentForm;

  /// Аппад харуулах эсэх. false бол апп ямар ч тохиолдолд тоглуулахгүй.
  final bool publicInApp;
  final bool openToResearchers;
  final bool aiTrainingAllowed;

  /// Ярьсан хүний нэрийг гаргах эсэх.
  final bool nameCredited;
  final String withdrawableBy;
  final String license;
  final List<String> tkLabels;

  factory Rights.fromJson(Map<String, dynamic>? j) {
    final m = j ?? const {};
    return Rights(
      consentOn: _str(m['consentOn']),
      consentForm: _str(m['consentForm']),
      publicInApp: m['publicInApp'] == true,
      openToResearchers: m['openToResearchers'] == true,
      aiTrainingAllowed: m['aiTrainingAllowed'] == true,
      nameCredited: m['nameCredited'] == true,
      withdrawableBy: _str(m['withdrawableBy']),
      license: _str(m['license']),
      tkLabels: [for (final t in (m['tkLabels'] as List? ?? [])) _str(t)],
    );
  }

  Map<String, dynamic> toJson() => {
    'consentOn': consentOn,
    'consentForm': consentForm,
    'publicInApp': publicInApp,
    'openToResearchers': openToResearchers,
    'aiTrainingAllowed': aiTrainingAllowed,
    'nameCredited': nameCredited,
    'withdrawableBy': withdrawableBy,
    'license': license,
    'tkLabels': tkLabels,
  };
}

/// Ярьсан хүн.
class Narrator {
  const Narrator({
    this.name = '',
    this.birthYear,
    this.birthPlace = '',
    this.dialect,
    this.dialectVerifiedBy = '',
    this.learnedFrom = '',
  });

  final String name;
  final int? birthYear;
  final String birthPlace;
  final Dialect? dialect;
  final String dialectVerifiedBy;

  /// Хэнээс сурсан — уламжлалын гинж.
  final String learnedFrom;

  factory Narrator.fromJson(Map<String, dynamic>? j) {
    final m = j ?? const {};
    return Narrator(
      name: _str(m['name']),
      birthYear: m['birthYear'] is num ? (m['birthYear'] as num).toInt() : null,
      birthPlace: _str(m['birthPlace']),
      dialect: Dialect.parse(_str(m['dialect'])),
      dialectVerifiedBy: _str(m['dialectVerifiedBy']),
      learnedFrom: _str(m['learnedFrom']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthYear': birthYear,
    'birthPlace': birthPlace,
    'dialect': dialect?.label ?? '',
    'dialectVerifiedBy': dialectVerifiedBy,
    'learnedFrom': learnedFrom,
  };
}

/// Бичлэгийн техникийн мэдээлэл.
class Recording {
  const Recording({
    this.app = '',
    this.master = '',
    this.duration = 0,
    this.recordedAt = '',
    this.recordedIn = '',
    this.recordedBy = '',
    this.equipment = '',
  });

  /// Аппад тараах хувилбар (AAC).
  final String app;

  /// Архивын эх хувь хаана байгаа (WAV). Git-д ордоггүй.
  final String master;
  final double duration;
  final String recordedAt;
  final String recordedIn;
  final String recordedBy;
  final String equipment;

  factory Recording.fromJson(Map<String, dynamic>? j) {
    final m = j ?? const {};
    return Recording(
      app: _str(m['app']),
      master: _str(m['master']),
      duration: _num(m['duration']),
      recordedAt: _str(m['recordedAt']),
      recordedIn: _str(m['recordedIn']),
      recordedBy: _str(m['recordedBy']),
      equipment: _str(m['equipment']),
    );
  }

  Map<String, dynamic> toJson() => {
    'app': app,
    'master': master,
    'duration': duration,
    'recordedAt': recordedAt,
    'recordedIn': recordedIn,
    'recordedBy': recordedBy,
    'equipment': equipment,
  };
}

/// Нэг үлгэр, домог эсвэл дуу.
class Story {
  const Story({
    required this.id,
    required this.titleB,
    required this.titleM,
    required this.genre,
    required this.audio,
    required this.narrator,
    required this.rights,
    this.transcriptBy = '',
    this.transcriptDate = '',
    this.transcriptVerifiedBy = '',
    this.segments = const [],
    this.notes = '',
  });

  final String id;
  final String titleB;
  final String titleM;
  final String genre;
  final Recording audio;
  final Narrator narrator;
  final Rights rights;
  final String transcriptBy;
  final String transcriptDate;
  final String transcriptVerifiedBy;
  final List<Segment> segments;
  final String notes;

  factory Story.fromJson(Map<String, dynamic> j) {
    final title = (j['title'] as Map?)?.cast<String, dynamic>() ?? const {};
    final tr = (j['transcript'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Story(
      id: _str(j['id']),
      titleB: _str(title['b']),
      titleM: _str(title['m']),
      genre: _str(j['genre']),
      audio: Recording.fromJson((j['audio'] as Map?)?.cast<String, dynamic>()),
      narrator: Narrator.fromJson(
        (j['narrator'] as Map?)?.cast<String, dynamic>(),
      ),
      rights: Rights.fromJson((j['rights'] as Map?)?.cast<String, dynamic>()),
      transcriptBy: _str(tr['by']),
      transcriptDate: _str(tr['date']),
      transcriptVerifiedBy: _str(tr['verifiedBy']),
      segments: [
        for (final s in (j['segments'] as List? ?? []))
          if (s is Map) Segment.fromJson(s.cast<String, dynamic>()),
      ],
      notes: _str(j['notes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': {'b': titleB, 'm': titleM},
    'genre': genre,
    'audio': audio.toJson(),
    'narrator': narrator.toJson(),
    'transcript': {
      'by': transcriptBy,
      'date': transcriptDate,
      'verifiedBy': transcriptVerifiedBy,
    },
    'rights': rights.toJson(),
    'segments': [for (final s in segments) s.toJson()],
    'notes': notes,
  };

  /// Аппад тоглуулж болох эсэх.
  ///
  /// Зөвшөөрөл нь эхний нөхцөл: [Rights.publicInApp] false бол бусад бүх зүйл
  /// бүрэн байсан ч тоглуулахгүй. Энэ шалгалтыг зөвхөн энд хийж, дэлгэц бүрд
  /// давтахгүй — хүний алдаанаас хамгаалах давхарга.
  bool get playableInApp =>
      rights.publicInApp && audio.app.isNotEmpty && segments.isNotEmpty;

  /// Ярьсан хүний нэрийг харуулах эсэх — зөвшөөрөлгүй бол хоосон.
  String get creditedName => rights.nameCredited ? narrator.name : '';

  /// Архивын бүрэн бүтэн байдал: дутуу зүйлсийн жагсаалт.
  ///
  /// Хоосон буцвал бичлэг архивт өгөхөд бэлэн. Бичлэг оруулах маягт үүнийг
  /// ашиглаж, дутуу талбарыг хэрэглэгчид харуулна.
  List<String> get archiveProblems {
    final p = <String>[];
    void need(String value, String label) {
      if (value.trim().isEmpty) p.add(label);
    }

    need(id, 'танигч (id)');
    need(titleB, 'гарчиг буриадаар');
    need(titleM, 'гарчиг монголоор');
    need(genre, 'төрөл жанр');

    need(audio.master, 'эх хувийн байршил');
    need(audio.recordedAt, 'бичсэн огноо');
    need(audio.recordedIn, 'бичсэн газар');
    need(audio.recordedBy, 'бичсэн хүн');

    need(narrator.name, 'ярьсан хүний нэр');
    if (narrator.dialect == null) p.add('аялгуу (хори / ага / сартуул)');

    need(transcriptBy, 'бичвэр буулгасан хүн');
    need(transcriptDate, 'бичвэр буулгасан огноо');

    need(rights.consentOn, 'зөвшөөрөл авсан огноо');
    need(rights.consentForm, 'бичгийн зөвшөөрлийн байршил');

    for (var i = 0; i < segments.length; i++) {
      if (!segments[i].isValid) {
        p.add('${i + 1}-р хэсгийн цаг эсвэл бичвэр буруу');
      }
    }
    return p;
  }
}

/// stories.json файлын агуулга.
class StoryArchive {
  const StoryArchive({required this.schema, required this.stories});

  static const currentSchema = 'buriad-archive/1';

  final String schema;
  final List<Story> stories;

  /// Аппад харуулж болох бичлэгүүд.
  List<Story> get playable => [
    for (final s in stories)
      if (s.playableInApp) s,
  ];

  /// Файлын агуулгыг уншина. Бүтэц таарахгүй бол null.
  static StoryArchive? parse(Object? raw) {
    if (raw is! Map) return null;
    final schema = _str(raw['schema']);
    if (schema != currentSchema) return null;
    final list = raw['stories'];
    if (list is! List) return null;

    final stories = <Story>[];
    for (final item in list) {
      if (item is! Map) return null;
      final s = Story.fromJson(item.cast<String, dynamic>());
      if (s.id.isEmpty) return null;
      stories.add(s);
    }
    if (stories.map((s) => s.id).toSet().length != stories.length) return null;
    return StoryArchive(schema: schema, stories: stories);
  }
}

String _str(Object? v) => (v ?? '').toString().trim();

double _num(Object? v) => v is num ? v.toDouble() : 0;
