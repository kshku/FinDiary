import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(const InvitationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: Text('No pending invitations'),
          );
        },
      ),
    );
  }
}
