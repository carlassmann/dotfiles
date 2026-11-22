import importlib.machinery
import importlib.util
import json
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "bin/claude-proxy"
loader = importlib.machinery.SourceFileLoader("claude_proxy", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
adapter = importlib.util.module_from_spec(spec)
loader.exec_module(adapter)


def failure(text="All credentials for model claude-opus-5-5 are cooling down (reset after 1h2m3s)"):
    return {"type": "assistant", "error": "rate_limit", "parent_tool_use_id": None, "session_id": "test", "message": {"content": [{"type": "text", "text": text}]}}


class CooldownTranslationTest(unittest.TestCase):
    def test_pool_deadline_reaches_both_t3_rate_limit_inputs(self):
        source = failure()
        event, assistant = [json.loads(line) for line in adapter.translate(json.dumps(source) + "\n", 1000)]
        self.assertEqual(event["type"], "rate_limit_event")
        self.assertEqual(event["rate_limit_info"], {"status": "rejected", "resetsAt": 4725})
        self.assertEqual(assistant["api_error_params"]["rate_limit_info"], event["rate_limit_info"])
        self.assertEqual(assistant["message"], source["message"])
        self.assertEqual(event["session_id"], source["session_id"])

    def test_passthrough_when_deadline_is_unknown_native_or_unrelated(self):
        messages = [failure("Limit reached"), failure("cooling down (reset after 0s)"), failure("cooling down (reset after 999999h)"), {"type": "result", "result": "cooling down (reset after 1h)"}, {**failure(), "parent_tool_use_id": "child"}, {**failure(), "api_error_params": {"rate_limit_info": {"resetsAt": 1234}}}]
        for message in messages:
            with self.subTest(message=message):
                line = json.dumps(message) + "\n"
                self.assertEqual(adapter.translate(line, 1000), [line])
        for line in ["diagnostic\n", "[]\n"]:
            self.assertEqual(adapter.translate(line, 1000), [line])

    def test_delay_formats_and_subsecond_margin(self):
        for duration, seconds in [("59s", 59), ("2m", 120), ("3h", 10800), ("2h5s", 7205)]:
            with self.subTest(duration=duration):
                info = adapter.reset_info(failure(f"cooling down (reset after {duration})"), 1000.8)
                self.assertEqual(info["resetsAt"], 1000 + seconds + 2)


if __name__ == "__main__":
    unittest.main()
