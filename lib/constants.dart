dynamic getValue(base, name, defaultValue) {
  try {
    return base[name] != null ? base[name] : defaultValue;
  } catch (e) {
    return defaultValue;
  }
}
