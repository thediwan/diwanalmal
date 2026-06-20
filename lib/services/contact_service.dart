import 'package:drift/drift.dart';

import '../core/helpers/phone_helper.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import 'lazarus_database_service.dart';

/// Persists and queries reusable contacts for debts and splits.
class ContactService {
  ContactService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// All active contacts for the signed-in user.
  Future<List<DbContact>> listActive() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];
    return _db.financeDao.getActiveContacts(userId);
  }

  /// Case-insensitive name search among active contacts.
  Future<List<DbContact>> search(String keyword) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return listActive();

    final all = await _db.financeDao.getActiveContacts(userId);
    return all
        .where((c) => c.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  /// Returns an existing contact or creates one with [name] and optional [phone].
  Future<DbContact> findOrCreateByName(
    String name, {
    String? phone,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for contact');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Contact name is required');
    }

    final normalizedPhone = PhoneHelper.normalize(phone);
    if (phone != null && phone.trim().isNotEmpty && normalizedPhone == null) {
      throw ArgumentError('Invalid phone number');
    }

    final existing = await _db.financeDao.findContactByName(
      userId: userId,
      name: trimmed,
    );

    final now = DateTime.now();

    if (existing != null) {
      if (normalizedPhone != null &&
          normalizedPhone != existing.phone &&
          existing.phone != normalizedPhone) {
        await _db.financeDao.updateContactRecord(
          ContactsCompanion(
            id: Value(existing.id),
            phone: Value(normalizedPhone),
            updatedAt: Value(now),
          ),
        );
        return existing.copyWith(
          phone: Value(normalizedPhone),
          updatedAt: now,
        );
      }
      return existing;
    }

    final id = UuidHelper.generate();
    await _db.financeDao.insertContact(
      ContactsCompanion.insert(
        id: id,
        userId: userId,
        name: trimmed,
        phone: Value(normalizedPhone),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return DbContact(
      id: id,
      userId: userId,
      name: trimmed,
      phone: normalizedPhone,
      notes: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  /// Updates the phone number for an existing contact.
  Future<DbContact> updatePhone({
    required String contactId,
    String? phone,
  }) async {
    final existing = await getById(contactId);
    if (existing == null) {
      throw ArgumentError('Contact not found');
    }

    final normalizedPhone = PhoneHelper.normalize(phone);
    if (phone != null && phone.trim().isNotEmpty && normalizedPhone == null) {
      throw ArgumentError('Invalid phone number');
    }

    final now = DateTime.now();
    await _db.financeDao.updateContactRecord(
      ContactsCompanion(
        id: Value(contactId),
        phone: Value(normalizedPhone),
        updatedAt: Value(now),
      ),
    );

    return existing.copyWith(
      phone: Value(normalizedPhone),
      updatedAt: now,
    );
  }

  /// Loads a contact by id.
  Future<DbContact?> getById(String contactId) {
    return _db.financeDao.getContactById(contactId);
  }
}
