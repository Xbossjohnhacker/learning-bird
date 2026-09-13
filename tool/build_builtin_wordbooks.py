"""Deterministic extraction of app JSON assets from a pinned ECDICT CSV.

Usage: python tool/build_builtin_wordbooks.py .artifact_work/ecdict-source/ecdict.csv
This transforms licensed source data; it never edits application/user databases.
"""
import csv
import hashlib
import json
import re
import sys
from pathlib import Path

REVISION = 'bc015ed2e24a7abef49fc6dbbb7fe32c1dadaf8b'
SOURCE_SHA256 = '1a6947e04785db63613a92e14903cdae7954f7e84860b10e68e5c7cbb3f9c3cf'
SOURCE = 'https://github.com/skywind3000/ECDICT'
BOOKS = [
    ('kaoyan', '考研英语', {'ky'}, '考研分类参考词汇'),
    ('cet4', '大学英语四级', {'cet4'}, '四级分类参考词汇'),
    ('cet6', '大学英语六级', {'cet4', 'cet6'}, '六级词汇，包含四级基础词'),
]

def main():
    source = Path(sys.argv[1])
    if hashlib.sha256(source.read_bytes()).hexdigest() != SOURCE_SHA256:
        raise ValueError('Source does not match the pinned ECDICT revision')
    output = Path(__file__).resolve().parents[1] / 'assets' / 'wordbooks'
    output.mkdir(parents=True, exist_ok=True)
    collected = {key: {} for key, *_ in BOOKS}
    rejected = {key: 0 for key, *_ in BOOKS}
    with source.open(encoding='utf-8-sig', newline='') as stream:
        for row in csv.DictReader(stream):
            tags = set((row.get('tag') or '').split())
            selected = [key for key, _, match, _ in BOOKS if tags & match]
            if not selected:
                continue
            word = (row.get('word') or '').strip()
            meaning = (row.get('translation') or '').replace('\\n', '\n').strip()
            valid = (0 < len(word) <= 120 and re.search('[A-Za-z]', word)
                     and re.search('[\u3400-\u9fff]', meaning)
                     and not re.search('[\x00-\x1f\x7f\ufffd]', word)
                     and '\ufffd' not in meaning)
            for key in selected:
                if valid:
                    collected[key].setdefault(word.lower(), {'word': word, 'meaning': meaning})
                else:
                    rejected[key] += 1
    catalog = {'version': 1, 'source': SOURCE, 'revision': REVISION,
               'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'books': []}
    for key, name, tags, description in BOOKS:
        rows = [collected[key][word] for word in sorted(collected[key])]
        if len(rows) < 1000:
            raise ValueError(f'{key}: unexpectedly small dataset ({len(rows)})')
        payload = (json.dumps(rows, ensure_ascii=False, separators=(',', ':')) + '\n').encode('utf-8')
        (output / f'{key}.json').write_bytes(payload)
        item = {'id': key, 'name': name, 'description': description,
                'count': len(rows), 'tags': sorted(tags), 'excludedRows': rejected[key],
                'sha256': hashlib.sha256(payload).hexdigest()}
        catalog['books'].append(item)
        print(json.dumps(item, ensure_ascii=False))
    (output / 'catalog.json').write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

if __name__ == '__main__':
    main()
