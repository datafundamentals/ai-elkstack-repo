# Automate_Insights_Elkstack 
This is the project repo for testing the knife-topo plugin by automate insights. The project is two fold. 
1. Spin up an elkstack standalone node 
2. Spin up a distributed elkstack cluster
3. Do both using the knife-topo plugin

## REQUIREMENTS


* ChefDK 0.6.0 or later
* Vagrant 1.6.5 or later on the system (avoid 1.7.2, has problematic issues)
* Basics understanding of Chef
* Grasp of knife-topo and having it installed (chef gem install knife-topo)
* Automate.insights account through amazon or email address. 

## NOTE 
This is designed to work with a chef-zero server locally. If you are set on working with a hosted chef-server. replace the knife.rb and .pem file in the projects .chef directory with your own credentials. 

in order to spin things up, you will need to run first spin up the chef-server

```
chef-zero -d -H10.0.1.1
```
Next, you will want to make sure that chef-zero has all the cookbooks up and running on the chef-zero server.

Use Berkshelf to pull in the cookbook dependencies, then upload to the newly created chef-zero server  

```
berks vendor 
knife cookbook upload --all --cookbook-path berks-cookbooks
```
you can verify very quickly with a "knife cookbook list" to see that your cookbooks have been properly uploaded. 

once you have done this, it is wise to spin up your vagrant machines. getting back to the projects root directory, simply run 

```
vagrant up
```
and you should have two brand new instances labeled
* ai-elkstack-1
* ai-elkstack-2
* ai-elkstack-3 

feel free to change the name, I am not sold on it. 

next, you will want to bootstrap your nodes with the appropriate cookbooks to ensure that you are running things properly. 

## For standalone ##
```
knife bootstrap 10.0.1.2 -x vagrant -P vagrant --sudo -N df_box_elkstack --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"
```

there has some been intermittent timeout issues on installation of java and logstash respectively, due to poor internet connection locally. if a converge fails during an initial bootstrap, the run_list will not be saved. Run the command to restore it.  
```
knife node run_list add df_box_elkstack "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"
```
then you will have to vagrant ssh into ai-elkstack-1 and run sudo chef-client to start the chef run again.

## For Clustered VM ##

```
knife bootstrap 10.0.1.3 -x vagrant -P vagrant --sudo -N df_box_elasticsearch --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_elasticsearch],recipe[df_logstash::logstash_ssl],recipe[df_kibana],recipe[df_kibana::kibana_nginx]"

knife bootstrap 10.0.1.2 -x vagrant -P vagrant --sudo -N df_box_logstash --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"

knife bootstrap 10.0.1.4 -x vagrant -P vagrant --sudo -N df_box_application --bootstrap-version 12.0.3 -r "recipe[df_logstash::logstash_ssl],recipe[df_logstash::logstash_forwarder]"
```
respective commands for node add after failed run_list 
```
knife node run_list add df_box_elasticsearch "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx]"

knife node run_list add df_box_logstash "recipe[df_java],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"
```

## Knife Topo steps
This is where we shall begin. Once you have set up and configured your machines as you want them using the run_list scripts, you will want to convert the topology data for your chef-server

###For Standalone
```
knife topo export df_box_elkstack --topo elkstack > elkstack.json
```
# For Cluster
```
knife topo export df_box_elasticsearch df_box_logstash df_box_application --topo elkstackcluster > elkstack2.json
```

After this, you will want to import the topologies into the system. 
```
# standalone
knife topo import elkstack.json
#cluster
knife topo import elkstackcluster.json
```

Finally, with the properly created topology cookbooks, you will want to create the servers. This is made easier. 

```
#standalone
knife topo create elkstack --bootstrap --sudo -xvagrant -Pvagrant
#cluster
knife topo create elkstackcluster --bootstrap --sudo -xvagrant -Pvagrant
```
this should bootstrap your system with the appropriate pieces needed. 


