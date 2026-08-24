#!/usr/bin/env python3
"""Deterministic randomized condition order within task/repetition blocks."""
from __future__ import annotations
import hashlib, random
def plan(tasks, conditions, repetitions, seed):
    cells=[]
    for repetition in range(1, repetitions + 1):
        for task in tasks:
            ordered=list(conditions); random.Random(f"{seed}:{task}:{repetition}").shuffle(ordered)
            cells.extend({"task_id":task,"condition_id":condition,"repetition":repetition,"id":hashlib.sha256(f"{task}:{condition}:{repetition}".encode()).hexdigest()} for condition in ordered)
    return cells
