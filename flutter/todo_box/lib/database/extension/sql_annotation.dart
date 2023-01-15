extension ConvertBool on bool {
  String toEqual() {
    if (this) {
      return '=';
    }

    return '!=';
  }
}
