abstract class ErrorExceptions {
  String message;

  ErrorExceptions(this.message);

  @override
  String toString() {
    return message;
  }
}

class ErrorLocalException extends ErrorExceptions {
  ErrorLocalException(super.message);
  @override
  String toString() {
    return super.message;
  }
}

class ErrorRemoteException extends ErrorExceptions {
  ErrorRemoteException(super.message);
  @override
  String toString() {
    return super.message;
  }
}
