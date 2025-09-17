# tests/test_smoke.py
from flexbuff_cleaning.fb_cleaner import run


def test_smoke():
    assert run(["/tmp"], dry_run=True) == 0
