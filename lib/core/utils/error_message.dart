// lib/core/utils/error_mapper.dart

String getFriendly401Message(String errorMessage) {
  if (errorMessage.contains("Invalid credentials")) {
    return "Incorrect email or password. Please try again.";
  } else if (errorMessage.contains("You do not have a local password")) {
    return "You signed up using Google or Facebook. Please log in with your social account or use 'Forgot Password' to set a password.";
  } else if (errorMessage.contains("Account locked")) {
    return "Your account has been locked due to too many failed attempts. Please try again later or reset your password.";
  } else if (errorMessage.contains("Email not confirmed")) {
    return "Please verify your email before logging in.";
  } else if (errorMessage.contains("IP address not found")) {
    return "Unable to detect your IP address. Please check your internet connection.";
  } else {
    return "Unauthorized access. Please check your credentials and try again.";
  }
}

String map400ErrorToUserMessage(String errorMessage) {
  if (errorMessage.contains("password") && errorMessage.contains("too weak")) {
    return "Your password is too weak. Please use a stronger password with uppercase, lowercase, numbers, and symbols.";
  } else if (errorMessage.contains("email") &&
      errorMessage.contains("invalid")) {
    return "Invalid email format. Please enter a valid email address.";
  } else if (errorMessage.contains("required")) {
    return "All fields are required. Please fill in all the details.";
  } else {
    return "Bad request. Please review your input and try again.";
  }
}

String map401ErrorToUserMessage(String errorMessage) {
  if (errorMessage.contains("Invalid credentials")) {
    return "Incorrect email or password. Please double-check your credentials.";
  } else if (errorMessage.contains("You do not have a local password")) {
    return "You signed up using Google or Facebook. Please log in using that method or use 'Forgot Password' to set a new password.";
  } else if (errorMessage.contains("Account locked")) {
    return "Your account has been temporarily locked due to too many failed attempts. Please try again later or use 'Forgot Password'.";
  } else if (errorMessage.contains("Email not confirmed")) {
    return "Your email address is not verified. Please check your inbox and confirm your email.";
  } else if (errorMessage.contains("IP address not found")) {
    return "Network issue detected. Please check your internet connection and try again.";
  } else {
    return "An error occurred during login. Please try again later.";
  }
}
