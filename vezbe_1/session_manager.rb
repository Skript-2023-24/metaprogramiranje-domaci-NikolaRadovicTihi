require "google_drive"
require_relative 'table'
class SessionManager

  def initialize(config_path)
    @session = GoogleDrive::Session.from_config(config_path)
  end

  def get_worksheet(spreadsheet_key)
    begin
      spreadsheet = @session.spreadsheet_by_key(spreadsheet_key)

      worksheet = spreadsheet.worksheets.first

      Table.new(worksheet,self,spreadsheet_key)
    rescue => e
      puts "An error occurred: #{e.message}"
      nil
    end
  end
  def create_worksheet(name,spreadsheet_key)

    spreadsheet = @session.spreadsheet_by_key(spreadsheet_key)

    worksheet = spreadsheet.add_worksheet(name)


  end
end
