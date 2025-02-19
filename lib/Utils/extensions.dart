extension listOptions on List {
  String showOptionsText() {
    if (this.length == 1) {
      return '1 option';
    } else {
      return '${this.length} options';
    }
  }
}

extension StringOps on String {
  bool isTrulyNotEmpty() {
    final String value = this.trim();
    if (value.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  String shortenString(int len) {
    final String value = this.trim() ?? '';
    if (value.length > len) {
      return value.substring(0, len) + '...';
    } else {
      return value;
    }
  }

  String firstLetterUpper() {
    if (this.length > 1) {
      return this[0].toUpperCase() +
          this.substring(1, this.length).toLowerCase();
    } else {
      return this;
    }
  }

  String commaFunction() {
    const commaSign = ',';
    final val = this.trim().split('.').first;
    final length = val.length;
    if (val.contains(commaSign)) {
      return val;
    } else {
      if (length > 3) {
        // if (length < 6) {
        return val.substring(0, length - 3) +
            commaSign +
            val.substring(length - 3);
        // } else {
        //   return '';
        // }
      } else {
        return val;
      }
    }
  }
}
