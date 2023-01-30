typedef Validator<T> = String? Function(T value);
typedef AsyncValidator<T> = Future<String?> Function(T value);

/// Returns an error message for empty strings
String? requiredString(String value) => value.isEmpty ? 'Required' : null;

/// Returns an error message when the value is null
String? requiredField<T>(T value) => value == null ? 'Required' : null;

/// Returns a new validator for strings of `minLength`
Validator<String> minLengthString(int minLength) => (String value) =>
    value.length < minLength ? 'Must be $minLength or longer' : null;
