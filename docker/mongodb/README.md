# MongoDB

MongoDB NoSQL database server.

## Quick Start

```bash
docker-compose up -d
```

## Default Credentials

- **User:** admin
- **Password:** admin
- **Port:** 27017

## Connection

```bash
# Connect via mongosh
mongosh "mongodb://admin:admin@localhost:27017"

# Connection string
mongodb://admin:admin@localhost:27017

# Connection string with auth database
mongodb://admin:admin@localhost:27017/?authSource=admin
```

## Initialization Scripts

Place `.js` or `.sh` files in the `init/` directory. They will be executed on first container start.

Example `init/01-create-user.js`:
```javascript
db = db.getSiblingDB('myapp');
db.createUser({
  user: 'myuser',
  pwd: 'mypassword',
  roles: [{ role: 'readWrite', db: 'myapp' }]
});
db.createCollection('users');
```

## Data Persistence

Data is stored in the `mongo_data` Docker volume.

## Backup

```bash
# Backup
docker exec mongodb mongodump --uri="mongodb://admin:admin@localhost:27017" --out=/dump
docker cp mongodb:/dump ./backup

# Restore
docker cp ./backup mongodb:/dump
docker exec mongodb mongorestore --uri="mongodb://admin:admin@localhost:27017" /dump
```
