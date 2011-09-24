# jruby-rack-standalone-jetty

Provides a way to run [jruby-rack](https://github.com/jruby/jruby-rack) with an embedded jetty,
no WAR files or separate servlet container needed. You simply write a launcher script that contains
code like this:

  	require 'jetty-runner'

		jetty_options = {
		  'host' => 'localhost',
		  'port' => 4567,
		  'jruby.rack.layout_class' => 'RailsFilesystemLayout',
		  'gem.path' => '.',
		  'rackup' => IO.read('config.ru')
		}

		server = JettyRunner.new(jetty_options)
		server.run
		server.join 

The options hash supports all jruby-rack context parameters.

This library requires that jetty 6.1.x and jruby-rack are in the classpath (it does not bundle them).