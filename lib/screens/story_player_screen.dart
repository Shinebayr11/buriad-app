import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/story.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/heritage_frame.dart';

class StoryPlayerScreen extends StatefulWidget {
  const StoryPlayerScreen({super.key, required this.story});

  final Story story;

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  final _player = AudioPlayer();
  final _subscriptions = <StreamSubscription<Object?>>[];
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _subscriptions
      ..add(
        _player.onPositionChanged.listen((position) {
          if (mounted) setState(() => _position = position);
        }),
      )
      ..add(
        _player.onPlayerStateChanged.listen((state) {
          if (mounted) setState(() => _state = state);
        }),
      )
      ..add(
        _player.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _position = Duration.zero);
        }),
      );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        final path = widget.story.audio.app;
        final assetPath = path.startsWith('assets/') ? path.substring(7) : path;
        await _player.play(AssetSource(assetPath));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бичлэгийг тоглуулж чадсангүй.')),
        );
      }
    }
  }

  Future<void> _seek(double seconds) async {
    final position = Duration(milliseconds: (seconds * 1000).round());
    await _player.seek(position);
    if (mounted) setState(() => _position = position);
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          story.title.mongolian.isEmpty ? 'Аман зохиол' : story.title.mongolian,
        ),
      ),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: story.audio.app.isEmpty
              ? const EmptyState(
                  icon: Icons.volume_off_outlined,
                  title: 'Бичлэг байхгүй байна',
                  message: 'Эх хэлтэй хүний бичлэг нэмэгдсэний дараа сонсох боломжтой.',
                )
              : Column(
                  children: [
                    _controls(),
                    const Divider(height: 1, color: AppColors.line),
                    Expanded(child: _segments()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _controls() {
    final total = widget.story.audio.duration;
    final current = (_position.inMilliseconds / 1000).clamp(0, total);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filled(
                onPressed: _togglePlayback,
                tooltip: _state == PlayerState.playing
                    ? 'Түр зогсоох'
                    : 'Тоглуулах',
                icon: Icon(
                  _state == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: current.toDouble(),
                  max: total <= 0 ? 1 : total,
                  onChanged: _seek,
                ),
              ),
              Text('${_time(current.toDouble())} / ${_time(total)}'),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _dialectLabel(widget.story.narrator.dialect),
              style: const TextStyle(color: AppColors.khadag),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segments() {
    final seconds = _position.inMilliseconds / 1000;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.story.segments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final segment = widget.story.segments[index];
        final active = seconds >= segment.start && seconds < segment.end;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active ? AppColors.tengerSoft : AppColors.tenger,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? AppColors.shar : AppColors.line,
              width: active ? 2 : 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buriad = _TranscriptColumn(
                label: 'Буриад бичвэр',
                text: segment.text.buriad,
                active: active,
              );
              final mongolian = _TranscriptColumn(
                label: 'Монгол орчуулга',
                text: segment.text.mongolian,
                active: active,
              );
              if (constraints.maxWidth < 440) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [buriad, const SizedBox(height: 14), mongolian],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: buriad),
                  const SizedBox(width: 20),
                  Expanded(child: mongolian),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _time(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  String _dialectLabel(String dialect) => switch (dialect) {
    'хори' => 'Хори аялгуу',
    'ага' => 'Ага аялгуу',
    'сартуул' => 'Сартуул аялгуу',
    _ => 'Аялгуу тэмдэглээгүй',
  };
}

class _TranscriptColumn extends StatelessWidget {
  const _TranscriptColumn({
    required this.label,
    required this.text,
    required this.active,
  });

  final String label;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.shar : AppColors.khadag,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(height: 1.5)),
      ],
    );
  }
}
