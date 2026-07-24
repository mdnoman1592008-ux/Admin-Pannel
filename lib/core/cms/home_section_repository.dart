import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_section_model.dart';

class HomeSectionRepository {
  static final HomeSectionRepository _instance =
      HomeSectionRepository._internal();
  factory HomeSectionRepository() => _instance;
  HomeSectionRepository._internal() {
    _firestore
        .collection('home_sections')
        .orderBy('displayOrder')
        .snapshots()
        .listen((snapshot) {
      _sections
        ..clear()
        ..addAll(snapshot.docs.map(
            (doc) => HomeSectionModel.fromJson({'id': doc.id, ...doc.data()})));
    });
  }

  final List<HomeSectionModel> _sections = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<HomeSectionModel> get sections => List.unmodifiable(
      _sections..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
  Stream<List<HomeSectionModel>> get sectionsStream => _firestore
      .collection('home_sections')
      .orderBy('displayOrder')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map(
              (doc) => HomeSectionModel.fromJson({'id': doc.id, ...doc.data()}))
          .where((section) =>
              section.isEnabled && section.scheduling.isCurrentlyActive)
          .toList(growable: false));

  List<HomeSectionModel> get enabledSections {
    return List.unmodifiable(
      _sections
          .where((s) => s.isEnabled && s.scheduling.isCurrentlyActive)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
    );
  }

  Future<void> createSection(HomeSectionModel section) async {
    final docId = section.id.isEmpty
        ? 'sec_${DateTime.now().millisecondsSinceEpoch}'
        : section.id;
    final nextOrder = _sections.isEmpty
        ? 1
        : (_sections
                .map((s) => s.displayOrder)
                .reduce((a, b) => a > b ? a : b) +
            1);
    final newSec = section.copyWith(
      id: docId,
      displayOrder:
          section.displayOrder <= 0 ? nextOrder : section.displayOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(docId)
        .set(newSec.toJson());
    debugPrint(
        '[HomeSectionRepository] Created section in Firestore: ${newSec.title}');
  }

  Future<void> updateSection(HomeSectionModel section) async {
    final updated = section.copyWith(updatedAt: DateTime.now());
    await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(section.id)
        .update(updated.toJson());
    debugPrint(
        '[HomeSectionRepository] Updated section in Firestore: ${section.title}');
  }

  Future<void> deleteSection(String sectionId) async {
    await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(sectionId)
        .delete();
    debugPrint(
        '[HomeSectionRepository] Deleted section from Firestore: $sectionId');
  }

  Future<void> duplicateSection(String sectionId) async {
    final doc = await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(sectionId)
        .get();
    if (!doc.exists) return;

    final original = HomeSectionModel.fromJson({'id': doc.id, ...doc.data()!});
    final dupId = 'sec_${DateTime.now().millisecondsSinceEpoch}';
    final dup = original.copyWith(
      id: dupId,
      title: '${original.title} (Copy)',
      slug: '${original.slug}_copy',
      displayOrder: original.displayOrder + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(dupId)
        .set(dup.toJson());
    debugPrint(
        '[HomeSectionRepository] Duplicated section in Firestore: ${dup.title}');
  }

  Future<void> toggleSectionEnabled(String sectionId, bool isEnabled) async {
    await FirebaseFirestore.instance
        .collection('home_sections')
        .doc(sectionId)
        .update({
      'isEnabled': isEnabled,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    debugPrint(
        '[HomeSectionRepository] Toggled section $sectionId isEnabled = $isEnabled in Firestore');
  }

  Future<void> reorderSections(List<String> orderedIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      final ref = FirebaseFirestore.instance
          .collection('home_sections')
          .doc(orderedIds[i]);
      batch.update(ref, {
        'displayOrder': i + 1,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
    await batch.commit();
    debugPrint(
        '[HomeSectionRepository] Reordered ${orderedIds.length} sections in Firestore');
  }
}
