import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class ScopeSwitcher extends StatelessWidget {
  const ScopeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<ScopeCubit>().state;
    final familyState = context.watch<FamilyBloc>().state;
    return PopupMenuButton<String>(
      initialValue: scope.scopeId,
      onSelected: (value) {
        if (value == 'personal') {
          context.read<ScopeCubit>().switchToPersonal();
        } else {
          final parts = value.split('|');
          if (parts.length == 2) {
            context.read<ScopeCubit>().switchToFamily(parts[0], parts[1]);
          }
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'personal',
            child: Row(
              children: [
                Icon(Icons.person, size: 18,
                  color: scope.isPersonal ? Theme.of(context).colorScheme.primary : null),
                const SizedBox(width: 8),
                const Text('Personal'),
                const Spacer(),
                if (scope.isPersonal)
                  Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ];
        if (familyState is FamilyLoaded && familyState.families.isNotEmpty) {
          items.add(const PopupMenuDivider());
          for (final f in familyState.families) {
            final val = '${f.id}|${f.name}';
            items.add(PopupMenuItem(
              value: val,
              child: Row(
                children: [
                  Icon(Icons.group, size: 18,
                    color: scope.scopeId == f.id ? Theme.of(context).colorScheme.primary : null),
                  const SizedBox(width: 8),
                  Text(f.name),
                  if (scope.scopeId == f.id)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ));
          }
        }
        return items;
      },
      child: Chip(
        avatar: Icon(scope.isPersonal ? Icons.person : Icons.group, size: 18),
        label: Text(scope.label),
      ),
    );
  }
}
