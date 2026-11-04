import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/media_storage.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

part 'product_media.dart';
part 'create/insert_options.dart';

/// Why an administrator was not bootstrapped.
enum AdminBootstrapFailure {
  /// An active administrator already owns the normalized email.
  alreadyExists,
}

/// Business reason a valid JSON product graph cannot be created.
enum AdminCreateProductFailure {
  /// The normalized handle is empty or malformed.
  invalidHandle,

  /// Options or variant selections are incomplete or duplicated.
  invalidOptions,

  /// A variant or its prices are incomplete or duplicated.
  invalidVariants,

  /// A requested currency is not configured by an active selling region.
  invalidCurrency,

  /// Uploaded media is malformed, duplicated, or not owned by this server.
  invalidMedia,

  /// The requested product type is missing or retired.
  invalidProductType,

  /// Another active product already owns the requested handle.
  handleConflict,

  /// Another active variant already owns one requested SKU.
  skuConflict,

  /// The committed product could not be read back.
  unavailable,
}

/// Reads the active storefront currencies needed by Medusa's create grid.
Future<Result<AdminProductCreateContext, SqlxError>>
    readAdminProductCreateContext(
  AdminProductCreateRepository products,
) async {
  final currencies = await products.activeCurrencies();
  return switch (currencies) {
    Ok(:final value) => Ok(AdminProductCreateContext(
        currencyCodes: value.map((row) => row.currencyCode).toList(),
      )),
    Err(:final error) => Err(error),
  };
}

/// Creates a complete sellable product graph in one transaction.
Future<
    Result<Result<AdminProductDetailResponse, AdminCreateProductFailure>,
        SqlxError>> createAdminProduct(
  CommerceDatabase database,
  AdminCreateProduct input, {
  required String Function() nextId,
  required AdminMediaStorage mediaStorage,
}) async {
  final claims = [for (final item in input.media) (id: item.id, url: item.url)];
  if (!mediaStorage.claim(claims)) {
    return const Ok(Err(AdminCreateProductFailure.invalidMedia));
  }
  try {
    return await database.transaction((tx) async {
      final writes = AdminProductCreateRepository(tx);
      final currencies = await writes.activeCurrencies();
      if (currencies case Err(:final error)) return Err(error);
      if (input.typeId case final typeId?) {
        final typeCount = await writes.activeProductTypeCount(typeId);
        if (typeCount case Err(:final error)) return Err(error);
        if ((typeCount as Ok<int, SqlxError>).value == 0) {
          return const Ok(Err(AdminCreateProductFailure.invalidProductType));
        }
      }
      final prepared = _prepareProduct(
        input,
        (currencies as Ok<List<AdminProductCurrencyResponse>, SqlxError>)
            .value
            .map((row) => row.currencyCode)
            .toList(),
        mediaStorage,
      );
      if (prepared case Err(:final error)) return Ok(Err(error));
      final product =
          (prepared as Ok<_PreparedProduct, AdminCreateProductFailure>).value;
      final productId = nextId();
      final inserted = await writes.insertProduct(
        productId,
        product.title,
        product.handle,
        product.subtitle,
        product.material,
        product.description,
        product.thumbnail,
        input.typeId,
        product.discountable ? 1 : 0,
        product.status.name,
      );
      if (inserted case Err(:final error)) return Err(error);
      if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Ok(Err(AdminCreateProductFailure.handleConflict));
      }

      for (var rank = 0; rank < product.media.length; rank++) {
        final imageWrite = await writes.insertImage(
          nextId(),
          productId,
          product.media[rank].url,
          rank,
        );
        if (imageWrite case Err(:final error)) return Err(error);
      }

      final optionWrite = await _insertCreatedOptions(
        writes,
        productId,
        product.options,
        nextId,
      );
      if (optionWrite case Err(:final error)) return Err(error);
      final createdOptions =
          (optionWrite as Ok<Map<String, _CreatedOption>, SqlxError>).value;

      for (final variant in product.variants) {
        final variantId = nextId();
        final variantWrite = await writes.insertVariant(
          variantId,
          productId,
          variant.title,
          variant.sku,
          variant.inventoryQuantity,
          variant.manageInventory ? 1 : 0,
          variant.allowBackorder ? 1 : 0,
        );
        if (variantWrite case Err(:final error)) return Err(error);
        if ((variantWrite as Ok<ExecResult, SqlxError>).value.rowsAffected ==
            0) {
          final cleanup = await writes.deleteCreatedProduct(productId);
          if (cleanup case Err(:final error)) return Err(error);
          return const Ok(Err(AdminCreateProductFailure.skuConflict));
        }
        for (final selection in variant.optionValues.entries) {
          final option = createdOptions[selection.key]!;
          final link = await writes.insertVariantOptionValue(
            variantId,
            option.id,
            option.values[selection.value]!,
          );
          if (link case Err(:final error)) return Err(error);
        }
        for (final price in variant.prices) {
          final priceWrite = await writes.insertPrice(
            variantId,
            price.currencyCode,
            price.amount,
          );
          if (priceWrite case Err(:final error)) return Err(error);
        }
      }

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(Ok(value)),
        None() => switch (await writes.deleteCreatedProduct(productId)) {
            Ok() => const Ok(Err(AdminCreateProductFailure.unavailable)),
            Err(:final error) => Err(error),
          },
      };
    });
  } finally {
    mediaStorage.release(claims);
  }
}

