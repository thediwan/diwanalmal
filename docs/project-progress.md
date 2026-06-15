# ديوان المال — وثيقة متابعة المشروع

> **آخر تحديث:** 10 يونيو 2026  
> **الغرض:** توثيق ما تم إنجازه، الوضع الحالي، وخطة العمل للمتابعة مع فريق التطوير.

---

## 1. نظرة عامة

**ديوان المال** (Dewan Al-Mal) تطبيق Flutter لإدارة المالية الشخصية يعمل **بدون إنترنت أولاً** (offline-first). المستخدم الواحد في المرحلة الأولى، مع تصميم لا يعيق دعم تعدد المستخدمين لاحقاً.

| البند | القيمة |
|-------|--------|
| اللغة الافتراضية | العربية (RTL إلزامي) |
| اللغة الثانوية | الإنجليزية (`lib/l10n/`) |
| إدارة الحالة | Provider |
| التوجيه | GoRouter |
| قاعدة البيانات المالية | SQLite عبر Drift — `lazarus.db` |
| الإعدادات والجلسة | Hive (`AppSettings`) |
| المصادقة البيومترية | `local_auth` |
| خط العناوين | قمرة (عند توفر الملفات) |
| خط النص | اليمامة (Alyamama) — حالياً Almarai/Cairo عبر `google_fonts` |

**اسم الحزمة التقني** (لم يتغيّر): `baytalmal`  
**معرّف التطبيق**: `com.example.baytalmal`

---

## 2. المبادئ المعمارية

1. **Offline-first** — كل البيانات المالية محلياً؛ لا اعتماد على الشبكة في المرحلة 1.
2. **مستخدم واحد** — `getActiveUserId()` يعيد أول مستخدم نشط.
3. **الرصيد محسوب** — لا يُخزَّن رصيد المحفظة؛ يُحسب من المعاملات والتحويلات.
4. **سعر الصرف مجمّد** — `exchange_rate` و`base_amount` تُحفظ لحظة إدخال المعاملة.
5. **العربية أولاً** — لا نصوص واجهة مكتوبة مباشرة في الكود؛ استخدم `context.l10n`.
6. **RTL** — كل شاشة جديدة تُختبر في العربية.

---

## 3. هيكل المشروع

```
lib/
├── core/           # الثيم، الألوان، الامتدادات، الويدجت المشتركة
│   ├── constants/  # AppConstants.appName = «ديوان المال»
│   ├── extensions/ # context.l10n
│   ├── theme/
│   └── widgets/    # AuthBackground, AppScaffoldShell, AppLifecycleObserver
├── features/
│   ├── auth/       # تسجيل، دخول، PIN، بصمة، رمز الأمان
│   ├── onboarding/ # اختيار العملة الأساسية
│   ├── dashboard/  # لوحة التحكم الرئيسية
│   ├── wallets/    # المحافظ (CRUD)
│   ├── settings/   # الإعدادات والعملات
│   ├── transactions/ # placeholder — قيد التطوير
│   └── profile/    # placeholder — قيد التطوير
├── database/       # Drift: الجداول، DAOs، البذور
├── l10n/           # app_ar.arb, app_en.arb
├── models/
├── providers/      # Settings, Currency, Wallet
├── router/         # GoRouter + إعادة التوجيه حسب حالة الجلسة
└── services/       # Auth, Hive, Lazarus, Biometric, Dashboard, Wallet...

docs/
├── project-progress.md              ← هذه الوثيقة
├── database-lazarus.md              ← مخطط قاعدة البيانات
├── dashboard-design-alignment-plan.md ← مواصفات لوحة التحكم
├── modules/auth.md                  ← وحدة المصادقة
└── seeds/dashboard-mockup.json      ← بيانات العرض المرجعية
```

---

## 4. ما تم إنجازه

### 4.1 الأساس والبنية التحتية

