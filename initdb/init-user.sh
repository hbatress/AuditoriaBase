#!/bin/bash
set -e

# ============================================
# CONFIGURACIÓN DE LOGGING
# ============================================
LOG_DIR="/var/log/postgresql"
LOG_FILE="$LOG_DIR/creacion_usuarios_$(date +%Y%m%d_%H%M%S).log"
mkdir -p $LOG_DIR

# Función para logging (muestra en pantalla y guarda en archivo)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función para separadores visuales
separador() {
    log "=================================================="
}

# Inicio del script
separador
log "INICIANDO CREACIÓN DE USUARIOS Y PERMISOS"
log "Archivo de log: $LOG_FILE"
separador

# ============================================
# CARGA DE VARIABLES DE ENTORNO
# ============================================
log "Cargando variables de entorno..."

if [ -f /docker-entrypoint-initdb.d/.env ]; then
    set -a
    source /docker-entrypoint-initdb.d/.env
    set +a
    log " Archivo .env cargado correctamente"
else
    log " ERROR: Archivo .env no encontrado en /docker-entrypoint-initdb.d/.env"
    exit 1
fi

# ============================================
# VERIFICACIÓN DE VARIABLES REQUERIDAS
# ============================================
log "Verificando variables de entorno..."

required_vars=(
    "POSTGRES_ADMIN_USER" "POSTGRES_ADMIN_PASSWORD"
    "POSTGRES_READ_USER" "POSTGRES_READ_PASSWORD"
    "POSTGRES_OPER_USER" "POSTGRES_OPER_PASSWORD"
    "POSTGRES_REPORT_USER" "POSTGRES_REPORT_PASSWORD"
    "POSTGRES_BACKUP_USER" "POSTGRES_BACKUP_PASSWORD"
    "POSTGRES_DEV_USER" "POSTGRES_DEV_PASSWORD"
    "POSTGRES_EXT_USER" "POSTGRES_EXT_PASSWORD"
    "POSTGRES_ETL_USER" "POSTGRES_ETL_PASSWORD"
    "POSTGRES_SUPPORT_USER" "POSTGRES_SUPPORT_PASSWORD"
    "POSTGRES_FIN_USER" "POSTGRES_FIN_PASSWORD"
)

variables_ok=true
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log " ERROR: Variable $var no está definida"
        variables_ok=false
    else
        log " Variable $var = ${!var:0:3}... (oculta)"
    fi
done

if [ "$variables_ok" = false ]; then
    log " ERROR: Faltan variables requeridas. Abortando."
    exit 1
fi

log " Todas las variables requeridas están definidas"
separador

# ============================================
# CREACIÓN DE USUARIOS EN POSTGRESQL
# ============================================
log "Conectando a PostgreSQL y creando usuarios..."
log "Base de datos: $POSTGRES_DB"
log "Usuario admin: $POSTGRES_USER"
separador

# Ejecutar script SQL y capturar salida
SQL_OUTPUT=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL 2>&1)
BEGIN;

-- Función para crear usuario si no existe
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
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_ADMIN_USER;
GRANT ALL PRIVILEGES ON SCHEMA public TO $POSTGRES_ADMIN_USER;

