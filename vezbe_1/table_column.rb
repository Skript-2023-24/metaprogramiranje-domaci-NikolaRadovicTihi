# frozen_string_literal: true

class TableColumn
  include Enumerable
  def initialize(data,index)
    @data = data
    @index = index
  end


  def each
    @data.each do |row|
      yield row[@index]
    end
  end

  def []=(row_index,val)
    @data[row_index][@index] = val if row_index < @data.length
  end

  def to_s
    @data.map { |row| row[@index].to_s }.join("\n")
  end

  def avg
    #checks if values are floats or int
    numeric_values = @data.map do |row|
      value = row[@index]
      value.to_f
    end

    sum = numeric_values.reduce(:+) # sums elements using reduce
    sum / numeric_values.length unless numeric_values.empty?
  end

  def sum
    numeric_values = @data.map do |row|
      value = row[@index]
      value.to_f
    end

    sum = numeric_values.reduce(:+)
  end

  def method_missing(method_name, *arguments, &block)
    value_to_find = method_name.to_s

    # Search for the row containing the value
    row_with_value = @data.find do |row|
      row_value = row[@index].to_s.downcase.gsub(/\s+/, "")
      row_value == value_to_find
    end
    return row_with_value if row_with_value
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    @data.any? { |row| row[@index].to_s.downcase.gsub(/\s+/, "") == method_name.to_s } || super
  end
end
