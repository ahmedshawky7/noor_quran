import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_quran/core/widgets/loading_widget.dart';
import 'package:noor_quran/core/widgets/error_widget.dart';
import 'package:noor_quran/features/quran/presentation/widgets/surah_card.dart';

import '../cubit/surah_cubit.dart';
import '../cubit/surah_state.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noor Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<SurahCubit, SurahState>(
        builder: (context, state) {
          if (state is SurahLoading || state is SurahInitial){
            return const LoadingWidget();
          }
          else if (state is SurahLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.surahs.length,
              itemBuilder: (context, index) {
                final surah = state.surahs[index];
                return SurahCard(
                  surah: surah,
                  onTap: () => context.push('/quran/${surah.id}'),
                );
              },
            );
          }
          else if (state is SurahError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context.read<SurahCubit>().loadSurahs(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}