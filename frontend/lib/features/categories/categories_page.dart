import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/di/injection.dart';
import 'bloc/category_bloc.dart';
import 'bloc/category_event.dart';
import 'bloc/category_state.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc(_categoryDao: sl<CategoryDao>()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const CategoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CategorySection(title: 'Income', categories: state.incomeCategories),
                const SizedBox(height: 24),
                _CategorySection(title: 'Expense', categories: state.expenseCategories),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Category> categories;

  const _CategorySection({required this.title, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) => Chip(
            avatar: CircleAvatar(
              backgroundColor: c.color != null
                  ? Color(int.parse(c.color!.replaceFirst('#', '0xFF')))
                  : null,
              child: Icon(_iconFor(c.icon), size: 18),
            ),
            label: Text(c.name),
          )).toList(),
        ),
      ],
    );
  }

  IconData _iconFor(String? icon) {
    switch (icon) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'business':
        return Icons.store;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'utilities':
        return Icons.bolt;
      case 'rent':
        return Icons.home;
      case 'insurance':
        return Icons.shield;
      case 'subscription':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }
}
