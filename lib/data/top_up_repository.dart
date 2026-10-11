import 'dart:math';

import '../wallet.dart';

class TopUpFailedException implements Exception {
  const TopUpFailedException(this.reason);

  final String reason;

  @override
  String toString() => 'TopUpFailedException($reason)';
}

abstract class TopUpApi {
  Future<void> topUp({required int amountMinor, required String idempotencyKey});
}

class TopUpRepository {
  TopUpRepository(this._api, {Random? random}) : _random = random ?? Random.secure();

  static const maxAttempts = 3;
  static const maxAmountMinor = 5000000;

  final TopUpApi _api;
  final Random _random;

  Future<void> topUp(Money amount) async {
    if (amount.minorUnits <= 0 || amount.minorUnits > maxAmountMinor) {
      throw ArgumentError.value(amount.minorUnits, 'amount', 'out of range');
    }

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _api.topUp(
          amountMinor: amount.minorUnits,
          idempotencyKey: _newKey(),
        );
        return;
      } on TimeoutException catch (_) {
        if (attempt == maxAttempts) {
          throw const TopUpFailedException('timeout');
        }
        await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
  }

  String _newKey() =>
      List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

class TimeoutException implements Exception {}
