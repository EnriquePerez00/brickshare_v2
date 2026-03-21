-- Rename remaining Spanish column names to English
-- Table: users_correos_dropping (Correos PUDO integration)

-- correos_ prefix is kept as it refers to the "Correos" brand (proper noun)
-- but the descriptive parts are translated to English

ALTER TABLE users_correos_dropping RENAME COLUMN correos_nombre TO correos_name;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_tipo_punto TO correos_point_type;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_calle TO correos_street;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_numero TO correos_street_number;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_postal TO correos_zip_code;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_ciudad TO correos_city;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_provincia TO correos_province;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_pais TO correos_country;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_completa TO correos_full_address;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_latitud TO correos_latitude;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_longitud TO correos_longitude;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_apertura TO correos_opening_hours;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_estructurado TO correos_structured_hours;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_disponible TO correos_available;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_telefono TO correos_phone;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_interno TO correos_internal_code;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_capacidad_lockers TO correos_locker_capacity;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_servicios_adicionales TO correos_additional_services;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_accesibilidad TO correos_accessibility;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_fecha_seleccion TO correos_selection_date;

-- Rename old foreign key constraints that still reference old Spanish table names
DO $$
BEGIN
  -- inventory_sets: rename old FK if it exists with old name
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'inventario_sets_set_id_fkey') THEN
    ALTER TABLE inventory_sets RENAME CONSTRAINT inventario_sets_set_id_fkey TO inventory_sets_set_id_fkey;
  END IF;
END $$;