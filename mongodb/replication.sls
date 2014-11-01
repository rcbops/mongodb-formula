mongo_create_replication_js:
  file.managed:
    - name: /etc/mongodb_set_replication.js
    - source: salt://mongodb/files/setreplication.jinja 
    - template: jinja
    - context:
       mongodb_ips: [{%  for server, addrs in salt['mine.get']('roles:mongodb', 'network.ip_addrs', expr_form='grain').items() %}{{ addrs[0] }}{% if loop.last %}{% else %},{% endif %} {% endfor %}]

mongodb_set_replication:
  cmd.run:
    - name: 'mongo {% for server, addrs in salt['mine.get']('roles:mongodb', 'network.ip_addrs', expr_form='grain').items() %}{% if loop.first %}{{ addrs[0] }}{% endif %}{% endfor %}:27017 /etc/mongodb_set_replication.js >> /tmp/mongoreplication.txt'
    - cwd: /
    - stateful: True
    
