import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/providers/favourites_provider.dart';
import 'package:test_app/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_app/screens/movie_detail_screen.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      body: Consumer<FavouritesProvider>(
        builder: (context, provider, child) {
          final favourites = provider.favourites;

          if (favourites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavourites,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final movie = favourites[index];
              return GestureDetector(
                onTap: () {
                  if (movie.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movieId: movie.id!),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.withValues(alpha: 0.1),
                                child: Center(
                                  child: LoadingAnimationWidget.beat(
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => provider.toggleFavourite(movie),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
