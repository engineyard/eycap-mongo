# don't use the standard Ubuntu package of Mongo
# because it will tend to be out of date. Don't install
# from source because it makes updating a pain. Use the
# 10gen debs as they're generally up to date.

file "/etc/apt/sources.list.d/10gen.list" do
  owner 'root'
  group 'root'
  mode '0644'
  content "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
end

bash "Adding 10gen mongo source"  do
  user 'root'
  code <<-EOC
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    apt-get update
  EOC
end

bash "installing and pinning mongodb 2.6.4" do
  user 'root'
  code <<-EOC
    apt-get install -y mongodb-org=2.6.4 mongodb-org-server=2.6.4 mongodb-org-shell=2.6.4 mongodb-org-mongos=2.6.4 mongodb-org-tools=2.6.4.
    echo "mongodb-org hold" | dpkg --set-selections
    echo "mongodb-org-server hold" | dpkg --set-selections
    echo "mongodb-org-shell hold" | dpkg --set-selections
    echo "mongodb-org-mongos hold" | dpkg --set-selections
    echo "mongodb-org-tools hold" | dpkg --set-selections
  EOC
end

template '/etc/init/mongodb.conf' do
  owner 'root'
  group 'root'
  mode '0700'
  source 'mongodb_upstart.conf.erb'
  notifies :run, "execute[restart-mongo]", :immediately
end

template '/etc/mongodb.conf' do
  owner 'mongodb'
  group 'mongodb'
  mode '0700'
  source 'mongodb.conf.erb'
  notifies :run, "execute[restart-mongo]", :immediately
end

execute "restart-mongo" do
  command  'service mongodb restart'
  action :nothing
end

