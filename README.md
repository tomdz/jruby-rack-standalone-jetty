# jruby-rack-standalone-jetty

Provides a way to run [jruby-rack](https://github.com/jruby/jruby-rack) with an embedded jetty,
no WAR files or separate servlet container needed. You simply write a launcher script that contains
code like this:

```ruby
require 'jetty-runner'

jetty_options = {
  :host => 'localhost',
  :port => 4567,
  # jruby-rack context parameters:
  'jruby.rack.layout_class' => 'RailsFilesystemLayout',
  'gem.path' => '.',
  'rackup' => IO.read('config.ru')
}

server = JettyRunner.new(jetty_options)
server.run
server.join 
```

The options hash supports all jruby-rack context parameters.

Supported Jetty options:

* `:host` The IP to bind to. `localhost` by default.
* `:port` The port to use. If not specified then Jetty will use a random one.
* `:use_nio` Whether to use NIO instead of blocking IO for HTTP (does not affect HTTPS). `true` by default
* `:min_threads` The minimum number of threads. 10 by default.
* `:max_threads` The maximum number of threads. 200 by default.
* `:low_threads` The number of threads that are considered to be low. 50 by default.
* `:accept_queue_size` The number of requests to be allowed in the accept queue. Uses the value of `:max_threads` by
  default.
* `:ssl_port` The HTTPS port. If not specified (along with `:keystore` and `:key_password`) then HTTPS will not be
  enabled.
* `:keystore` The keystore. If not specified (along with `:ssl_port` and `:key_password`) then HTTPS will not be
  enabled.
* `:key_password` The password for the key in the keystore. If not specified (along with `:ssl_port` and `:keystore`)
  then HTTPS will not be enabled.
* `:keystore_type` The type of the keystore. `JKS` by default.
* `:with_stats` Whether to enable Jetty statistics and expose them via JMX. `true` by default.
* `:request_log` The request log object to use (must implement `org.mortbay.jetty.RequestLog`). If neither this nor 
  `:request_log_path` are specified, then request logging will not be enabled.
* `:request_log_path` The path where the `NCSARequestLog` should log to. If neither this nor `:request_log` are
  specified, then request logging will not be enabled.

# Dependencies

This library requires that jetty 6.1.x and jruby-rack are in the classpath (it does not bundle them).