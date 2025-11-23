class FirebaseException implements Exception {
  static const Map<String, String> _errors = {
    'EMAIL_EXISTS': 'This email address is already in use.',
    'OPERATION_NOT_ALLOWED': 'Password sign-in is disabled for this project.',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'Too many attempts. Try again later.',
    'EMAIL_NOT_FOUND': 'There is no user record corresponding to this email.',
    'INVALID_PASSWORD':'The password is invalid or the user does not have a password.',
    'USER_DISABLED': 'The user account has been disabled by an administrator.',
  };
  final String key;

  const FirebaseException(this.key);
  @override
  String toString() {
    if (_errors.containsKey(key)) {
      return _errors[key]!;
    } else {
      return 'An unknown error occurred: $key';
    }
  }
}
