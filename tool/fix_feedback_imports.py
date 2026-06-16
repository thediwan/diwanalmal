from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

for path in ROOT.rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    new = text
    for depth in range(2, 6):
        bad = "import " + "../" * depth + "core/extensions/context_feedback.dart';"
        good = "import '" + "../" * depth + "core/extensions/context_feedback.dart';"
        new = new.replace(bad, good)
    if new != text:
        path.write_text(new, encoding="utf-8")
        print(f"fixed {path.relative_to(ROOT.parent)}")
