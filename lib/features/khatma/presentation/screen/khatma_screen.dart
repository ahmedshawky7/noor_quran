import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/khatma/domain/entities/khatma_progress.dart';
import 'package:noor_quran/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:noor_quran/features/khatma/presentation/cubit/khatma_state.dart';

class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});
  
  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  final _formKey = GlobalKey<FormState>();
  int _targetDays = 30;
  int _pagesPerDay = 1;
  
  @override
  void initState() {
    super.initState();
    context.read<KhatmaCubit>().loadCurrentKhatma();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khatma Tracker')),
      body: BlocConsumer<KhatmaCubit, KhatmaState>(
        listener: (context, state) {
          if (state is KhatmaCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mabrook! You completed your Khatma! 🎉')),
            );
          }
        },
        builder: (context, state) {
          if (state is KhatmaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KhatmaActive) {
            return _buildActiveKhatma(state.progress);
          } else if (state is KhatmaInitial) {
            return _buildStartKhatma();
          } else if (state is KhatmaError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
  
  Widget _buildStartKhatma() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Start New Khatma',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Target Days'),
              keyboardType: TextInputType.number,
              initialValue: '30',
              onChanged: (value) => _targetDays = int.tryParse(value) ?? 30,
              validator: (value) => value != null && int.tryParse(value) != null ? null : 'Invalid',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Pages Per Day'),
              keyboardType: TextInputType.number,
              initialValue: '1',
              onChanged: (value) => _pagesPerDay = int.tryParse(value) ?? 1,
              validator: (value) => value != null && int.tryParse(value) != null ? null : 'Invalid',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<KhatmaCubit>().startKhatma(_targetDays, _pagesPerDay);
                }
              },
              child: const Text('Start Khatma'),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildActiveKhatma(KhatmaProgress progress) {
    final totalPages = progress.targetDays * progress.pagesPerDay;
    final remainingPages = totalPages - progress.currentPage;
    final percentage = (progress.currentPage / totalPages) * 100;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Your Khatma Progress', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: percentage / 100),
                  const SizedBox(height: 16),
                  Text('${percentage.toStringAsFixed(1)}% Complete'),
                  const SizedBox(height: 8),
                  Text('Pages Read: ${progress.currentPage} / $totalPages'),
                  Text('Remaining Pages: $remainingPages'),
                  Text('Started: ${progress.startDate.toLocal()}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showUpdateDialog();
                  },
                  child: const Text('Update Progress'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showUpdateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Khatma Progress'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Pages Read Today'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final pages = int.tryParse(controller.text);
              if (pages != null && pages > 0) {
                context.read<KhatmaCubit>().updateProgress(pages);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}