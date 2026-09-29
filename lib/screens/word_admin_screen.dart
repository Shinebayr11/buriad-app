import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/word_entry.dart';
import '../state/word_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/heritage_frame.dart';

class WordAdminScreen extends StatefulWidget {
  const WordAdminScreen({super.key, required this.controller});

  final WordController controller;

  @override
  State<WordAdminScreen> createState() => _WordAdminScreenState();
}

class _WordAdminScreenState extends State<WordAdminScreen> {
  Future<void> _showForm([WordEntry? word]) async {
    final result = await showDialog<WordEntry>(
      context: context,
      builder: (context) => WordFormDialog(initial: word),
    );
    if (result == null) return;
    try {
      if (word == null) {
        await widget.controller.add(result);
      } else {
        await widget.controller.update(word, result);
      }
      if (mounted) {
        _message(word == null ? 'Үг нэмэгдлээ.' : 'Үг шинэчлэгдлээ.');
      }
    } catch (_) {
      if (mounted) _message('Өөрчлөлтийг хадгалж чадсангүй.');
    }
  }

  Future<void> _delete(WordEntry word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Үгийг устгах уу?'),
        content: const Text('Энэ үйлдлийг буцаах боломжгүй.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.controller.delete(word);
      if (mounted) _message('Үг устгагдлаа.');
    } catch (_) {
      if (mounted) _message('Үгийг устгаж чадсангүй.');
    }
  }

