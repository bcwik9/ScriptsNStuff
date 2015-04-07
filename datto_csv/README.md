## Setup
* clone the git url
* bundle install
* rake db:migrate
* put your CSV file under app/assets/csv/
* run rake data:import_csv['<path to csv file>']
* data has been imported!
* sort by age by running: rake data:sort_by_age
* list last names by running: rake data:last_name_search[<last name>]