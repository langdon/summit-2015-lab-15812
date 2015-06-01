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

### Packaging Wordpress

In this section we package the Wordpress application as an Atomic App. To demonstrate the composite nature of Atomic apps we have pre-loaded the database Atomic app. In this model a partnering software vendor provides an Atomic app that is certified on Red Hat platforms. The Wordpress application will reference  and connect to the certified Atomic app database service.

Copy the Nulecule template files to the workspace directory.

```
cp -R /root/lab5/nulecule_template/* /root/workspace/.
```

Open the Nulecule template file in a text editor.

1. Edit `name` for a database and wordpress graph component.

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

1. Copy the Wordpress kubernetes directory created in lab 4 into the `artifacts` directory. Since these are for the kubernetes providers we'll put them in a `kubernetes` sub-directory. This path will match the Nulecule template `- file:artifacts/kubernetes/` reference. Since it ends in a trailing "slash" (`/`) all files in the directory will be deployed.

        cp -R ~/workspace/wordpress/kubernetes ~/workspace/artifacts/.

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

1. Edit the kubernetes files and replace parameter values to match the name of each parameter in the Nulecule file. Strings that start with `$` will be replaced by parameter names.

            ...
            env:
            - name: DBUSER
              value: $db_user
            - name: DBPASS
              value: $db_pass
            - name: DBNAME
              value: $db_name
            ...

1. Edit the Nulecule file metadata section.

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

1. Build the Atomic app

        docker build -t wordpress-rhel7-atomicapp .

1. Run the Atomic app in `--dry-run` mode, then run it for real to verify it works

        atomic run wordpress-rhel7-atomicapp --dry-run

1. Check the deployment progress in the same way we did in lab 4.

        kubectl get pods -w

1. When you're satisfied push the Atomic app to the registry

        docker tag wordpress-rhel7-atomicapp summit-rhel-dev/wordpress-rhel7-atomicapp
        docker push summit-rhel-dev:5000/wordpress-rhel7-atomicapp
