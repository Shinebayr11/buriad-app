import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/word_store.dart';
import '../models/word.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/word_picture.dart';

/// Үг нэмэх (админ): маягт, Ү Ө Һ товчлуур, JSON солилцоо, үгийн жагсаалт.
class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.state});

  final GameState state;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _b = TextEditingController();
  final _m = TextEditingController();
  final _e = TextEditingController();
  final _n = TextEditingController();
  final _a = TextEditingController();
  final _bFocus = FocusNode();

  @override
  void dispose() {
    for (final c in [_b, _m, _e, _n, _a]) {
      c.dispose();
    }
    _bFocus.dispose();
    super.dispose();
  }

  /// Ү Ө Һ товчлуур: курсорын байрлалд үсэг оруулаад талбарт фокус үлдээнэ.
  void _insert(String ch) {
    final v = _b.value;
    final sel = v.selection;
    final start = sel.isValid ? sel.start : v.text.length;
    final end = sel.isValid ? sel.end : v.text.length;
    _b.value = TextEditingValue(
      text: v.text.replaceRange(start, end, ch),
      selection: TextSelection.collapsed(offset: start + ch.length),
    );
    _bFocus.requestFocus();
  }

  Future<void> _add() async {
    final b = _b.text.trim(), m = _m.text.trim();
    if (b.isEmpty || m.isEmpty) {
      _bFocus.requestFocus();
      return;
    }
    final e = _e.text.trim();
    await widget.state.addWord(
      Word(
        b: b,
        m: m,
        e: e.isEmpty ? Word.defaultMark : e,
        n: _n.text.trim(),
        a: _a.text.trim(),
      ),
    );
    for (final c in [_b, _m, _e, _n, _a]) {
      c.clear();
    }
  }

  /// «JSON татах»: утсан дээр татах гэдэг нь хуваалцах цонх (Файлд хадгалах,
  /// и-мэйл, AirDrop…) нээх гэсэн үг.
  Future<void> _export() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/buriad-ugs.json');
    await file.writeAsString(WordStore.encode(widget.state.words));
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      fileNameOverrides: const ['buriad-ugs.json'],
    );
  }

  Future<void> _import() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final bytes = res?.files.single.bytes;
    if (bytes == null) return;

    final String text;
    try {
      text = utf8.decode(bytes);
    } catch (_) {
      return _alert('JSON файлыг уншиж чадсангүй.');
    }
    List<Word>? list;
    try {
      list = Word.parseList(jsonDecode(text));
    } catch (_) {
      return _alert('JSON файлыг уншиж чадсангүй.');
    }
    if (list == null) {
      return _alert(
        'Файлын бүтэц таарахгүй байна. '
        'Бичлэг бүрд b (буриад) ба m (монгол) талбар байх ёстой.',
      );
    }
    await widget.state.replaceAll(list);
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuriadColors.tenger,
        title: Text('Анхны санг сэргээх үү?', style: display(size: 16)),
        content: Text(
          'Таны нэмсэн, устгасан бүх өөрчлөлт арилж, багцад орсон анхны үгийн сан буцна.',
          style: body(size: 14, color: BuriadColors.sutDim, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сэргээх'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.state.resetToBundled();
  }

  Future<void> _alert(String msg) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BuriadColors.tenger,
      content: Text(msg, style: body(size: 14, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Ойлголоо'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final words = widget.state.words;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Note(),
          _Label('Буриад үг'),
          _Field(controller: _b, focus: _bFocus, hint: 'жишээ нь: уһан'),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ch in 'ҮӨҺүөһ'.split(''))
                _KeyButton(ch, onTap: () => _insert(ch)),
            ],
          ),
          _Label('Монгол утга'),
          _Field(controller: _m, hint: 'жишээ нь: ус'),
          _Label('Зураг (эможи эсвэл зургийн хаяг)'),
          _Field(controller: _e, hint: '💧  эсвэл  https://...'),
          _Label('Тайлбар', suffix: '— заавал биш'),
          _Field(controller: _n, hint: 'Монгол с → буриад һ'),
          _Label('Дуудлагын файлын хаяг', suffix: '— заавал биш'),
          _Field(
            controller: _a,
            hint: 'https://.../uhan.m4a',
            keyboard: TextInputType.url,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MainButton(
                  text: 'Үг нэмэх',
                  onTap: _add,
                  display: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhostButton(text: 'JSON татах', onTap: _export),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhostButton(text: 'JSON оруулах', onTap: _import),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _FontCheck(),
          const SizedBox(height: 18),
          Text('ҮГИЙН САН · ${words.length}', style: label()),
          const SizedBox(height: 6),
          for (var i = 0; i < words.length; i++)
            _WordRow(word: words[i], onDelete: () => widget.state.removeAt(i)),
          const SizedBox(height: 16),
          GhostButton(text: 'Анхны санг сэргээх', onTap: _reset),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- хэсгүүд

class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: BuriadColors.shar.withValues(alpha: .1),
        border: Border.all(color: BuriadColors.shar.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          style: body(size: 13, height: 1.5),
          children: const [
            TextSpan(
              text: 'Жишээ өгөгдөл. ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: BuriadColors.shar,
              ),
            ),
            TextSpan(
              text:
                  'Аппад одоо байгаа 14 үгийг зөвхөн ажиллагааг үзүүлэх зорилгоор '
                  'оруулсан. Ашиглахаас өмнө Амин Тоонтогийн хэл шинжээчээр үг бүрийг, '
                  'ялангуяа аялгууны хувилбарыг заавал баталгаажуулна уу.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.suffix});

  final String text;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13, bottom: 5),
      child: Text.rich(
        TextSpan(
          text: text.toUpperCase(),
          style: label(),
          children: [
            if (suffix != null)
              TextSpan(
                text: ' $suffix',
                style: label().copyWith(letterSpacing: 0),
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.focus,
    this.keyboard,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focus;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BuriadColors.line),
    );
    return TextField(
      controller: controller,
      focusNode: focus,
      keyboardType: keyboard,
      style: body(size: 16),
      cursorColor: BuriadColors.shar,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: body(
          size: 16,
          color: BuriadColors.sutDim.withValues(alpha: .6),
        ),
        filled: true,
        fillColor: BuriadColors.khadag.withValues(alpha: .07),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: BuriadColors.shar),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton(this.ch, {required this.onTap});

  final String ch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$ch үсэг оруулах',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BuriadColors.khadag.withValues(alpha: .07),
            border: Border.all(color: BuriadColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ch,
            style: body(
              size: 15,
              weight: FontWeight.w600,
              color: BuriadColors.khadag,
            ),
          ),
        ),
      ),
    );
  }
}

class _FontCheck extends StatelessWidget {
  const _FontCheck();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorder(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ҮСГИЙН ШАЛГАЛТ', style: label()),
            const SizedBox(height: 6),
            Text('Үү Өө Һһ Ээ Ёё', style: display(size: 26, spacing: 1.5)),
            const SizedBox(height: 4),
            Text(
              'Дээрх зургаан үсэг дөрвөлжин хайрцаг болж харагдвал фонт буриад бичигт '
              'тохирохгүй байна. Апп фонтоо өөртөө багцалсан тул ингэж харагдах ёсгүй.',
              style: body(size: 12, color: BuriadColors.sutDim, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// CSS: border: 1px dashed var(--line); border-radius: 12px.
class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = BuriadColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => false;
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word, required this.onDelete});

  final Word word;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x178FC7DE))),
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(
              word.hasImage ? '🖼' : word.e,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.b, style: body(size: 14, weight: FontWeight.w600)),
                Text(word.m, style: body(size: 13, color: BuriadColors.sutDim)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'устгах',
            icon: Text(
              '×',
              style: body(size: 19, color: BuriadColors.sutDim, height: 1),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
