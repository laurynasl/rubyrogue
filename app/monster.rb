# Copyright (C) 2008 Laurynas Liutkus
# All rights reserved. See the file named LICENSE in the distribution
# for more details.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class Monster < Constructable
  attr_accessor :name, :x, :y, :inventory, :monster_type, :skills
  attr_accessor :maxhp, :hp, :energy, :hpfrac
  attr_accessor :dexterity, :perception, :health
  attr_accessor :weapon, :armor, :ammunition

  def initialize(attributes)
    @inventory = Inventory.new
    @energy = 0
    @hpfrac = 0
    @skills = {}
    super
    validate!
  end

  def attack(defender)
    wait
    chance = melee_chance_to_hit(defender)
    if rand < chance
      if weapon
        maxdamage = weapon.klass.damage
        skill = weapon.klass.skill
      else
        maxdamage = 2
        skill = 'unarmed'
      end
      damage = inflict_damage(defender, maxdamage)
      train(skill, chance, damage)
      if damage == 0
        "%s hits, but does not manage to hurt %s"
      elsif defender.alive?
        "%s hits %s"
      else
        "%s kills %s"
      end % [fullname, defender.fullname]
    else
      "%s misses %s" % [fullname, defender.fullname]
    end
  end

  def melee_chance_to_hit(defender)
    attack = melee_attack_rating
    defense = defender.melee_attack_rating
    attack / (attack + defense).to_f
  end

  def melee_attack_rating
    if weapon
      item_class = ItemClass.all[weapon.name]
      dexterity + (skill(item_class.skill) + item_class.accuracy) * 3
    else
      dexterity + skill('unarmed') * 3
    end
  end

  def ranged_attack(defender)
    wait
    rand
    "%s misses %s" % [fullname, defender.fullname]
  end

  def train(skill, chance, amount)
    @skills[skill] ||= 0.0
    @skills[skill] += amount / chance / chance / 100

    @skills['level'] ||= 0.0
    @skills['level'] += amount / chance / chance / 1000
  end

  def skill(s)
    if value = skills[s]
      Math.sqrt(value).to_i
    else
      0
    end
  end

  # returns amount of damage inflicted
  def inflict_damage(defender, maxdamage)
    damage = rand(maxdamage) + 1
    damage -= defender.rand_armor
    return 0 unless damage > 0
    defender.hp -= damage
    damage
  end

  def rand_armor
    if armor
      rand(armor.klass.armor+1)
    else
      0
    end
  end

  def fullname
    name || monster_type
  end

  def validate!
    %w{hp monster_type maxhp dexterity perception health}.each do |attribute|
      raise "#{attribute} is required!" unless send(attribute)
    end
  end

  def alive?
    hp > 0
  end

  def wait
    @energy -= 100
  end

  def square_range_to(monster)
    dx = x - (monster.is_a?(Monster) ? monster.x : monster.first)
    dy = y - (monster.is_a?(Monster) ? monster.y : monster.last)
    dx * dx + dy * dy
  end

  def regenerate
    return if @hp == @maxhp
    @hpfrac += @health
    if @hpfrac >= 1000
      @hpfrac -= 1000
      @hp += 1
    end
  end

  def equip(slot, id)
    @inventory << send(slot) if send(slot)
    send(slot + '=', inventory.take(id))
  end

  def klass
    MonsterClass.all[monster_type]
  end
end
