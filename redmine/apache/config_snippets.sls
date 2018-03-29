{% from "redmine/map.jinja" import defaults with context %}
{% from "redmine/map.jinja" import redmine with context %}

{% for instance, cfg in redmine.get('instances', {}).items() %}
  {% set web_user = cfg.get('web_user', defaults.web_user) %}
  {% set web_group = cfg.get('web_group', defaults.web_group) %}
  {% set instance_dir =  defaults.basedir ~ '/' ~ instance %}

{{ defaults.apache_snippet_dir }}/redmine-{{ instance }}.conf:
  file.managed:
    - source: salt://redmine/files/apache-snippet.conf.jinja
    - template: jinja
    - context:
        web_user: {{ web_user }}
        web_group: {{ web_group }}
        instance_dir: {{ instance_dir }}
        apache_alias: {{ cfg.get('apache_alias', False) }}
    - watch_in:
      - module: apache-reload
{% endfor %}
