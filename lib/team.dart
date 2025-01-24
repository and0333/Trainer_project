// lib/models/team.dart
class Team {
  final String id;
  final String projectName;
  final String projectSpecialization;
  final List<String> members;

  Team({
    required this.id,
    required this.projectName,
    required this.projectSpecialization,
    required this.members,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectName': projectName,
    'projectSpecialization': projectSpecialization,
    'members': members,
  };

  static Team fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    projectName: json['projectName'],
    projectSpecialization: json['projectSpecialization'],
    members: List<String>.from(json['members']),
  );
}