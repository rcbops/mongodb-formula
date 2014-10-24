{% from "mongodb/map.jinja" import mongodb with context %}

{% set version        = salt['pillar.get']('mongodb:version', none) %}
{% set package_name   = salt['pillar.get']('mongos:package_name', "mongodb-org-mongos") %}

{% if version is not none %}

{% set use_ppa        = salt['pillar.get']('mongos:use_ppa', none) %}
{% set settings       = salt['pillar.get']('mongos:settings', {}) %}
{% set log_path       = settings.get('log_path', '/var/log/mongos') %}
{% set log_file       = settings.get('log_file', '/var/log/mongos/mongos.log') %}

mongos_package:
{% if use_ppa is not none %}
  pkgrepo.managed:
    - humanname: MongoDB PPA
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - file: /etc/apt/sources.list.d/mongodb.list
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com
  pkg.installed:
    - name: {{ package_name }}
    - version: {{ version }}
    {% else %}
  pkg.installed:
     - name: mongos
    {% endif %}

mongos_log_file:
  file.directory:
    - name: {{ log_path }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

mongos_init:
  file.managed:
    - name: /etc/init/mongos.conf
    - source: salt://mongodb/mongos/files/init/mongos.conf.jinja
    - template: jinja
    - context:
        conf_path: {{ mongodb.conf_path }}

mongos_init_d:
  file.managed:
    - name: /etc/init.d/mongos
    - source: salt://mongodb/mongos/files/init.d/mongos.jinja
    - template: jinja

mongos_service:
  service.running:
    - name: {{ mongodb.mongos }}
    - enable: True
    - watch:
      - file: mongos_configuration

mongos_configuration:
  file.managed:
    - name: {{ mongodb.conf_path }}
    - user: root
    - group: root
    - mode: 644
    - source: salt://mongodb/mongos/files/mongos.conf.jinja
    - template: jinja
    - context:
        logfile: {{ log_file }}
        port: {{ settings.get('port', 27017) }}
        config_svrs: {% for server, addrs in salt['mine.get']('roles:mongoconfigsrv', 'network.ip_addrs', expr_form='grain').items() %}{{ addrs[0] }}:27017{% if loop.last %}{% else %},{% endif %}{% endfor %} 
mongos_logrotate:
  file.managed:
    - name: /etc/logrotate.d/mongos
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://mongodb/mongos/files/logrotate.jinja
    
mongodb_client:
  pkg.installed:
    - name: mongodb-clients
    
mongos_create_cluster_js:
  file.managed:
    - name: /etc/mongodb_create_cluster.js
    - source: salt://mongodb/mongos/files/createcluster.jinja
    - template: jinja
    
mongos_create_cluster:
  cmd.run:
    - name: 'mongo {% for server, addrs in salt['mine.get']('roles:mongos', 'network.ip_addrs', expr_form='grain').items() %}{% if loop.first %}{{ addrs[0] }}{% endif %}{% endfor %}:27017/admin /etc/mongodb_create_cluster.js >> /tmp/mongocluster.txt'
    - cwd: /
    - stateful: True
    
{% endif %}
