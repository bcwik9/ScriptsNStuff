### Create a new Parsehub project, or use an existing one
The first step if to figure out what project you want to use. If necessary, create a new Parsehub project using their tool. Log in to Parsehub, go to the project you want to use, and note the Project Token.

### Create a new ParsehubRun
Simply call:
```ruby
PARSEHUB_KEY = "MY_PARSEHUB_KEY"
parsehub_project_token = "PROJECT_TOKEN_HERE"
new_run = ParsehubRun.create_parsehub_run parsehub_project_token
```

If you need to specify other data, such as variables used in your Parsehub project, simply call:
```ruby
PARSEHUB_KEY = "MY_PARSEHUB_KEY"
parsehub_project_token = "PROJECT_TOKEN_HERE"
# below, note how we're escaping the key/value hash
parsehub_form_data = { my_key: :my_value, another_key: true }
new_run = ParsehubRun.create_parsehub_run parsehub_project_token, parsehub_form_data
```
and now your project can reference `my_key` for links, conditional statements, expressions, and other places where variables are accepted in your Parsehub project.

### Check the status of a ParsehubRun
Let's say you created a new ParsehubRun (using the method described above):
```ruby
PARSEHUB_KEY = "MY_PARSEHUB_KEY"
parsehub_project_token = "PROJECT_TOKEN_HERE"
new_run = ParsehubRun.create_parsehub_run parsehub_project_token
```

Now, check update the state of the run from Parsehub:
```ruby
response = new_run.get_status
```
`response` in this case contains the latest info about the run. You don't have to do anything with it; `new_run.get_status` updates the model in our database. It looks like this:
```ruby
{"status"=>"running",
 "start_time"=>"2016-02-10T19:09:17",
 "project_token"=>"tl8B2-wUSZ3sMk3nl8jGOsyf",
 "start_template"=>"main_template",
 "pages"=>"1",
 "run_token"=>"t6FjqubDoApx8NyRMvSuO2TN",
 "custom_proxies"=>"[]",
 "data_ready"=>0,
 "md5sum"=>nil,
 "end_time"=>nil,
 "start_url"=>"http://www.ticketmaster.com/",
 "start_value"=>"{}"}
 ```

Now check if the run has completed:
```ruby
new_run.complete?
```

### Get results from a ParsehubRun
```ruby
run = ParsehubRun.find <model id>
if run.complete?
  # run is already complete and we have the results in our database
  json_results = run.results
  results = JSON.parse json_results
else
  # run hasn't completed yet. update the status, check if it's complete, and then get results
  run.get_status # update status
  results = run.get_results if run.complete? # update results if run is complete
end
```

`results` will be a key/value hash. If the run isn't complete, it will return `nil`.

### Update status of all incomplete ParsehubRun, and get results if they're complete
```ruby
ParsehubRun.where(complete: false).each do |run|
  run.get_status
  run.get_results if run.complete?
end
```