- [x] مشروع Flutter مع Provider + GoRouter
- [x] ثيم فاتح/داكن/تلقائي
- [x] تعريب كامل لشاشات المصادقة (`context.l10n`)
- [x] دعم RTL والعربية كلغة افتراضية في `main.dart`
- [x] قفل الجلسة عند إرسال التطبيق للخلفية (`AppLifecycleObserver`)
- [x] دعم منطقة الكاميرا الأمامية والـ notch (`SafeArea` + edge-to-edge)

### 4.2 وحدة المصادقة والأمان

| الميزة | الحالة | المسار |
|--------|--------|--------|
| شاشة البداية | ✅ | `/auth/splash` |
| تسجيل حساب محلي | ✅ | `/auth/register` |
| تسجيل الدخول بكلمة المرور | ✅ | `/auth/login` |
| إعداد PIN (4 أرقام) | ✅ | `/auth/setup-lock` |
| البصمة / Face ID (اختياري) | ✅ | `local_auth` |
| رمز الأمان للاسترداد | ✅ | `/auth/security-code` |
| قفل التطبيق (PIN/بصمة) | ✅ | `/auth/unlock` |
| نسيت كلمة المرور | ✅ | `/auth/reset-password` |
| إعادة التوجيه التلقائي | ✅ | `app_router.dart` |

**تدفق المستخدم الجديد:**
```
/auth/start → /auth/register → /auth/setup-lock → /auth/security-code → /onboarding → /
```

**تدفق المستخدم العائد (مقفل):**
```
/auth/splash → /auth/start أو /auth/unlock → التطبيق
```

**قواعد مهمة:**
- رمز الأمان يُنشأ في `AuthService.completeSecuritySetup()` وليس عند التسجيل.
- بعد حفظ PIN: `context.go('/auth/security-code', extra: code)` فقط — **لا** `notifyListeners()` قبل التنقل.
- `main.dart` يستخدم `context.select` لـ `themeMode` فقط لتجنب شاشة بيضاء.

### 4.3 قاعدة بيانات Lazarus (SQLite)

- [x] مخطط كامل: مستخدمون، عملات، محافظ، معاملات، ديون، أهداف، ميزانيات، مرفقات
- [x] `FinanceDao.computeWalletBalance()` — حساب الرصيد من المعاملات
- [x] بذور تلقائية عند أول تشغيل (`DatabaseSeedService`)
- [x] ترحيل لمرة واحدة من Hive للعملات/المحافظ
- [x] بيانات تجريبية: `demo` / `demo123` — PIN `1234` في DB (واجهة المصادقة ما زالت Hive)

**التفاصيل:** `docs/database-lazarus.md`

### 4.4 لوحة التحكم (Dashboard)

- [x] تطابق تصميم العميل: رأس، رصيد إجمالي، عملات، ملخص شهري، أهداف، رسم بياني، معاملات أخيرة
- [x] شريط تنقل سفلي (4 تبويبات): الرئيسية، المعاملات، المحافظ، الإعدادات
- [x] زر FAB لإضافة معاملة → `/transactions/add` (placeholder)
- [x] البيانات من Lazarus عبر `DashboardService`
- [x] سحب للتحديث (pull-to-refresh)

**الفجوات المعروفة مقابل التصميم:** `docs/dashboard-design-alignment-plan.md` §5

### 4.5 المحافظ والإعدادات

| الميزة | الحالة |
|--------|--------|
| قائمة المحافظ | ✅ |
| إضافة/تعديل/حذف محفظة | ✅ |
| إدارة العملات | ✅ |
| اختيار العملة الأساسية (onboarding) | ✅ (نصوص جزئياً غير معرّبة) |
| شاشة الإعدادات | ✅ (نصوص جزئياً غير معرّبة) |

### 4.6 إصلاحات الجلسة الأخيرة (يونيو 2026)

#### أ) إعادة تسمية التطبيق → «ديوان المال»

| الموقع | التغيير |
|--------|---------|
| `AppConstants.appName` | ديوان المال |
| `app_ar.arb` / `app_en.arb` | الاسم + حقوق النشر + التحذير الأمني |
| Android `AndroidManifest.xml` | `android:label` |
| iOS `Info.plist` | `CFBundleDisplayName` |
| Web / Windows / Linux | عنوان النافذة والتطبيق |

