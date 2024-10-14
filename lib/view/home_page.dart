import 'dart:ui';

import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:artworks_images/model/artwork_model.dart';
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
          controller.fetchMoreArtworks();
        });
      }
    });
  }

  @override
  Widget desktop() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 233, 230, 0.9),
      body: Obx(() => _buildBody()),
    );
  }
 

     @override
       Widget tablet() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 233, 230, 0.9),
      body: Obx(() => _buildBody()),
    );
  }

  // Implement tablet() and mobile() methods similarly if needed

  Widget _buildBody() {
    return Stack(
      children: [
        _buildMainContent(),
        _buildSearchBar(),
        if (controller.isFetchingMore.value) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildMainContent() {
    if (controller.isLoading.value && controller.filteredArtworksList.isEmpty) {
      return Center(child: LottieBuilder.asset("assets/loading_animation.json"));
    } else if (controller.filteredArtworksList.isEmpty) {
      return const Center(child: Text("No artworks found"));
    } else {
      return InteractiveViewer(
        constrained: false,
        maxScale: 2.0,
        minScale: 0.5,
        boundaryMargin: EdgeInsets.zero,
        transformationController: TransformationController(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(Get.context!).size.width * 2.5,
            height: MediaQuery.of(Get.context!).size.height,
            child: _buildMasonryGridView(),
          ),
        ),
      );
    }
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
    return  Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LottieBuilder.asset("assets/loading_animation.json",width: 50,height: 50,),
      ),
    );
  }

  Widget _buildMasonryGridView() {
    return Obx(() => MasonryGridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      cacheExtent: 2000,
      mainAxisSpacing: 30,
      crossAxisSpacing: 30,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 12,
      ),
      itemCount: controller.filteredArtworksList.length,
      itemBuilder: (context, index) {
        Artwork artwork = controller.filteredArtworksList[index];
        String imageUrl = 'https://www.artic.edu/iiif/2/${artwork.imageId}/full/843,/0/default.jpg';
        return _buildGridItem(artwork, imageUrl);
      },
    ));
  }

  Widget _buildGridItem(Artwork artwork, String imageUrl) {
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
                          key: ValueKey(imageUrl),
                          cacheKey: imageUrl,
                          useOldImageOnUrlChange: true,
                          imageUrl: imageUrl,
                          placeholder: (context, url) => Center(
                              child: Image.asset(
                            "assets/loading.gif",
                            color: Colors.white,
                          )),
                          errorWidget: (context, url, error) {
                            return const Text("");
                          },
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            if (isHovered)
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
          clipBehavior: Clip.antiAlias,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                height: MediaQuery.of(context).size.width * 0.35,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDialogImage(artwork, imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDialogDetails(artwork),
                    ),
                  ],
                ),
              ),
              _buildCloseButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogImage(Artwork artwork, String imageUrl) {
    return Stack(
      children: [
        Hero(
          tag: 'artwork-${artwork.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              imageUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: IconButton.filledTonal(
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
    );
  }

  Widget _buildDialogDetails(Artwork artwork) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          artwork.title ?? "No Title",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      right: -0,
      top: -0,
      child: IconButton.filled(
      color: Colors.white,
        onPressed: () {
          Get.back();
        },
        icon: const Icon(Icons.close),
      ),
    );
  }
}
