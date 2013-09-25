# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?

  lr = Site.where(name: 'LR').first_or_create
  bf = Site.where(name: 'BF').first_or_create

  veg = Category.where(name: 'Baby veg').first_or_create
  salad = Category.where(name: 'Peppery salad').first_or_create

  toms = Crop.where(name: 'Tomatoes', category_id: veg).first_or_create
  mizuna = Crop.where(name: 'Mizuna', category_id: salad).first_or_create

  gardeners = Type.where(name: "Gardener's", crop_id: toms).first_or_create
  mizuna_type = Type.where(name: "Mizuna", crop_id: mizuna).first_or_create

  field = Size.where(name: 'Field').first_or_create
  ninecm = Size.where(name: '9cm').first_or_create

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

  for i in 1..17
    Batch.create(
      site_id: lr.id,
      category_id: veg.id,
      crop_id: toms.id,
      type_id: gardeners.id,
      size_id: ninecm.id,
      generation: 2 + i,
      units_per_tray: 100,
      total_trays: 20,
      start_week: 11 + i,
      germinate_week: 12 + i,
      pot_week: 13 + i,
      sale_week: 15 + i,
      expiry_week: 17 + 1
    )

    mizuna = Crop.where(name: "Mizuna #{i}", category_id: salad).first_or_create

    Batch.create(
      site_id: bf.id,
      category_id: salad.id,
      crop_id: mizuna.id,
      type_id: mizuna_type.id,
      size_id: field.id,
      generation: 2 + i,
      units_per_tray: 100,
      total_trays: 20,
      start_week: 11 + i,
      germinate_week: 12 + i,
      pot_week: 13 + i,
      sale_week: 15 + i,
      expiry_week: 17 + 1
    )
  end
end #development