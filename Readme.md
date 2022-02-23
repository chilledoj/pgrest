# PostgreSQL REST with Authentication
This is a reference Docker Compose file for putting the following items together for local development purposes:

+ [PostgreSQL](https://www.postgresql.org/) Database
+ [Adminer](https://www.adminer.org/) DB manager
+ [PostgREST](https://postgrest.org/en/stable/) REST API proxy for PostgreSQL
+ [LoginSrv](<https://github.com/tarent/loginsrv>) JWT provider from file

## Running

The `pgrest.yml` file is the main Docker Compose file to use and can be launched using the following command:
```sh
docker-compose -f ./pgrest.yml up
```

For ease of use there is a `Makefile` so that you can run:

+ `make up` - docker compose up
+ `make down` - docker compose down
+ `make cleandata` - will delete all files in the `pgdata` directory

## Initial DB Data
The `pgdata` folder (created on first startup if it doesn't exist) is where the PG database will persist its files. It is a mounted volume in the PG docker container. In order for the `init_db.sql` script to be run, there must not be any existing data in the folder i.e. it only runs once. Therefore if you make any changes to the init db script then you will need to clear down the data and allow the container to start afresh.

Additional scripts can be added in the `initsql` folder, but they would need to be added manuall into the volumes section of the `db` service.

e.g. let's assume you want to add a users table in a new file called `init_users.sql`.
```sql
/* ./initsql/init_users.sql 
 * 
 * Create users table 
 */
CREATE TABLE users(
  email    text primary key check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512),
  role     name not null check (length(role) < 512)
);
```

In the `pgrest.yml` amend the `volumes` section:

```yml
    environment:
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
      - ./initsql/init_db.sql:/docker-entrypoint-initdb.d/init01.sql
      - ./initsql/init_users.sql:/docker-entrypoint-initdb.d/init02.sql
```

**N.B.** the names of the files don't have to match, but the important thing is that within the container the files will be run in alphabetical order. Therefore, applying a numbering system may work best to visually identify which order they are applied.

It may be possible to mount the folder as a whole, but I've not tried that.


## Services

| Service | Address | Desc |
| :------ | :--: | :--- |
| db | http://localhost:5432/ | PostgreSQL database called DB |
| adminer | http://localhost:8888 | Database management tool |
| pgrest | http://localhost:4000 | Port for this service is set using `.env` file (`PGRST_SERVER_PORT`) |
| authpoint | http://localhost:8080 | Auth service for generating JWT to use against PGRest. POST username and password to `/login` |

