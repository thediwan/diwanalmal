from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

SUCCESS_KEYS = [
    "transactionFormSaveSuccess",
    "transactionFormTransferSaveSuccess",
    "transactionFormDebtSaveSuccess",
    "transactionEditSaveSuccess",
    "transactionDebtSettleSuccess",
    "transactionDeleteSuccess",
    "authFingerprintSuccess",
    "authCodeCopied",
    "walletFormSaveSuccess",
    "walletFormDeleteSuccess",
    "currencyFormSaveSuccess",
    "currencyDeleteSuccess",
    "goalPlanSaveSuccess",
    "goalEditSaveSuccess",
    "goalEditDeleteSuccess",
    "onboardingBaseCurrencySuccess",
]

ERROR_KEYS = [
    "authFingerprintError",
    "authBiometricFailed",
    "authInvalidCredentials",
    "authSecurityCodeFailed",
]

for path in ROOT.rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    new = text
    for key in SUCCESS_KEYS:
        new = new.replace(
            f"context.showWarningFeedback({key}",
            f"context.showSuccessFeedback({key}",
        )
        new = new.replace(
            f"context.showWarningFeedback(l10n.{key}",
            f"context.showSuccessFeedback(l10n.{key}",
        )
        new = new.replace(
            f"context.showWarningFeedback(context.l10n.{key}",
            f"context.showSuccessFeedback(context.l10n.{key}",
        )
    for key in ERROR_KEYS:
        new = new.replace(
            f"context.showWarningFeedback({key}",
            f"context.showErrorFeedback({key}",
        )
        new = new.replace(
            f"context.showWarningFeedback(l10n.{key}",
            f"context.showErrorFeedback(l10n.{key}",
        )
        new = new.replace(
            f"context.showWarningFeedback(context.l10n.{key}",
            f"context.showErrorFeedback(context.l10n.{key}",
        )
    if new != text:
        path.write_text(new, encoding="utf-8")
        print(f"retagged {path.relative_to(ROOT.parent)}")
