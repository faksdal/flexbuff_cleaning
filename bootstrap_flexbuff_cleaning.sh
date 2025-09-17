#!/usr/bin/env bash
# Bootstrap a PyCharm-friendly Python project scaffold for "flexbuff_cleaning"
set -euo pipefail

PROJECT_NAME="flexbuff_cleaning"
PKG_DIR="src/${PROJECT_NAME}"

# --- sanity check ------------------------------------------------------------
BASE_NAME="$(basename "$PWD")"
if [[ "${BASE_NAME}" != "${PROJECT_NAME}" ]]; then
  echo "❌ Please run this script from the base directory named '${PROJECT_NAME}'."
  echo "   Current directory: '${BASE_NAME}'"
  exit 1
fi

command -v python3 >/dev/null 2>&1 || { echo "❌ python3 not found in PATH"; exit 1; }

# --- directories -------------------------------------------------------------
echo "📁 Creating directories..."
mkdir -p \
  "${PKG_DIR}" \
  scripts \
  tests \
  docs \
  .github/workflows \
  .vscode

# --- package files -----------------------------------------------------------
echo "🧩 Writing package files..."
cat > "${PKG_DIR}/__init__.py" <<EOF
\"\"\"flexbuff_cleaning\"\"\"
__all__ = []
__version__ = "0.1.0"
EOF

cat > "${PKG_DIR}/__main__.py" <<EOF
import sys

def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    print("flexbuff_cleaning: hello! (stub CLI)")
    if argv:
        print("Args:", " ".join(argv))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
EOF

# --- scripts -----------------------------------------------------------------
echo "🧰 Writing helper run script..."
cat > scripts/run_flexbuff_cleaning.py <<EOF
#!/usr/bin/env python3
\"\"\"Convenience runner for development.\"\"\"
from flexbuff_cleaning.__main__ import main

if __name__ == "__main__":
    raise SystemExit(main())
EOF
chmod +x scripts/run_flexbuff_cleaning.py

# --- tests -------------------------------------------------------------------
echo "🧪 Writing a tiny test..."
cat > tests/test_smoke.py <<EOF
from flexbuff_cleaning import __version__

def test_version():
    assert isinstance(__version__, str) and len(__version__) >= 5
EOF

# --- docs --------------------------------------------------------------------
echo "📝 Writing README and docs..."
cat > README.md <<EOF
# flexbuff_cleaning

Tiny scaffold created for a PyCharm \`.venv\` project.

## Quick start

\`\`\`bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
\`\`\`

## Run
\`\`\`bash
python -m flexbuff_cleaning
# or
python scripts/run_flexbuff_cleaning.py
\`\`\`
EOF

cat > docs/notes.md <<EOF
# Developer Notes

- Keep production code under \`src/\`.
- Use \`tests/\` for pytest.
- Use \`scripts/\` for small CLIs / utilities.
EOF

# --- licensing & config ------------------------------------------------------
CURRENT_YEAR="$(date +%Y)"
cat > LICENSE <<EOF
MIT License

Copyright (c) ${CURRENT_YEAR} <Your Name>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
EOF

cat > requirements.txt <<EOF
# Add your pinned deps here
# asyncssh
# rich
EOF

cat > pyproject.toml <<EOF
[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
addopts = "-q"
EOF

# --- .gitignore --------------------------------------------------------------
echo "🚫 Writing .gitignore..."
cat > .gitignore <<EOF
__pycache__/
*.py[cod]
*.pyo

.venv/
venv/
ENV/
env/

*.egg-info/
build/
dist/

.log/
*.log

.idea/
.vscode/
.DS_Store
Thumbs.db
EOF

# --- venv --------------------------------------------------------------------
if [[ ! -d ".venv" ]]; then
  echo "🐍 Creating virtual environment (.venv)..."
  python3 -m venv .venv || echo "⚠️ Could not create .venv (maybe install python3-venv)."
fi

# --- git init ----------------------------------------------------------------
if [[ ! -d ".git" ]]; then
  echo "🌱 Initializing git repo..."
  git init >/dev/null
  git add .
  git commit -m "Scaffold ${PROJECT_NAME} project structure" >/dev/null || true
  echo "✅ Git initialized with initial commit."
else
  echo "ℹ️ Git repo already exists; not re-initializing."
fi

echo "🎉 Done. Next steps:"
echo "   1) source .venv/bin/activate"
echo "   2) pip install -r requirements.txt"
echo "   3) python -m ${PROJECT_NAME}"
