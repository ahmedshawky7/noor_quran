import 'package:flutter/material.dart';
import '../../domain/entities/ayah.dart';

class MushafPaginator {
  final double pageWidth;

  MushafPaginator({
    required this.pageWidth,
  });

  List<List<Ayah>> paginate(List<Ayah> ayahs, int surahId) {
    final pages = <List<Ayah>>[];
    List<Ayah> currentPage = [];

    for (final ayah in ayahs) {
      final testPage = [...currentPage, ayah];

      final isFirstPage = testPage.any((a) => a.ayahNumber == 1);

      final maxLines = isFirstPage ? 13 : 15;

      final estimatedLines = _estimateLines(testPage);

      if (currentPage.isNotEmpty && estimatedLines > maxLines) {
        pages.add(currentPage);
        currentPage = [ayah];
      } else {
        currentPage.add(ayah);
      }
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  int _estimateLines(List<Ayah> ayahs) {
    const charsPerLine = 35;

    int total = 0;

    for (final a in ayahs) {
      total += _clean(a.textUthmani).length + 5;
    }

    return (total / charsPerLine).ceil();
  }

  String _clean(String text) {
    final basmalaRegex = RegExp(
      r'^بِسْمِ\s+ٱ?للَّ?هِ?\s+ٱ?لرَّ?حْ?مَ?ٰ?نِ?\s+ٱ?لرَّ?حِ?يمِ?\s*',
      unicode: true,
    );

    return text.replaceFirst(basmalaRegex, '').trim();
  }
}