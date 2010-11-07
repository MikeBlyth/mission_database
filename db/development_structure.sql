CREATE TABLE `bloodtypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `abo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rh` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `full` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_bloodtypes_on_full` (`full`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cities` (
  `id` int(11) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'NG',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contact_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_contact_types_on_code` (`code`),
  UNIQUE KEY `index_contact_types_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_type_id` int(11) NOT NULL DEFAULT '0',
  `contact_name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `email_1` varchar(40) DEFAULT NULL,
  `email_2` varchar(40) DEFAULT NULL,
  `phone_1` varchar(15) DEFAULT NULL,
  `phone_2` varchar(15) DEFAULT NULL,
  `blog` varchar(100) DEFAULT NULL COMMENT 'Main website or blog (blog preferred)',
  `other_website` varchar(100) DEFAULT NULL COMMENT 'second website or blog',
  `skype` varchar(20) DEFAULT NULL COMMENT 'Skype name',
  `facebook` varchar(60) DEFAULT NULL COMMENT 'Facebook URL',
  `photos` varchar(50) DEFAULT '' COMMENT 'URL where person shares photos',
  `email_public` tinyint(1) DEFAULT '0' COMMENT 'Is the person''s email public?',
  `phone_public` tinyint(1) DEFAULT '0' COMMENT 'Are the person''s phone numbers public?',
  `skype_public` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `member_id` int(11) NOT NULL COMMENT 'Link to member',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ID` (`id`),
  KEY `member_id` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=852 DEFAULT CHARSET=utf8;

CREATE TABLE `contacts_sample` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `email1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `blog` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photosite` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `facebook` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contact_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contact_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nationality` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `include_in_selection` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_countries_on_code` (`code`),
  UNIQUE KEY `index_countries_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=263 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `educations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_education_codes_on_code` (`code`),
  UNIQUE KEY `index_education_codes_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `employment_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_employment_status_codes_on_code` (`code`),
  UNIQUE KEY `index_employment_status_codes_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `family_ids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `family` varchar(255) DEFAULT NULL,
  `father_id` int(11) DEFAULT NULL,
  `nationality` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8;

CREATE TABLE `home_address` (
  `ID` int(5) unsigned zerofill NOT NULL COMMENT 'ID key',
  `SIM ID` varchar(6) DEFAULT NULL,
  `home_address` varchar(255) DEFAULT NULL,
  `field_address` varchar(255) DEFAULT NULL,
  `HLINE1` varchar(30) DEFAULT NULL,
  `HLINE2` varchar(30) DEFAULT NULL,
  `HCITY` varchar(22) DEFAULT NULL,
  `HSTATE` varchar(3) DEFAULT NULL,
  `SM` varchar(30) DEFAULT NULL,
  `HPOST` varchar(10) DEFAULT NULL,
  `HCTRY` varchar(3) DEFAULT NULL,
  `CM` varchar(25) DEFAULT NULL,
  `FLINE1` varchar(30) DEFAULT NULL,
  `FCITY` varchar(22) DEFAULT NULL,
  `FSTATE` varchar(3) DEFAULT NULL,
  `FSM` varchar(30) DEFAULT NULL,
  `FPOST` varchar(10) DEFAULT NULL,
  `FCTRY` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `AddressMdNUMBER` (`SIM ID`),
  CONSTRAINT `fk_id` FOREIGN KEY (`ID`) REFERENCES `names-basic` (`Key`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_locations_on_code` (`code`),
  UNIQUE KEY `index_locations_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sex` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `family_id` int(11) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `spouse_id` int(11) DEFAULT NULL,
  `country_id` int(11) NOT NULL COMMENT 'references countries table',
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bloodtype_id` int(11) DEFAULT NULL COMMENT 'References bloodtypes table',
  `allergies` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `medical_facts` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Basic, important medical facts such as diabetes, seizures',
  `medications` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Special medications such as insulin',
  `status_id` int(11) DEFAULT NULL,
  `ministry_comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `qualifications` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_active` date DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `education_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `employment_status_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_bloodtypes` (`bloodtype_id`),
  KEY `fk_countries` (`country_id`),
  CONSTRAINT `fk_bloodtypes` FOREIGN KEY (`bloodtype_id`) REFERENCES `bloodtypes` (`id`),
  CONSTRAINT `fk_countries` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=786 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `ministries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ministry_codes_on_code` (`code`),
  UNIQUE KEY `index_ministry_codes_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `names_basic` (
  `Key` int(11) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `Family ID` varchar(50) DEFAULT NULL COMMENT 'Usually same as family name',
  `family_id` int(11) DEFAULT NULL,
  `Last Name` varchar(20) DEFAULT NULL COMMENT 'Actual family name',
  `First Name` varchar(20) DEFAULT NULL,
  `Casual Name` varchar(50) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `Nationality_id` int(11) DEFAULT NULL,
  `Nationality Code` varchar(3) DEFAULT NULL,
  `Ministry` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Key`),
  UNIQUE KEY `Key_or_ID` (`Key`),
  KEY `Family ID` (`Family ID`)
) ENGINE=InnoDB AUTO_INCREMENT=786 DEFAULT CHARSET=latin1;

CREATE TABLE `personnel` (
  `Key` int(11) unsigned zerofill NOT NULL,
  `StatusCode` char(1) DEFAULT NULL COMMENT 'On field, on leave, etc. Matches on StatusCodes table.',
  `MinistryCode` smallint(5) unsigned DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `MinistryComment` varchar(100) DEFAULT NULL COMMENT 'Further specify or explain ministry position',
  `education_id` int(11) DEFAULT NULL,
  `EducationCode` smallint(6) DEFAULT NULL,
  `QUALIFICAT` varchar(40) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `LocationCode` int(10) unsigned DEFAULT NULL,
  `BIRTHDAY` date DEFAULT NULL,
  `BLOODTYPE` varchar(3) DEFAULT NULL,
  `bloodtype_id` int(11) DEFAULT NULL,
  `miss_status_id` int(11) DEFAULT NULL,
  `Missionary Status Code` varchar(3) DEFAULT NULL,
  `DATEACTIVE` date DEFAULT NULL,
  `TERMLEN` double DEFAULT NULL,
  `NEXT` date DEFAULT NULL,
  `Departure Date` date DEFAULT NULL,
  `DATEARRIVE` date DEFAULT NULL,
  `DATEEMPLOY` date DEFAULT NULL,
  `MODIFIED` date DEFAULT NULL,
  `Term Status` varchar(50) DEFAULT NULL,
  `ONLEAVE` tinyint(4) DEFAULT NULL,
  `statuscode_i` int(11) DEFAULT NULL,
  PRIMARY KEY (`Key`),
  CONSTRAINT `fk_pers_mbr` FOREIGN KEY (`Key`) REFERENCES `names_basic` (`Key`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `personnel_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_code_id` int(11) DEFAULT NULL,
  `ministry_comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `qualifications` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_active` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `education_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `employment_status_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=786 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `position_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_states_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `on_field` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_status_codes_on_code` (`code`),
  UNIQUE KEY `index_status_codes_on_description` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `travels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `purpose` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `return_date` date DEFAULT NULL,
  `flight` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `origin` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `destination` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `guesthouse` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `baggage` int(11) DEFAULT NULL,
  `extra_passengers` int(11) DEFAULT NULL,
  `confirmed` date DEFAULT NULL,
  `other_travelers` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `with_spouse` tinyint(1) DEFAULT NULL,
  `with_children` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `password_salt` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `wives` (
  `family_id` int(11) NOT NULL DEFAULT '0',
  `lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Husband` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `Wife` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Wife_id` int(11) NOT NULL DEFAULT '0',
  `StatusCode` char(1) CHARACTER SET latin1 DEFAULT NULL COMMENT 'On field, on leave, etc. Matches on StatusCodes table.',
  `MinistryCode` smallint(5) unsigned DEFAULT NULL,
  `BIRTHDAY` date DEFAULT NULL,
  `miss_status_id` int(11) DEFAULT NULL,
  `Missionary Status Code` varchar(3) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`family_id`),
  UNIQUE KEY `WifeIndex` (`Wife_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20100914220049');

INSERT INTO schema_migrations (version) VALUES ('20100915183138');

INSERT INTO schema_migrations (version) VALUES ('20100915220552');

INSERT INTO schema_migrations (version) VALUES ('20100916073111');

INSERT INTO schema_migrations (version) VALUES ('20100916110504');

INSERT INTO schema_migrations (version) VALUES ('20100916122720');

INSERT INTO schema_migrations (version) VALUES ('20100916132530');

INSERT INTO schema_migrations (version) VALUES ('20100916134551');

INSERT INTO schema_migrations (version) VALUES ('20100916134708');

INSERT INTO schema_migrations (version) VALUES ('20100916135304');

INSERT INTO schema_migrations (version) VALUES ('20100916141220');

INSERT INTO schema_migrations (version) VALUES ('20100916153708');

INSERT INTO schema_migrations (version) VALUES ('20100916191309');

INSERT INTO schema_migrations (version) VALUES ('20100917092855');

INSERT INTO schema_migrations (version) VALUES ('20100917133442');

INSERT INTO schema_migrations (version) VALUES ('20100917133619');

INSERT INTO schema_migrations (version) VALUES ('20100917133807');

INSERT INTO schema_migrations (version) VALUES ('20100917133852');

INSERT INTO schema_migrations (version) VALUES ('20100917134046');

INSERT INTO schema_migrations (version) VALUES ('20100918110003');

INSERT INTO schema_migrations (version) VALUES ('20100918130027');

INSERT INTO schema_migrations (version) VALUES ('20100918130434');

INSERT INTO schema_migrations (version) VALUES ('20100918140132');

INSERT INTO schema_migrations (version) VALUES ('20100918141427');

INSERT INTO schema_migrations (version) VALUES ('20100918185522');

INSERT INTO schema_migrations (version) VALUES ('20100919081525');

INSERT INTO schema_migrations (version) VALUES ('20100919084122');

INSERT INTO schema_migrations (version) VALUES ('20100920223754');

INSERT INTO schema_migrations (version) VALUES ('20100921185625');

INSERT INTO schema_migrations (version) VALUES ('20100922141233');

INSERT INTO schema_migrations (version) VALUES ('20100924193606');

INSERT INTO schema_migrations (version) VALUES ('20100925145933');

INSERT INTO schema_migrations (version) VALUES ('20100928093704');

INSERT INTO schema_migrations (version) VALUES ('20100928093838');

INSERT INTO schema_migrations (version) VALUES ('20100928094528');

INSERT INTO schema_migrations (version) VALUES ('20100928120249');

INSERT INTO schema_migrations (version) VALUES ('20100929121030');

INSERT INTO schema_migrations (version) VALUES ('20101004183229');

INSERT INTO schema_migrations (version) VALUES ('20101005092520');

INSERT INTO schema_migrations (version) VALUES ('20101005101123');

INSERT INTO schema_migrations (version) VALUES ('20101006211818');

INSERT INTO schema_migrations (version) VALUES ('20101008141734');

INSERT INTO schema_migrations (version) VALUES ('20101008204155');

INSERT INTO schema_migrations (version) VALUES ('20101008211347');

INSERT INTO schema_migrations (version) VALUES ('20101011063650');

INSERT INTO schema_migrations (version) VALUES ('20101011081923');

INSERT INTO schema_migrations (version) VALUES ('20101011093507');

INSERT INTO schema_migrations (version) VALUES ('20101011132332');