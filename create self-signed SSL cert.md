Instructions are at https://www.devmynd.com/blog/rails-local-development-https-using-self-signed-ssl-certificate/

- Open `config/environments/<YOUR ENVIRONMENT>`, and add `config.force_ssl = true`
- Use command `openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt` to generate a self signed SSL cert
  - Only required if you need to recreate keys, which you should absolutely do for security since this is a public repo
- To start the server, run `bundle exec rails server -b "ssl://0.0.0.0?key=localhost.key&cert=localhost.crt"`
  - the key and cert are at the base of this repo. just specify the path to them if you are in a different directory than the base
