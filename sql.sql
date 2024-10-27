CREATE TABLE IF NOT EXISTS `carwash_clean_vehicles` (
    `plate` VARCHAR(8) NOT NULL,
    `clean_until` BIGINT NOT NULL,
    PRIMARY KEY (`plate`)
);
