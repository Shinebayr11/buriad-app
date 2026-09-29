#!/usr/bin/env python3
"""Аппын текстийг багцалсан фонтууд дэмжиж буйг шалгана."""

from pathlib import Path
import json
import re
import sys

from fontTools.ttLib import TTFont


ROOT = Path(__file__).resolve().parents[1]
FONT_PATHS = (
    ROOT / "assets/fonts/Onest-Variable.ttf",
    ROOT / "assets/fonts/GolosText-Variable.ttf",
)
STRING_PATTERN = re.compile(r"(?s)(?:r)?(['\"])(.*?)(?<!\\)\1")


def dart_texts(path: Path) -> list[str]:
    return [match.group(2) for match in STRING_PATTERN.finditer(path.read_text())]


def json_texts(value: object) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        return [text for item in value for text in json_texts(item)]
    if isinstance(value, dict):
        return [
            text
            for key, item in value.items()
            for text in (*json_texts(key), *json_texts(item))
        ]
    return []


def app_characters() -> set[str]:
    texts: list[str] = []
    for path in ROOT.glob("lib/**/*.dart"):
        texts.extend(dart_texts(path))
    for path in ROOT.glob("assets/data/*.json"):
        texts.extend(json_texts(json.loads(path.read_text())))
    return {
        character
        for text in texts
        for character in text
        if not character.isspace() and character.isprintable()
    }


def supported_characters(path: Path) -> set[str]:
    font = TTFont(path)
    return {
        chr(codepoint)
        for table in font["cmap"].tables
        for codepoint in table.cmap
    }


def main() -> int:
    required = app_characters()
    failed = False
    for path in FONT_PATHS:
        missing = sorted(required - supported_characters(path))
        if missing:
            failed = True
            details = " ".join(f"{char} (U+{ord(char):04X})" for char in missing)
            print(f"АЛДАА: {path.name} фонтод дутуу тэмдэгт: {details}")
        else:
            print(f"ЗӨВ: {path.name} бүх {len(required)} тэмдэгтийг дэмжиж байна.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
