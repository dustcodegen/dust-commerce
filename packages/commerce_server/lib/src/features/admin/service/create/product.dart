part of '../create.dart';

/// Error crossing the Admin product-create boundary.
sealed class AdminCreateProductError {
  /// Creates one product-create error.
  const AdminCreateProductError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminCreateProductRejected extends AdminCreateProductError {
  /// Creates one business rejection.
  const AdminCreateProductRejected(this.failure);

  /// The stable business reason.
  final AdminCreateProductFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminCreateProductStorage extends AdminCreateProductError {
  /// Creates one storage failure.
  const AdminCreateProductStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Creates a complete sellable product graph in one transaction.
Future<Result<AdminProductDetailResponse, AdminCreateProductError>>
    createAdminProduct(
  CommerceDatabase database,
  AdminCreateProduct input, {
  required String Function() nextId,
  required AdminMediaStorage mediaStorage,
}) async {
  final claims = [for (final item in input.media) (id: item.id, url: item.url)];
  if (!mediaStorage.claim(claims)) {
    return const Err(AdminCreateProductRejected(
      AdminCreateProductFailure.invalidMedia,
    ));
  }
  try {
    return await transactionResult<AdminProductDetailResponse,
        AdminCreateProductError>(
      database,
      (tx) async {
        final writes = AdminProductCreateRepository(tx);
        final currencies = await writes.activeCurrencies();
        if (currencies case Err(:final error)) {
          return Err(AdminCreateProductStorage(error));
        }
        if (input.typeId case final typeId?) {
          final typeCount = await writes.activeProductTypeCount(typeId);
          if (typeCount case Err(:final error)) {
            return Err(AdminCreateProductStorage(error));
          }
          if ((typeCount as Ok<int, SqlxError>).value == 0) {
            return const Err(AdminCreateProductRejected(
              AdminCreateProductFailure.invalidProductType,
            ));
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
        if (prepared case Err(:final error)) {
          return Err(AdminCreateProductRejected(error));
        }
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
        if (inserted case Err(:final error)) {
          return Err(AdminCreateProductStorage(error));
        }
        if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
          return const Err(AdminCreateProductRejected(
            AdminCreateProductFailure.handleConflict,
          ));
        }

        for (var rank = 0; rank < product.media.length; rank++) {
          final imageWrite = await writes.insertImage(
            nextId(),
            productId,
            product.media[rank].url,
            rank,
          );
          if (imageWrite case Err(:final error)) {
            return Err(AdminCreateProductStorage(error));
          }
        }

        final optionWrite = await _insertCreatedOptions(
          writes,
          productId,
          product.options,
          nextId,
        );
        if (optionWrite case Err(:final error)) {
          return Err(AdminCreateProductStorage(error));
        }
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
          if (variantWrite case Err(:final error)) {
            return Err(AdminCreateProductStorage(error));
          }
          if ((variantWrite as Ok<ExecResult, SqlxError>).value.rowsAffected ==
              0) {
            return const Err(AdminCreateProductRejected(
              AdminCreateProductFailure.skuConflict,
            ));
          }
          for (final selection in variant.optionValues.entries) {
            final option = createdOptions[selection.key]!;
            final link = await writes.insertVariantOptionValue(
              variantId,
              option.id,
              option.values[selection.value]!,
            );
            if (link case Err(:final error)) {
              return Err(AdminCreateProductStorage(error));
            }
          }
          for (final price in variant.prices) {
            final priceWrite = await writes.insertPrice(
              variantId,
              price.currencyCode,
              price.amount,
            );
            if (priceWrite case Err(:final error)) {
              return Err(AdminCreateProductStorage(error));
            }
          }
        }

        final refreshed =
            await AdminProductReadRepository(tx).findById(productId);
        if (refreshed case Err(:final error)) {
          return Err(AdminCreateProductStorage(error));
        }
        return switch (optionOf(
          (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
        )) {
          Some(:final value) => Ok(value),
          None() => const Err(AdminCreateProductRejected(
              AdminCreateProductFailure.unavailable,
            )),
        };
      },
      storageError: AdminCreateProductStorage.new,
    );
  } finally {
    mediaStorage.release(claims);
  }
}
