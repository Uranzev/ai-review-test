/// Money is stored as integer minor units (e.g. cents) to avoid floating-point
/// rounding errors.
class Money {
  const Money(this.minorUnits, {this.currency = 'MNT'});

  final int minorUnits;
  final String currency;

  Money operator +(Money other) {
    _checkCurrency(other);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _checkCurrency(other);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  bool operator <(Money other) {
    _checkCurrency(other);
    return minorUnits < other.minorUnits;
  }

  void _checkCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
  }

  @override
  String toString() => '$minorUnits $currency (minor units)';
}

class InsufficientFundsException implements Exception {
  const InsufficientFundsException();

  @override
  String toString() => 'InsufficientFundsException';
}

/// Data access goes through this abstraction so the UI never talks to the
/// network directly and tests can supply a fake.
abstract class WalletRepository {
  Future<Money> fetchBalance();

  /// [idempotencyKey] must be generated once per user intent and reused on
  /// retries so the backend never charges twice.
  Future<void> pay({required Money amount, required String idempotencyKey});
}

class InMemoryWalletRepository implements WalletRepository {
  InMemoryWalletRepository(this._balance);

  Money _balance;
  final Set<String> _processedKeys = {};

  @override
  Future<Money> fetchBalance() async => _balance;

  @override
  Future<void> pay({
    required Money amount,
    required String idempotencyKey,
  }) async {
    if (_processedKeys.contains(idempotencyKey)) return;
    if (amount.minorUnits <= 0) {
      throw ArgumentError.value(amount.minorUnits, 'amount', 'must be positive');
    }
    if (_balance < amount) throw const InsufficientFundsException();
    _balance = _balance - amount;
    _processedKeys.add(idempotencyKey);
  }
}
