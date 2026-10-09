# Review Rules

Severity guide: **Critical** = money loss, security, data leak, crash in a payment flow.
**Major** = likely bug, leak, or rule violation with user impact. **Minor** = maintainability.

## 1. Payments

- **No `double` for money.** Amounts must be integer minor units (`int` cents/möngö)
  or a decimal type (e.g. `Decimal` from `package:decimal`). Flag `double`/`num`
  used for amounts, balances, prices, fees, or any arithmetic on them, and parsing
  money with `double.parse`. Formatting for display is the only place a conversion
  is acceptable. (Critical)
- **Idempotency.** Every request that moves money (charge, transfer, refund, top-up,
  withdraw) must send an idempotency key that is generated once per user intent and
  reused on retry. Flag: no key, a new key generated inside a retry loop, or
  retries of non-idempotent calls. Also flag pay buttons that can be tapped twice
  while a request is in flight. (Critical)
- **No secrets or sensitive data in logs.** Flag `print`, `debugPrint`, `log`,
  logger calls, analytics events, or exception messages that include tokens,
  passwords, PINs, OTPs, card numbers (PAN), CVV, full account numbers, or raw
  request/response bodies of payment APIs. (Critical)
- **Secure storage.** Tokens, PINs, and credentials must use
  `flutter_secure_storage` (Keychain/Keystore). Flag `SharedPreferences`, plain
  files, Hive/sqflite without encryption, or hardcoded keys/secrets in source. (Critical)
- Validate amounts on input (non-negative, max limits) and never trust client-side
  totals as final. (Major)

## 2. Flutter

- **`mounted` across async gaps.** After any `await` inside a `State` method, check
  `if (!mounted) return;` before using `context`, `setState`, `Navigator`,
  `ScaffoldMessenger`, or `Theme.of`. In `StatelessWidget`/callbacks use
  `context.mounted`. (Major)
- **Dispose everything.** `TextEditingController`, `AnimationController`,
  `ScrollController`, `FocusNode`, `StreamSubscription`, `Timer`, `PageController`,
  and `ChangeNotifier`s created in a `State` must be disposed/cancelled in
  `dispose()`. (Major)
- **No heavy work in `build`.** Flag network calls, database/file I/O, JSON parsing
  of large data, sorting/filtering large lists, creating controllers, or starting
  futures/streams inside `build`. Use `initState`, state management, or
  memoization. `FutureBuilder(future: fetch())` created in `build` counts. (Major)
- Prefer `const` constructors where possible. (Minor)

## 3. Architecture

- **Repository layer.** Widgets and UI state must not call HTTP clients
  (`http`, `Dio`), platform channels, or storage directly. Data access goes through
  a repository (`*Repository`) that the UI/state layer depends on via an
  abstraction, so it can be mocked in tests. (Major)
- Repositories return domain models, not raw `Map<String, dynamic>` or
  `Response` objects. (Minor)
- Errors from repositories are typed/handled; no silently swallowed exceptions
  (`catch (_) {}`) in payment paths. (Major)
