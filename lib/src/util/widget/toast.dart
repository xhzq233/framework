enum ToastType {
  success,
  warning,
  error;

  static ToastType fromName(String name) => switch (name) {
        'success' => ToastType.success,
        'warning' => ToastType.warning,
        'error' => ToastType.error,
        _ => ToastType.success
      };
}
