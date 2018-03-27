{% from "redmine/map.jinja" import defaults with context %}
{% from "redmine/map.jinja" import redmine with context %}

redmine_dependencies:
  pkg.installed:
    - pkgs: {{ defaults.dependencies }}

{% set setup_group = defaults.setup_group %}

redmine_setup_group:
  group.present:
    - name: {{ setup_group }}
    - system: True

{% for instance, cfg in redmine.get('instances', {}).items() %}

  {% set setup_user = defaults.setup_user_prefix ~ instance %}
  {% set web_user = cfg.get('web_user', defaults.web_user) %}
  {% set web_group = cfg.get('web_group', defaults.web_group) %}
  {% set instance_dir =  defaults.basedir ~ '/' ~ instance %}

redmine_{{ instance }}_setup_user:
  user.present:
    - name: {{ setup_user }}
    - gid: {{ setup_group }}
    - createhome: False
    - home: {{ instance_dir }}
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: redmine_setup_group

redmine_{{ instance }}_base:
  file.directory:
    - name: {{ instance_dir }}
    - user: {{ setup_user }}
    - group: {{ web_group }}
    - mode: 750
    - makedirs: True
    - require:
      - user: redmine_{{ instance }}_setup_user

redmine_{{ instance }}_repo:
  svn.latest:
    - name: {{ cfg.svn_uri }}
    - target: {{ instance_dir }}
    - user: {{ setup_user }}
    - rev: {{ cfg.get('revision', 'HEAD') }}
    - force: True
    - require:
      - file: redmine_{{ instance }}_base
      - pkg: redmine_dependencies

redmine_{{ instance }}_public:
  file.directory:
    - name: {{ instance_dir }}/public
    - user: {{ setup_user }}
    - group: {{ setup_group }}
    - mode: 755

redmine_{{ instance }}_log:
  file.directory:
    - name: {{ instance_dir }}/log
    - user: {{ web_user }}
    - group: {{ setup_group }}
    - mode: 775

redmine_{{ instance }}_log_production:
  file.managed:
    - name: {{ instance_dir }}/log/production.log
    - user: {{ web_user }}
    - group: {{ setup_group }}
    - mode: 664

  {% for dir in ['files', 'tmp', 'public/plugin_assets'] %}
redmine_{{ instance }}_writable_{{ dir }}:
  file.directory:
    - name: {{ instance_dir }}/{{ dir }}
    - user: {{ web_user }}
    {% if dir in ['log', 'public/plugin_assets'] %}
    - group: {{ setup_group }}
    - dir_mode: 775
    - file_mode: 664
    {% else %}
    - group: {{ web_group }}
    - dir_mode: 755
    - file_mode: 755
    {% endif %}
    - recurse:
      - user
      - group
      - mode
  {% endfor %}

redmine_{{ instance }}_database_config:
  file.managed:
    - name: {{ instance_dir }}/config/database.yml
    - user: {{ setup_user }}
    - group: {{ web_group }}
    - mode: 640
    - contents: |
        {{ cfg.database|yaml(False)|indent(8) }}
    - require:
      - svn: redmine_{{ instance }}_repo

redmine_{{ instance }}_configuration:
  file.managed:
    - name: {{ instance_dir }}/config/configuration.yml
    - user: {{ setup_user }}
    - group: {{ web_group }}
    - mode: 640
    - contents: |
        {{ cfg.configuration|yaml(False)|indent(8) }}
    - require:
      - svn: redmine_{{ instance }}_repo

redmine_{{ instance }}_bundler_install:
  cmd.run:
    - name: bundle install --without development test --path vendor/bundle
    - cwd: {{ instance_dir }}
    - runas: {{ setup_user }}
    - onchanges:
      - svn: redmine_{{ instance }}_repo

redmine_{{ instance }}_generate_secret_token:
  cmd.run:
    - name: bundle exec rake generate_secret_token
    - cwd: {{ instance_dir }}
    - runas: {{ setup_user }}
    - onchanges:
      - svn: redmine_{{ instance }}_repo
    - require:
      - cmd: redmine_{{ instance }}_bundler_install

redmine_{{ instance }}_database_migration:
  cmd.run:
    - name: bundle exec rake db:migrate
    - env:
      - RAILS_ENV: production
    - cwd: {{ instance_dir }}
    - runas: {{ setup_user }}
    - onchanges:
      - svn: redmine_{{ instance }}_repo
    - require:
      - cmd: redmine_{{ instance }}_bundler_install
      - cmd: redmine_{{ instance }}_generate_secret_token

redmine_{{ instance }}_load_default_data:
  cmd.run:
    - name: bundle exec rake redmine:load_default_data
    - env:
      - RAILS_ENV: production
      - REDMINE_LANG: {{ cfg.get('language', 'en') }}
    - cwd: {{ instance_dir }}
    - runas: {{ setup_user }}
    - onchanges:
      - svn: redmine_{{ instance }}_repo
    - require:
      - cmd: redmine_{{ instance }}_bundler_install
      - cmd: redmine_{{ instance }}_database_migration

# TODO: bundler update / upgrade/update in general
{% endfor %}
