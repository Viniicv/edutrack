import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mês e Ano com navegação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_currentMonth)} ${_currentMonth.year}',
                  style: AppTextStyles.title,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Dias da semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Grid do calendário
          Expanded(
            flex: 3,
            child: _buildCalendarGrid(),
          ),
          
          const Divider(height: 1),
          
          // Título "Tarefas do Dia"
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarefas do Dia',
                  style: AppTextStyles.cardTitle,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  onPressed: () {
                    _showAddTaskDialog(context, _selectedDate);
                  },
                  tooltip: 'Adicionar tarefa para este dia',
                ),
              ],
            ),
          ),
          
          // Lista de tarefas do dia selecionado
          Expanded(
            flex: 2,
            child: _buildTasksForDay(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 1;
        
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return Container();
        }
        
        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final isSelected = _selectedDate.year == date.year &&
                           _selectedDate.month == date.month &&
                           _selectedDate.day == date.day;
        final hasTasks = _hasTasksOnDate(date);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (hasTasks && !isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTasksForDay() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final tasks = activityProvider.getActivitiesByDate(_selectedDate);
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 8),
                Text(
                  'Nenhuma tarefa para este dia',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    _showAddTaskDialog(context, _selectedDate);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar tarefa'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskItem(context, task);
          },
        );
      },
    );
  }
  
  Widget _buildTaskItem(BuildContext context, Activity task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: task.isCompleted,
        onChanged: (bool? value) {
          final provider = Provider.of<ActivityProvider>(context, listen: false);
          task.isCompleted = value ?? false;
          task.progress = task.isCompleted ? 100 : 0;
          provider.updateActivity(task);
          setState(() {});
        },
        title: Text(
          task.title,
          style: AppTextStyles.cardTitle.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 16,
          ),
        ),
        subtitle: Text(task.subject, style: AppTextStyles.progressLabel),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmation(context, task);
          },
        ),
      ),
    );
  }
  
  void _showAddTaskDialog(BuildContext context, DateTime date) {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    String selectedSubject = 'Dispositivos Móveis';
    
    final subjects = ['Dispositivos Móveis', 'Back End', 'Front End', 'Banco de Dados', 'Empreendedorismo', 'Residência de Software'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Tarefa - ${_formatDate(date)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título da tarefa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matéria',
                  border: OutlineInputBorder(),
                ),
                items: subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSubject = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = Activity(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: titleController.text,
                    subject: selectedSubject,
                    dueDate: date,
                    isUrgent: false,
                    isCompleted: false,
                    progress: 0,
                  );
                  Provider.of<ActivityProvider>(context, listen: false).addActivity(newTask);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Activity task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover tarefa'),
          content: Text('Deseja remover "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ActivityProvider>(context, listen: false).deleteActivity(task.id!);
                Navigator.pop(context);
                setState(() {});
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }
  
  bool _hasTasksOnDate(DateTime date) {
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    final tasks = provider.getActivitiesByDate(date);
    return tasks.isNotEmpty;
  }
  
  String _getMonthName(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[date.month - 1];
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}