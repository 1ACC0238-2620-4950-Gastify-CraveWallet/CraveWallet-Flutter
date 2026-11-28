import 'models.dart';

/// A frequent service the user can pick instead of typing its data (US04).
class CatalogService {
  const CatalogService(this.name, this.currency, this.category, this.color);

  final String name;
  final Currency currency;
  final SubscriptionCategory category;

  /// Brand-neutral badge color; the badge shows the service initials.
  final int color;

  String get initials {
    final words = name.split(RegExp(r'[\s+]+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}

/// Subscriptions most often reported by the two target segments, with the
/// currency they are usually billed in from Peru.
const subscriptionCatalog = <CatalogService>[
  CatalogService(
    'Netflix',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFFB71C1C,
  ),
  CatalogService(
    'Disney+',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFF0D47A1,
  ),
  CatalogService(
    'Max',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFF4527A0,
  ),
  CatalogService(
    'Prime Video',
    Currency.usd,
    SubscriptionCategory.streaming,
    0xFF01579B,
  ),
  CatalogService(
    'Paramount+',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFF1565C0,
  ),
  CatalogService(
    'Crunchyroll',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFFE65100,
  ),
  CatalogService(
    'Apple TV+',
    Currency.usd,
    SubscriptionCategory.streaming,
    0xFF212121,
  ),
  CatalogService(
    'YouTube Premium',
    Currency.pen,
    SubscriptionCategory.streaming,
    0xFFC62828,
  ),
  CatalogService(
    'Spotify Premium',
    Currency.pen,
    SubscriptionCategory.musica,
    0xFF1B5E20,
  ),
  CatalogService(
    'Apple Music',
    Currency.usd,
    SubscriptionCategory.musica,
    0xFFAD1457,
  ),
  CatalogService(
    'Deezer',
    Currency.pen,
    SubscriptionCategory.musica,
    0xFF6A1B9A,
  ),
  CatalogService(
    'Microsoft 365',
    Currency.pen,
    SubscriptionCategory.productividad,
    0xFFD84315,
  ),
  CatalogService(
    'Google One',
    Currency.pen,
    SubscriptionCategory.productividad,
    0xFF1976D2,
  ),
  CatalogService(
    'iCloud+',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF0277BD,
  ),
  CatalogService(
    'ChatGPT Plus',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF00695C,
  ),
  CatalogService(
    'Canva Pro',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF00838F,
  ),
  CatalogService(
    'Notion Plus',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF424242,
  ),
  CatalogService(
    'LinkedIn Premium',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF0A66C2,
  ),
  CatalogService(
    'Adobe Creative Cloud',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFFB71C1C,
  ),
  CatalogService(
    'Coursera Plus',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF1565C0,
  ),
  CatalogService(
    'Platzi',
    Currency.usd,
    SubscriptionCategory.productividad,
    0xFF2E7D32,
  ),
  CatalogService(
    'Duolingo Super',
    Currency.pen,
    SubscriptionCategory.productividad,
    0xFF558B2F,
  ),
  CatalogService(
    'Smart Fit',
    Currency.pen,
    SubscriptionCategory.fitness,
    0xFFF9A825,
  ),
  CatalogService(
    'Bodytech',
    Currency.pen,
    SubscriptionCategory.fitness,
    0xFF37474F,
  ),
  CatalogService(
    'Xbox Game Pass',
    Currency.usd,
    SubscriptionCategory.otros,
    0xFF2E7D32,
  ),
  CatalogService(
    'PlayStation Plus',
    Currency.usd,
    SubscriptionCategory.otros,
    0xFF283593,
  ),
  CatalogService(
    'Rappi Pro',
    Currency.pen,
    SubscriptionCategory.delivery,
    0xFFE64A19,
  ),
  CatalogService(
    'PedidosYa Plus',
    Currency.pen,
    SubscriptionCategory.delivery,
    0xFFC2185B,
  ),
];

/// Case- and accent-insensitive search over the catalog (US04, scenario 2).
List<CatalogService> searchCatalog(String query) {
  final q = foldText(query.trim());
  if (q.isEmpty) return subscriptionCatalog;
  return subscriptionCatalog
      .where((service) => foldText(service.name).contains(q))
      .toList();
}

/// Delivery places that come up most often in Lima (US18).
const deliveryMerchantCatalog = <String>[
  'Bembos',
  'Burger King',
  'Chili\'s',
  'China Wok',
  'Domino\'s Pizza',
  'Dunkin\'',
  'Edo Sushi Bar',
  'KFC',
  'La Lucha Sanguchería',
  'Madam Tusan',
  'McDonald\'s',
  'Mr. Sushi',
  'Norky\'s',
  'Papa John\'s',
  'Pardos Chicken',
  'Pizza Hut',
  'Popeyes',
  'Roky\'s',
  'Starbucks',
  'Tanta',
  'Tambo',
  'Mass',
];

/// Catalog merchants that match what the user typed; the whole catalog when
/// nothing is typed yet, so the user can pick one without writing.
List<String> searchMerchants(String query, {int limit = 8}) {
  final q = foldText(query.trim());
  if (q.isEmpty) return deliveryMerchantCatalog;
  return deliveryMerchantCatalog
      .where((merchant) => foldText(merchant).contains(q))
      .take(limit)
      .toList();
}

String foldText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[áàä]'), 'a')
    .replaceAll(RegExp('[éèë]'), 'e')
    .replaceAll(RegExp('[íìï]'), 'i')
    .replaceAll(RegExp('[óòö]'), 'o')
    .replaceAll(RegExp('[úùü]'), 'u')
    .replaceAll('ñ', 'n');
