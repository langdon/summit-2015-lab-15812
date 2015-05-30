## LAB 4: Orchestrated deployment of a decomposed application (Langdon)

In this lab we introduce how to orchestrate a multi-container application in Kubernetes.

Expected completion: 40-60 minutes

Question: single host or multi host?

### Fragility

Let's start with a little experimentation. I am sure you are all excited about your new blog site! And, now that it is getting super popular with 1000s of views per day, you are starting to worry about uptime.

So, let's see what will happen. Launch the site:

```
docker run -d -p 3306:3306 -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb --name mariadb mariadb-pod
docker run -d -p 80:80 --link mariadb:db wordpress
```
**Note** if you get an error about the names in use, just delete those containers with ```docker rm <name>```

Take a look at the site in your web browswer on your machine using **http://ip:port**

Now, let's see what happens when we kick over the database. However, for a later experiment, let's grab the container-id right before you do it. 

```
OLD_CONTAINER_ID=$(docker inspect --format '{{ .Id }}' mariadb)
docker stop mariadb
```

Take a look at the site in your web browswer now. And, imagine, explosions! *making sound effects will be much appreciated by your lab mates.*
```
web browswer -> **http://ip:port**
```

Now, what is neat about a container system, assuming your web application can handle it, is we can bring it right back up, with no loss of data.
```
docker start mariadb
```

OK, now, let's compare the old container id and the new one. 
```
NEW_CONTAINER_ID=$(docker inspect --format '{{ .Id }}' mariadb)
echo -e "$OLD_CONTAINER_ID\n$NEW_CONTAINER_ID"
```

Hmmm. Well, that is cool, they are exactly the same. OK, so all in all, about what you would expect for a web server and a database running on VMs, but a whole lot faster. However, what if we could automate the recovery? Or, in buzzword terms, "ensure the service remains up"? Enter Kubernetes. And, so you are up on the lingo, sometimes "kube" or "k8s".

### Pod Creation

Let's get started by talking about a pod. A pod is a set of containers that provide one "service." The sense here is that the pods need to be co-located on a host and need to spawned and re-spawned together.

Let's make a pod for mariadb. Open a file called mariadb-pod.json.
```
mkdir -p ~/workspace/mariadb/kubernetes
vi ~/workspace/mariadb/kubernetes/mariadb-pod.json
```
In that file, let's put in the pod indentification information:
```
{
    "apiVersion": "v1beta1",
    "id": "mariadb",
    "desiredState": {
        "manifest": {
            "version": "v1beta1",
            "id": "mariadb",
            "containers": []
        }
    },
    "labels": {
        "name": "mariadb"
    },
    "kind": "Pod"
}
```

We specified the version of the Kubernetes api, the name of this pod (aka ```id```), the ```kind``` of Kubernetes thing this is, and a ```label``` which lets other Kubernetes things find this one.

Generally speaking, this is the content you can copy and paste between pods, aside from the "id"s and "labels".

Now, let's add the custom information regarding this particular container. To start, we will add the most basic information. However, before we do that, we need to get the registry information which you pushed your container image to. If you remember it from the prior labs, this is the same, but, in case you don't, run ```docker images``` and grab the "REPOSITORY" field for the registry tagged mariadb. It should look something like ```192.168.121.197:5000/mariadb```

Now, replace the ```"containers": []```

```
            "containers": [
                {
                    "name": "mariadb",
                    "image": "MY_REPOSITORY_WITH_IMAGE_NAME",
                    "env": [],
                    "cpu": 100,
                    "ports": [
                        {
                            "containerPort": 3306
                        }
                    ]
                }
            ]
```
Here we set the ```name``` of the container; remember we can have more than one in a pod. We also set the ```image``` to pull, in other words, the container image that should be used and the registry to get it from. We can also set limitations here like cpu cap and exposed ports.

Lastly, we need to configure the environment variables that need to be fed from the host environment to the container. Replace ```"env": [],``` with:

                    "env": [
                        {
                            "name": "DBUSER",
                            "value": "user"
                        },
                        {
                            "name": "DBPASS",
                            "value": "mypassword"
                        },
                        {
                            "name": "DBNAME",
                            "value": "mydb"
                        }
                    ],

OK, now we are all done, and should have a file that looks like:
```
{
    "apiVersion": "v1beta1",
    "id": "mariadb",
    "desiredState": {
        "manifest": {
            "version": "v1beta1",
            "id": "mariadb",
            "containers": [
                {
                    "name": "mariadb",
                    "image": "MY_REPOSITORY_WITH_IMAGE_NAME",
                    "env": [
                        {
                            "name": "DBUSER",
                            "value": "user"
                        },
                        {
                            "name": "DBPASS",
                            "value": "mypassword"
                        },
                        {
                            "name": "DBNAME",
                            "value": "mydb"
                        }
                    ],
                    "cpu": 100,
                    "ports": [
                    {
                        "containerPort": 3306
                    }
                    ]
                }
            ]
        }
    },
    "labels": {
        "name": "mariadb"
    },
    "kind": "Pod"
}
```
**Note** you must replace ```MY_REPOSITORY_WITH_IMAGE_NAME``` with the unique IP, port and name of your image in your repository.

Our wordpress container is much less complex, so let's do that pod next.
```
mkdir -p ~/workspace/wordpress/kubernetes
vi ~/workspace/wordpress/kubernetes/wordpress-pod.json
```

