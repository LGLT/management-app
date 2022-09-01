class AddFileTypeToResumes < ActiveRecord::Migration[6.1]
  def change
    add_column :resumes, :resume_type, :string
  end
end
