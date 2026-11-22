import importlib.machinery
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "bin/agent-proxy"
loader = importlib.machinery.SourceFileLoader("agent_proxy", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
proxy = importlib.util.module_from_spec(spec)
loader.exec_module(proxy)


class ClientSettingsTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.home = Path(self.directory.name)
        proxy.STATE = self.home / ".cli-proxy-api"
        proxy.PROFILE = proxy.STATE / "client.json"
        proxy.CLAUDE = self.home / ".claude/settings.json"
        proxy.T3 = self.home / ".t3/userdata/settings.json"
        self.template = self.home / "tracked.json"
        self.template.write_text(json.dumps({"env": {"EXISTING": "keep"}, "theme": "dark"}))
        proxy.CLAUDE.parent.mkdir()
        proxy.CLAUDE.symlink_to(self.template)
        proxy.save_json(proxy.T3, {"unrelated": True})
        proxy.save_json(proxy.PROFILE, {
            "role": "client", "url": "https://host.example:8317",
            "api_key": "private-client-key", "management_key": "private-management-key",
        })

    def test_credentials_never_enter_tracked_symlink_and_t3_reference_survives(self):
        proxy.apply()
        self.assertNotIn("private", self.template.read_text())
        self.assertFalse(proxy.CLAUDE.is_symlink())
        settings = proxy.read_json(proxy.CLAUDE)
        self.assertEqual(settings["env"]["EXISTING"], "keep")
        self.assertEqual(settings["env"]["ANTHROPIC_AUTH_TOKEN"], "private-client-key")
        self.assertTrue(proxy.read_json(proxy.T3)["autoResumeLimitedThreads"])
        self.assertEqual(proxy.read_json(proxy.T3)["providerInstances"]["claudeAgent"]["config"]["binaryPath"], str(proxy.REPO / "scripts/bin/claude-proxy"))
        self.assertEqual(proxy.CLAUDE.stat().st_mode & 0o777, 0o600)
        settings = proxy.read_json(proxy.T3)
        self.assertTrue(settings["unrelated"])
        settings["usageLimitSources"][proxy.SOURCE]["managementKey"] = "__secret_reference__"
        proxy.save_json(proxy.T3, settings)
        proxy.apply(self.template)
        self.assertEqual(proxy.read_json(proxy.T3)["usageLimitSources"][proxy.SOURCE]["managementKey"], "__secret_reference__")
        original = proxy.read_json(proxy.PROFILE)["claude_binary"]
        settings = proxy.read_json(proxy.T3)
        settings["providerInstances"]["claudeAgent"]["config"]["binaryPath"] = "/different/checkout/scripts/bin/claude-proxy"
        proxy.save_json(proxy.T3, settings)
        proxy.apply()
        self.assertEqual(proxy.read_json(proxy.PROFILE)["claude_binary"], original)

    def test_disabled_profile_stays_disabled_after_dotfiles_apply(self):
        proxy.apply()
        proxy.disable()
        template = proxy.read_json(self.template)
        template["theme"] = "light"
        proxy.save_json(self.template, template)
        proxy.apply(self.template)
        self.assertNotIn("ANTHROPIC_AUTH_TOKEN", proxy.read_json(proxy.CLAUDE)["env"])
        self.assertNotIn(proxy.SOURCE, proxy.read_json(proxy.T3)["usageLimitSources"])
        self.assertFalse(proxy.read_json(proxy.PROFILE)["enabled"])
        self.assertEqual(proxy.read_json(proxy.CLAUDE)["theme"], "light")

    def test_client_import_uses_private_copy_without_host_credentials(self):
        profile = proxy.read_json(proxy.PROFILE)
        profile.update(role="host", unrelated="do-not-import")
        transfer = self.home / "host-profile.json"
        proxy.save_json(transfer, profile)
        proxy.client(str(transfer))
        imported = proxy.read_json(proxy.PROFILE)
        self.assertEqual(imported["role"], "client")
        self.assertNotIn("unrelated", imported)
        self.assertEqual(proxy.PROFILE.stat().st_mode & 0o777, 0o600)

    def test_host_profile_cannot_be_overwritten_by_client_import(self):
        profile = proxy.read_json(proxy.PROFILE)
        profile["role"] = "host"
        proxy.save_json(proxy.PROFILE, profile)
        with self.assertRaises(SystemExit):
            proxy.client(str(proxy.PROFILE))
        self.assertEqual(proxy.read_json(proxy.PROFILE)["role"], "host")

    def test_empty_host_preserves_existing_claude_connection(self):
        profile = proxy.read_json(proxy.PROFILE)
        profile["role"] = "host"
        proxy.save_json(proxy.PROFILE, profile)
        proxy.apply()
        self.assertNotIn("ANTHROPIC_BASE_URL", proxy.read_json(proxy.CLAUDE)["env"])
        accounts = proxy.STATE / "accounts"
        accounts.mkdir()
        (accounts / "claude-account.json").write_text("{}")
        proxy.apply()
        self.assertEqual(proxy.read_json(proxy.CLAUDE)["env"]["ANTHROPIC_BASE_URL"], "http://127.0.0.1:8317")
        self.assertEqual(proxy.read_json(proxy.T3)["usageLimitSources"][proxy.SOURCE]["url"], "http://127.0.0.1:8317")
        self.assertEqual(proxy.read_json(proxy.PROFILE)["url"], profile["url"])


if __name__ == "__main__":
    unittest.main()
