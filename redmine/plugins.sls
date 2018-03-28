{% from "redmine/map.jinja" import defaults with context %}
{% from "redmine/map.jinja" import redmine with context %}

include:
  - redmine.install

{% set migrate_block = {'missing': True} %}
{% for instance, cfg in redmine.get('instances', {}).items() %}

  {% set instance_dir =  defaults.basedir ~ '/' ~ instance %}
  {% set setup_user = defaults.setup_user_prefix ~ instance %}
  {% set web_user = cfg.get('web_user', defaults.web_user) %}

  {% for plugin, pcfg in cfg.get('plugins', {}).items() %}

    {% set remove = pcfg.get('remove', False) %}
    {% set plugin_dir = instance_dir ~ '/plugins/' ~ plugin %}

    {% if not remove %}
      {# ADD/KEEP PLUGIN #}
redmine_{{ instance }}_{{ plugin }}_repo:
  git.latest:
    - name: {{ pcfg.uri }}
    - branch: {{ pcfg.get('branch', 'master') }}
    - rev: {{ pcfg.get('revision', 'HEAD') }}
    - user: {{ setup_user }}
    - target: {{ plugin_dir }}
    - force_checkout: True
    - force_fetch: True
    - force_reset: True
    - onchanges_in:
      - cmd: redmine_{{ instance }}_bundle_install
      - cmd: redmine_{{ instance }}_bundle_update
      - cmd: redmine_{{ instance }}_plugins_migrate
      - cmd: redmine_{{ instance }}_restart_passenger

      {% if migrate_block.missing %}
        {% do migrate_block.update({'missing': False}) %}
redmine_{{ instance }}_plugins_migrate:
  cmd.run:
    - name: bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    - runas: {{ setup_user }}
    - env:
      - RAILS_ENV: production

redmine_{{ instance }}_restart_passenger:
  cmd.run:
    - name: touch {{ instance_dir }}/tmp/restart.txt
    - runas: {{ web_user }}
      {% endif %}
    {% else %}
      {# REMOVE PLUGIN #}
redmine_{{ instance }}_{{ plugin }}_remove_records:
  cmd.run:
    - name: bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME={{ plugin }} VERISION=0
    - runas: {{ setup_user }}
    - env:
      - RAILS_ENV: production
      - NAME: {{ plugin }}
      - VERISION: '0'
    - onlyif: test -d {{ plugin_dir }}

redmine_{{ instance }}_{{ plugin }}_remove_dir:
  file.absent:
    - name: {{ plugin_dir }}
    {% endif %}
  {% endfor %}
{% endfor %}
