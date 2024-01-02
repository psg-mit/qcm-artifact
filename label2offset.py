#!/usr/bin/env python3

import sys

LABELS = {}
lines = sys.stdin.readlines()

for i, line in enumerate(lines):
    words = line.split()
    if words[0][-1] == ':':
        LABELS[words[0][:-1]] = i

for i, line in enumerate(lines):
    words = line.split()
    if words[0][-1] == ':':
        words = words[1:]
    if ";" in words:
        words = words[:words.index(";")]

    for j, word in enumerate(words):
        if word in LABELS:
            offset = LABELS[word] - i
            if words[0].startswith("rj"):
                offset *= -1
            words[j] = "$" + ("+" if offset >= 0 else "") + str(offset)
    print(' '.join(words))
