import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool onboardingDone;
  final int salary; // centavos; 0 se não informado
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.onboardingDone,
    this.salary = 0,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? onboardingDone,
    int? salary,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      salary: salary ?? this.salary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoURL, onboardingDone, salary, createdAt];
}
