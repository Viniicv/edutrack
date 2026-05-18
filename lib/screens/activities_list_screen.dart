import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../utils/theme.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class ActivitiesListScreen extends StatelessWidget {
  const ActivitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de Atividades'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aqui estão todas as suas atividades:',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ActivityProvider>(
                builder: (context, activityProvider, _) {
                  final activities = activityProvider.activities;
                  
                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_turned_in, size: 80, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma atividade cadastrada',
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.assignment,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            activity.subject,
                            style: AppTextStyles.cardTitle,
                          ),
                          subtitle: Text(activity.title, style: AppTextStyles.progressLabel),
                          trailing: Text(
                            'Entrega até ${_formatDate(activity.dueDate)}',
                            style: AppTextStyles.progressLabel,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}