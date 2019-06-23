# Support for {{organization}}
If you're looking for support for this project the following resources are available:

| | |
|-|-|
{# if twitter #}
|{{twitter_name}}:|[{{twitter_org}}]({{twitter_link}})|
{# endif #}
{# if forum #}
|{{forum_name}}:|[{{forum_org}}]({{forum_link}})|
{# endif #}
{# if mailto #}
|{{mailto_name}}:|[{{mailto_org}}]({{mailto_link}})|
{# endif #}

{# if slack #}
## {{slack_name}}
The {{organization}} team has helpful community members that are willing to point you in the right direction.

| | |
|-|-|
|Login to our Slack workspace:|[{{slack_org}}]({{slack_link}})|
|Join our Slack workspace:|[Registration]({{slack_join}})|
|Check out past conversations:|[Archive]({{slack_archive}})|

The {{slack_name}} channels {{slack_channels}}are the usual places where people offer support.
{# endif #}

{# if stack #}
## {{stack_name}}
The {{organization}} community is active on {{stack_name}}.

| | |
|-|-|
|Post your questions here:|[{{stack_name}}]({{stack_link}})|
|What can be asked about:|[Topics](http://stackoverflow.com/help/on-topic)|
|How to ask good questions:|[Tips](http://stackoverflow.com/help/how-to-ask)|
{# endif #}

{# if comm_meeting #}
## {{comm_meeting_name}} 
A regular meeting of the {{organizarion}} community takes place regularly:
[{{comm_meeting_name}}]({{meeting}}).
{# endif #}

{# if documentation #}
## {{documentation_name}} 
For {{organization}} getting started guides, installation, deployment,
and administration, see our [{{documentation_name}}]({{documentation_link}}).
{# endif #}

{% include 'do-not-edit.md' %}