**لم يتغيّر:** اسم الحزمة `baytalmal`، معرّف التطبيق، أسماء الملفات التنفيذية.

#### ب) إصلاح البصمة / المصادقة البيومترية

| المشكلة | الحل |
|---------|------|
| `MainActivity` كان `FlutterActivity` | تغيير إلى `FlutterFragmentActivity` |
| ثيم Android غير AppCompat | `Theme.AppCompat.DayNight.NoActionBar` |
| Face ID بدون وصف على iOS | `NSFaceIDUsageDescription` |
| خيارات `local_auth` ناقصة | `stickyAuth`, `biometricOnly`, رسائل عربية |
| ملف | `lib/services/biometric_service.dart` |

#### د) إضافة هدف مالي (يونيو 2026)

| المرحلة | الوصف | المسار |
|---------|--------|--------|
| 1 — إدخال | اسم حر، مبلغ + عملة (قائمة منسدلة، افتراضي الأساسية)، مبلغ مدخر، تاريخ، أيقونة | `/goals/add` |
| 2 — حساب | مبلغ شهري = المتبقي ÷ الأشهر؛ مقارنة بالدخل/المصروف من المعاملات أو الراتب | خلف الكواليس |
| 3 — خطة | عرض الادخار الشهري والتاريخ + تحذيرات + قبول/تعديل/مقارنة | `/goals/plan` |

**قواعد التحذير:** ادخار شهري > 50% الدخل → تحذير لطيف؛ ادخار شهري > صافي الدخل → تاريخ غير واقعي.

**الحفظ:** لا يُكتب في `goals` إلا بعد «قبول الخطة».

**ملفات رئيسية:** `lib/features/goals/`, `lib/services/goal_service.dart`, `lib/services/goal_planning_service.dart`

#### ج) إصلاح المحتوى خلف الكاميرا الأمامية

| الملف | التغيير |
|-------|---------|
| `app_scaffold_shell.dart` | `SafeArea(bottom: false)` حول المحتوى |
| `auth_background.dart` | `SafeArea` لكل شاشات المصادقة |
| `main.dart` | `SystemUiMode.edgeToEdge` |
| `MainActivity.kt` | `WindowCompat.setDecorFitsSystemWindows(false)` |

---

## 5. الوضع الحالي لكل وحدة

| الوحدة | الحالة | ملاحظات |
|--------|--------|---------|
| المصادقة | 🟢 مكتمل | Hive للجلسة؛ SQL `auth_local` مبذور لكن غير موصول بالواجهة |
| Onboarding | 🟡 شبه مكتمل | يعمل؛ بعض النصوص hardcoded |
| Dashboard | 🟢 يعمل | فجوات تصميمية صغيرة (نسب %، أيقونات من DB) |
| المحافظ | 🟢 مكتمل | واجهة جديدة + تجميع افتراضي + بحث + بذور موحّدة |
| العملات | 🟢 مكتمل | متصل بـ Lazarus |
| المعاملات | 🔴 placeholder | قائمة وإضافة — «قريباً» |
| الملف الشخصي | 🔴 placeholder | `/profile` |
| النسخ الاحتياطي | ⬜ مرحلة 8 | معطّل في الإعدادات |
| التعريب الكامل | 🟡 جزئي | auth ✅ — settings/wallets/onboarding جزئياً |

---

## 6. خطة العمل (المراحل)

### المرحلة 1 — الأساس والعرض (الحالية) ✅ ~85%

**الهدف:** تطبيق يعمل بدون إنترنت مع مصادقة آمنة ولوحة تحكم حقيقية.

- [x] مصادقة كاملة (PIN + بصمة + رمز استرداد)
- [x] قاعدة Lazarus + بذور
- [x] لوحة تحكم متصلة بالبيانات
- [x] محافظ وعملات
- [x] إصلاحات المنصة (بصمة، safe area، التسمية)
- [ ] مواءمة بذور Dashboard 100% مع `dashboard-mockup.json`
- [ ] إزالة النسب المئوية الثابتة (+12% / −5%) — حساب من الشهر السابق
- [ ] تعريب settings / wallets / onboarding بالكامل

