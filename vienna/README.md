# Vienna

Vienna is a standalone database migration scripts. Database migration script can be written in Elixir lang. no need to create SQL

## Build

To build this application just simply type
```bash
mix do deps.get, compile && mix release
```

## Running
After build the application you can run the application located in rel folder and must specify the migration folder

```bash
vienna -f /path/to/migration/folder
```

### Running options
- -f / --file : must be located folder
- -s / --step : step of migration. negative means rollback and positive means migrate, default: `all`
- --force : force the migration step

## Migration file
Migration file can check the reference of Ecto
