/// Error reported by the native location button.
class LocationButtonException {
  const LocationButtonException(this.code, this.message);

  final String code;
  final String? message;

  @override
  String toString() => 'LocationButtonException($code, $message)';
}
