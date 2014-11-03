include: 
  - mongodb

/etc/default/mongos:
  file.managed:
    - source: salt://mongodb/mongos/files/default_mongos.jinja
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/init/mongos.conf:
  file.managed:
  - source: salt://mongodb/mongos/files/init_mongos.conf
  - makedirs: True
  - user: root
  - group: root
  - mode: 644

/etc/init.d/mongos:
  file.symlink:
    - target: /etc/init.d/mongod
    

mongod:
  service:
    - dead
    - enable: False
    - require: 
      - pkg: mongodb-org
 
mongos:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/default/mongos
      - file: /etc/init/mongos.conf
    - require:
      - pkg: mongodb-org
 
