rails_root = '/home/ancja-urls/ancja-urls'
rails_env  = 'production'
pid_file   = "#{rails_root}/pids/unicorn.pid"
socket_file= "#{rails_root}/var/unicorn.sock"
log_file   = "#{rails_root}/log/unicorn.log"
username   = 'ancja-urls'
group	   = 'ancja-urls'
old_pid    = pid_file + '.oldbin'
 
 
timeout 30
 
worker_processes 8
 
# Listen on a Unix data socket
listen socket_file, :backlog => 1024
pid pid_file
 
stdout_path log_file
 
preload_app true
##
# REE
 
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
 
before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
 
 
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
 
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
 
after_fork do |server, worker|
    defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
 
 
  worker.user(username, group) if Process.euid == 0 && rails_env == 'production'
end