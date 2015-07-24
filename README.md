# Automate_Insights_Elkstack 
This is the project repo for deploying a standalone elkstack using a chef-zero server locally, and a cookbook for spinning up a server. 

## REQUIREMENTS


* ChefDK 0.6.0 or later
* Vagrant 1.6.5 or later on the system (avoid 1.7.2, has problematic issues)
* Basics understanding of Chef
* Grasp of knife-topo
* Automate.insights account through amazon or email address. 

## NOTE 
This is designed to work with a chef-zero server locally. If you are set on working with a hosted chef-server. replace the knife.rb and .pem file in the projects .chef directory with your own credentials. 

in order to spin things up, you will need to run first spin up the chef-server

```
chef-zero -d -H10.0.1.1
```
Next, you will want to make sure that chef-zero has all the cookbooks up and running on the chef-zero server. 

```
cd cookbooks
knife cookbook upload * 
```
you can verify very quickly with a "knife cookbook list" to see that your cookbooks have been properly uploaded. 

once you have done this, it is wise to spin up your vagrant machines. getting back to the projects root directory, simply run 

```
vagrant up
```
and you should have two brand new instances labeled
* ai-elkstack-1
* ai-elkstack-2 

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
knife bootstrap 10.0.1.3 -x vagrant -P vagrant --sudo -N df_box_elasticsearch --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx]"

knife bootstrap 10.0.1.2 -x vagrant -P vagrant --sudo -N df_box_logstash --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"

```
respective commands for node add after failed run_list 
```
knife node run_list add df_box_elasticsearch "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx]"

knife node run_list add df_box_logstash "recipe[df_java],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"
```

### For Future releases
In this repo, we have included a basic shell script for creating a logstash-forwarder data bag with proper keys. The cookbooks currently do not use data_bags, so it is somewhat frivolous until further notice.

To generate, run: 
```
./make-lumberjack-key.sh
```

## Knife Topo steps
This is where we shall begin. Once you have set up and configured your machines as you want them using the run_list scripts, you will want to convert the topology data for your chef-server

###For Standalone
```
knife topo export elkstack df_box_elkstack > elkstack.json
```
# For Cluster
```
knife topo export elkstack df_box_elasticsearch df_box_logstash > elkstack.json
```

After this, you will want to import the topologies into the system. 
```
knife topo import elkstack.json
```

Finally, with the properly created topology cookbooks, you will want to create the servers. This is made easier. 

```
knife topo create elkstack --bootstrap --sudo -xvagrant -Pvagrant
```
this should bootstrap your system with the appropriate pieces needed. 


