/*
 Navicat MySQL Data Transfer

 Source Server         : localhost
 Source Server Version : 50612
 Source Host           : localhost
 Source Database       : wanalytic

 Target Server Version : 50612
 File Encoding         : utf-8

 Date: 07/01/2013 16:27:23 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `sites`
-- ----------------------------
DROP TABLE IF EXISTS `sites`;
CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `stats`
-- ----------------------------
DROP TABLE IF EXISTS `stats`;
CREATE TABLE `stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` bigint(11) NOT NULL,
  `type` varchar(200) NOT NULL,
  `classification` int(11) NOT NULL,
  `metric` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `value` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;
