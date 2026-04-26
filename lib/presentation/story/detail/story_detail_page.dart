import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'story_detail_provider.dart';
import '../list/story_list_provider.dart';

class StoryDetailPage extends StatelessWidget {
  final String storyId;

  const StoryDetailPage({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (context) => StoryDetailProvider(context.read(), storyId),
      child: Scaffold(
        body: Consumer<StoryDetailProvider>(
          builder: (context, provider, child) {
            if (provider.state == ResultState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state == ResultState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(provider.message),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: provider.fetchDetail,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry_button),
                    ),
                  ],
                ),
              );
            }

            final story = provider.story!;
            final formattedDate = DateFormat.yMMMd().format(story.createdAt);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: story.id,
                      child: CachedNetworkImage(
                        imageUrl: story.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              child: Text(
                                story.name.isNotEmpty
                                    ? story.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SelectableText(
                          story.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 48), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
