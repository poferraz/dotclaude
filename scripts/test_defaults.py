"""Check the shipped defaults and export only into disposable directories."""
import concurrent.futures
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONVERTER = ROOT / "scripts/convert.sh"
PORTABLE = (ROOT / "config/CLAUDE.md").read_text().split("<!-- Claude Code only -->")[0].strip()


def run_export(directory, target):
    return subprocess.run(["sh", str(CONVERTER), target], cwd=directory, capture_output=True)


class DefaultsTest(unittest.TestCase):
    def test_optional_settings_do_not_preapprove_commands_or_start_workers(self):
        settings = json.loads((ROOT / "config/settings.json").read_text())
        self.assertEqual(settings["permissions"]["defaultMode"], "default")
        self.assertFalse(settings["permissions"].get("allow"))
        self.assertIs(settings["autoMemoryEnabled"], False)
        for key in ("hooks", "enabledPlugins", "extraKnownMarketplaces", "statusLine"):
            self.assertNotIn(key, settings)
        self.assertIn("Read(**/.env)", settings["permissions"]["deny"])
        for agent in (ROOT / "config/agents").glob("*.md"):
            self.assertNotIn("memory: user", agent.read_text())

    def test_each_host_gets_portable_instructions(self):
        outputs = {"codex": "AGENTS.md", "gemini": "GEMINI.md",
                   "cursor": ".cursor/rules/dotclaude.mdc", "aider": "dotclaude-conventions.md"}
        for name, expected in outputs.items():
            with self.subTest(target=name), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                self.assertEqual(run_export(root, name).returncode, 0)
                output = (root / expected).read_text()
                if name == "cursor":
                    self.assertTrue(output.startswith("---\n"))
                    self.assertIn("alwaysApply: true", output.split("---", 2)[1])
                    output = output.split("---", 2)[2]
                self.assertEqual(output.strip(), PORTABLE)
                if name == "aider":
                    self.assertEqual((root / ".aider.conf.yml").read_text(), "read:\n  - dotclaude-conventions.md\n")
                (root / expected).write_text("existing user file")
                self.assertNotEqual(run_export(root, name).returncode, 0)
                self.assertEqual((root / expected).read_text(), "existing user file")

    def test_conflicts_and_linked_parents_preserve_user_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / ".aider.conf.yml").write_text("existing: true")
            self.assertNotEqual(run_export(root, "aider").returncode, 0)
            self.assertFalse((root / "dotclaude-conventions.md").exists())
            other = root / "separate"
            other.mkdir()
            (root / ".cursor").symlink_to(other, target_is_directory=True)
            self.assertNotEqual(run_export(root, "cursor").returncode, 0)
            self.assertFalse(any(other.iterdir()))
            (root / "GEMINI.md").symlink_to(other / "missing")
            self.assertNotEqual(run_export(root, "gemini").returncode, 0)
            self.assertFalse((other / "missing").exists())

    def test_concurrent_exports_leave_one_complete_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
                results = list(pool.map(lambda _: run_export(tmp, "aider").returncode, range(4)))
            self.assertEqual(results.count(0), 1)
            self.assertEqual((Path(tmp) / "dotclaude-conventions.md").read_text().strip(), PORTABLE)
            self.assertEqual(sorted(p.name for p in Path(tmp).iterdir()), [".aider.conf.yml", "dotclaude-conventions.md"])


if __name__ == "__main__":
    unittest.main()
