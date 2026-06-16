from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "lib"

PATTERN = re.compile(
    r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*"
    r"SnackBar\(content: Text\([^)]+\)\),\s*\);",
    re.MULTILINE | re.DOTALL,
)

for path in ROOT.rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    if "ScaffoldMessenger.of(context).showSnackBar" not in text:
        continue
    new = PATTERN.sub("context.showOperationError(e);", text)
    if new != text:
        path.write_text(new, encoding="utf-8")
        print(f"fixed errors in {path.relative_to(ROOT.parent)}")
