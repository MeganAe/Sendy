import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/model/sendy/parcel.dart';

void main() {
  SendyParcel sample() => SendyParcel(
    id: 'parcel-1',
    title: 'Cours',
    note: 'Chapitre 1',
    createdAt: DateTime.utc(2026, 9, 14),
    entries: [
      const ParcelEntry(name: 'cours.pdf', reference: '/documents/cours.pdf', size: 42),
      const ParcelEntry(name: 'photo.jpg', reference: 'content://documents/17', size: 58),
    ],
  );
  test('Reference-only library round trips without embedding contents', () {
    final encoded = SendyParcel.encodeLibrary([sample()]);
    final decoded = SendyParcel.decodeLibrary(encoded).single;
    expect(decoded.title, 'Cours');
    expect(decoded.note, 'Chapitre 1');
    expect(decoded.totalSize, 100);
    expect(decoded.entries.last.reference, 'content://documents/17');
    final entry = (jsonDecode(encoded)['parcels'][0]['entries'][0] as Map);
    expect(entry.keys, unorderedEquals(['name', 'reference', 'size']));
  });
  test('Only absent storage means a new empty library', () {
    expect(SendyParcel.decodeLibrary(null), isEmpty);
    expect(() => SendyParcel.decodeLibrary('broken'), throwsFormatException);
  });
  test('Newer schemas are never treated as an empty library', () {
    expect(() => SendyParcel.decodeLibrary('{"version":2,"parcels":[]}'), throwsFormatException);
  });
  test('Duplicate identifiers are rejected', () {
    expect(() => SendyParcel.decodeLibrary(SendyParcel.encodeLibrary([sample(), sample()])), throwsFormatException);
  });
  test('Entries cannot be changed after creating a parcel', () {
    expect(() => sample().entries.clear(), throwsUnsupportedError);
  });
  test('Empty parcels and blank titles are rejected', () {
    expect(() => SendyParcel(id: '1', title: ' ', note: '', createdAt: DateTime.now(), entries: sample().entries), throwsFormatException);
    expect(() => SendyParcel(id: '1', title: 'Cours', note: '', createdAt: DateTime.now(), entries: []), throwsFormatException);
  });
  test('Invalid saved references and negative sizes are rejected', () {
    expect(() => ParcelEntry.fromJson({'name': 'a', 'reference': '', 'size': 0}), throwsFormatException);
    expect(() => ParcelEntry.fromJson({'name': 'a', 'reference': '/a', 'size': -1}), throwsFormatException);
  });
}
