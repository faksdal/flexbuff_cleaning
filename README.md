# flexbuff_cleaning

Small async CLI tool to list unique VLBI “sessions” found on one or more FlexBuff hosts and (eventually) clean them safely.

## Project layout

```
.
├── docs/
│   └── notes.md
├── LICENSE
├── pyproject.toml
├── README.md           <-- you are here
├── requirements.txt
├── scripts/
│   └── run_flexbuff_cleaning.py
├── src/
│   ├── flexbuff_cleaning/
│   │   ├── cli.py
│   │   ├── fb_cleaner.py
│   │   ├── __init__.py
│   │   ├── __main__.py
│   │   └── remote_setup.py
│   └── flexbuff_cleaning.egg-info/
└── tests/
    └── test_smoke.py
```

## What it does (right now)

- Connects to each **host** you pass on the command line (SSH).
- Runs a configurable remote command (defaults to `vbs_ls -hlrt`) and parses the output to list unique session names.
- Pretty-prints a counted, bullet-point list of sessions per host.

> Note: the CLI argument is named `paths`, but today it effectively means **hosts** (e.g., IPs/hostnames). This may be renamed later for clarity. Arguments are wired up in `cli.py`, which also provides `--dry-run` and `--version`.

## Requirements

- **Python**: 3.10+ recommended
- **Packages (pip)**:
  - `asyncssh` (core dependency)
  - (optional, dev) `pytest` for running tests
- **System**
  - An SSH client/key that can authenticate to your FlexBuff hosts
  - Remote command available on the target hosts (default: `vbs_ls -hlrt`). Change in `src/flexbuff_cleaning/remote_setup.py`.

A minimal `requirements.txt` could be:

```
asyncssh>=2.14.0
```

(If you want test tooling, add `pytest` too.)

## Install & run (from Git)

```bash
# 1) Clone
git clone https://github.com/<your-org-or-user>/flexbuff_cleaning.git
cd flexbuff_cleaning

# 2) Create & activate venv
python3 -m venv .venv
source .venv/bin/activate

# 3) Install deps
pip install -r requirements.txt

# 4A) Run as a module (recommended)
python -m flexbuff_cleaning [IP-1] [IP-2]

# 4B) Or via helper script
./scripts/run_flexbuff_cleaning.py [IP]
```

Both entry points call the same `main()` function (`__main__.py` just imports the CLI).

## Usage

```
usage: flexbuff-cleaning [-h] [--dry-run] [--version] paths [paths ...]

Clean flexbuff data safely and predictably.

positional arguments:
  paths         One or more hosts (IPs/DNS) to query

options:
  -h, --help    show this help message and exit
  --dry-run     Show what would happen, do not modify anything
  --version     Show program version and exit
```

The CLI surfaces the package version from `__init__.py`. Current version: `0.1.0`.

### Examples

List unique sessions on two hosts:

```bash
python -m flexbuff_cleaning [IP-1] [IP-2]
```

Dry-run (no changes—currently listing is read-only anyway, but this flag is future-proofing for actual cleaning actions):

```bash
python -m flexbuff_cleaning --dry-run [IP-1]
```

### Output (sample)

```
Host: [IP-1] [IP-2]
TOTAL: <first line from remote command>
Found 7 unique sessions:
    • r4873_r1
    • r4873_r2
    • …
```

## Configuration

Edit `src/flexbuff_cleaning/remote_setup.py`:

```python
DEFAULT_COMMAND  = 'vbs_ls -hlrt'
DEFAULT_USERNAME = 'oper'
DEFAULT_TIMEOUT  = 300
```

- **DEFAULT_USERNAME** is used for SSH login (change if needed).
- **DEFAULT_COMMAND** must exist on the remote FlexBuff hosts.
- **DEFAULT_TIMEOUT** is the SSH connect timeout (seconds).

## Internals (quick tour)

- `fb_cleaner.py`  
  - `fetch_data(host, user, command, timeout)` opens an SSH connection, runs the command, returns `host/rc/err/out`. Exceptions are caught and returned with `rc="255"`.  
  - `main_async(hosts)` gathers tasks concurrently, prints totals and a unique, counted session list (bulleted).  
  - `run(paths, _dry_run)` is the entry point invoked by CLI or script.  
- `cli.py`  
  - Argument parsing, `--dry-run`, `--version`, and `main(argv)` which calls `run(...)`.  
- `__main__.py`  
  - Enables `python -m flexbuff_cleaning`.  
- `__init__.py`  
  - Exposes `__version__`.  
- `scripts/run_flexbuff_cleaning.py`  
  - Convenience launcher that calls the same CLI `main`.  

## Tests

```bash
# Inside your venv
pip install pytest
pytest -q
```

There’s a tiny smoke test in `tests/test_smoke.py`.

## Troubleshooting

- **SSH auth errors**: ensure your local SSH key is accepted on the FlexBuff hosts (e.g., `ssh oper@10.0.109.33`). Update `DEFAULT_USERNAME` if needed.  
- **Timeouts**: bump `DEFAULT_TIMEOUT` in `remote_setup.py`.  
- **Missing remote command**: ensure `vbs_ls` (or your chosen command) exists on the host, or update `DEFAULT_COMMAND`.  
- **Weird parsing**: the session name is extracted from column 8 (`cols[7]`), split on `_` and joined from the first two parts; adjust if remote output format changes.  

## Roadmap

- Actual “cleaning” actions (with strong safeguards)
- Configurable output parsers
- Better error reporting and structured output (JSON)

## License

See [LICENSE](./LICENSE).
