# Since we're running on a single node we can just use 127.0.0.1 for the server IP. Search isn't necessary
node.default[:go][:server][:host] = '127.0.01'
include_recipe "go::server"
include_recipe "go::agent"

Chef::Log.info("Node has #{node[:cpu][:total]} CPUs")