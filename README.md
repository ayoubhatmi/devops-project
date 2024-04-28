# devops-project

### Nextcloud available on : https://cloud.ayoub.uca-devops.ovh/

### Wordpress available on : https://blog.ayoub.uca-devops.ovh/

### Go app : http://185.34.141.134:8000

### Traefik Dashboard : http://185.34.141.134:8080

## Verify Databeses and users creation:
##### Access Mysql Command Line:

```sql
mysql -u beta -p
```

##### Verify Databases Creation:

```sql
> SHOW DATABASES;
```

##### Verify Users Creation:

```sql
>SELECT User, Host FROM mysql.user;
```