/// Creates an admin profile and provider identity in one transaction.
Future<Result<Result<AdminUserResponse, AdminBootstrapFailure>, SqlxError>>
    bootstrapAdmin(
  CommerceDatabase database,
  AdminCredentials credentials, {
  required String Function() nextId,
  required PasswordWorkLimiter passwordWork,
  String? firstName,
  String? lastName,
}) async {
  final email = credentials.email.trim().toLowerCase();
  final passwordHash = await Passwords.hash(
    credentials.password,
    limiter: passwordWork,
  );
  final userId = nextId();
  final authIdentityId = nextId();
  final providerIdentityId = nextId();

  return database.transaction((tx) async {
    final writes = AdminCreateRepository(tx);
    final inserted = await writes.insertAdmin(
      userId,
      email,
      firstName,
      lastName,
    );
    if (inserted case Err(:final error)) return Err(error);
    final user = optionOf(
      (inserted as Ok<AdminUserResponse?, SqlxError>).value,
    );
    if (user case None()) {
      return const Ok(Err(AdminBootstrapFailure.alreadyExists));
    }

    final identity = await writes.insertAuthIdentity(
      authIdentityId,
      jsonEncode({'admin_user_id': userId}),
    );
    if (identity case Err(:final error)) return Err(error);
    final provider = await writes.insertProviderIdentity(
      providerIdentityId,
      email,
      authIdentityId,
      jsonEncode({'password': passwordHash}),
    );
    if (provider case Err(:final error)) return Err(error);

    return Ok(Ok((user as Some<AdminUserResponse>).value));
  });
}

/// Exchanges valid admin credentials for a short-lived opaque token.
Future<Result<Option<AdminIssuedToken>, SqlxError>> adminSignIn(
  AdminReadRepository reads,
  AdminCreateRepository writes,
  AdminCredentials input, {
  required DateTime now,
  required Future<String> dummyPasswordHash,
  required PasswordWorkLimiter passwordWork,
  Duration lifetime = const Duration(days: 7),
}) async {
  final found = await reads.adminByEmail(input.email.trim().toLowerCase());
  if (found case Err(:final error)) return Err(error);
  final account = optionOf(
    (found as Ok<AdminPasswordCredential?, SqlxError>).value,
  );
  final expected = switch (account) {
    Some(value: final credential) => credential.passwordHash,
    None() => await dummyPasswordHash,
  };
  final valid = await Passwords.verify(
    input.password,
    expected,
    limiter: passwordWork,
  );
  if (account case None()) return const Ok(None<AdminIssuedToken>());
  if (!valid) return const Ok(None<AdminIssuedToken>());

  final credential = (account as Some<AdminPasswordCredential>).value;
  final token = Tokens.issue();
  final expiresAt = now.toUtc().add(lifetime);
  final stored = await writes.insertToken(
    await Tokens.fingerprint(token),
    credential.authIdentityId,
    expiresAt.toIso8601String(),
  );
  if (stored case Err(:final error)) return Err(error);
  return Ok(Some(AdminIssuedToken(token: token, expiresAt: expiresAt)));
}

