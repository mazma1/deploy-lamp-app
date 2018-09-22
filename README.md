# Automation of a LAMP Application Deployment on GCP
This is a demonstration of how the deployment of a LAMP stack on a minimal application can be automated using bash scripts. In this case, we would deploy Wordpress to a web server on Google Cloud Platform.

## Technology Stack
---
- Unix Bash Shell
- Google Cloud Platform
- Apache
- PHP
- MySQL

## Choice of Tools
---
1. ### Server - Cloud Hosting:
    I chose to host the demo application on a cloud platform for the following reasons:
    - It is relatively easy to set up a brand new virtual server instance on the cloud compared to dealing with a physical server.

      It will be nice to point out that like many cloud hosting providers, [GCP](https://cloud.google.com/free/) gives new users a trial period when they use some specified resources for free.

    - Cloud service providers have a pay-as-you-go option where you only get to pay for resources as you use them. By leveraging this option, going through this exercise cost me far less than a dollar. I didn't have to worry about, say a monthly subscription as is mostly obtainable in traditional hosting.


2. ### Scripting - Bash:
    - Bash scripts, like any other shell script allow us to run a myriad of small (and often very fast) programs in a series. Though other scripting languges like Python, Perl and Ruby can do this, they are not optimized for it.

    - For example, while Python can run the same programs as sjell scripts (bash), you often times will be forced to do bash scripting in the python script to accomplish the same thing, leaving you with both python and bash. Bash allows you to automate command line tasks by using the same language you would if you type the commands out manually.

    - Perl, Python, and Ruby scripts often end up complicated to perform a task that would have been much simpler with shell scripts.



    - 

## Get Started - Prerequisites
---
Before you can test out the scripts, the following must have been taken care of:
1. You should have an account on Google Cloud Platform. You can visit [here](https://cloud.google.com/) to sign up if you don't.
2. You should have the [Cloud SDK](https://cloud.google.com/sdk/) installed. This will enable you interact with GCP resources in your account from the command line.

    For instance, the automation scripts use the `gcloud` commands available in the SDK to create, start and make SSH connections to a web server instance.
3. Create a [project](https://medium.com/google-cloud/how-to-create-cloud-platform-projects-using-the-google-cloud-platform-console-e6f2cb95b467) from your GCP console for the test purpose.
4. Ensure you authentice the CLI by running the `gcloud auth login` command on your terminal, and that your demo project from **3.** is set to your current project.

    Below is a screenshot of what a successful CLI authentication looks like. Take note of the current project which in your case should be the name of your own project.

    ![alt text](img/gcloud_auth.png?raw=true "gcloud authentication output")
5. You need to add some parameters as project-wide [metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata#projectwide) (similar to environment variables). These variables will be used to configure your Wordpress database and SQL after installation. Follow the same pattern shown in the [sample file](metadata.sample), but feel free to update the values to what ever you choose.

Once we have the above prerequisites sorted out, then we are good to run our script!

## Execute!
---
1. Clone the repository and navigate to the project folder in your terminal.
2. Execute the scripts by running `./scripts/provision_instance.sh <instance-name>`. `instance-name` should be any name of your choice to identify your web server that will be created.

    If all things go well, you should have your web server up and running in your project dashboard. Note that `lamp02` was the `instance-name` I chose while executing the script.

    ![alt text](img/web_server.png?raw=true "gcloud authentication output")

3. Enter the external IP address of your server in a web browser and you should see your new Wordpress installation ready for set up.

    ![alt text](img/wordpress.png?raw=true "gcloud authentication output")

4. You can go ahead to complete the set up and try out the installation.

