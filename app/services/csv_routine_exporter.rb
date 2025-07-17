require 'csv'

class CsvRoutineExporter
  def initialize(routine_data)
    @routine = routine_data
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << ["Section", "Label", "Duration"]

      %i[morning work_blocks evening].each do |section|
        @routine[:routine][section].each do |item|
          label = item[:time] || item[:block]
          csv << [section.to_s.titleize, label, item[:duration]]
        end
      end
    end
  end
end
