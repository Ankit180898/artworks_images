import 'dart:ui';

import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:artworks_images/view/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

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
      backgroundColor: const Color.fromRGBO(237, 233, 230, 0.9),
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
      if (controller.isLoading.value && controller.filteredArtworksList.isEmpty) {
        return Center(child: LottieBuilder.asset("assets/loading_animation.json"));
      } else if (controller.filteredArtworksList.isEmpty) {
        return const Center(child: Text("No artworks found"));
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
    int crossAxisCount = isMobile ? 4 : (isTablet ? 6 : (isDesktop ? 12 : 12));
    
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
        String imageUrl = 'https://www.artic.edu/iiif/2/${artwork.imageId}/full/843,/0/default.jpg';
        return _buildGridItem(artwork, imageUrl, isMobile: isMobile);
      },
    );
  }

  Widget _buildGridItem(Artwork artwork, String imageUrl, {bool isMobile = false}) {
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
                  color: Colors.white,
                  child: artwork.imageId.isNotEmpty
                      ? CachedNetworkImage(
                          key: ValueKey(
                              artwork.id), // Use artwork ID or a unique key
                          imageUrl: imageUrl, // Full-sized image
                          placeholder: (context, url) => CachedNetworkImage(
                            imageUrl:
                                'https://www.artic.edu/iiif/2/${artwork.imageId}/full/!200,200/0/default.jpg', // Thumbnail
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => const Text(""),
                          fit: BoxFit.cover,
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
                    controller.downloadImageWeb(imageUrl, artwork.imageId);
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

  void _showArtworkDialog(BuildContext context, Artwork artwork, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isMobile = Responsive.isMobile(context);
        bool isTablet = Responsive.isTablet(context);
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: isMobile ? 24 : 80,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 1200,
              maxHeight: isMobile ? double.infinity : 800,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      child: isMobile || isTablet
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: _buildDialogImage(artwork, imageUrl),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _buildDialogDetails(artwork),
                                ),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildDialogImage(artwork, imageUrl),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: _buildDialogDetails(artwork),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                _buildCloseButton(isMobile: isMobile, isTablet: isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogImage(Artwork artwork, String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'artwork-${artwork.id}',
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.7),
            ),
            onPressed: () {
              controller.downloadImageWeb(imageUrl, artwork.imageId);
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
            tooltip: "Download Image",
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDetails(Artwork artwork) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          artwork.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Artist: ${artwork.artistDisplay}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          "Date: ${artwork.dateDisplay}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          "Description: ${artwork.mediumDisplay}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCloseButton({required bool isMobile, required bool isTablet}) {
    return Positioned(
      right: isMobile || isTablet ? 8 : -16,
      top: isMobile || isTablet ? 8 : -16,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}