import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:l10n/l10n.dart';

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
      appBar: AppBar(title: Text(l10n.postsTitle)),
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
          itemCount: state.posts.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            title: Text(state.posts[i].title),
            subtitle: Text(state.posts[i].body),
          ),
        ),
      },
    );
  }
}
