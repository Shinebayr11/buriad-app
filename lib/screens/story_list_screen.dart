import 'package:flutter/material.dart';

import '../data/story_repository.dart';
import '../models/story.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/heritage_frame.dart';
import 'story_player_screen.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key, this.genre, this.repository});

  final String? genre;
  final StoryRepository? repository;

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  late Future<List<Story>> _stories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _stories = (widget.repository ?? StoryRepository())
        .loadPublicStories()
        .then(
          (stories) => widget.genre == null
              ? stories
              : stories
                    .where((story) => story.genre == widget.genre)
                    .toList(growable: false),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.genre ?? 'Аман зохиол')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<Story>>(
            future: _stories,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.sync_problem,
                  title: 'Архивыг нээж чадсангүй',
                  message: 'Дахин оролдоно уу.',
                  action: FilledButton(
                    onPressed: () => setState(_load),
                    child: const Text('Дахин оролдох'),
                  ),
                );
              }
              final stories = snapshot.data ?? const [];
              if (stories.isEmpty) {
                return const EmptyState(
                  icon: Icons.graphic_eq,
                  title: 'Нийтлэх бичлэг алга',
                  message: 'Зөвшөөрөлтэй бичлэг нэмэгдэх үед энд харагдана. Бичлэгийн эрх тус бүрийг тусад нь шалгана.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.tengerSoft,
                        child: Icon(
                          story.genre == 'дуу'
                              ? Icons.music_note
                              : Icons.play_arrow,
                          color: AppColors.shar,
                        ),
                      ),
                      title: Text(
                        story.title.mongolian.isEmpty
                            ? 'Гарчиггүй бичлэг'
                            : story.title.mongolian,
                      ),
                      subtitle: Text(_subtitle(story)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StoryPlayerScreen(story: story),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _duration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes;
    final remaining = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$remaining';
  }

  String _subtitle(Story story) {
    if (story.genre == 'дуу') {
      final performer = story.performer.isEmpty
          ? 'Дуучин тэмдэглээгүй'
          : story.performer;
      final audio = story.audio.app.isEmpty
          ? 'Аудио хүлээгдэж байна'
          : _duration(story.audio.duration);
      return '$performer · $audio';
    }
    return '${story.genre} · ${_duration(story.audio.duration)} · ${_dialectLabel(story.narrator.dialect)}';
  }

  String _dialectLabel(String dialect) => switch (dialect) {
    'хори' => 'Хори аялгуу',
    'ага' => 'Ага аялгуу',
    'сартуул' => 'Сартуул аялгуу',
    'тэмдэглээгүй' => 'Аялгуу тэмдэглээгүй',
    _ => 'Аялгуу тэмдэглээгүй',
  };
}
