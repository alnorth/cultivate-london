# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

lr = Site.create(name: 'LR')
bf = Site.create(name: 'BF')

veg = Category.create(name: 'Baby veg')
salad = Category.create(name: 'Peppery salad')

toms = Crop.create(name: 'Tomatoes', category_id: veg.id)
mizuna = Crop.create(name: 'Mizuna', category_id: salad.id)

gardeners = Type.create(name: "Gardener's", crop_id: toms.id)
mizuna_type = Type.create(name: "Mizuna", crop_id: mizuna.id)

field = Size.create(name: 'Field')
ninecm = Size.create(name: '9cm')

Batch.create(
  site_id: lr.id,
  category_id: veg.id,
  crop_id: toms.id,
  type_id: gardeners.id,
  size_id: ninecm.id,
  generation: 1,
  units_per_tray: 18,
  total_trays: 20,
  start_week: 12,
  germinate_week: 13,
  pot_week: 16,
  sale_week: 20,
  expiry_week: 24
)

Batch.create(
  site_id: bf.id,
  category_id: salad.id,
  crop_id: mizuna.id,
  type_id: mizuna_type.id,
  size_id: field.id,
  generation: 1,
  units_per_tray: 100,
  total_trays: 20,
  start_week: 11,
  germinate_week: 12,
  pot_week: 13,
  sale_week: 15,
  expiry_week: 17
)
