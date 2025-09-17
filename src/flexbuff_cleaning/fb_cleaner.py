"""
Filename:   fb_cleaner.py
Author:     jole
Created:    17.09.2025
Description:

Notes:
"""

from typing import Sequence



def run(paths: Sequence[str], dry_run: bool = False) -> int:
    """
    Core entry point for the cleaner.
    Return process exit code (0 = ok).
    """
    # TODO: replace with your real implementation
    if dry_run:
        print("[dry-run] Would clean:", ", ".join(paths))
    else:
        print("Cleaning:", ", ".join(paths))
    return 0