  Future<void> _import() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final imported = await widget.controller.importJson(utf8.decode(bytes));
      if (!mounted) return;
      final skipped = imported.skipped == 0
          ? ''
          : ' ${imported.skipped} буруу бичлэгийг алгаслаа.';
      _message('${imported.words.length} үг орууллаа.$skipped');
    } on FormatException {
      if (mounted) _message('JSON файлын бүтэц буруу байна.');
    } catch (_) {
      if (mounted) _message('Файлыг оруулж чадсангүй.');
    }
  }

  Future<void> _export(BuildContext buttonContext) async {
    try {
      final box = buttonContext.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          title: 'Үгийн сан',
          subject: 'Үгийн сан',
          files: [
            XFile.fromData(
              utf8.encode(widget.controller.exportJson()),
              mimeType: 'application/json',
            ),
          ],
          fileNameOverrides: const ['buriad_words.json'],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) _message('Үгийн санг хуваалцаж чадсангүй.');
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Үгийн сан'),
        actions: [
          IconButton(
            onPressed: _import,
            tooltip: 'JSON оруулах',
            icon: const Icon(Icons.file_upload_outlined),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              onPressed: () => _export(buttonContext),
              tooltip: 'JSON хуваалцах',
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showForm,
        icon: const Icon(Icons.add),
        label: const Text('Үг нэмэх'),
      ),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              if (widget.controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (widget.controller.error != null &&
                  widget.controller.words.isEmpty) {
                return EmptyState(
                  icon: Icons.sync_problem,
                  title: 'Үгийн санг нээж чадсангүй',
                  message: 'Дахин оролдоно уу.',
                  action: FilledButton(
                    onPressed: widget.controller.load,
                    child: const Text('Дахин оролдох'),
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: widget.controller.search,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        labelText: 'Үг хайх',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(child: _wordList()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _wordList() {
    final words = widget.controller.visibleWords;
    if (widget.controller.words.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Үгийн сан хоосон байна',
        message:
            'Баталгаажсан үгээ JSON файлаар оруулах эсвэл гараар нэмнэ үү.',
        action: FilledButton.icon(
          onPressed: _showForm,
          icon: const Icon(Icons.add),
          label: const Text('Үг нэмэх'),
        ),
      );
    }
    if (words.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Илэрц олдсонгүй',
        message: 'Хайлтын утгаа өөрчилж үзнэ үү.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      itemCount: words.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          child: ListTile(
            leading: word.emoji.isEmpty
                ? const CircleAvatar(child: Icon(Icons.text_fields))
                : CircleAvatar(child: Text(word.emoji)),
            title: Text(word.buriad),
            subtitle: Text(
              [
                word.mongolian,
                if (word.dialect.isNotEmpty) word.dialect,
              ].join(' · '),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') _showForm(word);
                if (action == 'delete') _delete(word);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Засах')),
                PopupMenuItem(value: 'delete', child: Text('Устгах')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WordFormDialog extends StatefulWidget {
  const WordFormDialog({super.key, this.initial});

  final WordEntry? initial;

  @override
  State<WordFormDialog> createState() => _WordFormDialogState();
}

class _WordFormDialogState extends State<WordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _buriad;
  late final TextEditingController _mongolian;
  late final TextEditingController _emoji;
  late final TextEditingController _note;
  late final TextEditingController _audio;
  late final TextEditingController _source;
  late final TextEditingController _verifiedBy;
  String _dialect = '';

  @override
  void initState() {
    super.initState();
    final word = widget.initial;
    _buriad = TextEditingController(text: word?.buriad);
    _mongolian = TextEditingController(text: word?.mongolian);
    _emoji = TextEditingController(text: word?.emoji);
    _note = TextEditingController(text: word?.note);
    _audio = TextEditingController(text: word?.audioPath);
    _source = TextEditingController(text: word?.source);
    _verifiedBy = TextEditingController(text: word?.verifiedBy);
    _dialect = word?.dialect ?? '';
  }

  @override
  void dispose() {
    _buriad.dispose();
    _mongolian.dispose();
    _emoji.dispose();
    _note.dispose();
    _audio.dispose();
    _source.dispose();
    _verifiedBy.dispose();
    super.dispose();
  }

  void _insertLetter(String letter) {
    final selection = _buriad.selection;
    final start = selection.isValid ? selection.start : _buriad.text.length;
    final end = selection.isValid ? selection.end : _buriad.text.length;
    final updated = _buriad.text.replaceRange(start, end, letter);
    _buriad.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + letter.length),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      WordEntry(
        buriad: _buriad.text.trim(),
        mongolian: _mongolian.text.trim(),
        emoji: _emoji.text.trim(),
        note: _note.text.trim(),
        audioPath: _audio.text.trim(),
        dialect: _dialect,
        source: _source.text.trim(),
        verifiedBy: _verifiedBy.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Хаах',
            icon: const Icon(Icons.close),
          ),
          title: Text(widget.initial == null ? 'Үг нэмэх' : 'Үг засах'),
          actions: [
            TextButton(onPressed: _submit, child: const Text('Хадгалах')),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _buriad,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Буриад үг *'),
                validator: _required,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final letter in const ['Ү', 'Ө', 'Һ'])
                    ActionChip(
                      label: Text(letter),
                      onPressed: () => _insertLetter(letter),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mongolian,
                decoration: const InputDecoration(labelText: 'Монгол утга *'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emoji,
                decoration: const InputDecoration(labelText: 'Эможи'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Тайлбар, дүрэм'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _audio,
                decoration: const InputDecoration(labelText: 'Аудио зам'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _dialect,
                decoration: const InputDecoration(labelText: 'Аялгуу'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Тэмдэглээгүй')),
                  DropdownMenuItem(value: 'хори', child: Text('Хори')),
                  DropdownMenuItem(value: 'ага', child: Text('Ага')),
                  DropdownMenuItem(value: 'сартуул', child: Text('Сартуул')),
                ],
                onChanged: (value) => setState(() => _dialect = value ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _source,
                decoration: const InputDecoration(labelText: 'Эх сурвалж'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _verifiedBy,
                decoration: const InputDecoration(
                  labelText: 'Баталгаажуулсан хүн',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: const Text('Хадгалах')),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Заавал бөглөнө үү.';
    return null;
  }
}
