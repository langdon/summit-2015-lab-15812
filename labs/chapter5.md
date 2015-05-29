## LAB 5: Packaging an Atomic App

In this lab we walk through packaging an application into a single deployment unit. This is called an Atomic App and is based on the [Nulecule specification](https://github.com/projectatomic/nulecule/).

So far in the previous labs we have

1. Created docker images and pushed them to a registry
1. Created kubernetes files to orchestrate the running of the containers

In a production environment we have several problems:

1. How do we manage the orchestration files?
1. How do we manage changing parameters to reflect the deployment target?
1. How can we re-use common services such as a database so we don't have to re-write them every time?
1. How can we support different deployment targets (docker, kubernetes, openshift, etc) managed by a single deployment unit?

### Packaging Wordpress

In this section we package the Wordpress application as an Atomic App. To demonstrate the composite nature of Atomic apps we have pre-loaded the database atomic app. In this model a partnering software vendor provides an Atomic App that is certified on Red Hat platforms. The Wordpress application will reference the certified database Atomic App.

[insert image here]

1. Copy the Nulecule template files to TBD

        cp ~/lab5/nulecule_template/* .

1. Open the Nulecule file in a text editor. Create a database and wordpress graph component.
1. In the database component reference the database atomic app
1. Copy the wordpress kubernetes files into a `artifacts/kubernetes` directory
1. Edit the Nulecule file graph
  1. Edit `name`
  1. Edit the artifacts paths to match the files copied in step #2.
1. Edit the Nulecule file to add parameters `db_user`, `db_pass`, `db_name`
1. Edit the Nulecule file with metadata
1. Build the Atomic app
1. Run the Atomic app in `--dry-run` mode, then run it to verify it works
1. Push the Atomic app to the registry

