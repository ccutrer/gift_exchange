#!/usr/bin/env ruby

require 'yaml'

class GiftExchange
  def initialize(config_file, max_valid_count = 10000)
    @config = YAML.load_file(config_file)
    @max_valid_count = max_valid_count

    @person_to_family = {}
    @config['families'].each do |family, members|
      members.each do |member|
        @person_to_family[member] = family
      end
    end

    @history = (@config['history'] || {}).values.compact
  end

  def best_solution
    valid_solutions = []
    calculate(@person_to_family.keys, {}, valid_solutions)
    valid_solutions.sort_by do |solution|
      solution.map do |(giver, recipient)|
        @history.index do |year|
          year[giver] == recipient
        end || @history.length
      end.inject(0, &:+) * -1
    end
    valid_solutions.first
  end

  def calculate(remaining_people, assigned_so_far, valid_solutions)
    return if valid_solutions.length > @max_valid_count
    if remaining_people.empty?
      valid_solutions << assigned_so_far
      return
    end

    giver = remaining_people.first
    others = remaining_people - [giver]
    remaining_recipients = (@person_to_family.keys - assigned_so_far.values).shuffle
    remaining_recipients.each do |recipient|
      # can't give to yourself
      next if giver == recipient
      # can't give to someone in your family
      next if @person_to_family[giver] == @person_to_family[recipient]
      # same person gave last year
      next if @history[0] && @history[0][giver] == recipient
      next if @history[1] && @history[1][giver] == recipient
      # Brody has to have Lionel this year
      next if giver == 'Brody' && recipient != 'Lionel' && Time.now.year == 2020

      next_assigned_so_far = assigned_so_far.dup
      next_assigned_so_far[giver] = recipient

      calculate(others, next_assigned_so_far, valid_solutions)
    end
  end
end

solution = GiftExchange.new(ARGV[0] || 'config.yml').best_solution

puts ({ 'history' => { Time.now.year => solution } }.to_yaml)
