-- ============================================================================
--  loonybin_schema.sql  —  STARTER MySQL schema for a self-hosted Loonybin/Altis Life
--  backend (the missing life_server.pbo + extDB3 target DB).
--
--  STATUS: INFERRED, NOT the original Loonybin schema (that ships inside the
--  proprietary life_server.pbo, which is NOT in the deobfuscated mission).
--  Column set for `players` is anchored to the confirmed client save/load map
--  in core/session/fn_ClupdateRequest.sqf + fn_ClupdatePartial.sqf (slots 0-24).
--  Other tables follow the standard Tonic Altis Life layout + Loonybin extras
--  implied by the TON_fnc_* names (see SERVER_CONTRACT.md).
--
--  Array/struct columns are stored as SQF-array TEXT (how Altis Life persists
--  them via extDB3), e.g. "[1,0,1,0]". Adjust types to taste.
--
--  Engine: MySQL 5.7+/MariaDB. Created DB name `loonybin` to match the
--  `loonybin_*` references + EXTDB3 config the client expects.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `loonybin`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `loonybin`;

-- ----------------------------------------------------------------------------
-- players  (DB_fnc_insertRequest / queryRequest / updateRequest / updatePartial)
--   slot map from fn_ClupdatePartial.sqf:
--   0 cash | 1 bankacc | 2 licenses | 3/17 gear | 4 side_talents+exp | 5 arrested
--   6 cash+bank | 7 achievements | 8 crimes | 9 stats[17] | 10 position
--   14 honor exp+talents | 15 prefix | 16 prestige+cop_talents | 18 blood_money
--   19 title | 20 quests(completed+progress) | 21 gov_data | 22 infamy exp+talents
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `players` (
  `id`              INT(11)      NOT NULL AUTO_INCREMENT,
  `pid`             VARCHAR(17)  NOT NULL,                 -- BattlEye/Steam UID (getPlayerUID)
  `name`            VARCHAR(64)  NOT NULL DEFAULT 'Error',
  `cash`            BIGINT(20)   NOT NULL DEFAULT 0,        -- slot 0  life_cash (on hand)
  `bankacc`         BIGINT(20)   NOT NULL DEFAULT 0,        -- slot 1  life_atmcash (bank)
  `blood_money`     BIGINT(20)   NOT NULL DEFAULT 0,        -- slot 18 life_bloodMoney
  `adminlevel`      TINYINT(1)   NOT NULL DEFAULT 0,
  `donorlevel`      TINYINT(1)   NOT NULL DEFAULT 0,
  `arrested`        TEXT,                                   -- slot 5  life_is_arrested array
  -- licenses (slot 2 = combined licenses array; split per side here)
  `civ_licenses`    TEXT,
  `cop_licenses`    TEXT,
  `med_licenses`    TEXT,
  `reb_licenses`    TEXT,
  -- gear (slots 3 / 17 = life_gear, per active side)
  `civ_gear`        TEXT,
  `cop_gear`        TEXT,
  `med_gear`        TEXT,
  -- talents / progression (Loonybin: per-track exp + spent-talent arrays)
  `side_talents`    TEXT,                                   -- slot 4  life_side_talents
  `side_exp`        TEXT,                                   -- slot 4  life_side_exp
  `cop_talents`     TEXT,                                   -- slot 16 life_cop_talents
  `prestige`        TEXT,                                   -- slot 16 life_prestige
  `honor_exp`       BIGINT(20)   NOT NULL DEFAULT 0,        -- slot 14 life_honor_exp
  `honor_talents`   TEXT,                                   -- slot 14 life_honor_talents
  `infamy_exp`      BIGINT(20)   NOT NULL DEFAULT 0,        -- slot 22 life_infamy_exp
  `infamy_talents`  TEXT,                                   -- slot 22 life_infamy_talents
  -- identity / cosmetics
  `title`           VARCHAR(64),                            -- slot 19 ga_title
  `prefix`          VARCHAR(32),                            -- slot 15 ga_prefix
  `achievements`    TEXT,                                   -- slot 7  life_achievements
  -- crime / wanted snapshot on player (authoritative wanted list = `wanted`)
  `crimes`          TEXT,                                   -- slot 8  A_stats_crimes
  -- stats[17] (slot 9): warKills,warDeaths,warRating,copArrests,civArrests,
  --   warPoints,apbEvades,civKills,civDeaths,civRevives,civExecutes,civTime,
  --   copLethals,copDeaths,copTime,medTime,medRevives
  `stats`           TEXT,
  -- quests (slot 20)
  `completed_quests` TEXT,
  `progress_quests`  TEXT,
  -- government (slot 21 life_govClientData)
  `gov_data`        TEXT,
  `gang_id`         INT(11)               DEFAULT NULL,
  `position`        TEXT,                                   -- slot 10 life_ses_last_pos
  `playtime`        TEXT,
  `insert_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pid` (`pid`),
  KEY `gang_id` (`gang_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- vehicles  (getVehicles, vehicleCreate, vehicleStore, vehicleDelete,
--            vehicleDead, vehicleSetActive, srvSellVehicle, vehOwnerSwap,
--            updateVehicleMods, vehicleRepairSRV, garageCount, vehAddAlarm)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id`            INT(11)     NOT NULL AUTO_INCREMENT,
  `side`          VARCHAR(16) NOT NULL,                     -- civ/cop/med/reb
  `classname`     VARCHAR(64) NOT NULL,
  `type`          VARCHAR(16) NOT NULL DEFAULT 'Car',       -- Car/Air/Ship
  `pid`           VARCHAR(17) NOT NULL,                     -- owner UID
  `alive`         TINYINT(1)  NOT NULL DEFAULT 1,           -- vehicleDead flips this
  `active`        TINYINT(1)  NOT NULL DEFAULT 0,           -- spawned vs garaged
  `plate`         INT(11)     NOT NULL DEFAULT 0,
  `color`         INT(11)     NOT NULL DEFAULT 0,
  `inventory`     TEXT,                                     -- trunk virtual items
  `gear`          TEXT,
  `fuel`          DOUBLE      NOT NULL DEFAULT 1,
  `damage`        DOUBLE      NOT NULL DEFAULT 0,
  `mods`          TEXT,                                     -- updateVehicleMods
  `alarm`         TINYINT(1)  NOT NULL DEFAULT 0,           -- vehAddAlarm
  `gang_id`       INT(11)              DEFAULT NULL,
  `insert_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `pid` (`pid`),
  KEY `gang_id` (`gang_id`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- houses  (addHouse, transferHouse, srvSellHouse, updateHousePrice,
--          updateProperty, initHouseInventory, updateHouseTrunk, houseTaxSRV,
--          bldgUpdateKeys, keyManagement, repairBuildingSRV)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `houses` (
  `id`            INT(11)     NOT NULL AUTO_INCREMENT,
  `pid`           VARCHAR(17) NOT NULL,                     -- owner UID
  `pos`           VARCHAR(64) NOT NULL,                     -- "x,y,z" map key
  `owned`         TINYINT(1)  NOT NULL DEFAULT 1,
  `inventory`     TEXT,                                     -- trunk/virtual storage
  `containers`    TEXT,                                     -- placed crates/tents
  `keyholders`    TEXT,                                     -- bldgUpdateKeys/keyManagement
  `spare_keys`    INT(11)     NOT NULL DEFAULT 0,           -- updateProperty "spareKey"
  `price`         BIGINT(20)  NOT NULL DEFAULT 0,           -- updateHousePrice
  `tax_due`       DATETIME             DEFAULT NULL,        -- houseTaxSRV
  `gang_id`       INT(11)              DEFAULT NULL,        -- gang house (addGangHouse)
  `insert_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pos` (`pos`),
  KEY `pid` (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- gangs  (insertGang, removeGang, getGangInfo, updateGangMem, gangBank,
--         gangBHistory, setGangTagSRV, transferGangOwnerSRV, update1GangTalents,
--         updateWar, addGangHouse/changeGangHouseSRV/removeGangHouseSRV)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gangs` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `owner`         VARCHAR(17)  NOT NULL,                    -- leader UID
  `name`          VARCHAR(32)  NOT NULL,
  `tag`           VARCHAR(8),                               -- setGangTagSRV
  `members`       TEXT,                                     -- updateGangMem [uid,name,rank]
  `ranks`         TEXT,
  `bank`          BIGINT(20)   NOT NULL DEFAULT 0,          -- gangBank
  `bank_history`  TEXT,                                     -- gangBHistory
  `talents`       TEXT,                                     -- update1GangTalents
  `war_data`      TEXT,                                     -- updateWar
  `max_members`   INT(11)      NOT NULL DEFAULT 10,
  `active`        TINYINT(1)   NOT NULL DEFAULT 1,
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- gang_vehicles  (gangGarageAddSRV, gangGarageCount, gangGarageGetVehicles,
--                 gangGarageSetActive, gangGarageStore)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gang_vehicles` (
  `id`            INT(11)     NOT NULL AUTO_INCREMENT,
  `gang_id`       INT(11)     NOT NULL,
  `classname`     VARCHAR(64) NOT NULL,
  `type`          VARCHAR(16) NOT NULL DEFAULT 'Car',
  `added_by`      VARCHAR(17) NOT NULL,
  `active`        TINYINT(1)  NOT NULL DEFAULT 0,
  `plate`         INT(11)     NOT NULL DEFAULT 0,
  `inventory`     TEXT,
  `fuel`          DOUBLE      NOT NULL DEFAULT 1,
  `damage`        DOUBLE      NOT NULL DEFAULT 0,
  `mods`          TEXT,
  `insert_time`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `gang_id` (`gang_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- wanted  (wantedAdd, wantedFetch, wantedRemove, wantedRemoveCharge,
--          wantedPardon, wantedBounty)  — authoritative live wanted list
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `wanted` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `wantedID`      VARCHAR(17)  NOT NULL,                    -- target UID
  `wantedName`    VARCHAR(64)  NOT NULL,
  `wantedCrimes`  TEXT,                                     -- array of charge IDs
  `wantedBounty`  BIGINT(20)   NOT NULL DEFAULT 0,
  `active`        TINYINT(1)   NOT NULL DEFAULT 1,
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wantedID` (`wantedID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- bounties  (srvPersistentBounties)  — persistent player-placed bounties
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bounties` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `target_uid`    VARCHAR(17)  NOT NULL,
  `target_name`   VARCHAR(64)  NOT NULL,
  `amount`        BIGINT(20)   NOT NULL DEFAULT 0,
  `placed_by`     VARCHAR(17),
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `target_uid` (`target_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- mailbox  (processMailbox, handlePhoneMsg, handleWireTransfer)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mailbox` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `recipient`     VARCHAR(17)  NOT NULL,                    -- UID
  `sender`        VARCHAR(64),
  `type`          VARCHAR(16)  NOT NULL DEFAULT 'msg',      -- msg / wire / system
  `body`          TEXT,
  `amount`        BIGINT(20)   NOT NULL DEFAULT 0,          -- for wire transfers
  `read`          TINYINT(1)   NOT NULL DEFAULT 0,
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `recipient` (`recipient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- loadouts  (fetchLoadouts, handleLoadouts, domFetchLoadouts, domHandleLoadouts)
--   `mode` separates normal vs domination loadouts.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `loadouts` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `pid`           VARCHAR(17)  NOT NULL,
  `mode`          VARCHAR(16)  NOT NULL DEFAULT 'normal',   -- normal / domination
  `slot`          INT(11)      NOT NULL DEFAULT 0,
  `name`          VARCHAR(64),
  `gear`          TEXT,
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `pid_mode` (`pid`,`mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- exchange_market  (exchangeSystemSRV)  — player commodity exchange listings
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `exchange_market` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `seller`        VARCHAR(17)  NOT NULL,
  `item`          VARCHAR(64)  NOT NULL,
  `qty`           INT(11)      NOT NULL DEFAULT 0,
  `price`         BIGINT(20)   NOT NULL DEFAULT 0,
  `insert_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `item` (`item`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- NOTE: many TON_fnc_* are transient/in-memory (events, domination, cartels,
-- robberies, dispatch, weather, timers) and need NO table — they coordinate
-- live server state, not persistence. See SERVER_CONTRACT.md for the full list.
-- ============================================================================
