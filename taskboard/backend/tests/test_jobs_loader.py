from __future__ import annotations

import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.domain import BackupOptions, JobCatalog, JobDefinition, ScheduleDefinition  # noqa: E402
from app.jobs_loader import load_catalog, save_catalog  # noqa: E402


class JobsLoaderTests(unittest.TestCase):
    def test_command_job_persists_force_rclone_log_option(self) -> None:
        with TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "jobs.json"
            catalog = JobCatalog(
                jobs=[
                    JobDefinition(
                        key="trash",
                        order=1,
                        description="Очистка корзины",
                        timeout_seconds=3600,
                        enabled=True,
                        continue_on_error=False,
                        kind="command",
                        profile="standard",
                        schedule=ScheduleDefinition(enabled=True, mode="weekly", hour=16, weekdays=[0]),
                        command=["rclone", "delete", "mail:trash"],
                        options=BackupOptions(force_rclone_log=True),
                    )
                ],
                profiles={"standard": ["trash"]},
            )

            save_catalog(path, catalog)

            stored = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(stored["jobs"][0]["options"], {"force_rclone_log": True})

            loaded = load_catalog(path)
            self.assertTrue(loaded.get_job("trash").options.force_rclone_log)


if __name__ == "__main__":
    unittest.main()
