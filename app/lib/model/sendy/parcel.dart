// Sendy reference-only parcels. Never serialize file contents or transfer credentials.
import 'dart:convert';

class ParcelEntry {
  final String name;
  final String reference;
  final int size;

  const ParcelEntry({required this.name, required this.reference, required this.size});

  Map<String, Object> toJson() => {'name': name, 'reference': reference, 'size': size};

  factory ParcelEntry.fromJson(Map<String, dynamic> json) {
    final entry = ParcelEntry(name: json['name'] as String, reference: json['reference'] as String, size: json['size'] as int);
    if (entry.name.isEmpty || entry.reference.isEmpty || entry.size < 0) {
      throw const FormatException('Invalid parcel entry');
    }
    return entry;
  }
}

class SendyParcel {
  final String id;
  final String title;
  final String note;
  final DateTime createdAt;
  final List<ParcelEntry> entries;

  SendyParcel({required this.id, required this.title, required this.note, required this.createdAt, required List<ParcelEntry> entries})
    : entries = List.unmodifiable(entries) {
    if (id.isEmpty || title.trim().isEmpty || title.length > 120 || note.length > 4000 || entries.isEmpty || entries.length > 10000) {
      throw const FormatException('Invalid parcel');
    }
  }

  int get totalSize => entries.fold(0, (total, entry) => total + entry.size);

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };

  factory SendyParcel.fromJson(Map<String, dynamic> json) => SendyParcel(
    id: json['id'] as String,
    title: json['title'] as String,
    note: json['note'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    entries: (json['entries'] as List).map((entry) => ParcelEntry.fromJson((entry as Map).cast<String, dynamic>())).toList(),
  );

  static String encodeLibrary(List<SendyParcel> parcels) => jsonEncode({'version': 1, 'parcels': parcels.map((parcel) => parcel.toJson()).toList()});

  /// Corrupt or newer libraries must not be replaced silently by an empty list.
  static List<SendyParcel> decodeLibrary(String? data) {
    if (data == null) return [];
    final json = jsonDecode(data) as Map<String, dynamic>;
    if (json['version'] != 1) throw const FormatException('Unsupported parcel library version');
    final parcels = (json['parcels'] as List).map((parcel) => SendyParcel.fromJson((parcel as Map).cast<String, dynamic>())).toList();
    if (parcels.map((parcel) => parcel.id).toSet().length != parcels.length) {
      throw const FormatException('Duplicate parcel identifiers');
    }
    return parcels;
  }
}
