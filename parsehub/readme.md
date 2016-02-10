## Create a new Parsehub run

### Create a new Parsehub project, or use an existing one
The first step if to figure out what project you want to use. If necessary, create a new Parsehub project using their tool. Log in to Parsehub, go to the project you want to use, and note the Project Token.

### Create a new ParsehubRun
Simply call:
```ruby
new_run = ParsehubRun.create_parsehub_run "<Parsehub Project Token>"
```

If you need to specify other data, such as variables used in your Parsehub project, simply call:
```ruby
form_data = { :start_value_override => "{\"my_key_goes_here\": \"my_value_goes_here\"}" }
```
and now your project can reference `my_key_goes_here` for links and other places where variables are accepted.
