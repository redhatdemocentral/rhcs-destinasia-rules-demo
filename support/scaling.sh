#!/bin/sh 

# Used to scale pods up and down automatically.
#
for pods in {2..10}
do
	echo; echo "Scaling up to $pods pods..."; echo;
	oc scale dc/destinasia-rules-demo --replicas=$pods
	sleep 5
done

for pods in {9..1}
do
	echo; echo "Scaling down to $pods pods..."; echo;
	oc scale dc/destinasia-rules-demo --replicas=$pods
	sleep 5
done

