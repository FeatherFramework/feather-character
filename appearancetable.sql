-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.2.0-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for test
CREATE DATABASE IF NOT EXISTS `test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `test`;

-- Dumping structure for table test.character_appearance
CREATE TABLE IF NOT EXISTS `character_appearance` (
  `id` bigint(20) unsigned NOT NULL,
  `attributes` text DEFAULT '{}',
  `clothing` text DEFAULT '{}',
  `overlays` text DEFAULT '{}',
  `clothingtints` text DEFAULT '{}',
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_character_appearance_characters` FOREIGN KEY (`id`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table test.character_appearance: ~2 rows (approximately)
/*!40000 ALTER TABLE `character_appearance` DISABLE KEYS */;
/*!40000 ALTER TABLE `character_appearance` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
