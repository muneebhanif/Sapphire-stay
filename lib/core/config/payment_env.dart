/// Easypaisa account config via compile-time dart-defines.
class PaymentEnv {
  static const String easypaisaAccountTitle = String.fromEnvironment(
    'FLUTTER_EASYPAISA_ACCOUNT_TITLE',
    defaultValue: 'Sapphire Stay Hotel',
  );

  static const String easypaisaAccountNumber = String.fromEnvironment(
    'FLUTTER_EASYPAISA_ACCOUNT_NUMBER',
    defaultValue: '',
  );

  static bool get isConfigured => easypaisaAccountNumber.isNotEmpty;
}
