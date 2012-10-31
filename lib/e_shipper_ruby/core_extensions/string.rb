class String
  def camel_case(mode=:normal)
    worlds = self.split(/[^a-z0-9]/i)
    case mode
    when :normal
      return worlds[0] if 1 == worlds.size
      ([worlds.first] + worlds.drop(1).map{|w| w.capitalize}).join 
    when :cap_first_letter
      return worlds[0].capitalize if 1 == worlds.size
      worlds.map(&:capitalize).join
    end
  end

  def label
    self.split(/[^a-z0-9]/i).map(&:capitalize).join(' ')
  end
end