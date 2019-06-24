<p align="center"><img src="https://github.com/pavedroad-io/kevlar-repo/blob/master/assets/images/banner.png" alt="PavedRoad.io"></p>

# {{organization}}
## Overview
PavedRoad.io is an OSS project for modeling the Software Development and Operations (SDO) life cycle.  While Infrastructure as Code (IaC) gave us the ability to model our service, networks, storage, and compute resources.  PavedRoad.io introduces Stacks as Code (SaC) which encompass the entire tool network including libraries, development tools, CI/CD, operations, and advance analytics using ML/AI. 

## What is a 'Paved Road'?
The term "Paved Road" was coined by the Netflix tools teams which created several fully integrated end-to-end tool networks for writing, testing, deploying, and operating their streaming video service. For each support execution framework such as Java, Python, or Go, an integrated working CI/CD tool network was created.  This method of pre-integrated and tested tool networks converts a bumpy and difficult road into a delightfully smooth road which dramatically increases the velocity of development teams

## Kevlar for GO
Kevlar a foundation for delivering microservices, serverless functions, and integrating existing traditional and cloud applications, aka bare-metal and virtual machines.  It comes with a complete integrated tool network for developing, deploying, and operating those services. 

## Stacks as Code (SaC)
Infrastructure as Code (IaC) is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools [Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code).

In SaC, we first automate the entire tool chain by using Kubernetes Custom Resource Definitions (CRD) as an abstraction layers/data model between each step.  Kubernetes metadata provides an abstraction layer for passing data between each step.  Customer controllers manage the flow and create a data presentation layer for tools making up the chain.  This enables the tool network to be formed using standard k8s labels and selectors.

## Project Status

The project is an early preview. We realize that it's going to take a village to arrive at the vision of a multi-cloud control plane, and we wanted to open this up early to get your help and feedback. Please see the [Roadmap]({{roadmap}}) for details on what we are planning for future releases. 

## Official Releases

Official releases of {{organization}} can be found here:
[{{releases_name}}]({{releases_link}}).
Please note that it is **strongly recommended** that you use the official releases
of {{organization}}, as unreleased versions from the master branch are subject to
changes and incompatibilities that will not be supported in the official releases.
Builds from the master branch can have functionality changed and even removed
at any time without compatibility support and without prior notice.

{% include 'readme-trailer.md' %}