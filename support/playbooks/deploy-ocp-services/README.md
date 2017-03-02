Ansible Playbooks Service Deployment
====================================
It is assumed you have installed ansible-playbook tool for your platform before running the provided playbooks. 

Ansible playbooks provided for infrastructure automation to deploy the following services:

  - [Car service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/CarWS): .Net deployment to container
  - [Flight service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/FlightWS): Java deployment to EAP container
  - [Hotel service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/HotelWS): PHP deployment to PHP container
  - Rule service: rules extracted from BRMS container git repo deployment to xPaaS BRMS Decision Server 
  - [Microservice](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/FuseTravelAgency): Fuse service deploymet to xPaaS Integration, dependent on other services running

Playbook Structure
------------------
The playbooks are using central variable file (vars/vars.yml) that points to the github repos holding the services code. The hosts
file is used ensure we are working only on our localhost when looking up containers for deployment on OpenShift Container Platform.
The main file is the site.yml, which contains all of the roles to be exectued, meaning that each service will be run from their
corresponding playbook file (main.yml) found in their directories.

Execute each playbook to watch the service build and deploy in the OpenShift monitoring console:

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

