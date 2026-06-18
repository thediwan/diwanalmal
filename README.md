# ديوان المال · Dewan Al-Mal

تطبيق Flutter لإدارة المالية الشخصية — **بدون إنترنت أولاً** (offline-first)، مستخدم واحد في المرحلة الأولى، مع تصميم لا يعيق دعم تعدد المستخدمين لاحقاً.

| | |
|---|---|
| **اسم العرض** | ديوان المال |
| **اسم الحزمة** | `baytalmal` |
| **معرّف التطبيق** | `com.example.baytalmal` |
| **الإصدار** | 1.0.0+1 |
| **Flutter / Dart** | ^3.5.4 |

---

## الميزات

### متوفرة حالياً

- **مصادقة محلية آمنة** — تسجيل، دخول، PIN (4 أرقام)، بصمة/Face ID، رمز استرداد، قفل الجلسة
- **لوحة تحكم** — رصيد إجمالي، عملات متعددة، ملخص شهري، أهداف، رسم مصروفات، معاملات أخيرة
- **المحافظ (الخزائن)** — إضافة، تعديل، حذف، بحث، أرصدة افتتاحية
- **المعاملات** — دخل، مصروف، تحويل بين المحافظ، ذمم (مدين/دائن)، فلترة وبحث
- **الأهداف المالية** — إدخال → خطة ادخار مقترحة → قبول/تعديل
- **الفئات** — فئتا نظام ثابتتان + إدارة فئات المستخدم
- **العملات** — CRUD + عملة أساسية
- **الإعدادات** — ثيم فاتح/داكن/تلقائي، إدارة العملات
- **تنسيق الأرقام** — Western / European / Plain (الواجهة في الإعدادات لاحقاً)
- **تعريب** — العربية (افتراضي، RTL) والإنجليزية عبر `lib/l10n/`

### قيد التطوير أو لاحقاً

| الوحدة | الحالة |
|--------|--------|
| الملف الشخصي | placeholder — `/profile` |
| تسديد/تحصيل الذمم | مخطط — `debt_payments` |
| الميزانيات الشهرية | مخطط — `budgets` |
| النسخ الاحتياطي | المرحلة 8 |
| توحيد المصادقة مع Lazarus SQL | المرحلة 4 |
| تعريب كامل | settings / wallets / onboarding جزئياً |

---

## المبادئ المعمارية

1. **Offline-first** — البيانات المالية محلياً في `lazarus.db`؛ لا اعتماد على الشبكة في المرحلة 1.
2. **مستخدم واحد** — `getActiveUserId()` يعيد أول مستخدم نشط.
3. **الرصيد محسوب** — لا يُخزَّن في جدول المحافظ؛ يُحسب من المعاملات والتحويلات.
4. **سعر الصرف مجمّد** — `exchange_rate` و`base_amount` تُحفظ لحظة إدخال المعاملة.
5. **العربية أولاً** — لا نصوص واجهة hardcoded؛ استخدم `context.l10n`.
6. **RTL إلزامي** — اختبر كل شاشة جديدة بالعربية.

---

## التقنيات

