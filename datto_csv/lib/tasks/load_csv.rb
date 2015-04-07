namespace :data do
  require 'csv'
  
  desc 'Import data from a csv file'
  task :import_csv, [:csv_file_path] => :environment do |t, args|
    puts File.exists? args[:csv_file_path]
  end
end
