import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/quran/presentation/cubit/ayah_cubit.dart';
import 'package:noor_quran/features/quran/presentation/cubit/ayah_state.dart';
import 'package:noor_quran/core/widgets/loading_widget.dart';
import '../../../audio/domain/entities/reciter_model.dart';
import '../../../audio/presentation/cubit/audio_cubit.dart';
import '../../../audio/presentation/cubit/audio_state.dart';
import '../widgets/quran_page_view.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahId;

  const SurahDetailScreen({super.key, required this.surahId});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool _showUI = false;
  late int _currentSurahId;
  int? _selectedAyah;
  int? _targetPageIndex; // ◄◄◄ 0 = أول صفحة، -1 = آخر صفحة

  @override
  void initState() {
    super.initState();
    _currentSurahId = widget.surahId;
    context.read<AudioCubit>().reset();
    context.read<AyahCubit>().loadAyahs(_currentSurahId);
  }

  void _selectAyah(int? ayahNumber) {
    setState(() => _selectedAyah = ayahNumber);
  }

  void _changeSurah(int newSurahId, {int? targetPage}) {
    if (newSurahId < 1 || newSurahId > 114) return;

    setState(() {
      _currentSurahId = newSurahId;
      _targetPageIndex = targetPage;
      _selectedAyah = null;
    });

    context.read<AudioCubit>().reset();
    context.read<AyahCubit>().loadAyahs(newSurahId);
  }

  void _showRecitersBottomSheet(BuildContext context) {
    // ... (كما هو بدون تغيير)
    final audioCubit = context.read<AudioCubit>();
    final currentReciter = audioCubit.repository.currentReciter;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfff8f3e8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffc8a96b),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1a472a),
                  ),
                ),
              ),
              const Divider(color: Color(0xffc8a96b), height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allReciters.length,
                  itemBuilder: (context, index) {
                    final reciter = allReciters[index];
                    final isSelected = currentReciter.id == reciter.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      leading: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xff1a472a),
                            )
                          : const SizedBox(width: 24),
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: const Color(0xff1a472a),
                        ),
                      ),
                      trailing: isSelected
                          ? null
                          : const Icon(
                              Icons.person_outline,
                              color: Color(0xffc8a96b),
                              size: 20,
                            ),
                      onTap: () async {
                        final ayahCubit = context.read<AyahCubit>();
                        final currentAyah = await audioCubit.changeReciter(
                          reciter,
                        );
                        Navigator.pop(context);

                        if (currentAyah != null &&
                            ayahCubit.state is AyahLoaded) {
                          final ayahs = (ayahCubit.state as AyahLoaded).ayahs
                              .map((e) => e.ayahNumber)
                              .toList();
                          final remainingAyahs = ayahs
                              .skipWhile((a) => a != currentAyah)
                              .toList();
                          if (remainingAyahs.isNotEmpty) {
                            audioCubit.playSurah(
                              remainingAyahs,
                              _currentSurahId,
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xffefe5c8),
      body: BlocBuilder<AyahCubit, AyahState>(
        builder: (context, ayahState) {
          if (ayahState is AyahLoading || ayahState is AyahInitial) {
            return const LoadingWidget();
          }

          if (ayahState is AyahError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ayahState.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AyahCubit>().loadAyahs(_currentSurahId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (ayahState is AyahLoaded) {
            return BlocBuilder<AudioCubit, AudioState>(
              builder: (context, audioState) {
                final isPlaying = audioState is AudioPlaying;
                final currentAyah = isPlaying ? audioState.currentAyah : null;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        // ✅ شيلنا السحب العمودي عشان ما يتعارضش مع Scroll داخل الصفحة
                        // والتنقل بين السور بقى أفقي بالكامل
                        onTap: () => setState(() => _showUI = !_showUI),
                        child: QuranPageView(
                          key: ValueKey(
                            '$_currentSurahId-$_targetPageIndex',
                          ),
                          surahName: ayahState.surah.nameArabic,
                          ayahs: ayahState.ayahs,
                          surahId: _currentSurahId,
                          currentAyah: currentAyah,
                          selectedAyah: _selectedAyah,
                          onSelectAyah: _selectAyah,
                          // ◄◄◄ السورة التالية → ابدأ من أول صفحة
                          onNextSurah: () =>
                              _changeSurah(_currentSurahId + 1, targetPage: 0),
                          // ◄◄◄ السورة السابقة → ابدأ من آخر صفحة
                          onPreviousSurah: () =>
                              _changeSurah(_currentSurahId - 1, targetPage: -1),
                          initialPageIndex: _targetPageIndex,
                        ),

                      ),
                    ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: _showUI ? 0 : -(paddingTop + 60),
                      left: 0,
                      right: 0,
                      child: _buildAppBar(ayahState),
                    ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: _showUI ? 20 : -180,
                      left: 12,
                      right: 12,
                      child: _buildAudioBar(context, audioState, ayahState),
                    ),
                  ],
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAppBar(AyahLoaded state) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, paddingTop + 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xff1a472a),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            state.surah.nameArabic,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBar(
    BuildContext context,
    AudioState audioState,
    AyahLoaded ayahState,
  ) {
    final audioCubit = context.read<AudioCubit>();
    final isPlaying = audioState is AudioPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xfff8f3e8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRecitersBottomSheet(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        audioCubit.repository.currentReciter.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1a472a),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Color(0xff1a472a),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.grey),
                    onPressed: audioCubit.previous,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff1a472a),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioCubit.pause();
                        } else if (audioState is AudioPaused) {
                          audioCubit.resume();
                        } else {
                          final ayahs = ayahState.ayahs
                              .map((e) => e.ayahNumber)
                              .toList();
                          audioCubit.playSurah(ayahs, _currentSurahId);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.grey),
                    onPressed: audioCubit.next,
                  ),
                ],
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xff1a472a),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xff1a472a),
              trackHeight: 3,
            ),
            child: StreamBuilder<Duration?>(
              stream: audioCubit.position,
              builder: (context, posSnap) {
                return StreamBuilder<Duration?>(
                  stream: audioCubit.duration,
                  builder: (context, durSnap) {
                    final position = posSnap.data?.inSeconds.toDouble() ?? 0;
                    final duration = durSnap.data?.inSeconds.toDouble() ?? 1;
                    return Slider(
                      value: position.clamp(0, duration),
                      max: duration,
                      onChanged: (value) =>
                          audioCubit.seek(Duration(seconds: value.toInt())),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
