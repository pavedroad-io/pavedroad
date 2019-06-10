{% if support == 'sup-links' %}
# Support for the {{organization}} {{project}} project

If you're looking for support for the {{project}} project there are a lot of options, check out:

* [Documentation]({{docs_link}})
* [Twitter]({{twitter_link}})
* [Slack]({{slack_link}})
* [Email]({{support_email}})

The Slack team for the {{project}} project has many helpful community members that are willing to point you in the right direction.
{% elif support == 'sup-k8s' %}
# Support for deploying and using Kubernetes

Welcome to Kubernetes! We use GitHub for tracking bugs and feature requests. 
This isn't the right place to get support for using Kubernetes, but the following 
resources are available below, thanks for understanding.

## Stack Overflow

The Kubernetes Community is active on Stack Overflow, you can post your questions there: 

* [Kubernetes on Stack Overflow](http://stackoverflow.com/questions/tagged/kubernetes)

  * Here are some tips for [about how to ask good questions](http://stackoverflow.com/help/how-to-ask).
  * Don't forget to check to see [what's on topic](http://stackoverflow.com/help/on-topic).

## Documentation 

* [User Documentation](https://kubernetes.io/docs/) 
* [Troubleshooting Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting/)


## Real-time Chat

* [Slack](https://kubernetes.slack.com) ([registration](http://slack.k8s.io)):
The `#kubernetes-users` and `#kubernetes-novice` channels are usual places where 
people offer support.

* Also check out the 
[Slack Archive](http://kubernetes.slackarchive.io/) of past conversations.

## Mailing Lists/Groups

* [Kubernetes-users group](https://groups.google.com/forum/#!forum/kubernetes-users)

### Attribution
[Kubernetes Support](https://github.com/kubernetes/community/blob/master/contributors/devel/on-call-user-support.md)
{% endif %}
{% include 'do-not-edit.md' %}
