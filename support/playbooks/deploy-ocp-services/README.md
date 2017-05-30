Ansible Playbooks Service Deployment
====================================
It is assumed you have installed ansible-playbook tool for your platform before running the provided playbooks. 

Ansible playbooks provided for infrastructure automation to deploy the following services:

  - Rule service: rules extracted from BRMS container git repo deployment to xPaaS BRMS Decision Server 
  - [Car service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/CarWS): .Net deployment to container
  - [Flight service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/FlightWS): Java deployment to EAP container
  - [Hotel service](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/HotelWS): PHP deployment to PHP container
  - [Microservice](https://github.com/redhatdemocentral/destinasia-services-repo/tree/master/FuseTravelAgency): Fuse service deploymet to xPaaS Integration, dependent on other services running

Playbook Structure
------------------
The playbooks are using central variable file (vars/vars.yml) that points to the github repos holding the services code. The hosts
file is used ensure we are working only on our localhost when looking up containers for deployment on OpenShift Container Platform.
The main file is the site.yml, which contains all of the roles to be exectued, meaning that each service will be run from their
corresponding playbook file (main.yml) found in their directories.

Execute each playbook to watch the service build and deploy in the OpenShift monitoring console:

  ```
   # Run Rule service (xPaaS Decision Service) deployment playbook.
   #
   $ ./ansible-playbook-ruleservice.sh

   # Run Car service (.Net) deployment playbook.
   #
   $ ./ansible-playbook-dotnetservice.sh

   # Run Flight service (Java) deployment playbook.
   #
   $ ./ansible-playbook-javaservice.sh

   # Run Hotel service (PHP) deployment playbook.
   #
   $ ./ansible-playbook-phpservice.sh

   # Run Fuse service (xPaaS Integration Service) deployment playbook, deploy after all other 
   # services available as this is connecting to all the other endpoints.
   #
   $ ./ansible-playbook-fuseservice.sh
   ```

Once all the services are deployed, you can send a REST request to the xPaaS Integration Service (Fuse) endpoint to trigger a
response over the gathered car, hotel, flight and discount (rules) pricing:

   ```
   # To test the services you can push the following payload (request) to the
   # Fuse endpoint.
   #
   # Use a RESTClient plugin for Firefox, you can cut-and-paste this request into the client,
   # see example screenshot below. Change carRentalCo to "Avis" to see response change the 
   # discount from 15 to 0 due to the business rules in the rule service.
   #
   # Method: POST
   # Header: Content-Type application/json
   # URL: http://fusetravelagency-appdev-in-cloud.192.168.99.100.xip.io/rest/book
   # Body:
   {"flightReq":{"flightFrom":"SIN","flightTo":"PEK","flightDate":"03/08/2017","flightPassengers":2,"flightNo":"SIN22"},"hotelReq":{"hotelArrivalDate":"03/08/2017","hotelNights":33,"hotelCity":"PEK","hotelId":"Marriott"},"carReq":{"carCity":"PEK","carRentalCo":"Hertz","carType":"Econ","carStartDate":"03/08/2017","carDays":33}}
   ```

 ![Fuse post](https://github.com/redhatdemocentral/apac-destinasia-rules-demo/blob/master/docs/demo-images/destinasia-fuse-post.png)
