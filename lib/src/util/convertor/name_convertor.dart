//convert to first letter uppercase
extension ToFirstLetterUpperCase on String {
  String get firstLetterUpperCase {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }

  String get firstLetterLowerCase {
    if (isEmpty) {
      return this;
    }
    return this[0].toLowerCase() + substring(1);
  }
}

extension SnakeNormalize on String {
  // 将 snake_case 转换为 snake case
  String get snakeNormalize {
    if (isEmpty) {
      return this;
    }
    return firstLetterUpperCase.replaceAll("_", " ");
  }
}
