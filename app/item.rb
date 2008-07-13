class Item
  attr_accessor :name, :count

  def initialize(name)
    if matchdata = /^(\d+) (.+)s$/.match(name)
      @name = matchdata[2]
      @count = matchdata[1].to_i
    else
      @name = name
    end
  end

  def to_s
    if @count
      "#{@count} #{@name}s"
    else
      @name
    end
  end

  def klass
    ItemClass.all[name]
  end
end
