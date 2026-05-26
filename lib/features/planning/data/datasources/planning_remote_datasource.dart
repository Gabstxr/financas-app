import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/planning_model.dart';

abstract class PlanningRemoteDataSource {
  Future<PlanningModel?> getPlanning(String userId, String monthId);
  Future<PlanningModel> savePlanning(PlanningModel planning);
}

class PlanningRemoteDataSourceImpl implements PlanningRemoteDataSource {
  final FirebaseFirestore _firestore;

  const PlanningRemoteDataSourceImpl(this._firestore);

  DocumentReference _doc(String userId, String monthId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('planning')
      .doc(monthId);

  @override
  Future<PlanningModel?> getPlanning(String userId, String monthId) async {
    try {
      final doc = await _doc(userId, monthId).get();
      if (!doc.exists) return null;
      return PlanningModel.fromFirestore(doc, userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<PlanningModel> savePlanning(PlanningModel planning) async {
    try {
      final ref = _doc(planning.userId, planning.id);
      final data = planning.toFirestore();
      final existing = await ref.get();
      if (!existing.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      await ref.set(data, SetOptions(merge: true));
      final saved = await ref.get();
      return PlanningModel.fromFirestore(saved, planning.userId);
    } catch (_) {
      throw const ServerException();
    }
  }
}
