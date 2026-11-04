import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-matched merchant label for an order fulfillment status.
String adminOrderFulfillmentLabel(AdminOrderFulfillmentStatus status) =>
    switch (status) {
      AdminOrderFulfillmentStatus.notFulfilled => 'Not fulfilled',
      AdminOrderFulfillmentStatus.partiallyFulfilled => 'Partially fulfilled',
      AdminOrderFulfillmentStatus.fulfilled => 'Fulfilled',
      AdminOrderFulfillmentStatus.partiallyShipped => 'Partially shipped',
      AdminOrderFulfillmentStatus.shipped => 'Shipped',
      AdminOrderFulfillmentStatus.partiallyDelivered => 'Partially delivered',
      AdminOrderFulfillmentStatus.delivered => 'Delivered',
      AdminOrderFulfillmentStatus.canceled => 'Canceled',
    };

/// Medusa-matched semantic color for an order fulfillment status.
Color adminOrderFulfillmentColor(AdminOrderFulfillmentStatus status) =>
    switch (status) {
      AdminOrderFulfillmentStatus.notFulfilled ||
      AdminOrderFulfillmentStatus.canceled =>
        const Color(0xFFEF4444),
      AdminOrderFulfillmentStatus.partiallyFulfilled ||
      AdminOrderFulfillmentStatus.partiallyShipped ||
      AdminOrderFulfillmentStatus.partiallyDelivered =>
        const Color(0xFFF59E0B),
      AdminOrderFulfillmentStatus.fulfilled ||
      AdminOrderFulfillmentStatus.shipped ||
      AdminOrderFulfillmentStatus.delivered =>
        const Color(0xFF22C55E),
    };
