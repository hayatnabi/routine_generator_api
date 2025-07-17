require 'prawn'

class PdfRoutineExporter
  def initialize(routine_data)
    @routine = routine_data
  end

  def generate
    Prawn::Document.new do |pdf|
      pdf.text "Routine Plan", size: 24, style: :bold
      pdf.move_down 10

      pdf.text "Wake Time: #{@routine[:wake_time]}"
      pdf.text "Sleep Time: #{@routine[:sleep_time]}"
      pdf.text "Productivity Type: #{@routine[:productivity_type]}"
      pdf.move_down 10

      pdf.text "Goals:", style: :bold
      @routine[:goals].each_with_index do |goal, index|
        pdf.text "#{index + 1}. #{goal}"
      end

      %i[morning work_blocks evening].each do |section|
        pdf.move_down 10
        pdf.text "#{section.to_s.titleize}:", style: :bold
        @routine[:routine][section].each do |item|
          label = item[:time] || item[:block]
          pdf.text "#{label}: #{item[:duration]}"
        end
      end
    end.render
  end
end
