require 'java'

java_import 'java.lang.management.ManagementFactory'
java_import 'org.jruby.rack.RackFilter'
java_import 'org.jruby.rack.RackServletContextListener'
java_import 'org.mortbay.jetty.Handler'
java_import 'org.mortbay.jetty.NCSARequestLog'
java_import 'org.mortbay.jetty.Server'
java_import 'org.mortbay.jetty.bio.SocketConnector'
java_import 'org.mortbay.jetty.handler.DefaultHandler'
java_import 'org.mortbay.jetty.handler.HandlerCollection'
java_import 'org.mortbay.jetty.handler.ContextHandlerCollection'
java_import 'org.mortbay.jetty.handler.RequestLogHandler'
java_import 'org.mortbay.jetty.handler.StatisticsHandler'
java_import 'org.mortbay.jetty.nio.SelectChannelConnector'
java_import 'org.mortbay.jetty.servlet.Context'
java_import 'org.mortbay.jetty.servlet.DefaultServlet'
java_import 'org.mortbay.jetty.servlet.FilterHolder'
java_import 'org.mortbay.jetty.servlet.ServletHolder'
java_import 'org.mortbay.jetty.security.SslSocketConnector'
java_import 'org.mortbay.management.MBeanContainer'
java_import 'org.mortbay.thread.QueuedThreadPool'

module Rack
  class JettyRunner
    attr_reader :options
  
    def initialize(opts = {})
      @options = opts
    end
  
    def run()
      thread_pool = QueuedThreadPool.new
      thread_pool.setMinThreads((options[:min_threads] || 10).to_i)
      thread_pool.setMaxThreads((options[:max_threads] || 200).to_i)
      thread_pool.setLowThreads((options[:low_threads] || 50).to_i)
      thread_pool.setSpawnOrShrinkAt(2)

      @jetty = Java::org.mortbay.jetty.Server.new
      @jetty.setThreadPool(thread_pool)
      @jetty.setGracefulShutdown(1000)

      stats_on = options[:with_stats] || true

      if options[:use_nio] || true
        http_connector = SelectChannelConnector.new
        http_connector.setLowResourcesConnections(20000)
      else
        http_connector = SocketConnector.new
      end
      http_connector.setHost(options[:host] || 'localhost')
      http_connector.setPort(options[:port].to_i)
      http_connector.setMaxIdleTime(30000)
      http_connector.setAcceptors(2)
      http_connector.setStatsOn(stats_on)
      http_connector.setLowResourceMaxIdleTime(5000)
      http_connector.setAcceptQueueSize((options[:accept_queue_size] || thread_pool.getMaxThreads).to_i)
      http_connector.setName("HttpListener")
      @jetty.addConnector(http_connector)

      if options[:ssl_port] && options[:keystore] && options[:key_password]
        https_connector = SslSocketConnector.new

        https_connector.setKeystore(options[:keystore])
        https_connector.setKeystoreType(options[:keystore_type] || 'JKS')
        https_connector.setKeyPassword(options[:key_password])
        https_connector.setHost(http_connector.getHost)
        https_connector.setPort(options[:ssl_port].to_i)
        https_connector.setMaxIdleTime(30000)
        https_connector.setAcceptors(2)
        https_connector.setStatsOn(stats_on)
        https_connector.setLowResourceMaxIdleTime(5000)
        https_connector.setAcceptQueueSize(http_connector.getAcceptQueueSize)
        https_connector.setName("HttpsListener")
        @jetty.addConnector(http_connector)
      end

      contextHandlers = ContextHandlerCollection.new

      root = Context.new(contextHandlers, "/", Context::NO_SESSIONS)
      root.set_init_params(options)
      root.add_filter(FilterHolder.new(RackFilter.new), "/*", Handler::DEFAULT)
      root.add_event_listener(RackServletContextListener.new)
      root.add_servlet(ServletHolder.new(DefaultServlet.new), "/")

      handlers = HandlerCollection.new
      handlers.addHandler(contextHandlers)
      handlers.addHandler(DefaultHandler.new)

      if options[:request_log] || options[:request_log_path]
        request_log_handler = RequestLogHandler.new

        request_log_handler.setRequestLog(options[:request_log] || NCSARequestLog.new(options[:request_log_path]))
        handlers.addHandler(request_log_handler)
      end
      if stats_on
        mbean_container = MBeanContainer.new(ManagementFactory.getPlatformMBeanServer)

        @jetty.getContainer.addEventListener(mbean_container)
        mbean_container.start

        stats_handler = StatisticsHandler.new
        stats_handler.addHandler(handlers)
        @jetty.addHandler(stats_handler)
      else
        @jetty.addHandler(handlers)
      end
      @jetty.start
    end

    def join
      @jetty.join
    end

    def running?
      @jetty && @jetty.isStarted
    end
  
    def stopped?
      !@jetty || @jetty.isStopped
    end
  
    def stop()
      @jetty && @jetty.stop
    end

    def destroy()
      @jetty && @jetty.destroy
    end
  end
end