import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'story_list_provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/story_card.dart';

class StoryListPage extends StatelessWidget {
  const StoryListPage({super.key});

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout_button),
          content: Text(l10n.logout_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.logout_cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthProvider>().logout();
              },
              child: Text(l10n.logout_button),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 200, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 100,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stories_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/stories/add'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, l10n),
          ),
        ],
      ),
      body: Consumer<StoryListProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case ResultState.loading:
              return _buildLoadingState(context);
            case ResultState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: provider.fetchStories,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry_button),
                      ),
                    ],
                  ),
                ),
              );
            case ResultState.noData:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.no_stories,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            case ResultState.hasData:
              return RefreshIndicator(
                onRefresh: provider.fetchStories,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.stories.length,
                  itemBuilder: (context, index) {
                    final story = provider.stories[index];
                    return StoryCard(
                      story: story,
                      onTap: () => context.push('/stories/${story.id}'),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
