# The Zoo
class Zoo
  attr_accessor :name, :location, :enclosures

  def initialize name, location, enclosures=[]
    # basic param check
    return false if name.nil? or location.nil? or enclosures.nil?

    @name = name
    @location = location
    @enclosures = enclosures
  end
end

# An enclosure holds animals
class Enclosure
  # size is ft^2
  attr_accessor :animals, :size

  def initialize size, animals=[]
    return false if size.nil? or animals.nil?

    @size = size
    @animals = animals
  end
end

# Represents a generic animal
module Animal
  attr_accessor :name, :age, :num_legs
  
  def initialize name, age, num_legs
    return false if name.nil? or age.nil? or num_legs.nil?
    
    @name = name
    @age = age
    @num_legs = num_legs
  end

  def move
    report_action 'walking!'
    sleep 2
  end

  def eat
    report_action 'eating!'
    sleep 4
  end

  def nap
    report_action 'sleeping!'
    sleep 10
  end

  # makes the animal do a series of actions randomly
  def do_stuff more_actions=[], num_actions=5
    actions = []
    num_actions.times do
      actions.push ((['move', 'eat', 'nap'] + more_actions).sample)
    end
    actions.each do |action|
      m = method action
      m.call
    end
    puts "#{@name} is done doing stuff!"
  end

  def report_action action
    puts "#{@name} is: #{action}"
  end
end

class Elephant
  include Animal

  def initialize name, age
    super name, age, 4
  end

  def shoot_water
    report_action 'shooting water and being crazy!'
    sleep 1
  end

  def move
    super
    sleep 1 # wait an extra second because elephants are slow!
  end
  
  def do_stuff
    super(['shoot_water'])
  end
end

class Penguin
  include Animal

  def initialize name, age
    super name, age, 2
  end

  def move
    report_action 'swimming!'
    sleep 5
  end

  def eat
    super
    report_action 'happy to be eating fish!'
  end
end


class Wolf
  include Animal

  # wolves can be dangerous, 0 being cuddly and 9 being lethal
  attr_accessor :danger_level

  def initialize name, age
    super name, age, 4
    @danger_level = rand(10)
  end

  # returns true if the wolf attacks, false otherwise
  def attack?
    if rand(@danger_level) > 3
      report_action 'attacking!'
      sleep 7
      return true
    else 
      report_action 'not attacking....'
      sleep 1
      return false
    end
  end

  def do_stuff
    super(['attack?'])
  end
end


# main entry point
# essentially we're creating a bunch of random animals and having them do random actions
zoo = Zoo.new 'Bens Zoo', 'NYC'
animals = [Elephant, Penguin, Wolf]
zoo.enclosures.push(Enclosure.new(1000))

num_animals=100
threads = []

num_animals.times do |i|
  threads.push(Thread.new do
                 random_animal_class = animals.sample
                 new_animal = random_animal_class.new "#{random_animal_class.to_s}#{i}", 3
                 zoo.enclosures.first.animals.push new_animal # add animal to enclosure
                 new_animal.do_stuff
               end)
end

threads.each do |t| t.join end
puts "ALL DONE"
