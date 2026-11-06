import 'package:dust_dart/db.dart';

part 'media_model.g.dart';

/// Private SQLx projection used by staged-media cleanup.
@Derive([FromRow()])
final class AdminMediaReference {
  /// Creates one active public media reference.
  const AdminMediaReference({required this.url});

  /// Public URL retained by an active product image.
  final String url;
}
