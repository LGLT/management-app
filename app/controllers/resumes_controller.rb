require 'csv'

class ResumesController < ApplicationController
  def index   
    @resumes = Resume.all;   
  end   
    
  def new   
    @resume = Resume.new;  
  end   
    
  def create   
    @resume = Resume.new(resume_params);   
       
    if @resume.save   
      redirect_to resumes_path, notice: "Successfully uploaded.";   
    else   
      render "new";  
    end   
  end   
    
  def destroy   
    @resume = Resume.find(params[:id]);   
    @resume.destroy;  
    redirect_to resumes_path, notice:  "Successfully deleted.";  
  end
  
  def conciliacion
    review_report(params[:report_resume], params[:logs_resume][:name]);
  end

  def print_message
    respond_to do |format|
        format.js; 
    end
  end
    
 private   
  def resume_params   
    params.require(:resume).permit(:name, :attachment, :resume_type);   
  end
  
  def review_report(report_resume, logs_resume)
    @report_entity = Resume.find_by(name: report_resume);
    @logs_entity = Resume.find_by(name: logs_resume);
    
    results = [];
    i = 0;

    CSV.foreach(("public#{@report_entity.attachment}"), headers: true, col_sep: ",") do |row_report|
      finded = false;
      CSV.foreach(("public#{@logs_entity.attachment}"), headers: true, col_sep: ",") do |row_logs|
        if row_logs[1].include? row_report[3];
          CSV.foreach(("public#{@logs_entity.attachment}"), headers: true, col_sep: ",") do |row_logs_second|
            if ((row_logs_second[1].include? row_logs[1][8, 36]) && (row_logs_second[1].include? "pending"))
              token_index = row_logs_second[1].index("token")
              results[i] = {transporter_key: row_report[3], log: row_logs[1], token: row_logs_second[1][token_index+8, 11]};
              finded = true;
              i += 1;
            end
          end
        end
      end 
      if finded == false
        results[i] = {
          transporter_key: row_report[3], 
          log: "No se encontraron registros (posible doble reservación)", 
          token: "No se encontraron registros (posible doble reservación)"};
        i += 1;
      end
    end 
    csv_generation(results, report_resume);
  end

  def csv_generation(results, report_resume)
    CSV.open("#{Rails.root}/public/generations/#{report_resume}_reviewed.csv", "wb") do |csv|
        results.each do |result|
          csv << [result[:transporter_key], result[:log], result[:token]]
        end
    end
    
    resume_params = {
      name: "#{report_resume}_reviewed",
      attachment: "#{Rails.root}/public/generations/#{report_resume}_reviewed.csv"
    }

    Resume.create!(
      attachment: ActionDispatch::Http::UploadedFile.new(
        tempfile: File.open("#{Rails.root}/public/generations/#{report_resume}_reviewed.csv"), 
        filename: "#{report_resume}_reviewed.csv",
        content_type: 'text/csv'
      ),
      name: "#{report_resume}_reviewed.csv"
    )

  end
    
end