```
{
  "apiVersion": "v1beta1",
  "id": "wordpress",
  "desiredState": {
    "manifest": {
      "version": "v1beta1",
      "id": "wordpress",
      "containers": [
        {
          "name": "wordpress",
          "image": "MY_REPOSITORY_WITH_IMAGE_NAME",
          "ports": [
            {
              "containerPort": 80
            }
          ],
          "env": [
            {
              "name": "DB_ENV_DBUSER",
              "value": "user"
            },
            {
              "name": "DB_ENV_DBPASS",
              "value": "mypassword"
            },
            {
              "name": "DB_ENV_DBNAME",
              "value": "mydb"
            }
          ]
        }
      ]
    }
  },
  "labels": {
    "name": "wpfrontend"
  },
  "kind": "Pod"
}
```

A couple things to notice about this file. Obviously, we change all the appropriate names to reflect "wordpress" but, largely, it is the same as the mariadb pod file. We also use the environment variables that are specified by the wordpress container, although they need to get the same values as the ones in the mariadb pod. Lastly, just to show you aren't bound to the image or pod names, we also changed the ```labels``` value to "wpfronted".

Ok, so, lets launch our pods and make sure they come up correctly. In order to do this, we need to introduce the ```kubectl``` command which is what drives Kubernetes. Generally, speaking, the formate of ```kubectl``` commands is ```kubetctl <operation> <kind>```. Where ```<operation>``` is something like ```create```, ```get```, ```remove```, etc. and ```kind``` is the ```kind``` from the pod files.

```
kubectl create -f ~/workspace/mariadb/kubernetes/mariadb-pod.json
kubectl create -f ~/workspace/wordpress/kubernetes/wordpress-pod.json
```
Now, I know i just said, ```kind``` is a parameter, but, as this is a create statement, it looks in the ```-f``` file for the ```kind```.

Ok, let's see if they came up:
```
kubectl get pods
```

Which should output two pods, one called ```mariadb``` and one called ```wordpress```.

Ok, now let's kill them off so we can introduce the services that will let them more dynamically find each other.
```
kubectl delete pod mariadb
kubectl delete pod wordpress
```
**Note** you used the "singular" form here on the ```kind```, which, for delete, is required and requires a "name". However, you can, usually, use them interchangably depending on the kind of information you want.

### Service Creation
Now we want to create Kubernetes Services for our pods so that Kubernetes can introduce a layer of indirection between the pods. 

Let's start with mariadb. Open up a service file:
```
vi ~/workspace/mariadb/kubernetes/mariadb-service.json
```

and insert the following content:

```
{
  "kind": "Service",
  "apiVersion": "v1beta1",
  "id": "mariadb",
  "port": 3306,
  "selector": {
    "name": "mariadb"
  },
  "containerPort": 3306,
  "labels": {
    "name": "mariadb"
  }
}
```
As you can probably tell, there isn't really anything new here. However, you need to make sure the ```kind``` is of type ```Service``` and that the ```selector``` matches at least one of the ```labels``` from the pod file. The ```selector``` is how the service finds the pod that provides its functionality.

OK, now let's move on to the wordpress service. Open up a new service file:
```
vi ~/workspace/wordpress/kubernetes/wordpress-service.json
```

and insert:
```
{
  "kind": "Service",
  "apiVersion": "v1beta1",
  "id": "wpfrontend",
  "port": 80,
  "selector": {
    "name": "wpfrontend"
  },
  "containerPort": 80,
  "labels": {
    "name": "wpfrontend"
  },
  "createExternalLoadBalancer": true
}
```
So, here you may notice, there is no reference to wordpress at all. In fact, we might even want to name the file wpfrontend-service.json to make it clearer that, in fact, we could have any pod that provides "wordpress capabilities". However, for a lab like this, I thought it would be confusing. 

An even better example might have been if we had made the mariadb-service just a "db" service and then, the pod could be mariadb, mysql, sqlite, anything really, that can support SQL the way wordpress expects it to. In order to do that, we would have just add a ```label``` to the ```mariadb-pod.json``` called "db" and a ```selector``` in the ```mariadb-service.json``` (although, an even better name might be ```db-service.json```) called ```db```. Feel free to experiment with that at the end of this lab if you have time.

Now let's get things going. Start mariadb:
```
kubectl create -f ~/workspace/mariadb/kubernetes/mariadb-pod.json
kubectl create -f ~/workspace/mariadb/kubernetes/mariadb-service.json
```

Now let's start wordpress.
```
kubectl create -f ~/workspace/wordpress/kubernetes/wordpress-service.json
kubectl create -f ~/workspace/wordpress/kubernetes/wordpress-pod.json
    ```

OK, now let's make sure everything came up correctly:
```
kubectl get pods
kubectl get services
```
**Note** these may take a while to get to a running state as it pulls the image from the registry, spin up the containers, do these kubernetes magic, etc. 

Eventually, you should see:
```
NEED TO INSERT EXAMPLE OUTPUT HERE
```

Seemed awfully manual and ordered up there, didn't it? Just wait til Lab5 where we make it a lot less painful!

TODO: CHECK IT IN A WEB BROWSER

OK, so let's put the proof in the pudding! Find the wordpress container (we want to simulate an outage here, so we don't want to delete the pods or services) and knock it over. And, as soon as that completes (or even consider running it in the background) run docker ps on a loop and watch Kubernetes recreate it. You can also open the site in a web browser as a above and keep reloading to see the site go away and then come back. 

```
docker rm wordpress &
watch -n 1 docker ps
```

TODO: add in "always make sure wp stays up with two instances of wp"?
TODO: add in "db outage tolerance to wp container"?
