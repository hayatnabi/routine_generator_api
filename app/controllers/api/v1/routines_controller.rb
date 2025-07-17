class Api::V1::RoutinesController < ApplicationController
  include ActionController::MimeResponds

  def generate
    wake_time = Time.parse(params[:wake_time])
    sleep_time = Time.parse(params[:sleep_time])
    focus_hours = params[:focus_hours].to_i
    goals = params[:goals] || []
    productivity_type = params[:productivity_type] || "balanced"
    
    total_hours = ((sleep_time - wake_time) / 3600).to_i
    
    morning_routine = generate_morning_routine(productivity_type)
    work_blocks = generate_work_blocks(wake_time, focus_hours, productivity_type)
    evening_routine = generate_evening_routine(sleep_time, productivity_type)
    
    # Store the routine in session for export action
    session[:routine_data] = {
      wake_time: wake_time.strftime("%H:%M"),
      sleep_time: sleep_time.strftime("%H:%M"),
      productivity_type: productivity_type,
      goals: goals,
      routine: {
        morning: morning_routine,
        work_blocks: work_blocks,
        evening: evening_routine
      }
    }

    @@routine = session[:routine_data]
  
    render json: @@routine
  end

  def export
    return render json: { error: "No routine to export" }, status: :not_found unless @@routine
  
    respond_to do |format|
      format.pdf do
        pdf_data = PdfRoutineExporter.new(@@routine).generate
        send_data pdf_data,
                  filename: "routine.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
  
      format.csv do
        csv_data = CsvRoutineExporter.new(@@routine).generate
        send_data csv_data,
                  filename: "routine.csv",
                  type: "text/csv",
                  disposition: "attachment"
      end
    end
  end

  private

  def generate_morning_routine(type)
    case type
    when "early_bird"
      [
        { time: "Wake Up", duration: "6:00 AM - 6:15 AM" },
        { time: "Exercise", duration: "6:15 AM - 6:45 AM" },
        { time: "Breakfast & Planning", duration: "6:45 AM - 7:30 AM" }
      ]
    when "night_owl"
      [
        { time: "Wake Up", duration: "9:00 AM - 9:15 AM" },
        { time: "Slow Start & Breakfast", duration: "9:15 AM - 10:00 AM" }
      ]
    else
      [
        { time: "Wake Up", duration: "7:30 AM - 7:45 AM" },
        { time: "Light Stretch & Planning", duration: "7:45 AM - 8:15 AM" }
      ]
    end
  end

  def generate_work_blocks(start_time, hours, type)
    blocks = []
    current = start_time + 2.hours # assuming morning routine ends

    hours.times do |i|
      blocks << {
        block: "Focus Block #{i+1}",
        duration: "#{current.strftime('%I:%M %p')} - #{(current + 1.hour).strftime('%I:%M %p')}"
      }
      current += 1.5.hours # including 30 min breaks
    end

    blocks
  end

  def generate_evening_routine(sleep_time, type)
    [
      { time: "Dinner", duration: "7:30 PM - 8:00 PM" },
      { time: "Wind Down / Reading", duration: "8:00 PM - #{(sleep_time - 30.minutes).strftime('%I:%M %p')}" },
      { time: "Prepare for Bed", duration: "#{(sleep_time - 30.minutes).strftime('%I:%M %p')} - #{sleep_time.strftime('%I:%M %p')}" }
    ]
  end
end
