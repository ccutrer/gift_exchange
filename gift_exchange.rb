#!/usr/bin/env ruby

require 'yaml'

class GiftExchange
  def initialize(config_file)
    @config = YAML.load_file(config_file)

    @person_to_family = {}
    @config['families'].each do |family, members|
      members.each do |member|
        @person_to_family[member] = family
      end
    end

    @history = (@config['history'] || {}).values
  end

  def best_solution
    valid_solutions = calculate(@person_to_family.keys, {})
  end

  def calculate(remaining_people, assigned_so_far)
    return assigned_so_far if remaining_people.empty?

    giver = remaining_people.first
    others = remaining_people - [giver]
    @person_to_family.keys.map do |recipient|
      # can't give to yourself
      next if giver == recipient
      # can't give to someone in your family
      next if @person_to_family[giver] == @person_to_family[recipient]
      # this person is already receiving a gift
      next if assigned_so_far.values.include?(recipient)
      # same person gave last year
      next if @history.first && history.first[giver] == recipient

      next_assigned_so_far = assigned_so_far.dup
      next_assigned_so_far[giver] = recipient

      calculate(others, next_assigned_so_far)
    end.flatten    
  end
end

puts GiftExchange.new(ARGV[0] || 'config.yml').best_solution.inspect