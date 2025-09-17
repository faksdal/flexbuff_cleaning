import sys

def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    print("flexbuff_cleaning: hello! (stub CLI)")
    if argv:
        print("Args:", " ".join(argv))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
