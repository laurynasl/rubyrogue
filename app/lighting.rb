class Lighting < Constructable
  attr_accessor :map, :tiles, :memorize

  def initialize(options)
    super
    @tiles ||= []
  end

  def calculate_fov
    RubyFov.calculate(self, map.game.player.x, map.game.player.y, map.game.player.perception)
  end

  def [](i)
    tiles[i]
  end

  def apply_lighting(x, y)
    @tiles[y * map.width + x] = true
    @map.apply_lighting(x, y) if memorize
  end

  def opaque_at?(x, y)
    @map.opaque_at?(x, y)
  end
end
