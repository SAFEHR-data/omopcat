DROP TABLE IF EXISTS @resultsDatabaseSchema.calypso_concepts;
DROP TABLE IF EXISTS @resultsDatabaseSchema.calypso_monthly_counts;
DROP TABLE IF EXISTS @resultsDatabaseSchema.calypso_summary_stats;

CREATE TABLE @resultsDatabaseSchema.calypso_concepts (
    concept_id BIGINT,
    concept_name VARCHAR,
    domain_id VARCHAR,
    vocabulary_id VARCHAR,
    concept_class_id VARCHAR,
    standard_concept VARCHAR,
    concept_code VARCHAR
);

CREATE TABLE @resultsDatabaseSchema.calypso_monthly_counts (
    concept_id BIGINT,
    concept_name VARCHAR,
    date_year INTEGER,
    date_month INTEGER,
    person_count BIGINT,
    records_per_person DOUBLE
);

CREATE TABLE @resultsDatabaseSchema.calypso_summary_stats (
    concept_id BIGINT,
    concept_name VARCHAR,
    summary_attribute VARCHAR,
    value_as_string VARCHAR,
    value_as_number DOUBLE
);
