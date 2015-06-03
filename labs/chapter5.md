## LAB 5: Packaging an Atomic App

In this lab we walk through packaging an application into a single deployment unit. This is called an Atomic App and is based on the [Nulecule specification](https://github.com/projectatomic/nulecule/).

So far in the previous labs we have:

1. Decomposed an application into microservices
1. Created docker images and pushed them to a registry
1. Created kubernetes files to orchestrate the running of the containers

In a production environment we still have several problems:

1. How do we manage the orchestration files?
1. How do we manage changing parameters to reflect the deployment target?
1. How can we re-use common services such as a database so we don't have to re-write them every time?
1. How can we support different deployment targets (docker, kubernetes, openshift, etc) managed by a single deployment unit?

### Terms

* **Nulecule**: Nulecule is a specification that defines a pattern and model for packaging complex multi-container applications, referencing all their dependencies, including orchestration metadata in a container image for building, deploying, monitoring, and active management.
* **Atomic app**: An implementation of the Nulecule specification. Atomic app supports running applications packaged as a Nulecule.
* **Provider**: Plugin interface for specific deployment platform, an orchestration provider
* **Artifacts**: Provider files
* **Graph**: Declarative representation of dependencies in the context of a multi-container Nulecule application

### Packaging Wordpress

In this section we package the Wordpress application as an Atomic App. To demonstrate the composite nature of Atomic apps we have pre-loaded the database Atomic app. In this use case a partnering software vendor might provide an Atomic app that is certified on Red Hat platforms. The Wordpress application will reference  and connect to the certified Atomic app database service.

#### The Nulecule file

1. Copy the Nulecule template files to the workspace directory.

        cp -R ~/lab5/nulecule_template/* ~/workspace/.

1. Open the `~/workspace/Nulecule` template file in a text editor.

        vi ~/workspace/Nulecule

Take a look at the Nulecule file. There are two primary sections: metadata and graph. The graph is a list of components to deploy, like the database and wordpress services in our lab. The artifacts are a list of provider files to deploy. In this lab we have one provider, kubernetes, and the provider artifact files are the service and pod YAML files. The params section defines the parameters that may be changed when the application is deployed.

1. Open the Nulecule file in an editor. Edit the `name` key for each component in the Nulecule file. In this lab this is our database and wordpress services we've been working with.

        ...
        graph:
          - name: mariadb
            source: "docker://registry.example.com/some/database"
          - name: wordpress
        ...

1. To reference another Atomic app use the `source` key to point to another container image. In the database component reference the database atomic app that was pre-built for this lab.

        ...
        graph:
          - name: mariadb
            source: "docker://mariadb-atomicapp"
        ...

1. Save and close the Nulecule file. Copy the Wordpress kubernetes directory created in lab 4 into the `artifacts` directory. Since these are for the kubernetes provider we'll put them in a `kubernetes` sub-directory.

        cp -R ~/workspace/wordpress/kubernetes ~/workspace/artifacts/.

1. Open the Nulecule file in an editor. Add a path to each kubernetes file in the Nulecule file as a list of files to be deployed. Replace the `kubernetes:` section with the two file references.

            artifacts:
              kubernetes:
                - file://artifacts/kubernetes/wordpress-pod.yaml
                - file://artifacts/kubernetes/wordpress-service.yaml

#### Parameters

We want to allow some of the values in the kubernetes files to be changed at deployment time. Edit the Nulecule file to add the following parameters. Items without a default value will require input during deployment time. Replace the contents of the `params:` section with the list of parameters.

        ...
          - name: wordpress
            params:
              - name: image
                description: wordpress docker image
              - name: db_user 
                description: wordpress database username
                default: wp_user
              - name: db_pass
                description: wordpress database password
              - name: db_name
                description: wordpress database name
                default: db_wordpress
              - name: publicip 
                description: wordpress frontend public IP address
        ...

Save and close the Nulecule file.

#### Provider files

We need to edit the kubernetes files so the values from the previous step can be replaced.

1. Edit the pod file `~/workspace/artifacts/kubernetes/wordpress-pod.yaml` and replace parameter values to match the name of each parameter in the Nulecule file. Strings that start with `$` will be replaced by parameter names: `$db_user`, `$db_pass`, `$db_name`

            ...
            env:
            - name: DBUSER
              value: $db_user
            - name: DBPASS
              value: $db_pass
            - name: DBNAME
              value: $db_name
            ...

1. Edit the Wordpress service file `~/workspace/artifacts/kubernetes/wordpress-service.yaml`. Change the publicIPs value to `$publicip`.

        ...
           publicIPs: 
           - $publicip
        ...

#### Metadata

The Nulecule specification provides a section for arbitrary metadata. For this lab we will simply change a few values for demonstration purposes.

Open the Nulecule file in an editor. Edit the metadata section of the Nulecule file, changing the name and description fields.

        --- 
        specversion: "0.0.2"

        id: summit-2015-wp
        metadata: 
          name: Wordpress
          appversion: v1.0.0
          description: >
            WordPress is web software you can use to create a beautiful
            website or blog. We like to say that WordPress is both free
            and priceless at the same time.
...

Save and close the file.

That completes the Nulecule file work. You can check your work against the reference file for this lab in `~/workspace/Nulecule.reference`.

```
diff ~/workspace/Nulecule ~/workspace/Nulecule.reference
```

### Build and Deploy

We will be packaging the atomic app as a container. This way there is no "out of band" metadata mangement channel: everything is a container.

1. Build the Atomic app. We will use the standard Dockerfile for atomic app.

        docker build -t wordpress-rhel7-atomicapp ~/workspace/.

1. Change to a temporary directory so we can see the files that are unpacked during the deployment. Run the Atomic app.

        cd /tmp
        ls
        atomic run wordpress-rhel7-atomicapp

1. You will be prompted for each parameter. Where default parameters are provided you may press `enter`. Parameters you will need:

  * wordpress image: `192.168.135.2:5000/wordpress`
  * mariadb image: `192.168.135.2:5000/mariadb`
  * database password: your choice. NOTE: you'll be prompted twice, once for db and wordpress pods.
  * public IP: `192.168.135.3`

The mariadb atomic app should be downloaded. The wordpress and database pods and services should be deployed to kubernetes. By default the deployment is in debug mode so expect a lot of terminal output.

Check the deployment progress in the same way we did in lab 4.

```
kubectl get pods
kubectl get services
kubectl get endpoints
```

The wordpress files were downloaded to the local directory. The mariadb files are placed in an `external` directory.

```
ls -l /tmp
ls -l /tmp/external
```

View the sample answerfile.

```
cat answers.conf.sample
```

This may be renamed `answers.conf` and used for future unattended deployments.
