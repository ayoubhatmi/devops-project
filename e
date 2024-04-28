---
  - name: Installer les dépendances (Docker, Git, Go, Python, MariaDB client)
    hosts: servers
    become: true
    gather_facts: false  # Disable gathering facts
    tasks:
      - name: Installer Docker
        apt:
          name:
            - docker.io
            - docker-compose
          state: present
          
      - name: Installer Git
        apt:
          name: git
          state: present
  
      - name: Installer Go
        apt:  
          name: golang
          state: present
  
      - name: Installer le module python de Docker
        apt:
          name: python3-pip
          state: present
  
      - name: Installer le module Docker Python
        pip:
          name: docker
  
      - name: Démarrer et activer le service Docker
        systemd:
          name: docker
          state: started
          enabled: yes
  
      - name: Install MariaDB client
        apt:
          name: mariadb-client
          state: present
  
  - name: Deploy Traefik Docker container
    hosts: servers
    become: true
    tasks:
      - name: Pull Traefik Docker image
        docker_image:
          name: traefik:v2.6 # Change this to the desired Traefik version
          source: pull
  
      - name: Create Docker network for Traefik
        docker_network:
          name: traefik_network
          state: present
  
      - name: Start Traefik Docker container
        docker_container:
          name: traefik
          image: traefik:latest 
          restart_policy: always
          networks:
            - name: traefik_network
          ports:
            - "80:80"
            - "443:443"
          volumes:
            - "{{ ansible_env.PWD }}/acme.json:/acme.json"
            - "{{ ansible_env.PWD }}/traefik.yaml:/traefik.yaml"

  - name: Deploy Docker containers and clone Git repository on Vmachine
    hosts: all
    become: true
    vars:
      mariadb_root_password: "root"
      databases:
        - name: alphadb
        - name: betadb
      users:
        - name: alpha
          password: alphabdpwd
        - name: beta
          password: betadbpwd
  
    tasks:
      - name: Create Docker network for containers communication (wordpress/nextcloud)
        community.docker.docker_network:
          name: app_network
          state: present
  
      - name: Start Docker service
        service:
          name: docker
          state: started
  
      - name: Create a Docker container for MariaDB
        docker_container:
          name: mariadb
          image: mariadb:latest
          env:
            MYSQL_ROOT_PASSWORD: "root"
          ports:
            - "8083:80"
          networks_cli_compatible: yes
          networks:
            - name: app_network
  
      - name: Install MariaDB client tools inside MariaDB container
        community.docker.docker_container_exec:
          container: mariadb
          command: "apt-get install -y mariadb-client"
          detach: false
        register: mariadb_install_result
        until: mariadb_install_result is succeeded
        retries: 2
        delay: 5
  
      - name: Create databases
        community.docker.docker_container_exec:
          container: mariadb
          command: "mariadb -uroot -p{{ mariadb_root_password }} -e 'CREATE DATABASE IF NOT EXISTS {{ item.name }};'"
        loop: "{{ databases }}"
  
      - name: Create users and grant privileges
        community.docker.docker_container_exec:
          container: mariadb
          command: "mariadb -uroot -p{{ mariadb_root_password }} -e 'CREATE USER IF NOT EXISTS {{ item.name }} IDENTIFIED BY \"{{ item.password }}\"; GRANT ALL PRIVILEGES ON . TO {{ item.name }}@\"%\";'"
        loop: "{{ users }}"
  
      - name: Create a Docker container for Nextcloud
        docker_container:
          name: nextcloud
          image: nextcloud:latest
          ports:
            - "8080:80"
          networks_cli_compatible: yes
          networks:
            - name: app_network
            - name: traefik_network

          restart_policy: always
          env:
            MYSQL_HOST: mariadb
            MYSQL_DATABASE: alphadb
            MYSQL_USER: alpha
            MYSQL_PASSWORD: alphadbpwd
          labels:
            traefik.enable: "true"
            traefik.http.routers.nextcloud.rule: "Host('cloud.hadid.uca-devops.ovh')"
            traefik.http.routers.nextcloud.entrypoints: "secure"
            traefik.http.services.nextcloud.loadbalancer.server.port: "80"
            traefik.http.routers.nextcloud.tls: "true"
            traefik.http.routers.nextcloud.tls.certresolver: "letsencrypt"
  
      - name: Create a Docker container for Wordpress
        docker_container:
          name: wordpress
          image: wordpress:latest
          ports:
            - "8081:80"
          networks_cli_compatible: yes
          networks:
            - name: app_network
            - name: traefik_network

          volumes:
            - wordpress:/var/www/html
          restart_policy: always
          env:
            WORDPRESS_DB_HOST: mariadb
            WORDPRESS_DB_NAME: betadb
            WORDPRESS_DB_USER: beta
            WORDPRESS_DB_PASSWORD: betadbpwd
          labels:
            traefik.enable: "true"
            traefik.http.routers.wordpress.rule: "Host('blog.hadid.uca-devops.ovh')"
            traefik.http.routers.wordpress.entrypoints: "secure"
            traefik.http.services.wordpress.loadbalancer.server.port: "80"
            traefik.http.routers.wordpress.tls: "true"
            traefik.http.routers.wordpress.tls.certresolver: "letsencrypt"
  
      # - name: Cloner le dépôt Git
      #   git:
      #     repo: https://git.forestier.re/uca/2022-2023/devops-m1/tp-not/code-tp-note
      #     dest: /home/cloud/projectEts
  
      # - name: Construction de l'application et lancement
      #   shell: |
      #     cd /home/cloud/projectEts
      #     go mod download
      #     go build -o ./app ./cmd
      #     ./app

      beta_password