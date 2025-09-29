"""
Filename:       fb_cleaner.py
Author:         jole
Created:        17.09.2025

Description:    Lists unique sessions on the flexbuff passed as parameter.

Notes:
"""

import asyncio
import asyncssh

from typing import Sequence, Dict, List

from remote_setup import DEFAULT_COMMAND, DEFAULT_USERNAME, DEFAULT_TIMEOUT



async def fetch_data(_host: str,
                     _username: str,
                     _command: str,
                     _timeout: float) -> Dict[str, str]:
    """
    Run one command over ssh to retrieve the file list

    :param _host:
    :param _username:
    :param _command:
    :param _timeout:

    :return:
    """

    try:
        print(f'Getting data from {_host}, please wait.')
        async with asyncssh.connect(
            _host,
            username        = _username,
            connect_timeout = _timeout
        ) as conn:
            result = await conn.run(_command, check = False)
            return {
                "host": _host,
                "rc":   str(result.exit_status),
                "err":  (result.stderr or "").strip(),
                "out":  (result.stdout or "").strip()
            }
    except (asyncssh.Error, OSError) as exc:
        return {
            "host": _host,
            "rc":   "255",
            "out":  "",
            "err":  str(exc)
        }



async def main_async(_paths: Sequence[str]) -> int:
    """

    :param _paths:

    :return:
    """

    tasks   = [fetch_data(p, DEFAULT_USERNAME, DEFAULT_COMMAND, DEFAULT_TIMEOUT) for p in _paths]
    results = await asyncio.gather(*tasks)

    for r in results:
        print(f"Host: {r['host']}")

        out = r['out']

        # --- Print first line with totals
        print(f"{out.splitlines()[0]}")

        # --- Split rest into lines, skip the first one
        lines = out.splitlines()[1:]

        session_list: List[str] = []
        current_session: str    = ""
        counter: int            = 0

        for line in lines:
            cols            = line.split()
            session_name = "_".join(cols[7].split("_", 2)[:2])

            if session_name != current_session:
                counter += 1
                session_list.append(session_name)
                current_session = session_name

        print(f"Found {counter} unique sessions:")
        print("\n".join(f"\t• {s}" for s in session_list))
        # print("    \n".join(session_list))
        print("\n")

        # for item in session_list:
        #     print(session_list)

    return 0



def run(_paths: Sequence[str], _dry_run: bool = False) -> int:
    """
    Core entry point for the cleaner.
    Return process exit code (0 = ok).
    """

    if _dry_run:
        print("[dry-run] Would clean:", ", ".join(_paths))
        return 0

    return asyncio.run(main_async(_paths))
