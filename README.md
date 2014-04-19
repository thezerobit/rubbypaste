# RUBBYPASTE

A single file pastebin implementation for using Sinatra,
DataMapper, and Rouge.

## Install

Ubuntu:

```
sudo apt-get install postgresql postgresql-server-dev-9.1 python-dev

sudo -u postgres createuser -D -A -P rubbypasteuser # rubbypastepass
sudo -u postgres createdb -O rubbypasteuser rubbypaste
```

## Deployment

```
bundle install
rackup
```

## Author

* Stephen A. Goss (steveth45@gmail.com)

## Copyright

Copyright (c) 2014 Stephen A. Goss (steveth45@gmail.com)

# License

Licensed under the Modified BSD License.

