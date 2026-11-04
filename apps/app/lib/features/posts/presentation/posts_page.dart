import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:navigation/navigation.dart';

/// Provides the bloc via the composition root's factory and loads posts.
class PostsPage extends StatelessWidget {
  const PostsPage({required this.createBloc, super.key});

  final PostsBloc Function() createBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc()..add(const PostsRequested()),
      child: const PostsView(),
    );
  }
}

class PostsView extends StatelessWidget {
  const PostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<PostsBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: switch (state.status) {
        PostsStatus.initial || PostsStatus.loading => const AppLoader(),
        PostsStatus.failure => ErrorView(
          message: l10n.errorGeneric,
          retryLabel: l10n.retryLabel,
          onRetry: () => context.read<PostsBloc>().add(const PostsRequested()),
        ),
        PostsStatus.loaded when state.posts.isEmpty => EmptyView(
          message: l10n.postsEmpty,
        ),
        PostsStatus.loaded => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.posts.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.posts[i].title,
                    style: context.typography.subtitle.bold!.brand,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    state.posts[i].body,
                    style: context.typography.body.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      },
    );
  }
}
