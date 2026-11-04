part of 'development_seed.dart';

const _taxonomyBeforeProducts = <_Statement>[
  _Statement(r'''
INSERT INTO product_collections (id, title, handle)
VALUES ('pcol_featured', 'Featured', 'featured')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_types (id, value)
VALUES
  ('ptyp_shirt', 'Shirt'),
  ('ptyp_sweatshirt', 'Sweatshirt'),
  ('ptyp_pants', 'Pants'),
  ('ptyp_shorts', 'Shorts')
ON CONFLICT DO NOTHING
'''),
];

const _taxonomyAfterProducts = <_Statement>[
  _Statement(r'''
INSERT INTO product_categories (id, name, handle, rank)
VALUES
  ('pcat_shirts', 'Shirts', 'shirts', 0),
  ('pcat_sweatshirts', 'Sweatshirts', 'sweatshirts', 1),
  ('pcat_pants', 'Pants', 'pants', 2),
  ('pcat_merch', 'Merch', 'merch', 3)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_category_products
  (product_id, category_id, rank)
VALUES
  ('prod_tshirt', 'pcat_shirts', 0),
  ('prod_sweatshirt', 'pcat_sweatshirts', 0),
  ('prod_sweatpants', 'pcat_pants', 0),
  ('prod_shorts', 'pcat_merch', 0)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_tags (id, value)
VALUES
  ('ptag_apparel', 'Apparel'),
  ('ptag_cotton', 'Cotton')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_tag_products (product_id, tag_id)
VALUES
  ('prod_tshirt', 'ptag_apparel'),
  ('prod_tshirt', 'ptag_cotton'),
  ('prod_sweatshirt', 'ptag_apparel'),
  ('prod_sweatshirt', 'ptag_cotton'),
  ('prod_sweatpants', 'ptag_apparel'),
  ('prod_sweatpants', 'ptag_cotton'),
  ('prod_shorts', 'ptag_apparel'),
  ('prod_shorts', 'ptag_cotton')
ON CONFLICT DO NOTHING
'''),
];
