# flexbuff-cleaning

Small toolkit to list unique sessions on flexbuff.

It requires a local file remote_setup.py which contains:
- DEFAULT_COMMAND     = 'vbs_ls -hlrt'
- DEFAULT_USERNAME    = 'oper'
- DEFAULT_TIMEOUT     = 300

## Install (dev)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -e .
