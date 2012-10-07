class String
  def camel_case
    worlds = self.split(/[^a-z0-9]/i)
    return worlds[0] if 1 == worlds.size
    ([worlds.first] + worlds.drop(1).map{|w| w.capitalize}).join 
  end
end