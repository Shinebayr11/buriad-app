import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';

/// Үгийн сангийн эх сурвалж.
///
/// Анхны сан багцад орсон assets/data/words.json. Хэрэглэгч «Үг нэмэх» хэсгээс
/// үг нэмэх, устгах, JSON оруулах бүрд бүхэл жагсаалтыг төхөөрөмж дээр
/// хадгална — вэб хувилбарын localStorage-ийн адил, апп хаагаад ч алдагдахгүй.
class WordStore {
  static const _assetPath = 'assets/data/words.json';
  static const _prefsKey = 'words_v1';

  Future<List<Word>> loadBundled() async {
    final text = await rootBundle.loadString(_assetPath);
    return Word.parseList(jsonDecode(text)) ?? const [];
  }

  /// Хэрэглэгчийн хадгалсан сан; байхгүй эсвэл эвдэрсэн бол null.
  Future<List<Word>?> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_prefsKey);
    if (text == null) return null;
    return decode(text);
  }

  Future<void> save(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, encode(words));
  }

  /// Хадгалсан саныг устгаж, багцын анхны сан руу буцаана.
  Future<void> clearSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// Экспортын формат — вэб хувилбарын «JSON татах»-тай яг ижил (2 зайн догол).
  static String encode(List<Word> words) =>
      const JsonEncoder.withIndent('  ')
          .convert(words.map((w) => w.toJson()).toList());

  /// Хэрэглэгчийн оруулсан JSON текст; бүтэц буруу бол null.
  static List<Word>? decode(String text) {
    try {
      return Word.parseList(jsonDecode(text));
    } catch (_) {
      return null;
    }
  }
}
