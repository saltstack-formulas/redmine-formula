{% from "redmine/map.jinja" import defaults with context %}
{% from "redmine/map.jinja" import redmine with context %}

{% set git_user = defaults.git_user %}
{% set git_group = defaults.git_group %}

redmine_gitolite_perl_db_driver_pkgs:
  pkg.installed:
    - pkgs: {{ defaults.db_driver_pkgs | json }}

{{ defaults.apache_redmine_dir }}:
  file.directory: []

{{ defaults.apache_redmine_dir }}/htpasswd:
  file.managed:
    - contents: ''
    - require:
      - file: {{ defaults.apache_redmine_dir }}

{{ defaults.apache_redmine_dir }}/perl_modules:
  file.directory:
    - require:
      - file: {{ defaults.apache_redmine_dir }}

{{ defaults.apache_redmine_dir }}/perl_modules/Apache:
  file.directory:
    - require:
      - file: {{ defaults.apache_redmine_dir }}/perl_modules

{{ defaults.apache_redmine_dir }}/load_custom_perl_modules.pl:
  file.managed:
    - contents: |
        use lib qw({{ defaults.apache_redmine_dir }}/perl_modules/);
        1;
    - require:
      - file: {{ defaults.apache_redmine_dir }}
      - file: {{ defaults.apache_redmine_dir }}/perl_modules
    - watch_in:
      - module: {{ defaults.apache_reload_id }}

{# Script must be within suexec's doc root. See suexec -V. #}
{{ defaults.apache_suexec_docroot }}/gitolite:
  file.symlink:
    - target: {{ defaults.gitolite_src }}

{{ defaults.apache_suexec_docroot }}/bin:
  file.directory:
    - user: {{ defaults.git_user }}
    - group: {{ defaults.git_group }}

{% for instance, cfg in redmine.get('instances', {}).items() %}
  {% set instance_dir =  defaults.basedir ~ '/' ~ instance %}

  {% if loop.first %}
{{ defaults.apache_redmine_dir }}/perl_modules/Apache/Redmine.pm:
  file.managed:
    - source: {{ instance_dir }}/extra/svn/Redmine.pm
  {% endif %}

{% set wrapper = defaults.apache_suexec_docroot ~ '/bin/' ~ instance ~ '-gitolite-suexec-wrapper.sh' %}
{{ wrapper }}:
  file.managed:
    - source: salt://redmine/files/apache-gitolite-suexec-wrapper.sh.jinja
    - template: jinja
    - user: {{ git_user }}
    - group: {{ git_group }}
    - mode: 755
    - context:
        git_project_root: {{ cfg.get('git_project_root', defaults.git_project_root)}}
        gitolite_http_home: {{ cfg.get('gitolite_http_home', defaults.gitolite_http_home)}}
        gitolite_http_remote_user: {{ cfg.get('gitolite_http_remote_user', defaults.gitolite_http_remote_user)}}
        gitolite_shell: {{ defaults.apache_suexec_docroot }}/gitolite/gitolite-shell
    - require:
      - file: {{ defaults.apache_suexec_docroot }}/bin

{{ defaults.apache_snippet_dir }}/redmine-{{ instance }}-gitolite.conf:
  file.managed:
    - source: salt://redmine/files/apache-gitolite-snippet.conf.jinja
    - template: jinja
    - context:
        git_user: {{ git_user }}
        git_group: {{ git_group }}
        instance_dir: {{ instance_dir }}
        git_alias: {{ cfg.get('git_alias', defaults.git_alias) }}
        apache_redmine_dir: {{ defaults.apache_redmine_dir }}
        apache_suexec_docroot: {{ defaults.apache_suexec_docroot }}
        wrapper: {{ wrapper }}
        RedmineDSN: {{ cfg.get('RedmineDSN') }}
        RedmineDbWhereClause: {{ cfg.get('RedmineDbWhereClause', False) }}
        RedmineDbUser: {{ cfg.get('RedmineDbUser') }}
        RedmineDbPass: {{ cfg.get('RedmineDbPass') }}
    - watch_in:
      - module: {{ defaults.apache_reload_id }}
{% endfor %}

