Ansible Playbooks Service Deployment
====================================

Here you find all the Ansible playbooks for infrastructure automation to deploy the following services:

  - Car service: .Net deployment to container
  - Flight service: Java deployment to EAP container
  - Hotel service: PHP deployment to PHP container
  - Rule service: rules extracted from BRMS container git repo deployment to xPaaS BRMS Decision Server 
  - Microservice: Fuse service deploymet to xPaaS Integration, dependent on other services running

Playbook Structure
------------------
The playbooks are using central variable file (vars/vars.yml) that points to the github repos holding the services code. The hosts
file is used ensure we are working only on our localhost when looking up containers for deployment on OpenShift Container Platform.
The main file is the site.yml, which contains all of the roles to be exectued, meaning that each service will be run from their
corresponding playbook file (main.yml) found in their directories.

If you run the playbook site.yml file, it will deploy all the services one after the other.

It is also possible to deploy each service individually by using 'tags' assigned as follows:

   ```
   # Run Car service (.Net) deployment playbook.
   #
   $ ansible-playbook -v -i hosts site.yml --tags "dotnetservice"

   # Run Flight service (Java) deployment playbook.
   #
   $ ansible-playbook -v -i hosts site.yml --tags "javaservice"

   # Run Hotel service (PHP) deployment playbook.
   #
   $ ansible-playbook -v -i hosts site.yml --tags "phpservice"

   # Run Rule service (xPaaS Decision Service) deployment playbook.
   #
   $ ansible-playbook -v -i hosts site.yml --tags "ruleservice"

   # Run Fuse service (xPaaS Integration Service) deployment playbook, deploy after all other services available
   # as this is connecting to all the other endpoints.
   #
   $ ansible-playbook -v -i hosts site.yml --tags "fuseservice"
   ```

Once all the services are deployed, you can send a REST request to the xPaaS Integration Service (Fuse) endpoint to trigger a
response over the gathered car, hotel, flight and discount (rules) pricing:

   ```
   # TODO: add REST URL and example payload.
   ```

TODO: fix tools (awk, sed, args) to use env vars and fuse service to work.
