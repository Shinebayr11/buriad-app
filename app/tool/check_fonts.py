#!/usr/bin/env python3
"""Багцалсан фонтууд аппын бүх текстийг гаргаж чадахыг шалгана.

Ажиллуулах:  python3 tool/check_fonts.py
Шаардлага:   pip3 install fonttools

Буриад бичигт Ү Ө Һ үсэг зайлшгүй. Фонт солих эсвэл шинэ тэмдэгт нэмэх бүрд
энэ шалгалтыг ажиллуулж, дөрвөлжин хайрцаг гарахаас сэргийлнэ.
"""
import glob
import io
import json
import re
import sys
import unicodedata

from fontTools.ttLib import TTFont

# Буриад бичигт заавал байх ёстой үсгүүд
REQUIRED = "ҮүӨөҺһЁёЭэ"

# Текстээр хэзээ ч зурдаггүй тэмдэгтүүд.
# ◈ — үгэнд зураг ороогүйг заах өгөгдлийн тэмдэг (Word.defaultMark).
#     Дэлгэцэд DefaultMark widget ромбыг зурж гаргадаг тул фонт хэрэггүй.
NOT_RENDERED_AS_TEXT = "◈"


def cmap(path):
    font = TTFont(path, lazy=True)
    chars = set()
    for table in font["cmap"].tables:
        chars |= set(table.cmap.keys())
    return chars


def collect_chars():
    """Dart эх код болон үгийн сангаас хэрэглэгчид харагдах тэмдэгтүүдийг цуглуулна."""
    found = {}
    for path in glob.glob("lib/**/*.dart", recursive=True):
        src = io.open(path, encoding="utf-8").read()
        for m in re.finditer(r"'([^'\\\n]*)'|\"([^\"\\\n]*)\"", src):
            literal = m.group(1) or m.group(2) or ""
            if literal.startswith(("package:", "assets/", "dart:", ".", "/")):
                continue
            for ch in literal:
                found.setdefault(ch, path)

    for word in json.load(open("assets/data/words.json", encoding="utf-8")):
        for key in ("b", "m", "n"):
            for ch in word.get(key, ""):
                found.setdefault(ch, "assets/data/words.json")
    return found


def main():
    fonts = {p: cmap(p) for p in sorted(glob.glob("assets/fonts/*.ttf"))}
    if not fonts:
        print("assets/fonts/ дотор фонт алга"); return 1

    problems = []

    # 1) Заавал байх ёстой үсгүүд фонт бүрд бий эсэх
    for path, chars in fonts.items():
        missing = [c for c in REQUIRED if ord(c) not in chars]
        if missing:
            problems.append(f"{path}: заавал байх үсэг дутуу → {' '.join(missing)}")

    # 2) Аппын бүх текст ядаж нэг фонтод багтах эсэх
    #    (эможи болон тусгай тэмдгийг системийн эможи фонт зурдаг тул алгасна)
    any_font = set().union(*fonts.values())
    for ch, where in sorted(collect_chars().items()):
        cp = ord(ch)
        if cp < 0x20 or cp in any_font:
            continue
        if ch in NOT_RENDERED_AS_TEXT:
            continue
        if cp >= 0x1F000 or 0x2600 <= cp <= 0x27BF or cp in (0xFE0F, 0x200D):
            continue  # эможи
        name = unicodedata.name(ch, f"U+{cp:04X}")
        problems.append(f"{where}: {ch!r} ({name}) ямар ч багцалсан фонтод алга")

    if problems:
        print("ФОНТЫН ШАЛГАЛТ УНАЛАА:")
        for p in problems:
            print("  •", p)
        return 1

    print(f"Фонтын шалгалт OK — {len(fonts)} фонт, бүх текст багтана.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
