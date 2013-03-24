class Stage < ClassyEnum::Base
end

class Stage::Sow < Stage
  def week(batch)
    batch.start_week
  end

  def self.title
    'Sow / Cuttings'
  end

  def self.next
    Stage::Germinate
  end
end

class Stage::Germinate < Stage
  def week(batch)
    batch.germinate_week
  end

  def self.title
    'Germinate / Root'
  end

  def self.next
    Stage::Pot
  end
end

class Stage::Pot < Stage
  def week(batch)
    batch.pot_week
  end

  def self.title
    'Pot / Ground'
  end

  def self.next
    Stage::Sale
  end
end

class Stage::Sale < Stage
  def week(batch)
    batch.sale_week
  end

  def self.title
    'Sale'
  end

  def self.next
    Stage::Expiry
  end
end

class Stage::Expiry < Stage
  def week(batch)
    batch.expiry_week
  end

  def self.title
    'Expiry'
  end
end
