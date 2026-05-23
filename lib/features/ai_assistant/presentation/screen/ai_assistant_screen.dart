import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_cubit.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_state.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Islamic Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => context.read<AIAssistantCubit>().clearChatHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AIAssistantCubit, AIAssistantState>(
              builder: (context, state) {
                if (state is AIAssistantInitial) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Ask me about Quran, memorization, or Islamic topics'),
                        SizedBox(height: 8),
                        Text('Note: I cannot give fatwas or rulings.'),
                      ],
                    ),
                  );
                } else if (state is AIAssistantLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AIAssistantResponse) {
                  return _buildChatView(state.response);
                } else if (state is AIAssistantError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about Quran, memorization tips...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      context.read<AIAssistantCubit>().sendChatMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatView(String response) {
    return ListView(
      controller: _scrollController,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Assistant:'),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(response),
          ),
        ),
      ],
    );
  }
}