### المرحلة 2 — المعاملات والحركة المالية

**الهدف:** إدخال وعرض الدخل والمصروف والتحويلات.

- [ ] شاشة قائمة المعاملات (`/transactions`)
- [x] نموذج إضافة معاملة (`/transactions/add`) — دخل / مصروف + keypad
- [x] ربط بالفئات (`categories`) + بذور افتراضية
- [ ] تحويل بين المحافظ (`transfers`)
- [x] تحديث Dashboard تلقائياً بعد الإضافة
- [ ] فلترة وبحث (اختياري)

### المرحلة 3 — الديون والأهداف والميزانيات

- [ ] إدارة الديون (`debts` + `debt_payments`)
- [x] إضافة هدف مالي (3 مراحل: إدخال → حساب → خطة مقترحة)
- [x] تعديل/حذف الأهداف المالية (`/goals/:id`)
- [ ] ميزانيات شهرية حسب الفئة (`budgets`)
- [x] ربط زر «إضافة هدف» في Dashboard

### المرحلة 4 — توحيد المصادقة مع Lazarus

- [ ] نقل credentials من Hive إلى `auth_local` / `security_settings`
- [ ] مزامنة `user_settings` (عملة، لغة، ثيم) مع SQL
- [ ] إزالة الازدواجية بين Hive وLazarus للإعدادات

### المرحلة 5 — الملف الشخصي والتجربة

- [ ] شاشة الملف الشخصي (`app_users`: اسم، صورة)
- [ ] إشعارات الجرس (محلية)
- [ ] تحسينات RTL وresponsive
- [ ] خطوط قمرة واليمامة من assets

### المرحلة 6 — التقارير والتحليلات

- [ ] تقارير شهرية/سنوية
- [ ] تصدير PDF أو CSV (محلي)
- [ ] رسوم بيانية إضافية

### المرحلة 7 — الجودة والاختبار

- [ ] اختبارات وحدة لـ `FinanceDao` و`DashboardService`
- [ ] اختبار عقد البذور (`dashboard_seed_contract_test`)
- [ ] `flutter analyze` بدون تحذيرات جديدة
- [ ] اختبار يدوي على أجهزة Android/iOS متعددة

### المرحلة 8 — النسخ الاحتياطي والمزامنة المستقبلية

- [ ] نسخ احتياطي مشفّر محلي (ملف + استعادة)
- [ ] تصميم واجهة sync دون تنفيذ سحابي (عدم حظر multi-user)

---

## 7. الأولويات الفورية (الأسابيع القادمة)

| # | المهمة | الملفات المتوقعة | الأولوية |
|---|--------|------------------|----------|
| 1 | تعريب settings / wallets / onboarding | `settings_screen.dart`, `wallets_screen.dart`, `select_base_currency_screen.dart`, `app_ar.arb` | عالية |
| 2 | مواءمة `DatabaseSeedService` مع `dashboard-mockup.json` | `database_seed_service.dart` | عالية |
| 3 | شاشة إضافة معاملة (مصروف/دخل) | `features/transactions/` | عالية |
| 4 | قائمة المعاملات | `transactions_list_placeholder_screen.dart` | عالية |
| 5 | حساب نسبة التغيير الشهري في Dashboard | `dashboard_service.dart`, `dashboard_monthly_summary.dart` | متوسطة |
| 6 | أيقونات المعاملات من `categories` | `dashboard_service.dart` | متوسطة |

---

## 8. المسارات والتنقل

### مسارات التطبيق الرئيسية

```
/auth/splash
/auth/start | /auth/register | /auth/login | /auth/setup-lock
/auth/security-code | /auth/unlock | /auth/reset-password
/onboarding
/  (Dashboard — داخل ShellRoute)
/goals/add | /goals/plan | /goals/:id
/transactions | /transactions/add
/wallets | /wallets/add | /wallets/:id/edit
/settings | /settings/currencies | ...
/profile (خارج Shell)
```

### ترتيب إعادة التوجيه (`app_router.dart`)

