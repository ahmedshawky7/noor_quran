import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_cubit.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_state.dart';
import 'package:noor_quran/features/ai_assistant/data/repositories/ai_repository_impl.dart';

class AIAssistantScreen extends StatelessWidget {
  final String? initialPrompt;
  final String? surahName;
  final int? ayahNumber;
  final String? ayahText;

  const AIAssistantScreen({
    super.key,
    this.initialPrompt,
    this.surahName,
    this.ayahNumber,
    this.ayahText,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIAssistantCubit(AIRepositoryImpl()),
      child: _AIAssistantScreenContent(initialPrompt: initialPrompt),
    );
  }
}

class _AIAssistantScreenContent extends StatefulWidget {
  final String? initialPrompt;
  const _AIAssistantScreenContent({this.initialPrompt});

  @override
  State<_AIAssistantScreenContent> createState() =>
      _AIAssistantScreenContentState();
}

class _AIAssistantScreenContentState extends State<_AIAssistantScreenContent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto send initial prompt (from MushafPage)
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.read<AIAssistantCubit>().sendChatMessage(
            widget.initialPrompt!,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AIAssistantCubit>().sendChatMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AIAssistantCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مساعد إسلامي تعليمي',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteCurrentDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'سجل المحادثات',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Expanded(
              child: BlocBuilder<AIAssistantCubit, AIAssistantState>(
                builder: (context, state) {
                  final sessions = cubit.allSessions;
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد محادثات',
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        title: Text(
                          session.title,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          _formatDate(session.updatedAt),
                          textDirection: TextDirection.rtl,
                        ),
                        leading: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') {
                              _showRenameDialog(
                                context,

                                session.id,
                                session.title,
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(context, session.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(
                                'إعادة تسمية',
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'حذف',
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          cubit.loadSession(session.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text(
                'دردشة جديدة',
                textDirection: TextDirection.rtl,
              ),
              onTap: () {
                cubit.newSession();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: BlocConsumer<AIAssistantCubit, AIAssistantState>(
              listener: (context, state) {
                if (state is AIAssistantSessionLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                final history = cubit.chatHistory;

                if (state is AIAssistantError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => cubit.newSession(),
                            child: const Text(
                              'بدء محادثة جديدة',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is AIAssistantLoading && history.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (history.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(Icons.chat, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'اسألني عن القرآن، الحفظ، أو أي موضوع إسلامي',
                          style: TextStyle(fontSize: 16),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final msg = history[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Typing Indicator
          BlocBuilder<AIAssistantCubit, AIAssistantState>(
            builder: (context, state) {
              if (state is AIAssistantLoading && cubit.chatHistory.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'المساعد يكتب...',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                    textDirection: TextDirection.rtl,
                  ),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Dialogs ====================

  void _showRenameDialog(
      BuildContext context,
      String sessionId,
      String currentTitle,
      ) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة تسمية المحادثة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AIAssistantCubit>().renameSession(
                sessionId,
                controller.text,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المحادثة؟'),
        content: const Text(
          'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AIAssistantCubit>().deleteSession(sessionId);
              Navigator.pop(dialogContext);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCurrentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح المحادثة الحالية؟'),
        content: const Text(
          'سيتم مسح كل الرسائل وبدء محادثة جديدة.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AIAssistantCubit>().newSession();
              Navigator.pop(dialogContext);
            },
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}