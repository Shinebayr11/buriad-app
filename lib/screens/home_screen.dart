import 'package:flutter/material.dart';

import '../state/word_controller.dart';
import '../theme.dart';
import '../widgets/heritage_frame.dart';
import 'memory_screen.dart';
import 'quiz_screen.dart';
import 'word_admin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final WordController controller;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openWords(BuildContext context) {
    _open(context, WordAdminScreen(controller: controller));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Буриад үг'),
        actions: [
          IconButton(
            onPressed: () => _openWords(context),
            tooltip: 'Үгийн сан',
            icon: const Icon(Icons.library_books_outlined),
          ),
        ],
      ),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                _Stats(wordCount: controller.words.length),
                const SizedBox(height: 28),
                Text(
                  'Тоглоом',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 360;
                    final cards = [
                      _FeatureCard(
                        icon: Icons.quiz_outlined,
                        title: 'Тааварлах',
                        description: '4 сонголтоос зөв хариултыг олно.',
                        onTap: () => _open(
                          context,
                          QuizScreen(
                            words: controller.words,
                            onAddWords: () => _openWords(context),
                          ),
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.grid_view_outlined,
                        title: 'Хос олох',
                        description: 'Эможи болон үгийг хослуулна.',
                        onTap: () => _open(
                          context,
                          MemoryScreen(
                            words: controller.words,
                            onAddWords: () => _openWords(context),
                          ),
                        ),
                      ),
                    ];
                    if (narrow) {
                      return Column(
                        children: [
                          cards.first,
                          const SizedBox(height: 12),
                          cards.last,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards.first),
                        const SizedBox(width: 12),
                        Expanded(child: cards.last),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Аман зохиол',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _emptyArchive(context),
                      child: const Text('Бүгдийг үзэх'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.25,
                  children: [
                    for (final genre in const [
                      ('Үлгэр', Icons.auto_stories_outlined),
                      ('Домог', Icons.landscape_outlined),
                      ('Түүх', Icons.history_edu_outlined),
                      ('Өгүүллэг', Icons.record_voice_over_outlined),
                    ])
                      _GenreCard(
                        title: genre.$1,
                        icon: genre.$2,
                        onTap: () => _emptyArchive(context),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _openWords(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Үг нэмэх, удирдах'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _emptyArchive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нийтлэх зөвшөөрөлтэй бичлэг одоогоор алга.'),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.wordCount});

  final int wordCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tengerSoft, AppColors.tenger],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatValue(label: 'Нийт үг', value: '$wordCount'),
          ),
          const SizedBox(
            height: 44,
            child: VerticalDivider(color: AppColors.line),
          ),
          const Expanded(
            child: _StatValue(label: 'Давталт', value: '0'),
          ),
        ],
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: const TextStyle(color: AppColors.sutDim)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.shar, size: 34),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(color: AppColors.sutDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.khadag),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
