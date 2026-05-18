import 'package:edutrack_app/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/activity_provider.dart';
import '../providers/subject_provider.dart';
import '../utils/theme.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'calendar_screen.dart';
import 'activities_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = 'Estudante';
  
  final List<Widget> _screens = [
    const HomeContent(),
    const CalendarScreen(),
    const ActivitiesListScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }
  
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Estudante';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Matérias',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
     SliverAppBar(
  floating: true,
  pinned: false,
  title: Row(
    children: [
      // Logo quadrada pequena na AppBar
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),// Logo - Quadrado Azul
        child: const Center(child: LogoWidget(size: 24, showText: false)),
      ),
      const SizedBox(width: 10),
      const Text(
        'EDUTRACK',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () {
        // Notificações
      },
    ),
  ],
),
        
        SliverToBoxAdapter(
          child: _buildHeader(context),
        ),
        
        SliverToBoxAdapter(
          child: _buildUrgentSection(context),
        ),
        
        SliverToBoxAdapter(
          child: _buildSubjectsProgress(context),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _getUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'Estudante';
              return Text(
                'Olá, $name!',
                style: AppTextStyles.heading,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Aqui estão suas prioridades:',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
  
  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Estudante';
  }
  
  Widget _buildUrgentSection(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final urgentActivities = activityProvider.getTodayUrgentActivities();
        
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.urgentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hoje: URGENTE!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.urgentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (urgentActivities.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Nenhuma tarefa urgente! 🎉',
                        style: AppTextStyles.subtitle,
                      ),
                    ),
                  ),
                )
              else
                ...urgentActivities.map((activity) => _buildTaskCard(
                  context,
                  activity.title,
                  activity.subject,
                  activity.dueDate,
                  isUrgent: true,
                )),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSubjectsProgress(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, _) {
        final subjects = subjectProvider.subjects;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suas Matérias',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 16),
              ...subjects.map((subject) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubjectCard(context, subject),
              )),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTaskCard(BuildContext context, String title, String subject, DateTime dueDate, {bool isUrgent = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? const Color(0xFFEF4444).withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUrgent ? Icons.warning_amber_rounded : Icons.assignment,
                    size: 20,
                    color: isUrgent ? const Color(0xFFEF4444) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        style: AppTextStyles.progressLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Entregue até ${_formatDate(dueDate)}',
                  style: AppTextStyles.progressLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectCard(BuildContext context, dynamic subject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(int.parse(subject.color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subject.name,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                ),
              ],
            ),
            Text(
              '${subject.progress}% Concluído',
              style: AppTextStyles.progressLabel,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: subject.progress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              Color(int.parse(subject.color.replaceFirst('#', '0xFF'))),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
