# {{comm_meeting_name}}

{% if comm_meeting %}
A regular community meeting takes place [{{comm_meeting_time}}]({{comm_meeting_link}}).
Convert to your [local timezone]({{comm_meeting_zone}}).

Any changes to the meeting schedule will be added to the [{{agenda_name}}]({{agenda_link}})
and posted to [Slack #announce]({{slack_announce}}) 
and the [{{organization}} {{forum_name}}]({{forum_link}}).

Anyone who wants to discuss the direction of the project, design and implementation reviews, or general questions with the broader community is welcome and encouraged to join.

* [Meeting link]({{comm_meeting_link}})
* [Current agenda and past meeting notes]({{agenda_link}})
* [Past meeting recordings]({{recording_link}})
{% else %}
There is no regularly scheduled {{comm_meeting_name}} at this time.
  {% if slack %}
See [Slack Announcements]({{slack_announce}}) for impromptu meetings.
  {% endif %}
{% endif %}

{% include 'do-not-edit.md' %}
