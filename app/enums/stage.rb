class Stage < ClassyEnum::Base
  def self.ordered
    [Stage::Sow, Stage::Germinate, Stage::Pot, Stage::Sale, Stage::Expiry]
  end
end

class Stage::Sow < Stage
  def self.field
    'start_week'
  end

  def self.title
    'Sow / Cuttings'
  end

  def self.next
    Stage::Germinate
  end
end

class Stage::Germinate < Stage
  def self.field
    'germinate_week'
  end

  def self.title
    'Germinate / Root'
  end

  def self.next
    Stage::Pot
  end
end

class Stage::Pot < Stage
  def self.field
    'pot_week'
  end

  def self.title
    'Pot / Ground'
  end

  def self.next
    Stage::Sale
  end
end

class Stage::Sale < Stage
  def self.field
    'sale_week'
  end

  def self.title
    'Sale'
  end

  def self.next
    Stage::Expiry
  end
end

class Stage::Expiry < Stage
  def self.field
    'expiry_week'
  end

  def self.title
    'Expiry'
  end
end
