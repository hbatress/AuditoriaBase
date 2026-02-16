#!/bin/bash
set -e

# ============================================
# CONFIGURACIÓN DE LOGGING
# ============================================
LOG_DIR="/var/log/postgresql"
LOG_FILE="$LOG_DIR/creacion_usuarios_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

separador() {
    log "=================================================="
}

separador
log "INICIANDO CREACIÓN DE USUARIOS Y PERMISOS"
log "Archivo de log: $LOG_FILE"
separador

# ============================================
# CARGA DE VARIABLES DE ENTORNO
# ============================================
log "Cargando variables de entorno..."
ENV_FILE="/docker-entrypoint-initdb.d/.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
    log "Archivo .env cargado correctamente"
else
    log "ERROR: Archivo .env no encontrado"
    exit 1
fi

# ============================================
# VERIFICACIÓN DE VARIABLES
# ============================================
log "Verificando variables requeridas..."
required_vars=(
    POSTGRES_ADMIN_USER POSTGRES_ADMIN_PASSWORD
    POSTGRES_READ_USER POSTGRES_READ_PASSWORD
    POSTGRES_OPER_USER POSTGRES_OPER_PASSWORD
    POSTGRES_REPORT_USER POSTGRES_REPORT_PASSWORD
    POSTGRES_BACKUP_USER POSTGRES_BACKUP_PASSWORD
    POSTGRES_DEV_USER POSTGRES_DEV_PASSWORD
    POSTGRES_EXT_USER POSTGRES_EXT_PASSWORD
    POSTGRES_ETL_USER POSTGRES_ETL_PASSWORD
    POSTGRES_SUPPORT_USER POSTGRES_SUPPORT_PASSWORD
    POSTGRES_FIN_USER POSTGRES_FIN_PASSWORD
)
variables_ok=true
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "ERROR: Variable $var no definida"
        variables_ok=false
    else
        log "Variable $var = ${!var:0:3}... (oculta)"
    fi
done

if [ "$variables_ok" = false ]; then
    log "ERROR: Faltan variables requeridas. Abortando"
    exit 1
fi
log "Todas las variables requeridas están definidas"
separador

# ============================================
# CREACIÓN DE USUARIOS EN POSTGRESQL
# ============================================
log "Creando usuarios en PostgreSQL..."
separador

SQL_OUTPUT=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" 2>&1 <<EOSQL
BEGIN;

CREATE OR REPLACE FUNCTION crear_usuario_si_no_existe(nombre_usuario TEXT, password_usuario TEXT)
RETURNS VOID AS \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = nombre_usuario) THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', nombre_usuario, password_usuario);
        RAISE NOTICE 'Usuario % creado exitosamente', nombre_usuario;
    ELSE
        RAISE NOTICE 'Usuario % ya existe', nombre_usuario;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

-- 1. Administrador
SELECT crear_usuario_si_no_existe('$POSTGRES_ADMIN_USER', '$POSTGRES_ADMIN_PASSWORD');
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO "$POSTGRES_ADMIN_USER";
GRANT ALL PRIVILEGES ON SCHEMA public TO "$POSTGRES_ADMIN_USER";

-- 2. Solo lectura
SELECT crear_usuario_si_no_existe('$POSTGRES_READ_USER', '$POSTGRES_READ_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_READ_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_READ_USER";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "$POSTGRES_READ_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "$POSTGRES_READ_USER";

-- 3. Operativo
SELECT crear_usuario_si_no_existe('$POSTGRES_OPER_USER', '$POSTGRES_OPER_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_OPER_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_OPER_USER";
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO "$POSTGRES_OPER_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO "$POSTGRES_OPER_USER";

-- 4. Reportes
SELECT crear_usuario_si_no_existe('$POSTGRES_REPORT_USER', '$POSTGRES_REPORT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_REPORT_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_REPORT_USER";

-- 5. Backup
SELECT crear_usuario_si_no_existe('$POSTGRES_BACKUP_USER', '$POSTGRES_BACKUP_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_BACKUP_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_BACKUP_USER";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "$POSTGRES_BACKUP_USER";

-- 6. Desarrollador
SELECT crear_usuario_si_no_existe('$POSTGRES_DEV_USER', '$POSTGRES_DEV_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_DEV_USER";
GRANT USAGE, CREATE ON SCHEMA public TO "$POSTGRES_DEV_USER";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "$POSTGRES_DEV_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "$POSTGRES_DEV_USER";

-- 7. Externo
SELECT crear_usuario_si_no_existe('$POSTGRES_EXT_USER', '$POSTGRES_EXT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_EXT_USER";

-- 8. ETL
SELECT crear_usuario_si_no_existe('$POSTGRES_ETL_USER', '$POSTGRES_ETL_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_ETL_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_ETL_USER";
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO "$POSTGRES_ETL_USER";

-- 9. Soporte
SELECT crear_usuario_si_no_existe('$POSTGRES_SUPPORT_USER', '$POSTGRES_SUPPORT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_SUPPORT_USER";
GRANT USAGE ON SCHEMA public TO "$POSTGRES_SUPPORT_USER";
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA public TO "$POSTGRES_SUPPORT_USER";

-- 10. Finanzas
SELECT crear_usuario_si_no_existe('$POSTGRES_FIN_USER', '$POSTGRES_FIN_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO "$POSTGRES_FIN_USER";

DROP FUNCTION crear_usuario_si_no_existe(TEXT, TEXT);

COMMIT;

SELECT usename AS usuario, usesuper AS superusuario, usecreatedb AS crea_db
FROM pg_user
WHERE usename NOT LIKE 'pg_%'
ORDER BY usename;

EOSQL
)

SQL_EXIT_CODE=$?

# ============================================
# PROCESAMIENTO DEL RESULTADO
# ============================================
if [ $SQL_EXIT_CODE -eq 0 ]; then
    log "Script SQL ejecutado correctamente"
    separador
    log "RESULTADOS DE POSTGRESQL:"
    echo "$SQL_OUTPUT" | while IFS= read -r line; do
        log " $line"
    done
    separador
    log "CREACIÓN DE USUARIOS COMPLETADA EXITOSAMENTE"
else
    log "ERROR: Falló la ejecución del script SQL (código: $SQL_EXIT_CODE)"
    echo "$SQL_OUTPUT" | while IFS= read -r line; do
        log "  $line"
    done
    exit 1
fi

separador
log "Log completo en: $LOG_FILE"
separador

