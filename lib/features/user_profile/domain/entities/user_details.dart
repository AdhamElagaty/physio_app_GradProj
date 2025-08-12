import 'package:equatable/equatable.dart';

import 'diabetes_type.dart';
import 'gender.dart';
import 'movement_level.dart';

class UserDetails extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final bool isTwoFactorEnabled;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? imageUrl;
  final int? age;
  final double? height;
  final double? weight;
  final bool? isSmoker;
  final MovementLevel? movementLevel;
  final DiabetesType? diabetesType;
  final double? bmi;

  const UserDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.isTwoFactorEnabled,
    required this.gender,
    this.dateOfBirth,
    this.imageUrl,
    this.age,
    this.height,
    this.weight,
    this.isSmoker,
    this.movementLevel,
    this.diabetesType,
    this.bmi,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        userName,
        isTwoFactorEnabled,
        gender,
        dateOfBirth,
        imageUrl,
        age,
        height,
        weight,
        isSmoker,
        movementLevel,
        diabetesType,
        bmi,
      ];
}