module MassLoadable
  def all
    eval "@@#{self.name}all"
  end

  def all=(value)
    eval "@@#{self.name}all = value"
  end

  def load_all_from(filename)
    f = File.open(filename)
    items_data = YAML::load(f)
    self.all = {}
    items_data.each do |key, value|
      all[key] = new(value)
    end
    f.close
  end
end
