import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';
import '../utils/theme.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = '#6366F1';
  
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Roxo', 'code': '#6366F1'},
    {'name': 'Verde', 'code': '#10B981'},
    {'name': 'Laranja', 'code': '#F59E0B'},
    {'name': 'Vermelho', 'code': '#EF4444'},
    {'name': 'Rosa', 'code': '#EC4899'},
    {'name': 'Azul', 'code': '#3B82F6'},
  ];
  
  void _saveSubject() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da matéria!')),
      );
      return;
    }
    
    final subject = Subject(
      name: _nameController.text,
      color: _selectedColor,
    );
    
    Provider.of<SubjectProvider>(context, listen: false).addSubject(subject);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matéria ${_nameController.text} adicionada!'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Matéria'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título da Matéria',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Dispositivos Móveis',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 32),
            Text(
              'Cor da Matéria',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color['code'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color['code'];
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color['code'].replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppTheme.primaryColor, width: 3)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        color['name'],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveSubject,
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}