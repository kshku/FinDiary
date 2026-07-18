import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyDetailPage extends StatefulWidget {
  final String familyId;
  const FamilyDetailPage({super.key, required this.familyId});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(FamilyDetailRequested(widget.familyId));
  }

  void _showInviteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
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
                sl<FamilyGrpcService>().inviteMember(
                  widget.familyId,
                  controller.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitation sent')),
                );
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyDetailLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.family.name,
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Your role: Owner',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Members', style: theme.textTheme.titleMedium),
                    FilledButton.tonalIcon(
                      onPressed: _showInviteDialog,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Invite'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No members yet')),
                  )
                else
                  ...state.members.map((m) => ListTile(
                        leading: CircleAvatar(
                            child: Text(m.userId[0].toUpperCase())),
                        title: Text(m.userId),
                        subtitle: Text(m.role),
                      )),
              ],
            );
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
