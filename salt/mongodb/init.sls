mongodb:
  pkgrepo.managed:
    - humanname: MongoDB 
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - file: /etc/apt/sources.list.d/mongodb.list
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: mongodb-org
  pkg.latest:
    - name: mongodb-org
    - refresh: True
