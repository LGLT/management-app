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
      CSV.foreach(("public#{@logs_entity.attachment}"), headers: true, col_sep: ",") do |row_logs|
          if row_logs[1].include? row_report[3];
              results[i] = {transporter_key: row_report[3], log: row_logs[1]};
              i += 1;
              puts "¡Registro del transporter_key #{row_report[3]} encontrado!";
              #puts row_logs[1][45, 45], row_logs[1][162...];
          end
      end 
    end 
    csv_generation(results);
  end

  def csv_generation(results)
    results.each do |result| 
      CSV.open("#{Rails.root}/public/generations/file.csv", "wb") do |csv|
        csv << [result[:transporter_key], result[:log]]
      end
    end
  end
    
end