1. لا حساب → `/auth/start`
2. لا PIN → `/auth/setup-lock`
3. يحتاج رمز الأمان → `/auth/security-code`
4. الجلسة مقفلة → `/auth/unlock`
5. لم يكتمل الإعداد → `/onboarding`
6. مسارات auth/onboarding بعد الاكتمال → `/`

---

## 9. تشغيل المشروع

### المتطلبات

- Flutter SDK ^3.5.4
- Dart ^3.5.4

### الأوامر

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

### بعد تغييرات native (Android/iOS)

```bash
# إيقاف التطبيق ثم إعادة البناء الكامل — Hot Reload لا يكفي
flutter run
```

### إعادة البذور (بيانات تجريبية جديدة)

1. احذف التطبيق من الجهاز/المحاكي، أو
2. امسح `lazarus.db` من مجلد بيانات التطبيق

### التحقق

```bash
flutter analyze
flutter build apk --debug
```

---

## 10. قواعد حرجة — لا تكسرها

1. **رمز الأمان** — يُولَّد في `completeSecuritySetup()` فقط.
2. **بعد حفظ PIN** — تنقل بـ `context.go` مع `extra: code`؛ لا `notifyListeners()` قبلها.
3. **قفل الجلسة** — على `paused`/`detached` فقط؛ ليس `inactive` (حتى لا تتعطل نافذة البصمة).
4. **الرصيد** — لا تخزّنه في جدول `wallets`؛ استخدم `WalletBalanceService`.
5. **النصوص** — لا `Text('حفظ')`؛ استخدم `context.l10n`.
6. **RTL** — اختبر كل شاشة جديدة بالعربية.
7. **Android للبصمة** — `MainActivity` يجب أن يبقى `FlutterFragmentActivity`.

---

## 11. قائمة متابعة سريعة للمطور

### عند بدء جلسة عمل

- [ ] `git pull` وقراءة آخر تحديث في هذه الوثيقة
- [ ] `flutter pub get` إذا تغيّر `pubspec.yaml`
- [ ] تحديد المهمة من **§7 الأولويات**

### عند إنهاء ميزة

- [ ] `flutter analyze`
- [ ] تعريب أي نص جديد في `app_ar.arb` + `app_en.arb`
- [ ] اختبار RTL
- [ ] تحديث هذه الوثيقة أو الوثيقة الفرعية المناسبة
- [ ] اختبار على جهاز حقيقي (بصمة + notch)

### اختبارات المصادقة

- [ ] تسجيل → PIN → رمز الأمان → onboarding
- [ ] قتل التطبيق منتصف التدفق — إعادة التوجيه صحيح
- [ ] قفل التطبيق → فتح بـ PIN والبصمة
- [ ] استعادة كلمة المرور برمز الأمان
- [ ] رمز خاطئ — رسالة خطأ واضحة

---

## 12. الوثائق المرتبطة

| الموضوع | الملف |
|---------|-------|
| مخطط قاعدة البيانات | `docs/database-lazarus.md` |
| وحدة المصادقة | `docs/modules/auth.md` |
| مواصفات لوحة التحكم | `docs/dashboard-design-alignment-plan.md` |
| بيانات البذور المرجعية | `docs/seeds/dashboard-mockup.json` |
| قواعد Cursor للمشروع | `.cursor/rules/` |

---

## 13. سجل التغييرات

| التاريخ | التغيير |
|---------|---------|
| 2026-06-09 | إعادة تسمية التطبيق إلى «ديوان المال» |
| 2026-06-09 | إصلاح البصمة (FlutterFragmentActivity + local_auth) |
| 2026-06-09 | إصلاح Safe Area للكاميرا الأمامية وedge-to-edge |
| 2026-06-09 | إعادة كتابة وثيقة متابعة المشروع بالكامل |
| 2026-06-09 | شاشة المحافظ الجديدة + بذور موحّدة مع Dashboard |
| 2026-06-09 | نموذج الخزائن متعددة العملات (`wallet_currency_accounts`) + واجهة محدّثة |

---

*للأسئلة أو تحديث الخطة: عدّل هذا الملف مع كل معلم رئيسي يُنجز.*