| الطبقة | التقنية |
|--------|---------|
| الواجهة | Flutter (Material 3) |
| الحالة | Provider |
| التوجيه | GoRouter |
| البيانات المالية | SQLite + [Drift](https://drift.simonbinder.eu/) → `lazarus.db` |
| الإعدادات والجلسة | Hive (`AppSettings`) |
| المصادقة البيومetrية | `local_auth` |
| خط العناوين | **Qomra** — `assets/fonts/Qomra.ttf` |
| خط النص | **Alyamama** — `assets/fonts/Alyamama.ttf` |
| التعريب | `flutter gen-l10n` — `app_ar.arb`, `app_en.arb` |

---

## هيكل المشروع

```
lib/
├── core/              # ثيم، ألوان، امتدادات، ويدجت مشتركة
├── features/
│   ├── auth/          # تسجيل، دخول، PIN، بصمة، رمز الأمان
│   ├── onboarding/    # اختيار العملة الأساسية
│   ├── dashboard/     # لوحة التحكم
│   ├── wallets/       # المحافظ
│   ├── transactions/  # المعاملات والذمم
│   ├── goals/         # الأهداف المالية
│   ├── categories/    # إدارة الفئات
│   ├── settings/      # الإعدادات والعملات
│   └── profile/       # placeholder
├── database/          # Drift: جداول، DAOs، بذور
├── l10n/
├── models/
├── providers/
├── router/
└── services/

docs/                  # وثائق المشروع (انظر أدناه)
assets/
├── fonts/             # Qomra.ttf, Alyamama.ttf
├── images/            # شعار التطبيق (light/dark حسب الثيم)
└── icon/              # أيقونة المنصات (app_icon.png)
```

---

## التشغيل

### المتطلبات

- Flutter SDK ^3.5.4
- Dart ^3.5.4
- لبناء **Windows**: Visual Studio مع أدوات C++ (راجع [Flutter desktop](https://docs.flutter.dev/platform-integration/windows/setup))

### الأوامر

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

### التحقق

```bash
flutter analyze
flutter build apk --debug
```

### إعادة توليد أيقونة التطبيق (جميع المنصات)

```bash
dart run flutter_launcher_icons
flutter clean
flutter build windows   # أو المنصة المطلوبة
```

> أيقونة Windows تُضمَّن في `.exe` من `windows/runner/resources/app_icon.ico` — Hot Reload لا يحدّثها.

### إعادة البذور (بيانات تجريبية)

1. احذف التطبيق من الجهاز/المحاكي، **أو**
2. امسح `lazarus.db` من مجلد بيانات التطبيق

> البذور التجريبية معطّلة افتراضياً (`SeedConstants.enabled = false`).

### بعد تغييرات native (Android / iOS / Windows)

أوقف التطبيق ثم نفّذ **إعادة بناء كاملة** — Hot Reload لا يكفي.

### Windows — MSVC 14.51+

إذا فشل البناء بخطأ `STL1011` (coroutine deprecated) في plugins مثل `local_auth_windows`، المشروع يتضمن workaround في `windows/CMakeLists.txt`:

```cmake
add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)
```

---

## تدفقات المصادقة

**مستخدم جديد:**

```
/auth/start → /auth/register → /auth/setup-lock → /auth/security-code → /onboarding → /
```

**مستخدم عائد (مقفل):**

```
/auth/splash → /auth/start أو /auth/unlock → التطبيق
```

**نسيت كلمة المرور:**

```
/auth/login → /auth/reset-password → /auth/login
```

### ترتيب إعادة التوجيه

1. لا حساب → `/auth/start`
2. لا PIN → `/auth/setup-lock`
3. يحتاج رمز الأمان → `/auth/security-code`
4. الجلسة مقفلة → `/auth/unlock`
5. لم يكتمل الإعداد → `/onboarding`
6. مسارات auth/onboarding بعد الاكتمال → `/`

---

## المسارات الرئيسية

```
/auth/splash | /auth/start | /auth/register | /auth/login
/auth/setup-lock | /auth/security-code | /auth/unlock | /auth/reset-password
/onboarding
/                          ← Dashboard (ShellRoute)
/transactions | /transactions/add
/wallets | /wallets/add | /wallets/:id/edit
/goals/add | /goals/plan | /goals/:id
/categories
/settings | /settings/currencies
/profile
```

---

## قاعدة البيانات Lazarus

ملف **`lazarus.db`** — مصدر الحقيقة المحلي للبيانات المالية.

```
wallet_balance = opening_balance + income − expense + transfers_in − transfers_out
```

| الجدول | الغرض |
|--------|--------|
| `app_users`, `auth_local`, `security_settings`, `user_settings` | المستخدم والمصادقة |
| `currencies`, `wallets`, `wallet_currency_accounts` | العملات والمحافظ |
| `transactions`, `transfers`, `categories` | الحركة المالية |
| `debts`, `debt_payments` | الذمم |
| `goals`, `budgets`, `attachments` | التخطيط والمرفقات |

**Hive** يحتفظ بإعدادات الجلسة (`AppSettings`) حتى اكتمال المرحلة 4 (توحيد المصادقة مع SQL).

التفاصيل الكاملة: [`docs/database-lazarus.md`](docs/database-lazarus.md)

---

## قواعد حرجة للمطورين

1. **رمز الأمان** — يُولَّد في `AuthService.completeSecuritySetup()` فقط.
2. **بعد حفظ PIN** — `context.go('/auth/security-code', extra: code)`؛ لا `notifyListeners()` قبل التنقل.
3. **قفل الجلسة** — على `paused`/`detached` فقط؛ ليس `inactive` (حتى لا تتعطل نافذة البصمة).
4. **الرصيد** — لا تخزّنه في `wallets`؛ استخدم `WalletBalanceService`.
5. **النصوص** — لا `Text('حفظ')`؛ استخدم `context.l10n`.
6. **RTL** — اختبر كل شاشة جديدة بالعربية.
7. **Android للبصمة** — `MainActivity` يجب أن يبقى `FlutterFragmentActivity`.

---

## الوثائق

| الموضوع | الملف |
|---------|-------|
| متابعة المشروع والخطة | [`docs/project-progress.md`](docs/project-progress.md) |
| مخطط قاعدة البيانات | [`docs/database-lazarus.md`](docs/database-lazarus.md) |
| مواصفات لوحة التحكم | [`docs/dashboard-design-alignment-plan.md`](docs/dashboard-design-alignment-plan.md) |
| وحدة المصادقة | [`docs/modules/auth.md`](docs/modules/auth.md) |
| تنسيق الأرقام | [`docs/modules/number-formatting.md`](docs/modules/number-formatting.md) |
| بيانات البذور المرجعية | [`docs/seeds/dashboard-mockup.json`](docs/seeds/dashboard-mockup.json) |
| قواعد Cursor | [`.cursor/rules/`](.cursor/rules/) |

---

## خارطة الطريق (ملخص)

| المرحلة | المحتوى | الحالة |
|---------|---------|--------|
| 1 | أساس، مصادقة، لوحة تحكم، محافظ | ~85% |
| 2 | المعاملات والتحويلات والذمم | مكتمل |
| 3 | أهداف، ديون (تسديد لاحقاً)، ميزانيات | جزئي |
| 4 | توحيد Hive ↔ Lazarus للمصادقة | مخطط |
| 5 | ملف شخصي، إشعارات، تحسينات UX | مخطط |
| 6 | تقارير وتصدير | مخطط |
| 7 | اختبارات وجودة | مخطط |
| 8 | نسخ احتياطي ومزامنة مستقبلية | مخطط |

التفاصيل والأولويات الفورية: [`docs/project-progress.md`](docs/project-progress.md)

---

## المنصات المدعومة

Android · iOS · Windows · macOS · Linux · Web

---

*آخر تحديث للوثائق: يونيو 2026 — راجع `docs/project-progress.md` لأحدث حالة المشروع.*