Result<_PreparedProduct, AdminCreateProductFailure> _prepareProduct(
  AdminCreateProduct input,
  List<String> activeCurrencies,
  AdminMediaStorage mediaStorage,
) {
  final title = input.title.trim();
  final handle = _handleFor(input.handle, title);
  if (handle.isEmpty ||
      !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(handle)) {
    return const Err(AdminCreateProductFailure.invalidHandle);
  }
  if (input.options.isEmpty) {
    return const Err(AdminCreateProductFailure.invalidOptions);
  }
  final preparedMedia = _prepareProductMedia(input.media, mediaStorage);
  if (preparedMedia case Err(:final error)) return Err(error);
  final media =
      (preparedMedia as Ok<List<_PreparedMedia>, AdminCreateProductFailure>)
          .value;
  final options = <_PreparedOption>[];
  final valuesByOption = <String, Set<String>>{};
  for (final option in input.options) {
    if (!option.validate().isValid) {
      return const Err(AdminCreateProductFailure.invalidOptions);
    }
    final optionTitle = option.title.trim();
    final values = option.values.map((value) => value.trim()).toList();
    final uniqueValues = values.toSet();
    if (values.isEmpty ||
        values.any((value) => value.isEmpty || value.length > 255) ||
        uniqueValues.length != values.length ||
        valuesByOption.containsKey(optionTitle)) {
      return const Err(AdminCreateProductFailure.invalidOptions);
    }
    valuesByOption[optionTitle] = uniqueValues;
    options.add(_PreparedOption(optionTitle, values));
  }
  if (input.variants.isEmpty) {
    return const Err(AdminCreateProductFailure.invalidVariants);
  }
  final requiredCurrencies = activeCurrencies.toSet();
  if (requiredCurrencies.isEmpty) {
    return const Err(AdminCreateProductFailure.invalidCurrency);
  }
  final skus = <String>{};
  final selections = <String>{};
  final variants = <_PreparedVariant>[];
  for (final variant in input.variants) {
    if (!variant.validate().isValid) {
      return const Err(AdminCreateProductFailure.invalidVariants);
    }
    final selected = <String, String>{
      for (final entry in variant.optionValues.entries)
        entry.key.trim(): entry.value.trim(),
    };
    if (selected.keys
            .toSet()
            .difference(valuesByOption.keys.toSet())
            .isNotEmpty ||
        valuesByOption.keys
            .toSet()
            .difference(selected.keys.toSet())
            .isNotEmpty ||
        selected.entries.any(
          (entry) =>
              !(valuesByOption[entry.key]?.contains(entry.value) ?? false),
        )) {
      return const Err(AdminCreateProductFailure.invalidOptions);
    }
    final selectionKey =
        options.map((option) => selected[option.title]).join('\u001F');
    if (!selections.add(selectionKey)) {
      return const Err(AdminCreateProductFailure.invalidVariants);
    }
    final skuText = variant.sku?.trim() ?? '';
    final sku = skuText.isEmpty ? null : skuText;
    if (sku != null && !skus.add(sku)) {
      return const Err(AdminCreateProductFailure.invalidVariants);
    }
    final prices = <_PreparedPrice>[];
    final priceCurrencies = <String>{};
    for (final price in variant.prices) {
      if (!price.validate().isValid ||
          !priceCurrencies.add(price.currencyCode)) {
        return const Err(AdminCreateProductFailure.invalidVariants);
      }
      prices.add(_PreparedPrice(price.currencyCode, price.amount));
    }
    if (priceCurrencies.length != requiredCurrencies.length ||
        !priceCurrencies.containsAll(requiredCurrencies)) {
      return const Err(AdminCreateProductFailure.invalidCurrency);
    }
    variants.add(_PreparedVariant(
      title: variant.title.trim(),
      sku: sku,
      inventoryQuantity: variant.inventoryQuantity,
      manageInventory: variant.manageInventory,
      allowBackorder: variant.allowBackorder,
      optionValues: selected,
      prices: prices,
    ));
  }
  return Ok(_PreparedProduct(
    title: title,
    handle: handle,
    subtitle: input.subtitle,
    material: input.material,
    description: input.description,
    media: media,
    discountable: input.discountable,
    status: input.status,
    options: options,
    variants: variants,
  ));
}

String _handleFor(String? requested, String title) {
  final supplied = requested?.trim() ?? '';
  if (supplied.isNotEmpty) return supplied;
  return title
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

final class _PreparedProduct {
  const _PreparedProduct({
    required this.title,
    required this.handle,
    required this.subtitle,
    required this.material,
    required this.description,
    required this.media,
    required this.discountable,
    required this.status,
    required this.options,
    required this.variants,
  });

  final String title;
  final String handle;
  final String? subtitle;
  final String? material;
  final String? description;
  final List<_PreparedMedia> media;
  final bool discountable;
  final AdminProductLifecycle status;
  final List<_PreparedOption> options;
  final List<_PreparedVariant> variants;

  String? get thumbnail {
    for (final item in media) {
      if (item.isThumbnail) return item.url;
    }
    return null;
  }
}

final class _PreparedOption {
  const _PreparedOption(this.title, this.values);

  final String title;
  final List<String> values;
}

final class _PreparedPrice {
  const _PreparedPrice(this.currencyCode, this.amount);

  final String currencyCode;
  final int amount;
}

final class _PreparedVariant {
  const _PreparedVariant({
    required this.title,
    required this.sku,
    required this.inventoryQuantity,
    required this.manageInventory,
    required this.allowBackorder,
    required this.optionValues,
    required this.prices,
  });

  final bool allowBackorder;
  final int inventoryQuantity;
  final bool manageInventory;
  final Map<String, String> optionValues;
  final List<_PreparedPrice> prices;
  final String? sku;
  final String title;
}

final class _CreatedOption {
  const _CreatedOption(this.id, this.values);

  final String id;
  final Map<String, String> values;
}