-- 2. Solo Lectura
SELECT crear_usuario_si_no_existe('$POSTGRES_READ_USER', '$POSTGRES_READ_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_READ_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_READ_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $POSTGRES_READ_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $POSTGRES_READ_USER;

-- 3. Operativo
SELECT crear_usuario_si_no_existe('$POSTGRES_OPER_USER', '$POSTGRES_OPER_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_OPER_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_OPER_USER;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO $POSTGRES_OPER_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO $POSTGRES_OPER_USER;

-- 4. Reportes
SELECT crear_usuario_si_no_existe('$POSTGRES_REPORT_USER', '$POSTGRES_REPORT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_REPORT_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_REPORT_USER;

-- 5. Backup
SELECT crear_usuario_si_no_existe('$POSTGRES_BACKUP_USER', '$POSTGRES_BACKUP_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_BACKUP_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_BACKUP_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $POSTGRES_BACKUP_USER;

-- 6. Desarrollador
SELECT crear_usuario_si_no_existe('$POSTGRES_DEV_USER', '$POSTGRES_DEV_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_DEV_USER;
GRANT USAGE, CREATE ON SCHEMA public TO $POSTGRES_DEV_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $POSTGRES_DEV_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $POSTGRES_DEV_USER;

-- 7. Externo
SELECT crear_usuario_si_no_existe('$POSTGRES_EXT_USER', '$POSTGRES_EXT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_EXT_USER;

-- 8. ETL
SELECT crear_usuario_si_no_existe('$POSTGRES_ETL_USER', '$POSTGRES_ETL_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_ETL_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_ETL_USER;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO $POSTGRES_ETL_USER;

-- 9. Soporte
SELECT crear_usuario_si_no_existe('$POSTGRES_SUPPORT_USER', '$POSTGRES_SUPPORT_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_SUPPORT_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_SUPPORT_USER;
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA public TO $POSTGRES_SUPPORT_USER;

-- 10. Finanzas
SELECT crear_usuario_si_no_existe('$POSTGRES_FIN_USER', '$POSTGRES_FIN_PASSWORD');
GRANT CONNECT ON DATABASE $POSTGRES_DB TO $POSTGRES_FIN_USER;
GRANT USAGE ON SCHEMA public TO $POSTGRES_FIN_USER;

-- Limpiar función temporal
DROP FUNCTION crear_usuario_si_no_existe(TEXT, TEXT);

COMMIT;

-- Mostrar usuarios creados
SELECT
    usename as usuario,
    usesuper as superusuario,
    usecreatedb as crea_db
FROM pg_user
WHERE usename NOT LIKE 'pg_%'
ORDER BY usename;

EOSQL

SQL_EXIT_CODE=$?

# ============================================
# PROCESAMIENTO DE RESULTADOS
# ============================================
if [ $SQL_EXIT_CODE -eq 0 ]; then
    log " Script SQL ejecutado correctamente"
    separator

    # Extraer y mostrar los resultados del SQL
    log "RESULTADOS DE POSTGRESQL:"
    echo "$SQL_OUTPUT" | while IFS= read -r line; do
        if [[ $line == *"NOTICE:"* ]]; then
            log " $line"
        elif [[ $line == *"usuario"* && $line == *"superusuario"* ]]; then
            log " $line"
        elif [[ ! -z "$line" && $line != *"CREATE FUNCTION"* && $line != *"DROP FUNCTION"* ]]; then
            log "   $line"
        fi
    done

    separator
    log "VERIFICANDO USUARIOS CREADOS..."

    # Lista de usuarios a verificar
    USERS_CREADOS=(
        "$POSTGRES_ADMIN_USER"
        "$POSTGRES_READ_USER"
        "$POSTGRES_OPER_USER"
        "$POSTGRES_REPORT_USER"
        "$POSTGRES_BACKUP_USER"
        "$POSTGRES_DEV_USER"
        "$POSTGRES_EXT_USER"
        "$POSTGRES_ETL_USER"
        "$POSTGRES_SUPPORT_USER"
        "$POSTGRES_FIN_USER"
    )

    # Contador de usuarios creados
    creados=0
    for user in "${USERS_CREADOS[@]}"; do
        # Verificar si el usuario existe
        USER_EXISTS=$(psql -t -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT COUNT(*) FROM pg_user WHERE usename = '$user';" | xargs)
        if [ "$USER_EXISTS" -eq "1" ]; then
            log " Usuario '$user' creado exitosamente"
            ((creados++))

            # Verificar permisos básicos
            CAN_CONNECT=$(psql -t -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT has_database_privilege('$user', '$POSTGRES_DB', 'CONNECT');" | xargs)
            if [ "$CAN_CONNECT" == "t" ]; then
                log "   └─ Permiso CONNECT: "
            else
                log "   └─ Permiso CONNECT: "
            fi
        else
            log " ERROR: Usuario '$user' NO fue creado"
        fi
    done

    separator
    log "RESUMEN FINAL:"
    log " Usuarios creados correctamente: $creados/${#USERS_CREADOS[@]}"

    # Mostrar lista completa de usuarios en la base de datos
    log " Usuarios actuales en PostgreSQL:"
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT usename FROM pg_user WHERE usename NOT LIKE 'pg_%' ORDER BY usename;" | while IFS= read -r line; do
        if [[ $line != *"usename"* && $line != *"row"* && $line != *"----"* && ! -z "$line" ]]; then
            log "   • $line"
        fi
    done

else
    log " ERROR: Falló la ejecución del script SQL (código: $SQL_EXIT_CODE)"
    log "Salida del error:"
    echo "$SQL_OUTPUT" | while IFS= read -r line; do
        log "   ️ $line"
    done
    exit 1
fi

# ============================================
# FINALIZACIÓN
# ============================================
separador
log " CREACIÓN DE USUARIOS COMPLETADA EXITOSAMENTE"
log " Log guardado en: $LOG_FILE"
separador

# Mostrar instrucciones al usuario
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "   LOG COMPLETO DISPONIBLE EN:"
echo "   $LOG_FILE"
echo "═══════════════════════════════════════════════════════════════"
echo "  Para ver el log:"
echo "  docker exec -it postgres_audit cat $LOG_FILE"
echo ""
echo "  Para seguir en tiempo real:"
echo "  docker exec -it postgres_audit tail -f $LOG_FILE"
echo "═══════════════════════════════════════════════════════════════"