abstract class FailureExceptions {
  String message;

  FailureExceptions(this.message);

  @override
  String toString() {
    return message;
  }
}

class FailuerLocalException extends FailureExceptions {
  FailuerLocalException(super.message);
  @override
  String toString() {
    return super.message;
  }
}

class FailuerRemoteException extends FailureExceptions {
  FailuerRemoteException(super.message);
  @override
  String toString() {
    return super.message;
  }
}
