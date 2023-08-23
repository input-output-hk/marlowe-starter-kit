# Demeter run deployment

This document describes how to set up a hosted version of the Marlowe Runtime services and Cardano node through demeter.run. 

The demeter.run web3 development platform provides an extension, Cardano Marlowe Runtime, that has Marlowe tools installed. This extension provides the Marlowe Runtime backend services and a Cardano node, so you don't need to set environment variables, install tools or run backend services. 

## Steps

Visit [demeter.run](https://demeter.run/). 

Sign in or create an account. 

### Create a Project

Along the top navigation bar, select Projects. The Projects panel displays. 

Select NEW PROJECT + 

The Project creation wizard displays. 

Enter a project name in the Name field. 

Enter a project description in the Description field. 

Create an organization or select one if you have previously created an organization. 

Select a cluster (US Central or Europe). 

Select Create Project. The project dashboard displays. 

### DCUs

Obtain DCUs (Demeter Compute Units) according to your project needs. You will need to determine your payment method as you go through that process. 

### Connecting Cardano Node Extension

Along the top navigation bar, select Extensions. The Extensions page displays. 

Select Cardano Nodes. The Cardano Nodes Extensions panel displays. 

Under the heading Shared instances, click the toggle switch corresponding to the Preview network instance. Initially it says Disconnected. After clicking the toggle switch, it says Connecting in orange. Once connected, it displays Connected in green. 

At the top of the Cardano Nodes Extensions page, click Extensions to return to the list of Extensions. 

### Connecting Cardano Marlowe Runtime

From the list of extensions, select Cardano Marlowe Runtime. The Cardano Marlowe Runtime panel displays. 

From the list of shared instances, click the toggle switch for the Preview network corresponding to the latest version of Marlowe Runtime. Initially it says Disconnected. After clicking the toggle switch, it says Connecting in orange. Once connected, it displays Connected in green. 

At the top of the Cardano Marlowe Extensions page, click Extensions to return to the list of Extensions. 

Now you will be able to use services from the Node and Runtime. 

### Workloads

Along the top navigation bar, select Workloads. The Create workload page displays. 

Under the Create workload heading, click Workspace. The Create Workspace page displays. 

Under the heading "Are you cloning an existing repository?" click the toggle switch for "Activate to enter repository URL." Two fields display. 

In the URL field, enter the URL for the Marlowe Starter Kit: 

* https://github.com/input-output-hk/marlowe-starter-kit

In the Branch field, leave the default value of "main" in place. 

### Select your extras

Scroll down the page until you see the heading Select your extras. 

Under this heading, click Cardano Binaries. The Cardano Binaries item is highlighted to indicate it is selected. 

Under the same heading, select Jupyter Notebook. The Jupyter Notebook item is highlighted to indicate it is selected. 

### Select the Workspace Size

Under the heading Select the Workspace Size, select Medium. 

### Select the network to connect

Under the heading Select the network to connect, select Preview. 

### Advanced

Under the heading Advanced, in the Workspace name field, enter a name for your workspace. 

Enter your name in the Git Author field. 

Enter your email address in the Git Email field. 

Click the Create button. You will return to the Demeter > Playground page. 

### Provisioning

Under the Dashboard heading, your new workspace is shown with the status of Provisioning. Demeter run is now provisioning your selected services. 

In approximately one minute or so, the status of your new workspace will change to Running. 

### Open VS Code

Just above the Running status message on the right side of the panel, click the VS Code icon located just above the word "RUNNING" to enter a VS Code window. 

The prompt message Do you trust the authors of the files in this folder? displays. Select Yes, I trust the authors. 

A view of the cloned version of the Marlowe Starter Kit displays. The folders and files are listed in a panel in the left side of the workspace. 

### Setup folder

From the left column, expand the item "setup." 

Select the file `00-local-environment.jpynb`. This opens the file titled "Local environment checks." 

### Command Line Tools and Environment

Scroll down to the code block under the heading Command Line Tools and Environment. 

Select the area just to the left of the code block. Once selected, a blue line displays along the left margin of the page next to the code block. 

At the top of the page, select the field to the right of the filename 00-preliminaries.jpynb. From the drop-down list, select Jupyter Kernel. Select Bash /usr/bin/python3. The code block executes. 

Just below the code block, two lines display: 

CARDANO_NODE_SOCKET_PATH = /jpc/node.socket
CARDANO_TESTNET_MAGIC = 2

These lines indicate that there is a Cardano node socket and that it is connected to the Cardano testnet magic network. 

At this point, you are connected and ready to run any of the Jupyter notebook files shown in the left panel. 
