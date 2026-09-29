import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/buriad_text.dart';
import '../models/word_entry.dart';
import '../state/word_controller.dart';
import '../theme.dart';
import '../widgets/heritage_frame.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, required this.controller});

  final WordController controller;

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Үгийн сан')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              final words = searchAndSortWords(widget.controller.words, _query);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        labelText: 'Үг, тайлбараар хайх',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: words.isEmpty
                        ? Center(
                            child: Text(
                              _query.trim().isEmpty
                                  ? 'Үгийн сан хоосон байна'
                                  : 'Илэрц олдсонгүй',
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                            itemCount: words.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) =>
                                _WordCard(word: words[index]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word});

  final WordEntry word;

  Future<void> _openSource(BuildContext context) async {
    final uri = Uri.tryParse(word.source);
    if (uri == null || !await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Эх сурвалжийг нээж чадсангүй.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word.buriad, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(word.mongolian),
            if (word.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(word.note, style: const TextStyle(color: AppColors.sutDim)),
            ],
            if (word.verifiedBy.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Баталгаажуулсан эх сурвалж: ${word.verifiedBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (word.source.isNotEmpty) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => _openSource(context),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Эх сурвалжийг нээх'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
