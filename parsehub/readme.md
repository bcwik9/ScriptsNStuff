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
parsehub_form_data = { :start_value_override => "{\"my_key_goes_here\": \"my_value_goes_here\"}" }
new_run = ParsehubRun.create_parsehub_run parsehub_project_token, parsehub_form_data
```
and now your project can reference `my_key_goes_here` for links and other places where variables are accepted in your Parsehub project.

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
First, check that your run is done running:
```ruby
run = ParsehubRun.find <model id>
results = run.get_results if run.complete?
```

`results` will be a key/value hash. If the run isn't complete, it will return `nil`.
