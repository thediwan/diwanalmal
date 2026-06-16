import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib" / "features"


def depth_import(path: Path) -> str:
    rel = path.relative_to(ROOT.parent)
    ups = len(rel.parts) - 1
    return f"import {'../' * ups}core/extensions/context_feedback.dart';"


def transform(content: str) -> str:
    content = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*"
        r"SnackBar\(content: Text\(([^)]+)\)\),\s*\);",
        r"context.showWarningFeedback(\1);",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*"
        r"SnackBar\(\s*content: Text\([^)]*?\(e\.toString\(\)\)[^)]*\),\s*\),\s*\);",
        r"context.showOperationError(e);",
        content,
        flags=re.MULTILINE | re.DOTALL,
    )
    content = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*"
        r"SnackBar\(content: Text\(e\.toString\(\)\.replaceFirst\([^)]+\)\)\),\s*\);",
        r"context.showOperationError(e);",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\("
        r"SnackBar\(content: Text\(([^)]+)\)\)\);",
        r"context.showWarningFeedback(\1);",
        content,
    )
    return content


def main() -> None:
    for path in ROOT.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        if "ScaffoldMessenger.of(context).showSnackBar" not in text:
            continue
        new = transform(text)
        if new == text:
            continue
        if "context_feedback.dart" not in new:
            lines = new.splitlines()
            insert_at = 0
            for i, line in enumerate(lines):
                if line.startswith("import "):
                    insert_at = i + 1
            lines.insert(insert_at, depth_import(path))
            new = "\n".join(lines) + "\n"
        path.write_text(new, encoding="utf-8")
        print(f"updated {path.relative_to(ROOT.parents[1])}")


if __name__ == "__main__":
    main()
