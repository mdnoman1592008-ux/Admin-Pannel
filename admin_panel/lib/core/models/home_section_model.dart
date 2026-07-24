import 'package:flutter/material.dart';

enum SectionLayoutType {
  heroBanner,
  horizontalCarousel,
  top10,
  billboard,
  continueWatching,
  comingSoon,
  grid,
  verticalList,
  masonryGrid,
}

enum SectionContentSource {
  manual,
  category,
  genre,
  tag,
  language,
  country,
  releaseYear,
  trending,
  mostViewed,
  highestRated,
  recentlyAdded,
  comingSoon,
  continueWatching,
  random,
  recommended,
  playlist,
  customQuery,
}

enum SectionVisibilityRule {
  visible,
  hidden,
  guestOnly,
  premiumOnly,
  kidsOnly,
}

class SectionStyleConfig {
  final String titleFont;
  final String titleColorHex;
  final String backgroundColorHex;
  final String gradientStartHex;
  final String gradientEndHex;
  final bool enableGlass;
  final double glassOpacity;
  final double cardRadius;
  final double posterRatio;
  final double cardHeight;
  final bool autoScroll;
  final bool loop;
  final bool showMoreButton;

  const SectionStyleConfig({
    this.titleFont = 'Inter',
    this.titleColorHex = '#FFFFFF',
    this.backgroundColorHex = 'transparent',
    this.gradientStartHex = '',
    this.gradientEndHex = '',
    this.enableGlass = false,
    this.glassOpacity = 0.15,
    this.cardRadius = 12.0,
    this.posterRatio = 1.4,
    this.cardHeight = 220.0,
    this.autoScroll = false,
    this.loop = true,
    this.showMoreButton = true,
  });

  factory SectionStyleConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SectionStyleConfig();
    return SectionStyleConfig(
      titleFont: json['titleFont'] as String? ?? 'Inter',
      titleColorHex: json['titleColorHex'] as String? ?? '#FFFFFF',
      backgroundColorHex: json['backgroundColorHex'] as String? ?? 'transparent',
      gradientStartHex: json['gradientStartHex'] as String? ?? '',
      gradientEndHex: json['gradientEndHex'] as String? ?? '',
      enableGlass: json['enableGlass'] as bool? ?? false,
      glassOpacity: (json['glassOpacity'] as num?)?.toDouble() ?? 0.15,
      cardRadius: (json['cardRadius'] as num?)?.toDouble() ?? 12.0,
      posterRatio: (json['posterRatio'] as num?)?.toDouble() ?? 1.4,
      cardHeight: (json['cardHeight'] as num?)?.toDouble() ?? 220.0,
      autoScroll: json['autoScroll'] as bool? ?? false,
      loop: json['loop'] as bool? ?? true,
      showMoreButton: json['showMoreButton'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'titleFont': titleFont,
        'titleColorHex': titleColorHex,
        'backgroundColorHex': backgroundColorHex,
        'gradientStartHex': gradientStartHex,
        'gradientEndHex': gradientEndHex,
        'enableGlass': enableGlass,
        'glassOpacity': glassOpacity,
        'cardRadius': cardRadius,
        'posterRatio': posterRatio,
        'cardHeight': cardHeight,
        'autoScroll': autoScroll,
        'loop': loop,
        'showMoreButton': showMoreButton,
      };
}

class SectionScheduleConfig {
  final DateTime? publishAt;
  final DateTime? expireAt;
  final bool autoActivate;
  final bool autoDeactivate;

  const SectionScheduleConfig({
    this.publishAt,
    this.expireAt,
    this.autoActivate = true,
    this.autoDeactivate = true,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (publishAt != null && now.isBefore(publishAt!)) return false;
    if (expireAt != null && now.isAfter(expireAt!)) return false;
    return true;
  }

  factory SectionScheduleConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SectionScheduleConfig();
    return SectionScheduleConfig(
      publishAt: json['publishAt'] != null ? DateTime.tryParse(json['publishAt'].toString()) : null,
      expireAt: json['expireAt'] != null ? DateTime.tryParse(json['expireAt'].toString()) : null,
      autoActivate: json['autoActivate'] as bool? ?? true,
      autoDeactivate: json['autoDeactivate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'publishAt': publishAt?.toIso8601String(),
        'expireAt': expireAt?.toIso8601String(),
        'autoActivate': autoActivate,
        'autoDeactivate': autoDeactivate,
      };
}

class HomeSectionModel {
  final String id;
  final String title;
  final String slug;
  final String description;
  final SectionLayoutType layoutType;
  final SectionContentSource contentSource;
  final Map<String, dynamic> filters;
  final List<String> manualItemIds;
  final String bannerUrl;
  final String iconName;
  final int displayOrder;
  final int maxItems;
  final bool isEnabled;
  final SectionVisibilityRule visibility;
  final SectionStyleConfig style;
  final SectionScheduleConfig scheduling;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HomeSectionModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description = '',
    required this.layoutType,
    required this.contentSource,
    this.filters = const {},
    this.manualItemIds = const [],
    this.bannerUrl = '',
    this.iconName = 'movie',
    required this.displayOrder,
    this.maxItems = 10,
    this.isEnabled = true,
    this.visibility = SectionVisibilityRule.visible,
    this.style = const SectionStyleConfig(),
    this.scheduling = const SectionScheduleConfig(),
    required this.createdAt,
    required this.updatedAt,
  });

  HomeSectionModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    SectionLayoutType? layoutType,
    SectionContentSource? contentSource,
    Map<String, dynamic>? filters,
    List<String>? manualItemIds,
    String? bannerUrl,
    String? iconName,
    int? displayOrder,
    int? maxItems,
    bool? isEnabled,
    SectionVisibilityRule? visibility,
    SectionStyleConfig? style,
    SectionScheduleConfig? scheduling,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      layoutType: layoutType ?? this.layoutType,
      contentSource: contentSource ?? this.contentSource,
      filters: filters ?? this.filters,
      manualItemIds: manualItemIds ?? this.manualItemIds,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      iconName: iconName ?? this.iconName,
      displayOrder: displayOrder ?? this.displayOrder,
      maxItems: maxItems ?? this.maxItems,
      isEnabled: isEnabled ?? this.isEnabled,
      visibility: visibility ?? this.visibility,
      style: style ?? this.style,
      scheduling: scheduling ?? this.scheduling,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Section',
      slug: json['slug'] as String? ?? 'untitled',
      description: json['description'] as String? ?? '',
      layoutType: _parseLayoutType(json['layoutType']),
      contentSource: _parseContentSource(json['contentSource']),
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      manualItemIds: List<String>.from(json['manualItemIds'] as List? ?? []),
      bannerUrl: json['bannerUrl'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'movie',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 1,
      maxItems: (json['maxItems'] as num?)?.toInt() ?? 10,
      isEnabled: json['isEnabled'] as bool? ?? true,
      visibility: _parseVisibility(json['visibility']),
      style: SectionStyleConfig.fromJson(json['style'] as Map<String, dynamic>?),
      scheduling: SectionScheduleConfig.fromJson(json['scheduling'] as Map<String, dynamic>?),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'description': description,
        'layoutType': layoutType.name,
        'contentSource': contentSource.name,
        'filters': filters,
        'manualItemIds': manualItemIds,
        'bannerUrl': bannerUrl,
        'iconName': iconName,
        'displayOrder': displayOrder,
        'maxItems': maxItems,
        'isEnabled': isEnabled,
        'visibility': visibility.name,
        'style': style.toJson(),
        'scheduling': scheduling.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static SectionLayoutType _parseLayoutType(dynamic raw) {
    if (raw == null) return SectionLayoutType.horizontalCarousel;
    final val = raw.toString().toLowerCase();
    for (final type in SectionLayoutType.values) {
      if (type.name.toLowerCase() == val || _layoutAliasMatch(type, val)) {
        return type;
      }
    }
    return SectionLayoutType.horizontalCarousel;
  }

  static bool _layoutAliasMatch(SectionLayoutType type, String val) {
    if (type == SectionLayoutType.heroBanner && (val == 'hero' || val == 'hero_banner')) return true;
    if (type == SectionLayoutType.horizontalCarousel && (val == 'horizontal' || val == 'carousel' || val == 'slider')) return true;
    if (type == SectionLayoutType.top10 && (val == 'top_10' || val == 'ranking')) return true;
    if (type == SectionLayoutType.continueWatching && (val == 'continue_watching' || val == 'history')) return true;
    if (type == SectionLayoutType.comingSoon && (val == 'coming_soon' || val == 'upcoming')) return true;
    if (type == SectionLayoutType.verticalList && (val == 'list' || val == 'vertical')) return true;
    if (type == SectionLayoutType.masonryGrid && val == 'masonry') return true;
    return false;
  }

  static SectionContentSource _parseContentSource(dynamic raw) {
    if (raw == null) return SectionContentSource.trending;
    final val = raw.toString().toLowerCase();
    for (final src in SectionContentSource.values) {
      if (src.name.toLowerCase() == val || _sourceAliasMatch(src, val)) {
        return src;
      }
    }
    return SectionContentSource.trending;
  }

  static bool _sourceAliasMatch(SectionContentSource src, String val) {
    if (src == SectionContentSource.trending && val == 'trending_now') return true;
    if (src == SectionContentSource.mostViewed && (val == 'most_viewed' || val == 'views')) return true;
    if (src == SectionContentSource.highestRated && (val == 'highest_rated' || val == 'rating')) return true;
    if (src == SectionContentSource.recentlyAdded && (val == 'recently_added' || val == 'newest')) return true;
    if (src == SectionContentSource.comingSoon && val == 'coming_soon') return true;
    if (src == SectionContentSource.continueWatching && val == 'continue_watching') return true;
    if (src == SectionContentSource.customQuery && val == 'custom_query') return true;
    return false;
  }

  static SectionVisibilityRule _parseVisibility(dynamic raw) {
    if (raw == null) return SectionVisibilityRule.visible;
    final val = raw.toString().toLowerCase();
    for (final vis in SectionVisibilityRule.values) {
      if (vis.name.toLowerCase() == val) return vis;
    }
    return SectionVisibilityRule.visible;
  }
}
