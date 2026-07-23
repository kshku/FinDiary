import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(const FamilyListRequested());
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Family'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Family name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<FamilyBloc>()
                    .add(FamilyCreated(controller.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Families')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyLoaded) {
            if (state.families.isEmpty) {
              return const Center(
                child: Text('No families yet'),
              );
            }
            return ListView.builder(
              itemCount: state.families.length,
              itemBuilder: (_, i) => _FamilyTile(family: state.families[i]),
            );
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final Family family;
  const _FamilyTile({required this.family});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(family.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/families/${family.id}'),
    );
  }
}
