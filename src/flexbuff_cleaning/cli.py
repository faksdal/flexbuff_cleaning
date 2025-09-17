# src/flexbuff_cleaning/cli.py

import argparse
import sys
from . import __version__
from .fb_cleaner import run


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="flexbuff-cleaning",
        description="Clean flexbuff data safely and predictably."
    )
    p.add_argument("paths", nargs="+", help="One or more paths to clean")
    p.add_argument("--dry-run", action="store_true", help="Show what would happen, do not modify anything")
    p.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    return p


def main(argv = None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    args = build_parser().parse_args(argv)

    return run(args.paths, dry_run = args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
