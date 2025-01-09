import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:artworks_images/view/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class HomePage extends GetResponsiveView<ArtworkController> {
  HomePage({super.key}) {
    _setupScrollController();
  }

  final ScrollController scrollController = ScrollController();
  final RxMap<int, bool> hoveredItems = <int, bool>{}.obs;

  void _setupScrollController() {
    scrollController.addListener(() {
      if (!controller.isFetchingMore.value &&
          scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            controller.fetchMoreArtworks();
          }
        });
      }
    });
  }

  @override
  Widget? builder() {
    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),
      body: Responsive(
        mobile: _buildBody(isMobile: true),
        tablet: _buildBody(isTablet: true),
        desktop: _buildBody(isDesktop: true),
        extraLargeScreen: _buildBody(isExtraLarge: true),
      ),
    );
  }

  Widget _buildBody({
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
    bool isExtraLarge = false,
  }) {
    return Stack(
      children: [
        _buildMainContent(
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
          isExtraLarge: isExtraLarge,
        ),
        _buildSearchBar(),
        if (controller.isFetchingMore.value) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildMainContent({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isExtraLarge,
  }) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.filteredArtworksList.isEmpty) {
        return Center(
            child: LottieBuilder.asset("assets/loading_animation.json"));
      } else if (controller.filteredArtworksList.isEmpty) {
        return const Center(
            child: Text(
          "No artworks found",
          style: TextStyle(color: Colors.white),
        ));
      } else {
        return InteractiveViewer(
          interactionEndFrictionCoefficient: 100,
          alignment: Alignment.center,
          constrained: false,
          maxScale: 1.0,
          minScale: 0.5,
          boundaryMargin: EdgeInsets.zero,
          transformationController: TransformationController(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: MediaQuery.of(Get.context!).size.width * 2.0,
              height: MediaQuery.of(Get.context!).size.height,
              child: _buildMasonryGridView(
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
                isExtraLarge: isExtraLarge,
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildSearchBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Search Artworks',
            suffixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
          onChanged: (value) {
            controller.updateSearchQuery(value.trim());
          },
        ),
      ).paddingOnly(top: 16.0),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LottieBuilder.asset(
          "assets/loading_animation.json",
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  Widget _buildMasonryGridView({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isExtraLarge,
  }) {
    int crossAxisCount = isMobile ? 4 : (isTablet ? 6 : (isDesktop ? 10 : 12));

    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      cacheExtent: 5000,
      mainAxisSpacing: isMobile ? 10 : 30,
      crossAxisSpacing: isMobile ? 10 : 30,
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: controller.filteredArtworksList.length,
      itemBuilder: (context, index) {
        Artwork artwork = controller.filteredArtworksList[index];
        String imageUrl =
            'https://www.artic.edu/iiif/2/${artwork.imageId}/full/843,/0/default.jpg';
        return _buildGridItem(artwork, imageUrl, isMobile: isMobile);
      },
    );
  }

  Widget _buildGridItem(Artwork artwork, String imageUrl,
      {bool isMobile = false}) {
    return Obx(() {
      bool isHovered = hoveredItems[artwork.id] ?? false;
      return MouseRegion(
        onEnter: (_) => hoveredItems[artwork.id] = true,
        onExit: (_) => hoveredItems[artwork.id] = false,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => _showArtworkDialog(Get.context!, artwork, imageUrl),
              child: Hero(
                tag: 'artwork-${artwork.id}',
                child: Container(
                  child: artwork.imageId.isNotEmpty
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: isHovered
                              ? (Matrix4.identity()..scale(1.05))
                              : Matrix4.identity(),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: isHovered ? 0.5 : 0.0,
                              sigmaY: isHovered ? 0.5 : 0.0,
                            ),
                            child: CachedNetworkImage(
                              key: ValueKey(artwork.id),
                              imageUrl: imageUrl,
                              placeholder: (context, url) => CachedNetworkImage(
                                imageUrl:
                                    'https://www.artic.edu/iiif/2/${artwork.imageId}/full/!200,200/0/default.jpg',
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Text(""),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            if (isHovered && !isMobile)
              Positioned(
                right: 10,
                bottom: 10,
                child: IconButton.filledTonal(
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    // controller.downloadImageWeb(imageUrl, artwork.imageId);
                  },
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  tooltip: "Download Image",
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showArtworkDialog(
      BuildContext context, Artwork artwork, String imageUrl) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? size.width * 0.9 : 600,
              maxHeight: isMobile ? size.height * 0.6 : size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 15 / 9,
                        child: Hero(
                          tag: 'artwork-${artwork.id}',
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                const Text(""),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        // onPressed: () => controller.downloadImageWeb(
                        //     imageUrl, artwork.imageId),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDialogDetails(artwork, isMobile),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogDetails(Artwork artwork, bool isMobile) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: isMobile ? 16 : 20,
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = GoogleFonts.dmSans(
      fontSize: isMobile ? 12 : 16,
      fontWeight: FontWeight.w500,
    );
    final bodyStyle = GoogleFonts.dmSans(
      fontSize: isMobile ? 12 : 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(artwork.title, style: titleStyle),
        const SizedBox(height: 8),
        Text("Artist: ${artwork.artistDisplay}", style: subtitleStyle),
        const SizedBox(height: 4),
        Text("Date: ${artwork.dateDisplay}", style: subtitleStyle),
        const SizedBox(height: 8),
        Text("Description:", style: subtitleStyle),
        const SizedBox(height: 4),
        Text(artwork.mediumDisplay, style: bodyStyle),
      ],
    );
  }
}
