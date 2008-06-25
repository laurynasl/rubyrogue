module MassLoadable
  def all
    @@all
  end

  def all=(value)
    @@all = value
  end

  def load_all_from(filename)
    f = File.open(filename)
    items_data = YAML::load(f)
    @@all = {}
    items_data.each do |key, value|
      @@all[key] = new(value)
    end
    f.close
  end
end
