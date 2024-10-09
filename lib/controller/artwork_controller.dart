import 'dart:io';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:artworks_images/model/pagination_model.dart';
import 'package:path_provider/path_provider.dart';

class ArtworkController extends GetxController {
  var artworksList = <Artwork>[].obs; // Use the Artwork model list
  var isLoading = false.obs;
  var isFetchingMore = false.obs;
  var searchQuery = "".obs;
  var pagination = Rx<Pagination?>(null); // Store pagination details
  RxBool isHovered = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArtworks(); // Fetch initial data
  }

  /// Fetch artworks dynamically with optional parameters
  Future<void> fetchArtworks(
      {String query = "", int limit = 40, int page = 1}) async {
    isLoading.value = true;
    try {
      // Use limit and page parameters for pagination
      String url =
          'https://api.artic.edu/api/v1/artworks?page=$page&limit=$limit';
      if (query.isNotEmpty) {
        url =
            'https://api.artic.edu/api/v1/artworks/search?q=$query&page=$page&limit=$limit';
      }

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Parse pagination data and update the controller
        pagination.value = Pagination.fromJson(data['pagination']);

        // Parse artwork data
        var artworksJson = data['data'];
        var newArtworks = artworksJson
            .map<Artwork>((json) => Artwork.fromJson(json))
            .toList();

        // Add new artworks to the list
        if (page == 1) {
          artworksList.value = newArtworks; // Clear and set for the first page
        } else {
          artworksList.addAll(newArtworks); // Append for subsequent pages
        }
      } else {
        throw Exception('Failed to load artworks');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch more items when user scrolls to the bottom
  Future<void> fetchMoreArtworks() async {
    if (!isFetchingMore.value && pagination.value != null) {
      if (pagination.value!.currentPage < pagination.value!.totalPages) {
        isFetchingMore.value = true;
        try {
          // Increment the page and fetch the next set of results
          int nextPage = pagination.value!.currentPage + 1;
          await fetchArtworks(query: searchQuery.value, page: nextPage);
        } catch (e) {
          print("Error: $e");
        } finally {
          isFetchingMore.value = false;
        }
      }
    }
  }

  /// Reset and refresh the artworks list
  void resetArtworks() {
    artworksList.clear(); // Clear the list
    fetchArtworks(
        query: searchQuery.value, page: 1); // Fetch fresh results from page 1
  }

  /// Update the search query dynamically and refetch
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetArtworks(); // Clear and fetch new results based on the updated query
  }

//   Future<void> downloadArtwork(String url) async {
//   try {
//     // Get the directory to save the file
//     Directory? appDocDir = await get;
//     String fileName = url.split('/').last; // Get the file name from the URL
//     String savePath = '${appDocDir?.path}/$fileName';

//     // Send a GET request to the URL
//     var response = await http.get(Uri.parse(url));

//     // Check if the request was successful
//     if (response.statusCode == 200) {
//       // Write the response body to a file
//       File file = File(savePath);
//       await file.writeAsBytes(response.bodyBytes);

//       // Show success message
//       print("Downloaded: $fileName to $savePath");

//     } else {
//       throw Exception('Failed to download file');
//     }
//   } catch (e) {
//     // Handle error
//     print("Download failed: $e");
//     Get.snackbar("Download Failed", "Could not download the artwork.",
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
// }

  void downloadFile(String url, String name) {
    AnchorElement anchorElement = AnchorElement(href: url);
    anchorElement.download = name;
    anchorElement.click();
  }
}
