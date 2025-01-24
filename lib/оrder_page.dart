// lib/mentor_page.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sclad/team.dart';
import 'package:sclad/warehouse_entiti.dart';
import 'package:sclad/warehouse_repository.dart';

class MentorPage extends StatefulWidget {
  final Logger logger;

  MentorPage({required this.logger});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectSpecializationController = TextEditingController();
  final TextEditingController _teamMembersController = TextEditingController();
  final TextEditingController _newMemberController = TextEditingController();
  final MentorRepository _mentorRepository;

  _MentorPageState() : _mentorRepository = MentorRepository(logger: Logger());

  List<Mentor> _mentors = [];
  final List<String> _specializations = ['Math', 'Science', 'Literature']; // Example specializations
  final int _maxTeamsPerMentor = 5;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    final mentors = await _mentorRepository.getMentors();
    setState(() {
      _mentors = mentors;
    });
  }

  Future<void> _showAddMentorDialog([Mentor? mentorToEdit]) async {
    if (mentorToEdit != null) {
      _nameController.text = mentorToEdit.name;
      _specializationController.text = mentorToEdit.specialization;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(mentorToEdit == null ? 'Добавить наставника' : 'Редактировать наставника'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _specializationController.text.isNotEmpty ? _specializationController.text : null,
                items: _specializations.map((specialization) {
                  return DropdownMenuItem(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) {
                  _specializationController.text = value!;
                },
                decoration: InputDecoration(labelText: 'Специализация', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = _nameController.text;
                final specialization = _specializationController.text;

                if (mentorToEdit == null) {
                  final mentor = Mentor(
                    id: DateTime.now().toString(),
                    name: name,
                    specialization: specialization,
                    teams: [],
                  );

                  await _mentorRepository.addMentor(mentor);
                  widget.logger.i('Added mentor: $mentor');

                  setState(() {
                    _mentors.add(mentor);
                  });
                } else {
                  final mentor = Mentor(
                    id: mentorToEdit.id,
                    name: name,
                    specialization: specialization,
                    teams: mentorToEdit.teams,
                  );

                  await _mentorRepository.updateMentor(mentor);
                  widget.logger.i('Updated mentor: $mentor');

                  setState(() {
                    _mentors[_mentors.indexOf(mentorToEdit)] = mentor;
                  });
                }

                Navigator.of(context).pop();
                _nameController.clear();
                _specializationController.clear();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddTeamDialog(Mentor mentor, [Team? teamToEdit]) async {
    if (teamToEdit != null) {
      _projectNameController.text = teamToEdit.projectName;
      _projectSpecializationController.text = teamToEdit.projectSpecialization;
      _teamMembersController.text = teamToEdit.members.join(', ');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(teamToEdit == null ? 'Добавить команду' : 'Редактировать команду'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _projectNameController,
                decoration: InputDecoration(labelText: 'Наименование проекта', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _projectSpecializationController.text.isNotEmpty ? _projectSpecializationController.text : null,
                items: _specializations.map((specialization) {
                  return DropdownMenuItem(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) {
                  _projectSpecializationController.text = value!;
                },
                decoration: InputDecoration(labelText: 'Специализация проекта', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _teamMembersController,
                decoration: InputDecoration(labelText: 'Члены команды (через запятую)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final projectName = _projectNameController.text;
                final projectSpecialization = _projectSpecializationController.text;
                final members = _teamMembersController.text.split(',').map((e) => e.trim()).toList();

                if (projectSpecialization != mentor.specialization) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Специализация команды не соответствует специализации наставника')),
                  );
                  return;
                }

                if (mentor.teams.length >= _maxTeamsPerMentor) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Превышен лимит команд у наставника')),
                  );
                  return;
                }

                if (teamToEdit == null) {
                  final team = Team(
                    id: DateTime.now().toString(),
                    projectName: projectName,
                    projectSpecialization: projectSpecialization,
                    members: members,
                  );

                  mentor.teams.add(team);
                  await _mentorRepository.updateMentor(mentor);
                  widget.logger.i('Added team: $team to mentor: $mentor');
                } else {
                  final team = Team(
                    id: teamToEdit.id,
                    projectName: projectName,
                    projectSpecialization: projectSpecialization,
                    members: members,
                  );

                  mentor.teams[mentor.teams.indexOf(teamToEdit)] = team;
                  await _mentorRepository.updateMentor(mentor);
                  widget.logger.i('Updated team: $team in mentor: $mentor');
                }

                setState(() {});

                Navigator.of(context).pop();
                _projectNameController.clear();
                _projectSpecializationController.clear();
                _teamMembersController.clear();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddMemberDialog(Mentor mentor, Team team) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Добавить члена команды'),
          content: TextField(
            controller: _newMemberController,
            decoration: InputDecoration(labelText: 'Имя члена команды', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newMember = _newMemberController.text.trim();
                if (newMember.isNotEmpty) {
                  team.members.add(newMember);
                  await _mentorRepository.updateMentor(mentor);
                  widget.logger.i('Added member: $newMember to team: $team in mentor: $mentor');
                  setState(() {});
                }
                Navigator.of(context).pop();
                _newMemberController.clear();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMentor(Mentor mentorToDelete) async {
    setState(() {
      _mentors.remove(mentorToDelete);
    });

    await _mentorRepository.deleteMentor(mentorToDelete.id);
    widget.logger.i('Deleted mentor with ID: ${mentorToDelete.id}');
  }

  void _deleteTeam(Mentor mentor, Team teamToDelete) async {
    mentor.teams.remove(teamToDelete);
    await _mentorRepository.updateMentor(mentor);
    widget.logger.i('Deleted team with ID: ${teamToDelete.id} from mentor: ${mentor.id}');

    setState(() {});
  }

  void _moveMemberToPreviousTeam(Mentor mentor, Team currentTeam, String member) {
    final currentIndex = mentor.teams.indexOf(currentTeam);
    if (currentIndex > 0) {
      setState(() {
        currentTeam.members.remove(member);
        mentor.teams[currentIndex - 1].members.add(member);
      });
      _mentorRepository.updateMentor(mentor);
      widget.logger.i('Moved member: $member to previous team in mentor: $mentor');
    }
  }

  void _moveMemberToNextTeam(Mentor mentor, Team currentTeam, String member) {
    final currentIndex = mentor.teams.indexOf(currentTeam);
    if (currentIndex < mentor.teams.length - 1) {
      setState(() {
        currentTeam.members.remove(member);
        mentor.teams[currentIndex + 1].members.add(member);
      });
      _mentorRepository.updateMentor(mentor);
      widget.logger.i('Moved member: $member to next team in mentor: $mentor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Наставники'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView(
        children: [
          for (var mentor in _mentors)
            Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              elevation: 5,
              child: ExpansionTile(
                title: Text(mentor.name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Специализация: ${mentor.specialization}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddMentorDialog(mentor),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMentor(mentor),
                    ),
                  ],
                ),
                children: [
                  for (var team in mentor.teams)
                    ListTile(
                      title: Text(team.projectName, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Специализация: ${team.projectSpecialization}\nЧлены команды: ${team.members.join(', ')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddTeamDialog(mentor, team),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTeam(mentor, team),
                          ),
                          IconButton(
                            icon: Icon(Icons.person_add, color: Colors.green),
                            onPressed: () => _showAddMemberDialog(mentor, team),
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Text('Переместить члена команды'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var member in team.members)
                                    ListTile(
                                      title: Text(member),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.arrow_upward, color: Colors.orange),
                                            onPressed: () => _moveMemberToPreviousTeam(mentor, team, member),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_downward, color: Colors.orange),
                                            onPressed: () => _moveMemberToNextTeam(mentor, team, member),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Закрыть'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ListTile(
                    title: Text('Добавить команду', style: TextStyle(color: Colors.deepPurple)),
                    trailing: Icon(Icons.add, color: Colors.deepPurple),
                    onTap: () => _showAddTeamDialog(mentor),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMentorDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}