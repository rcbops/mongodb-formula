{% set replica_set    = salt['pillar.get']('mongodb:replica_set', none) %}

mongos_create_cluster_js:
  file.managed:
    - name: /etc/mongodb_create_cluster.js
    - source: salt://mongodb/mongos/files/createcluster.jinja
    - template: jinja
    - context:
       mongodb_ips: {{ replica_set }}/{% for server, addrs in salt['mine.get']('roles:mongodb', 'network.ip_addrs', expr_form='grain').items() %}{{ addrs[0] }}:27017{% if loop.last %}{% else %},{% endif %}{% endfor %}

mongos_create_cluster:
  cmd.run:
    - name: 'mongo {% for server, addrs in salt['mine.get']('roles:mongos', 'network.ip_addrs', expr_form='grain').items() %}{% if loop.first %}{{ addrs[0] }}{% endif %}{% endfor %}:27017/admin /etc/mongodb_create_cluster.js >> /tmp/mongocluster.txt'
    - cwd: /
    - stateful: True
