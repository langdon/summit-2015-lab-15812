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

* **Nulecule**:
* **Atomic app**:
* **Provider**:
* **Artifacts**:
* **Graph**:

### Packaging Wordpress

In this section we package the Wordpress application as an Atomic App. To demonstrate the composite nature of Atomic apps we have pre-loaded the database Atomic app. In this use case a partnering software vendor might provide an Atomic app that is certified on Red Hat platforms. The Wordpress application will reference  and connect to the certified Atomic app database service.

#### The Nulecule file

1. Copy the Nulecule template files to the workspace directory.

        cp -R ~/lab5/nulecule_template/* ~/workspace/.

1. Open the `~/workspace/Nulecule` template file in a text editor.

        vi ~/workspace/Nulecule

Take a look at the Nulecule file. There are two primary sections: metadata and graph. The graph is a list of components to deploy, like the database and wordpress services in our lab. The artifacts are a list of provider files to deploy. In this lab we have one provider, kubernetes, and the provider artifact files are the service and pod YAML files. The params section defines the parameters that may be changed when the application is deployed.

1. In an editory edit the `name` key for each component in the Nulecule file. In this lab this is our database and wordpress services we've been working with.

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
            source: "docker://projectatomic/mariadb-atomicapp"
        ...

1. Copy the Wordpress kubernetes directory created in lab 4 into the `artifacts` directory. Since these are for the kubernetes providers we'll put them in a `kubernetes` sub-directory. This path will match the Nulecule template `- file:artifacts/kubernetes/` reference. All files in this directory will be deployed.

        cp -R ~/workspace/wordpress/kubernetes ~/workspace/artifacts/.

#### Parameters

We want to allow some of the values in the kubernetes files to be changed at deployment time.

1. Edit the Nulecule file to add parameters `db_user`, `db_pass`, `db_name`

        ...
          - name: wordpress
            params:
              - name: image
                description: wordpress docker image
                default: wordpress
              - name: db_user 
                description: wordpress database username
                default: wp_user
              - name: db_pass
                description: wordpress database password
                hidden: true
              - name: db_name
                description: wordpress database name
                default: db_wordpress
        ...

1. We need to edit the kubernetes files so the values from the previous step can be replaced. Edit the pod file `~/workspace/artifacts/kubernetes/wordpress-pod.yaml` and replace parameter values to match the name of each parameter in the Nulecule file. Strings that start with `$` will be replaced by parameter names.

            ...
            env:
            - name: DBUSER
              value: $db_user
            - name: DBPASS
              value: $db_pass
            - name: DBNAME
              value: $db_name
            ...

#### Metadata

The Nulecule specification provides a section for arbitrary metadata. For this lab we will simply change a few values for demonstration purposes.

1. Edit the metadata section of the Nulecule file.

        vi ~/workspace/Nulecule

1. Edit the name and description fields.

        --- 
        specversion: "0.0.2"

        id: summit2015-lab
        metadata: 
          name: Wordpress
          appversion: v1.0.0
          description: >
            WordPress is web software you can use to create a beautiful
            website or blog. We like to say that WordPress is both free
            and priceless at the same time.
...

### Build and Deploy

We will be packaging the atomic app as a container so it can be managed the same way.

1. Build the Atomic app

        docker build -t wordpress-rhel7-atomicapp ~/workspace/.

1. Run the Atomic app.

        atomic run wordpress-rhel7-atomicapp

This will download the mariadb atomic app and deploy the databse to kubernetes. It will also deploy the wordpress pod and service. Check the deployment progress in the same way we did in lab 4.

```
kubectl get pods
kubectl get services
```

The mariadb files were downloaded to the local directory.

```
ls -l ~/workspace/mariadb
```

When you're satisfied push the Atomic app to the registry.

```
docker tag wordpress-rhel7-atomicapp summit-rhel-dev/wordpress-rhel7-atomicapp
docker push summit-rhel-dev:5000/wordpress-rhel7-atomicapp
```

