enum CourierUserPreferencesStatus {

  optedIn(value: "OPTED_IN"),
  optedOut(value: "OPTED_OUT"),
  required(value: "REQUIRED"),
  unknown(value: "UNKNOWN");

  final String value;

  const CourierUserPreferencesStatus({
    required this.value,
  });

  factory CourierUserPreferencesStatus.fromJson(dynamic data) {
    switch (data) {
      case 'OPTED_IN':
        return CourierUserPreferencesStatus.optedIn;
      case 'OPTED_OUT':
        return CourierUserPreferencesStatus.optedOut;
      case 'REQUIRED':
        return CourierUserPreferencesStatus.required;
      default:
        return CourierUserPreferencesStatus.unknown;
    }
  }

}