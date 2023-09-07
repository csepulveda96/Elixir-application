#!/usr/bin/env ruby

class ApplicationTest
  attr_reader :incomming_weight, :incomming_gravity

  LAUNCH = 'launch'
  LAND = 'land'

  REQUIRED_KEYS = [LAUNCH, LAND]

  def initialize(weight:, gravity:)
    @incomming_weight = weight
    @incomming_gravity = gravity
  end

  def perform
    @weight = Float(@incomming_weight)
    @gravity = parse_gravity    
    raise ArgumentError, "Gravity variable is on an incorrect format" unless @gravity.is_a?Array

    fuel_hash = calculate_fuel
    fuel_hash = calculate_extra_fuel(fuel_hash)
    
    fuel = fuel_hash.sum { |hash| hash[:fuel] }
    extra_fuel = fuel_hash.sum { |hash| hash[:extra_fuel] }


    puts "The initial fuel you will need is: #{fuel}"
    puts "The extra fuel you will need is: #{extra_fuel}"
    puts "The required fuel for the whole mission is: #{fuel + extra_fuel}"
  rescue ArgumentError => e
    puts e.message
  end

  private

  def calculate_extra_fuel(original_fuel)
    original_fuel.map do |original|
      total_extra_fuel = iterate_on_extra_fuel(original).sum
      
      original.merge(extra_fuel: total_extra_fuel)
    end
  end

  def iterate_on_extra_fuel(original)
    need_extra_fuel = original[:fuel]
    extra = need_extra_fuel
    array = []

    loop do
      extra = original[:type].eql?(LAUNCH.to_sym) ? launch_formula(extra, original[:gravity]) : land_formula(extra, original[:gravity])
      break unless extra.positive?

      array << extra.floor
      @weight += extra
      need_extra_fuel = need_extra_fuel + extra
    end

   array
  end

  def calculate_fuel
    original_fuel = []

    @gravity.each do |grav|
      this_key = grav[:type]
      calculated = this_key.eql?(LAUNCH.to_sym) ? launch_formula(@weight, grav[:gravity]) : land_formula(@weight, grav[:gravity])
      
      original_fuel << grav.merge(fuel: calculated.floor)
      @weight += calculated
    end

    original_fuel
  end

  def launch_formula(weight, gravity)
    weight * gravity * 0.042 - 33
  end

  def land_formula(weight, gravity)
    weight * gravity * 0.033 - 42
  end

  def parse_gravity
    # Personally I wouldn't use eval sentence, but it's the only way I found to parse the string as an array
    temp = eval(@incomming_gravity)
    final_hash = []

    temp.each do |value|
      raise ArgumentError, "Key #{value.first} not allowed!" unless REQUIRED_KEYS.include?(value.first.to_s)
      
      final_hash << {
        type: value.first,
        gravity: value.last
      }
    end
    
    final_hash
  rescue NameError => e
    false
  end
end

puts "Welcome! Please enter the Weight of the Service Module:"
weight = gets.chomp
puts "Please enter the Gravity information in this format: [[:launch, 9.807], [:land, 1.62], [:launch, 1.62], [:land, 9.807]]"
gravity = gets.chomp
puts "-----------------------------------------------------"


ApplicationTest.new(weight: weight, gravity: gravity).perform
