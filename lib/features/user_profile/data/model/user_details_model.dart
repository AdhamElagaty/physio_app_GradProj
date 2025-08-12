import '../../domain/entities/diabetes_type.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/movement_level.dart';
import '../../domain/entities/user_details.dart';

class UserDetailsModel extends UserDetails {
  const UserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.userName,
    required super.isTwoFactorEnabled,
    required super.gender,
    super.dateOfBirth,
    super.imageUrl,
    super.age,
    super.height,
    super.weight,
    super.isSmoker,
    super.movementLevel,
    super.diabetesType,
    super.bmi,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      userName: json['userName'],
      isTwoFactorEnabled: json['twoFactorEnabled'] == "enable",
      gender: json['gender'] != null ? _genderFromInt(int.tryParse(json['gender']) ?? 0) : null,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      imageUrl: json['imageUrl'],
      age: json['age'],
      // Ensure numeric types are parsed safely
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      isSmoker: json['isSmoker'],
      movementLevel: json['movementLevel'] != null ? _movementLevelFromInt(int.tryParse(json['movementLevel']) ?? 0) : null,
      diabetesType: json['diabetesType'] != null ? _diabetesTypeFromInt(int.tryParse(json['diabetesType']) ?? 0) : null,
      bmi: (json['bmi'] as num?)?.toDouble(),
    );
  }

  // Helper functions to map integers from JSON to Dart enums
  // These are based on your C# enum definitions (1-based index)
  static Gender _genderFromInt(int index) {
    switch (index) {
      case 2:
        return Gender.female;
      case 1:
      default:
        return Gender.male;
    }
  }

  static MovementLevel _movementLevelFromInt(int index) {
    switch (index) {
      case 2: return MovementLevel.low;
      case 3: return MovementLevel.medium;
      case 4: return MovementLevel.high;
      case 1:
      default:
        return MovementLevel.none;
    }
  }

  static DiabetesType _diabetesTypeFromInt(int index) {
    switch (index) {
      case 2: return DiabetesType.type2;
      case 3: return DiabetesType.gestational;
      case 4: return DiabetesType.prediabetes;
      case 5: return DiabetesType.none;
      case 1:
      default:
        return DiabetesType.type1;
    }
  }
}