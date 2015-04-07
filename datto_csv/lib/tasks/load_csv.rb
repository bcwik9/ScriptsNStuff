namespace :data do
  require 'csv'

  # test if a string is an integer
  def is_integer? i
    i.to_i.to_s == i
  end
  
  desc 'Import data from a csv file'
  task :import_csv, [:csv_file_path] => :environment do |t, args|
    # make sure CSV file exists
    if File.exists? args[:csv_file_path]
      csv_file = args[:csv_file_path]
    else
      # check csv folder to see if it exists
      csv_file = Rails.root.join('app','assets','csv',File.basename(args[:csv_file_path]))
      raise 'Please specify valid CSV file location' unless File.exists? csv_file
    end

    # Process CSV
    CSV.foreach(csv_file, headers: [:id, :first_name, :last_name, :age, :github_account, :date_of_third_grade_graduation]) do |row|
      person_params = row.to_h
      next unless is_integer? person_params[:id] # skip header
      date = person_params[:date_of_third_grade_graduation]
      person_params[:date_of_third_grade_graduation] = Date.new(date, '%m/%d/%y')
      puts "Creating person: #{person_params}"
      Person.create! person_params # create and save person
    end
  end

  desc 'Return list of ids for players with a certain last name'
  task :last_name_search, [:last_name] => :environment do |t, args|
    raise 'Must specify last name' if args[:last_name].nil?
    Person.where(last_name: args[:last_name]).each { |p| puts p[:id] }
  end

  desc 'Return list of all people, sorted by age'
  task :sort_by_age => :environment do
    # get sorted, non empty ages
    aged_people = Person.where("age <> ''").order(:age)
    # get people with empty ages
    ageless_people = Person.where(age: nil)
    # print out records
    (aged_people + ageless_people).each do |p|
      puts p.to_s
    end
  end
end
