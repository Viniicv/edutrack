import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  
  List<Subject> get subjects => _subjects;
  
  SubjectProvider() {
    _subjects = [
      Subject(id: 1, name: 'Dispositivos Móveis', color: '#6366F1', progress: 100),
      Subject(id: 2, name: 'Bancos de Dados', color: '#10B981', progress: 80),
      Subject(id: 3, name: 'Front End', color: '#F59E0B', progress: 70),
      Subject(id: 4, name: 'Back End', color: '#EF4444', progress: 70),
    ];
  }
  
  void addSubject(Subject subject) {
    subject.id = _subjects.length + 1;
    _subjects.add(subject);
    notifyListeners();
  }
}
