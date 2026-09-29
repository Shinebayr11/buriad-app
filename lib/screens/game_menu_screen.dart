import 'package:flutter/material.dart';

import '../state/word_controller.dart';
import '../theme.dart';
import '../widgets/heritage_frame.dart';
import 'memory_screen.dart';
import 'quiz_screen.dart';
import 'word_admin_screen.dart';

class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key, required this.controller});

  final WordController controller;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Буриад үг')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                Text(
                  'Тоглоом',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _MenuCard(
                  icon: Icons.quiz_outlined,
                  title: 'Тааварлах',
                  description: '4 сонголтоос зөв хариултыг олно.',
                  onTap: () => _open(
                    context,
                    QuizScreen(
                      words: controller.words,
                      onAddWords: () => _open(
                        context,
                        WordAdminScreen(controller: controller),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.grid_view_outlined,
                  title: 'Хос олох',
                  description: 'Эможи болон үгийн 6 хосыг олно.',
                  onTap: () => _open(
                    context,
                    MemoryScreen(
                      words: controller.words,
                      onAddWords: () => _open(
                        context,
                        WordAdminScreen(controller: controller),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Үгийн сан',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _open(context, WordAdminScreen(controller: controller)),
                  icon: const Icon(Icons.library_books_outlined),
                  label: Text('${controller.words.length} үг · Удирдах'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.tengerSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.shar),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.sutDim),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
