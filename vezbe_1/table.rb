require_relative 'table_column'
require_relative 'session_manager'
require 'securerandom'

class Table
  attr_accessor :data, :headers, :worksheet

  include Enumerable

  def initialize(worksheet,session,spreadsheet_key)
    @worksheet = worksheet
    @session = session
    @spreadsheet_key = spreadsheet_key
    generate_table
    @alternative_headers = convert_to_camel_case(@headers)
  end

  def each

    combined = [@headers] + @data #Combine headers with data
    combined.each do |row|
      row.each do |cell|
        yield cell
      end
    end
  end


  def row(index)
    if @data.length < index
      return nil
    end
    @data[index]
  end

  def [](header_name)

    column_index = @headers.index(header_name)
    return [] unless column_index

    TableColumn.new(@data,column_index) #TODO: get instance from the list

  end

  def +(other)

    raise "Headers do not match" unless @headers == other.headers

    new_worksheet = Table.new(nil,@session,@spreadsheet_key) #creates uninitialized table

    new_worksheet.data = @data + other.data

    new_worksheet
  end

  def -(other)

    raise "Headers do not match" unless @headers == other.headers

    new_worksheet = Table.new(nil,@session,@spreadsheet_key) #creates uninitialized table

    new_worksheet.data = @data - other.data
    new_worksheet
  end


  def method_missing(method_name, *arguments, &block)
    # Convert method name to header format


    # Check if the header exists and return the column, otherwise call super
    if @alternative_headers.include?(method_name.to_s)
      real_name = @headers[@alternative_headers.index(method_name.to_s)]
      self[real_name]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    header_name = convert_to_camel_case_to_header(method_name)
    @headers.include?(header_name) || super
  end


  def sync(worksheet_name = nil)

    if @worksheet.nil?

      @worksheet = @session.create_worksheet(worksheet_name,@spreadsheet_key)

      if worksheet_name.nil?
        worksheet_name = SecureRandom.alphanumeric(20)
      end

      @worksheet.title = worksheet_name
    end
    end_data = [@headers] + @data

    end_data.each_with_index do |row_data, index|
      update_row_in_worksheet(end_data,index + @row_start)
    end

    @worksheet.save

  end

  private
  #TODO: HANDLE MERGE AND AVG TOTAL THIS GENERATES TABLE THE FIRST TIME
  def generate_table
    @headers = []
    @data = []
    @row_start = 0
    header_found = false
    @header_shift = 0
    if worksheet.nil?
      return @data
    end
    @worksheet.rows.each_with_index do |row, index|


      next if row.all? { |cell| cell.nil? || cell.strip.empty? } && !header_found

      unless header_found
        @header_shift = row.index { |cell| !cell.nil? && !cell.strip.empty? }
        @headers = row.drop(@header_shift)
        @headers = map { |cell| cell ? cell.strip : cell}
        header_found = true
        @row_start = index
        next
      end

      aligned_row = row.drop(@header_shift)
      @data << aligned_row
    end
  end
  def convert_to_camel_case(headers)
    headers.map do |header|
      words = header.split
      words.map!.with_index { |word, index| index.zero? ? word.downcase : word.capitalize }
      words.join
    end

  end

  def update_row_in_worksheet(row,row_index)

    row_data = row[row_index]
    # Update the worksheet
    begin
      worksheet_row_index = @row_start + row_index + 1
      adjusted_row_data = Array.new(@header_shift, nil) + row_data
      adjusted_row_data.each_with_index do |value, col_index|
        @worksheet[worksheet_row_index, col_index + 1] = value
      end
    rescue => e
      # Handle any errors that occur during the update
      raise "Failed to update worksheet row: #{e.message}"
    end
  end

end
