# Automate_Insights_Elkstack 
This is the project repo for deploying a standalone elkstack using a chef-zero server locally, and a cookbook for spinning up a server. 

## REQUIREMENTS
* 
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

## For Clustered VM ##

```
knife bootstrap 10.0.1.2 -x vagrant -P vagrant --sudo -N df_box_elkstack --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_elasticsearch],recipe[df_kibana],recipe[df_kibana::kibana_nginx]"

knife bootstrap 10.0.1.3 -x vagrant -P vagrant --sudo -N df_box_logstash --bootstrap-version 12.0.3 -r "recipe[df_java],recipe[df_nginx],recipe[df_logstash],recipe[df_logstash::logstash_forwarder]"

```
* (please note in this you will have to push some attributes to the logstash cookbook. Might need to look into a data bag) 

