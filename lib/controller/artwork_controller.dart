import 'dart:async';
import 'dart:convert';
// import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:artworks_images/logger_helper.dart';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:artworks_images/model/pagination_model.dart';

class ArtworkController extends GetxController {
  var artworksList = <Artwork>[].obs;
  var filteredArtworksList = <Artwork>[].obs;
  var isLoading = false.obs;
  var isFetchingMore = false.obs;
  var searchQuery = "".obs;
  var pagination = Rx<Pagination?>(null);
  RxBool isHovered = false.obs;
  var searchController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchArtworks();
  }

  Future<void> fetchArtworks(
      {String query = "", int limit = 50, int page = 1}) async {
    isLoading.value = true;
    try {
      String url =
          'https://api.artic.edu/api/v1/artworks?page=$page&limit=$limit';
      if (query.isNotEmpty) {
        url =
            'https://api.artic.edu/api/v1/artworks/search?q=$query&page=$page&limit=$limit';
      }
      LoggerHelper.debug("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        pagination.value = Pagination.fromJson(data['pagination']);
        var artworksJson = data['data'];
        var newArtworks = artworksJson
            .map<Artwork>((json) => Artwork.fromJson(json))
            .toList();

        if (page == 1) {
          artworksList.value = newArtworks;
        } else {
          artworksList.addAll(newArtworks);
        }
        debugPrint(
            "Fetched ${newArtworks.length} artworks. Total: ${artworksList.length}"); // Debug debugPrint
        _updateFilteredList();
      } else {
        LoggerHelper.debug(
            "Failed to load artworks. Status code: ${response.statusCode}");
        // Debug debugPrint
        throw Exception('Failed to load artworks');
      }
    } catch (e) {
      LoggerHelper.debug("Error fetching artworks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreArtworks() async {
    if (!isFetchingMore.value && pagination.value != null) {
      if (pagination.value!.currentPage < pagination.value!.totalPages) {
        isFetchingMore.value = true;
        try {
          int nextPage = pagination.value!.currentPage + 1;
          await fetchArtworks(query: searchQuery.value, page: nextPage);
        } catch (e) {
          LoggerHelper.debug("Error fetching more artworks: $e");
        } finally {
          isFetchingMore.value = false;
        }
      }
    }
  }

  void resetArtworks() {
    artworksList.clear();
    filteredArtworksList.clear();
    pagination.value = null;
    fetchArtworks(query: searchQuery.value, page: 1);
  }

  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      if (query.isEmpty) {
        _updateFilteredList();
      } else {
        fetchArtworks(query: "", page: 1);
      }
    });
  }

  void _updateFilteredList() {
    if (searchQuery.value.isEmpty) {
      filteredArtworksList.assignAll(artworksList);
    } else {
      filteredArtworksList.assignAll(artworksList.where((artwork) => artwork
          .title
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase())));
    }
    LoggerHelper.debug(
        "Filtered list updated. Count: ${filteredArtworksList.length}");
    // Debug print
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // void downloadImageWeb(String url, String name) async {
  //   var res = await http.get(Uri.parse(url));
  //   if (res.statusCode == 200) {
  //     final blob = html.Blob([res.bodyBytes]);
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     html.Url.revokeObjectUrl(url);
  //   } else {
  //     debugPrint("Download failed, status code: ${res.statusCode}");
  //   }
  // }
}
