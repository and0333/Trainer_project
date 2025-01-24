// lib/models/mentor.dart
import 'team.dart';

class Mentor {
  final String id;
  final String name;
  final String specialization;
  final List<Team> teams;

  Mentor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.teams,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialization': specialization,
    'teams': teams.map((team) => team.toJson()).toList(),
  };

  static Mentor fromJson(Map<String, dynamic> json) => Mentor(
    id: json['id'],
    name: json['name'],
    specialization: json['specialization'],
    teams: (json['teams'] as List).map((team) => Team.fromJson(team)).toList(),
  );
}