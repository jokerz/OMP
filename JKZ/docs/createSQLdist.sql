-- MySQL dump 10.11
--

-- ------------------------------------------------------
-- Server version	5.0.51a-modified

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


--
-- Table structure for table `base_ad`
--

DROP TABLE IF EXISTS `base_ad`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `base_ad` (
  `day` tinyint(3) unsigned NOT NULL default '0' COMMENT '日付',
  `hour` tinyint(3) unsigned NOT NULL default '0' COMMENT '時間',
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `adid` int(10) unsigned NOT NULL default '0',
  `kind` tinyint(3) unsigned NOT NULL default '0' COMMENT '集計種別',
  `carrier` tinyint(3) unsigned NOT NULL default '0' COMMENT 'キャリア種別',
  `sex` tinyint(3) unsigned NOT NULL default '0' COMMENT '性別',
  `value` int(10) unsigned default NULL COMMENT '集計値',
  PRIMARY KEY  (`day`,`hour`,`admailno`,`adid`,`kind`,`carrier`,`sex`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ad yyyymmdd のテンプレート';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `base_admailmanage`
--

DROP TABLE IF EXISTS `base_admailmanage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `base_admailmanage` (
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `adid` int(10) unsigned NOT NULL default '0' COMMENT '広告ID',
  `id_no` int(10) unsigned zerofill NOT NULL default '0000000000' COMMENT '会員ID',
  `send_status` tinyint(3) unsigned NOT NULL default '0' COMMENT '送信チェック',
  `accessdate` datetime default NULL COMMENT 'ポイント追加日時',
  `pointdate` datetime default NULL COMMENT 'ポイントを追加した日',
  PRIMARY KEY  (`admailno`,`adid`,`id_no`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='admanage? ?はメール回数 のテンプレート';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `base_adpointmanage`
--

DROP TABLE IF EXISTS `base_adpointmanage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `base_adpointmanage` (
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `adid` int(10) unsigned NOT NULL default '0' COMMENT '広告ID',
  `id_no` int(20) unsigned zerofill NOT NULL default '00000000000000000000' COMMENT '会員ID',
  `accessdate` datetime default NULL COMMENT 'ポイント取得日',
  PRIMARY KEY  (`id_no`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='adpointmanage? ?はメール回数 のテンプレート';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `error_mail`
--

DROP TABLE IF EXISTS `error_mail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `error_mail` (
  `err_id` int(11) NOT NULL auto_increment,
  `error_mailaddr` varbinary(255) NOT NULL default '                                                                                                                                                                                                                                                               ' COMMENT 'エラーメールのアドレス',
  `count` smallint(2) unsigned NOT NULL default '0' COMMENT 'えらーのカウント',
  `date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`err_id`),
  UNIQUE KEY `error_mailaddr` (`error_mailaddr`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAccessLogF`
--

DROP TABLE IF EXISTS `tAccessLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAccessLogF` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `in_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `acd` char(6) NOT NULL default '',
  `carrier` tinyint(3) unsigned NOT NULL,
  `guid` char(30) default NULL,
  `ip` char(15) NOT NULL default '',
  `host` char(100) default NULL,
  `useragent` char(100) NOT NULL default '',
  `referer` char(100) default NULL,
  PRIMARY KEY  (`id`),
  KEY `in_datetime` (`in_datetime`),
  KEY `acd` (`acd`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `tAdcontents`
--

DROP TABLE IF EXISTS `tAdcontents`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdcontents` (
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `carrier` tinyint(3) unsigned NOT NULL default '0' COMMENT 'キャリア種別',
  `subject` varchar(255) default NULL COMMENT '件名',
  `contents` mediumtext COMMENT '送信内容',
  PRIMARY KEY  (`admailno`,`carrier`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='admailnoに対応する件名･本文';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdinfo`
--

DROP TABLE IF EXISTS `tAdinfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdinfo` (
  `adid` int(10) unsigned NOT NULL auto_increment COMMENT '広告ID',
  `adname` varchar(255) default NULL COMMENT '名称',
  `delad` tinyint(3) unsigned default NULL COMMENT '削除済',
  `adlimit` datetime default NULL COMMENT '広告の有効期限',
  `adpoint` int(10) unsigned default NULL COMMENT 'ポイント',
  `pointlimit` datetime default NULL COMMENT 'ポイントプレゼントの有効期限',
  `countdate` datetime default NULL COMMENT '集計カウンタの開始日時',
  `urld` varchar(255) default NULL COMMENT 'アクセス先URL',
  `urlj` varchar(255) default NULL COMMENT 'アクセス先URL',
  `urle` varchar(255) default NULL COMMENT 'アクセス先URL',
  `urlo` varchar(255) default NULL COMMENT 'アクセス先URL',
  PRIMARY KEY  (`adid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='広告一覧';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdmail`
--

DROP TABLE IF EXISTS `tAdmail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdmail` (
  `admailno` int(10) unsigned NOT NULL auto_increment COMMENT 'メール回数',
  `fromaddress` varchar(255) default NULL COMMENT '送信元アドレス',
  `sendmax` int(10) unsigned default NULL COMMENT '送信最大数',
  `senddate` datetime default NULL COMMENT '送信日時',
  `sendend` datetime default NULL COMMENT '送信終了日時',
  `status` tinyint(3) unsigned default NULL COMMENT '送信状態',
  `client` varchar(255) default NULL COMMENT 'クライアント名',
  `presentpoint` int(10) unsigned default NULL COMMENT 'プレゼントポイント',
  `presentlimit` datetime default NULL COMMENT '有効期限',
  `sendd` int(11) NOT NULL default '0' COMMENT 'DoCoMo送信数',
  `sendj` int(11) NOT NULL default '0' COMMENT 'Vodafone送信数',
  `sende` int(11) NOT NULL default '0' COMMENT 'EZweb送信数',
  `sendo` int(11) NOT NULL default '0' COMMENT 'その他送信数',
  `subjectd` varchar(255) default NULL COMMENT '件名',
  `subjectj` varchar(255) default NULL COMMENT '件名',
  `subjecte` varchar(255) default NULL COMMENT '件名',
  `subjecto` varchar(255) default NULL COMMENT '件名',
  `contentsd` mediumtext COMMENT '送信内容',
  `contentsj` mediumtext COMMENT '送信内容',
  `contentse` mediumtext COMMENT '送信内容',
  `contentso` mediumtext COMMENT '送信内容',
  `condition` mediumtext COMMENT '検索条件',
  `sqlcond` mediumtext COMMENT 'SQL条件文',
  PRIMARY KEY  (`admailno`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='広告メール';
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `tAdmailsetting`
--

DROP TABLE IF EXISTS `tAdmailsetting`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdmailsetting` (
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `fromaddress` varchar(255) NOT NULL default '' COMMENT '送信元アドレス',
  `server` varchar(255) NOT NULL default '' COMMENT 'メールサーバ',
  `header` mediumtext COMMENT 'メールヘッダ',
  PRIMARY KEY  (`admailno`,`server`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='admailnoに対応するFrom及びヘッダ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdminPointConfM`
--

DROP TABLE IF EXISTS `tAdminPointConfM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdminPointConfM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `type_of_point` tinyint(3) unsigned NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL,
  `adminpoint` int(10) unsigned NOT NULL default '0',
  `description` char(255) default NULL,
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`type_of_point`,`id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdsetmail`
--

DROP TABLE IF EXISTS `tAdsetmail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdsetmail` (
  `admailno` int(10) unsigned NOT NULL default '0' COMMENT 'メール回数',
  `carrier` tinyint(3) unsigned NOT NULL default '0' COMMENT 'キャリア種別',
  `adid` int(10) unsigned NOT NULL default '0' COMMENT '広告ID',
  PRIMARY KEY  (`admailno`,`carrier`,`adid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='メールと広告IDの関連づけ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdvAccessLogF`
--

DROP TABLE IF EXISTS `tAdvAccessLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdvAccessLogF` (
  `in_date` date NOT NULL COMMENT '“yyyy-mm-dd',
  `in_time` char(2) NOT NULL default '' COMMENT 'HH 0-23',
  `acd` char(6) NOT NULL,
  `accesscount` int(10) unsigned default '0',
  `last_accesscount` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`in_date`,`in_time`,`acd`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAdvM`
--

DROP TABLE IF EXISTS `tAdvM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAdvM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `acd` char(10) NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL default '1',
  `carrier` tinyint(3) unsigned NOT NULL default '1' COMMENT 'アクセス可能キャリアビットで 3キャリアなら16 ',
  `access_url` char(100) NOT NULL COMMENT '遷移先のページ',
  `valid_date` date NOT NULL,
  `expire_date` date NOT NULL,
  `client_name` char(30) default NULL COMMENT 'リンク・バナー先',
  `comment` char(100) default NULL,
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `acd` (`acd`),
  KEY `status_flag` (`status_flag`),
  KEY `carrier` (`carrier`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='広告外部リンクマスタ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAffiliateAccessLogF`
--

DROP TABLE IF EXISTS `tAffiliateAccessLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAffiliateAccessLogF` (
  `in_date` char(6) NOT NULL COMMENT '%y%m%d',
  `guid` char(30) NOT NULL,
  `acd` char(10) NOT NULL,
  `afcd` char(64) default NULL,
  `return_url` char(100) default 'NULL',
  `subno` char(30) NOT NULL,
  `in_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `useragent` char(255) default NULL,
  `carrier` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY  (`guid`,`in_date`),
  KEY `acd` (`acd`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tAffiliateM`
--

DROP TABLE IF EXISTS `tAffiliateM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tAffiliateM` (
  `acd` char(10) NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL default '1',
  `valid_date` date NOT NULL,
  `expire_date` date NOT NULL,
  `param_name1` char(10) default NULL,
  `param_name2` char(10) default NULL,
  `return_url` char(100) NOT NULL,
  `access_url` char(100) NOT NULL,
  `client_name` char(30) default NULL,
  `price` smallint(5) unsigned default NULL,
  `comment` char(100) default NULL,
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`acd`),
  KEY `valid_date` (`valid_date`),
  KEY `expire_date` (`expire_date`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `tBannerDataF`
--

DROP TABLE IF EXISTS `tBannerDataF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tBannerDataF` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `bannerm_id` int(10) unsigned NOT NULL COMMENT 'tBannerMのid 複合のキーになる',
  `bannerdatam_id` int(10) unsigned NOT NULL COMMENT 'tBannerDataMのid 複合のキーになる',
  `status_flag` tinyint(1) unsigned NOT NULL default '0',
  `carrier` tinyint(3) unsigned NOT NULL default '0' COMMENT 'キャリアのbit合計値',
  `sex` tinyint(3) unsigned NOT NULL default '0' COMMENT '性別の合計値',
  `personality` bigint(20) unsigned NOT NULL default '1' COMMENT '系統のbit合計値',
  `bloodtype` tinyint(3) unsigned NOT NULL default '1' COMMENT '血液型のbit合計値',
  `occupation` bigint(20) unsigned NOT NULL default '1' COMMENT '職業のbit合計値',
  `prefecture` bigint(20) unsigned default NULL COMMENT '県コードのビット値',
  `banner_url` char(200) NOT NULL,
  `banner_text` char(36) NOT NULL,
  `image_flag` tinyint(3) unsigned NOT NULL default '1' COMMENT '画像使用のフラグ２＝使用する',
  `image_name` char(60) default NULL,
  `registration_date` datetime NOT NULL,
  PRIMARY KEY  (`bannerm_id`,`bannerdatam_id`,`id`),
  KEY `status_flag` (`status_flag`),
  KEY `carrier` (`carrier`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tBannerDataM`
--

DROP TABLE IF EXISTS `tBannerDataM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tBannerDataM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `bannerm_id` int(10) unsigned NOT NULL COMMENT 'tBannerMのid 複合のキーになる',
  `status_flag` tinyint(1) unsigned NOT NULL default '0',
  `banner_name` char(30) default NULL COMMENT 'クライントやバナーの名前　30文字まで',
  `point_flag` tinyint(1) unsigned NOT NULL default '0' COMMENT '還元の有無',
  `point` int(11) unsigned NOT NULL default '0' COMMENT '還元ポイント数',
  `point_limit` tinyint(1) unsigned NOT NULL default '0' COMMENT '還元回数一日',
  `valid_date` datetime NOT NULL COMMENT '掲載開始日',
  `expire_date` datetime NOT NULL COMMENT '掲載終了日',
  `registration_date` datetime NOT NULL COMMENT '登録日',
  PRIMARY KEY  (`bannerm_id`,`id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tBannerImageF`
--

DROP TABLE IF EXISTS `tBannerImageF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tBannerImageF` (
  `id` int(10) unsigned NOT NULL COMMENT 'tBannerDataF.id',
  `bannerm_id` int(10) unsigned NOT NULL COMMENT 'tBannerDataF.bannerm_id',
  `bannerdatam_id` int(10) unsigned NOT NULL COMMENT 'tBannerDataF.bannerdatam_id',
  `image` mediumblob NOT NULL COMMENT '元画像',
  `resized_image` mediumblob NOT NULL COMMENT 'サイズ変更済み画像',
  `mime_type` char(20) character set sjis NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'このレコードに何らかの変更があった場合に自動的に',
  PRIMARY KEY  (`bannerm_id`,`bannerdatam_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='バナー画像格納テーブル';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tBannerM`
--

DROP TABLE IF EXISTS `tBannerM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tBannerM` (
  `id` smallint(5) unsigned NOT NULL auto_increment,
  `status_flag` tinyint(1) unsigned NOT NULL default '0',
  `description` char(200) default NULL COMMENT 'バナーの説明 200文字まで',
  `spare1` tinyint(1) unsigned NOT NULL default '0' COMMENT '予備１',
  `spare2` tinyint(1) unsigned NOT NULL default '0' COMMENT '予備2',
  `registration_date` datetime NOT NULL COMMENT '登録日',
  PRIMARY KEY  (`id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tCategoryM`
--

DROP TABLE IF EXISTS `tCategoryM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tCategoryM` (
  `category_id` int(10) unsigned NOT NULL auto_increment,
  `status_flag` tinyint(3) unsigned NOT NULL default '1',
  `category_name` char(20) NOT NULL,
  `description` char(100) default NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`category_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='大カテゴリ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tCmsMemberM`
--

DROP TABLE IF EXISTS `tCmsMemberM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tCmsMemberM` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `login_name` char(16) NOT NULL default '',
  `login_password` char(10) NOT NULL default '',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT 'アカウントの有効状態2は有効',
  `name` char(12) default NULL,
  `level` tinyint(3) unsigned NOT NULL default '1' COMMENT 'アカウント管理権限範囲 とりあえづ設置現在は使用しない',
  `description` char(240) default NULL COMMENT '補足説明など 240文字まで',
  `registration_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `login_name` (`login_name`),
  KEY `login_password` (`login_password`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='管理画面ログインユーザーマスタ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tFriendIntroAccessLogF`
--

DROP TABLE IF EXISTS `tFriendIntroAccessLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tFriendIntroAccessLogF` (
  `in_date` char(6) NOT NULL COMMENT '%y%m%d',
  `guid` char(30) NOT NULL,
  `friend_intr_id` char(32) default NULL,
  `friend_owid` int(10) unsigned NOT NULL,
  `friend_guid` char(30) NOT NULL,
  `in_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `useragent` char(255) default NULL,
  `carrier` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY  (`guid`,`in_date`),
  KEY `friend_intr_id` (`friend_intr_id`),
  KEY `friend_guid` (`friend_guid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tJKZSessionF`
--

DROP TABLE IF EXISTS `tJKZSessionF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tJKZSessionF` (
  `id` char(32) NOT NULL default '',
  `data` text,
  `timeref` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `tMailAddressLogF`
--

DROP TABLE IF EXISTS `tMailAddressLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMailAddressLogF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `guid` char(30) NOT NULL,
  `session_id` char(255) NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL default '0' COMMENT 'データ新規挿入時は１　確認で更新で２',
  `type_flag` tinyint(1) unsigned NOT NULL default '3',
  `former_mobilemailaddress` char(255) default NULL COMMENT '変更前のアドレス。新規登録の場合はここはヌル',
  `new_mobilemailaddress` char(255) NOT NULL COMMENT '新アドレス',
  `registration_date` date NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `guid` (`guid`),
  KEY `session_id` (`session_id`),
  KEY `type_flag` (`type_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMailSettingM`
--

DROP TABLE IF EXISTS `tMailSettingM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMailSettingM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `type` char(10) default NULL,
  `from_address` char(255) NOT NULL default '',
  `subject` char(100) NOT NULL default '',
  `header` char(255) NOT NULL default '',
  `body` char(255) NOT NULL default '',
  `footer` char(255) NOT NULL default '',
  `description` char(100) default NULL,
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMediaAccessLogF`
--

DROP TABLE IF EXISTS `tMediaAccessLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMediaAccessLogF` (
  `session_id` char(32) NOT NULL,
  `status_flag` tinyint(2) unsigned NOT NULL default '1',
  `ad_id` int(10) unsigned NOT NULL,
  `ad_point` int(10) unsigned NOT NULL,
  `price_per_regist` smallint(5) unsigned default '0' COMMENT '登録単価　登録に対して支払われ金額',
  `guid` char(30) NOT NULL,
  `carrier` tinyint(2) unsigned NOT NULL default '1',
  `useragent` char(255) default NULL,
  `in_date` char(6) NOT NULL COMMENT '%y%m%d',
  `result_session_id` char(32) default NULL,
  `result_date` datetime default NULL,
  `in_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `session_id` (`session_id`),
  UNIQUE KEY `result_session_id` (`result_session_id`),
  KEY `ad_id` (`ad_id`),
  KEY `guid` (`guid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMediaAgentM`
--

DROP TABLE IF EXISTS `tMediaAgentM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMediaAgentM` (
  `agent_id` int(10) unsigned NOT NULL auto_increment,
  `agent_name` char(30) NOT NULL,
  `status_flag` tinyint(1) unsigned NOT NULL default '2',
  `return_base_url` char(60) NOT NULL default 'http://ptbk.1mp.jp/ptbk.mpl',
  `kick_back_url` char(100) NOT NULL,
  `param_name_for_session_id` char(12) default NULL,
  `param_name_for_status` char(12) default NULL,
  `param_name_for_result_session_id` char(12) default NULL,
  `status_value_for_success` tinyint(2) unsigned NOT NULL default '2',
  `send_param_name` char(12) default NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`agent_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMediaCategoryM`
--

DROP TABLE IF EXISTS `tMediaCategoryM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMediaCategoryM` (
  `mediacategory_id` int(10) unsigned NOT NULL auto_increment,
  `status_flag` tinyint(2) unsigned NOT NULL default '1',
  `mediacategory_name` char(20) NOT NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`mediacategory_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMediaM`
--

DROP TABLE IF EXISTS `tMediaM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMediaM` (
  `ad_id` int(10) unsigned NOT NULL auto_increment COMMENT '広告id',
  `status_flag` tinyint(1) unsigned NOT NULL default '1',
  `point_type` tinyint(3) unsigned NOT NULL default '2' COMMENT 'ポイント付与タイプ。2は登録でポイント。',
  `agent_name` char(30) NOT NULL COMMENT '代理店名',
  `ad_name` char(100) NOT NULL COMMENT '広告設定名・サイト名',
  `ad_url` char(255) NOT NULL COMMENT '広告先のURL',
  `ad_period_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT '広告有効期限のあり、無し',
  `valid_date` datetime default NULL COMMENT '開始日',
  `expire_date` datetime default NULL COMMENT '終了日',
  `point` int(10) unsigned NOT NULL default '0' COMMENT '付与ポイント',
  `mediacategory_id` int(10) unsigned NOT NULL,
  `personality` bigint(20) unsigned NOT NULL default '1' COMMENT '会員属性.１の場合は全員',
  `carrier` tinyint(3) unsigned NOT NULL default '14' COMMENT '対象キャリアBIT値 2=DOCOMO 4 SOFTBANK 8 AU',
  `price_per_regist` smallint(5) unsigned default '0' COMMENT '登録単価。一登録で支払われる金額',
  `return_url` char(100) NOT NULL COMMENT 'キックバックurl 成果情報受信url ポイントバック専用',
  `ad_16words_text` char(100) default NULL,
  `ad_text` char(255) default NULL COMMENT 'WEB詳細説明',
  `param_name_for_session_id` char(12) default NULL,
  `param_name_for_status` char(12) default NULL,
  `param_name_for_result_session_id` char(12) default NULL,
  `status_value_for_success` tinyint(2) unsigned NOT NULL default '2',
  `send_param_name` char(12) default NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`ad_id`),
  KEY `status_flag` (`status_flag`),
  KEY `ad_period_flag` (`ad_period_flag`),
  KEY `mediacategory_id` (`mediacategory_id`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ポイント広告のマスタ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMemberM`
--

DROP TABLE IF EXISTS `tMemberM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMemberM` (
  `owid` int(10) unsigned NOT NULL auto_increment,
  `status_flag` tinyint(3) unsigned NOT NULL default '1' COMMENT '登録状態フラグ 仮登録仮会員1 本登録正会員2 退会4',
  `guid` char(30) NOT NULL COMMENT 'DCMGUID',
  `subno` char(30) default NULL COMMENT '携帯端末番号',
  `carrier` tinyint(2) unsigned NOT NULL default '1',
  `mobilemailaddress` char(255) NOT NULL COMMENT '会員登録時の携帯電話のメールアドレス',
  `memberstatus_flag` tinyint(3) unsigned NOT NULL default '1',
  `mailstatus_flag` tinyint(3) unsigned NOT NULL default '0' COMMENT 'メール状態フラグ　0は正常　1はエラー',
  `sessid` char(32) NOT NULL default '' COMMENT '仮登録時のセッションid',
  `intr_id` char(32) NOT NULL COMMENT 'ENCRYPT BY md5(guid) Can not be decryped',
  `friend_intr_id` char(32) default NULL,
  `password` char(20) NOT NULL COMMENT 'ログイン時のパスワード',
  `cryptpassword` char(20) NOT NULL COMMENT 'ログイン時の暗号済みパスワード',
  `HPTitle` char(20) default NULL COMMENT 'ホームページのタイトル・変更不可',
  `HPCategory` bigint(20) default NULL COMMENT 'ホームページのジャンル変更不可 ジャンルマスターからのビット値',
  `HPURL` char(50) default NULL COMMENT 'ホームページのURL・DOMAIN+/id/',
  `HPeditURL` char(50) default NULL COMMENT 'ホームページ編集URL・管理画面URL',
  `nickname` char(40) default NULL COMMENT 'ニックネーム',
  `family_name` char(20) default NULL,
  `first_name` char(20) default NULL,
  `family_name_kana` char(20) default NULL,
  `first_name_kana` char(20) default NULL,
  `personality` bigint(20) unsigned NOT NULL default '1' COMMENT '系統のbit値',
  `bloodtype` tinyint(3) unsigned NOT NULL default '1' COMMENT '血液型のbit値',
  `occupation` bigint(20) unsigned NOT NULL default '1' COMMENT '職業のbit値',
  `keyword` char(100) default NULL COMMENT 'ｻｲﾄのキーワード',
  `sex` tinyint(3) unsigned NOT NULL default '1',
  `year_of_birth` char(4) default NULL COMMENT '西暦4桁',
  `month_of_birth` char(2) default NULL COMMENT '生まれた月',
  `date_of_birth` char(2) default NULL COMMENT '生まれた日',
  `prefecture` bigint(20) unsigned default NULL COMMENT '県コードのビット値',
  `zip` char(7) default NULL,
  `city` char(15) default NULL,
  `street` char(45) default NULL,
  `address` char(20) default NULL,
  `tel` char(11) default NULL,
  `selfintroduction` text COMMENT '自己紹介文',
  `point` int(10) unsigned NOT NULL default '0' COMMENT '所持ポイント',
  `adminpoint` int(10) unsigned NOT NULL default '0' COMMENT '管理ポイント',
  `limitpoint` int(10) unsigned NOT NULL default '0',
  `pluspoint` int(10) unsigned NOT NULL default '0' COMMENT 'プラスポイント',
  `minuspoint` int(10) default '0' COMMENT 'minus point is inserted with operator -',
  `adv_code` char(10) default NULL COMMENT '広告コード',
  `afcd` char(64) default NULL COMMENT 'アフィリエイトセッションid・コード',
  `useragent` char(255) default NULL COMMENT 'ユーザーエージェント',
  `registration_date` datetime NOT NULL COMMENT '本登録日',
  `withdraw_date` datetime default NULL COMMENT '退会日',
  `reregistration_date` datetime default NULL COMMENT '再登録日',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  USING BTREE (`owid`),
  UNIQUE KEY `guid` (`guid`),
  UNIQUE KEY `mobilemailaddress` (`mobilemailaddress`),
  UNIQUE KEY `subno` (`subno`),
  KEY `status_flag` (`status_flag`),
  KEY `mailstatus_flag` (`mailstatus_flag`),
  KEY `carrier` (`carrier`),
  KEY `intr_id` (`intr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMonthM`
--

DROP TABLE IF EXISTS `tMonthM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMonthM` (
  `DMON` tinyint(2) unsigned zerofill NOT NULL,
  PRIMARY KEY  (`DMON`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tMyPageMediaF`
--

DROP TABLE IF EXISTS `tMyPageMediaF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tMyPageMediaF` (
  `ad_id` int(10) unsigned NOT NULL COMMENT '広告id',
  `status_flag` tinyint(1) unsigned NOT NULL default '2',
  `ad_name` char(100) NOT NULL,
  `point` int(10) unsigned NOT NULL default '0' COMMENT '付与ポイント',
  `mediacategory_id` int(10) unsigned NOT NULL,
  `carrier` tinyint(3) unsigned NOT NULL default '14' COMMENT '対象キャリアBIT値 2=DOCOMO 4 SOFTBANK 8 AU',
  `ad_16words_text` char(100) default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`ad_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='マイページに表示するポイント広告';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tOrderDataF`
--

DROP TABLE IF EXISTS `tOrderDataF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tOrderDataF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ordernum` char(16) NOT NULL default '0',
  `guid` char(30) NOT NULL,
  `owid` int(10) unsigned NOT NULL,
  `orderstatus_flag` tinyint(3) unsigned NOT NULL default '0' COMMENT 'bit値で格納 1 新規受注 2 確認済み・発送待ち 8 完了 16はｷｬﾝｾﾙ32は受け取り拒否64NG',
  `paymeth` tinyint(3) unsigned NOT NULL default '0' COMMENT '2は代引4はｸﾚｼﾞｯﾄ8はコンビに',
  `mobilemailaddress` char(255) NOT NULL,
  `used_point` int(10) unsigned NOT NULL default '0' COMMENT 'ポイント使用時は整数が入る',
  `family_name` char(20) default NULL,
  `first_name` char(20) default NULL,
  `family_name_kana` char(20) default NULL,
  `first_name_kana` char(20) default NULL,
  `prefecture` bigint(20) unsigned default NULL COMMENT '県コードのビット値',
  `zip` char(7) default NULL,
  `city` char(15) default NULL,
  `street` char(45) default NULL,
  `address` char(20) default NULL,
  `tel` char(11) default NULL,
  `order_date` datetime default NULL,
  `deliver_date` date default NULL,
  `deliver_time` char(5) default '0',
  `opinion` char(255) default '0',
  `sagawa_id` char(12) default '0',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ordernum` (`ordernum`),
  KEY `guid` (`guid`),
  KEY `orderstatus_flag` (`orderstatus_flag`),
  KEY `paymeth` (`paymeth`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tOrderDetailF`
--

DROP TABLE IF EXISTS `tOrderDetailF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tOrderDetailF` (
  `id` int(10) unsigned NOT NULL,
  `ordernum` char(16) NOT NULL,
  `orderstatus_flag` tinyint(3) unsigned NOT NULL default '1',
  `owid` int(10) unsigned NOT NULL default '0',
  `product_id` int(10) unsigned NOT NULL,
  `qty` tinyint(3) unsigned NOT NULL default '1',
  `point` int(10) unsigned NOT NULL default '0',
  `tanka` int(6) unsigned NOT NULL,
  `deliver_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ordernum`,`id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tPageViewLogF`
--

DROP TABLE IF EXISTS `tPageViewLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tPageViewLogF` (
  `in_date` date NOT NULL COMMENT 'DATE yyyy-mm',
  `in_time` char(2) NOT NULL default '' COMMENT 'TIME HH 0-23',
  `carrier` tinyint(1) unsigned NOT NULL,
  `tmplt_name` char(30) NOT NULL,
  `pvcount` int(10) unsigned default '0',
  `last_pv` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`in_date`,`in_time`,`carrier`,`tmplt_name`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `tPointLogF`
--

DROP TABLE IF EXISTS `tPointLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tPointLogF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `owid` int(10) unsigned NOT NULL,
  `guid` char(30) NOT NULL,
  `type_of_point` tinyint(3) unsigned NOT NULL COMMENT '処理タイプ 1 会員新規登録時付与ﾎﾟｲﾝﾄ 2ポイントバック広告登録 4商品購入 8マイナスポイント 16 管理によるプラス 32管理によるマイナス',
  `id_of_type` int(10) unsigned NOT NULL COMMENT 'ポイント処理タイプのID。例えば2であれば、広告ID 4であれば商品ID',
  `point` int(11) NOT NULL default '0' COMMENT 'ポイント数 マイナス場合はマイナス',
  `session_id` char(64) default NULL COMMENT 'session_idなど処理タイプにsession_idが関係ある場合',
  `registration_date` datetime NOT NULL COMMENT 'ポイント消費・追加日',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `session_id` (`session_id`),
  KEY `owid` (`owid`),
  KEY `guid` (`guid`),
  KEY `type_of_point` (`type_of_point`),
  KEY `id_of_type` (`id_of_type`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='ポイント履歴ログテーブル';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tProductDecoTmplt`
--

DROP TABLE IF EXISTS `tProductDecoTmplt`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tProductDecoTmplt` (
  `productm_id` int(10) unsigned NOT NULL,
  `dmt` mediumblob NOT NULL COMMENT 'DoCoMoデコメテンプレファイル',
  `hmt` mediumblob NOT NULL COMMENT 'SoftBankデコメテンプレファイル',
  `khm` mediumblob NOT NULL COMMENT 'KDDIデコメテンプレファイル',
  `mime_type_docomo` char(60) character set sjis NOT NULL COMMENT 'DoCoMoのMimeType',
  `mime_type_softbank` char(60) character set sjis NOT NULL COMMENT 'SoftBankのMimeType',
  `mime_type_au` char(60) character set sjis NOT NULL COMMENT 'AUのMimeType',
  `file_size_docomo` char(8) NOT NULL default '0' COMMENT 'DoCoMoファイルサイズ',
  `file_size_softbank` char(8) NOT NULL default '0' COMMENT 'SoftBankファイルサイズ',
  `file_size_au` char(8) NOT NULL default '0' COMMENT 'AUファイルサイズ',
  PRIMARY KEY  (`productm_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='デコメテンプレート格納テーブル';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tProductImageM`
--

DROP TABLE IF EXISTS `tProductImageM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tProductImageM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `productm_id` int(10) unsigned NOT NULL default '0',
  `image` mediumblob,
  `image1` mediumblob,
  `image2` mediumblob,
  `mime_type` char(20) character set sjis NOT NULL,
  PRIMARY KEY  (`productm_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='商品画像';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tProductM`
--

DROP TABLE IF EXISTS `tProductM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tProductM` (
  `product_id` int(10) unsigned NOT NULL auto_increment COMMENT '品のＩＤ',
  `status_flag` tinyint(2) unsigned NOT NULL default '2',
  `charge_flag` tinyint(3) unsigned NOT NULL default '1',
  `point_flag` tinyint(2) unsigned NOT NULL default '1',
  `latest_flag` tinyint(3) unsigned NOT NULL default '1' COMMENT 'to show contents on new arrival page default value is 1',
  `recommend_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT 'if this product is recommended  flag value 2 stands for recommended product',
  `product_name` text NOT NULL,
  `product_code` char(60) default NULL,
  `categorym_id` int(10) unsigned NOT NULL,
  `subcategorym_id` int(10) unsigned NOT NULL default '0',
  `smallcategorym_id` int(10) unsigned default NULL,
  `description` text NOT NULL,
  `description_detail` mediumtext,
  `genka` int(6) unsigned NOT NULL default '0',
  `tanka` int(6) unsigned NOT NULL default '0',
  `tanka_notax` int(6) unsigned NOT NULL default '0',
  `teika` int(6) unsigned NOT NULL default '0',
  `tmplt_id` int(10) unsigned NOT NULL,
  `point` int(10) unsigned NOT NULL,
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  `stock` tinyint(3) default '0',
  PRIMARY KEY  (`product_id`),
  KEY `status_flag` (`status_flag`),
  KEY `categorym_id` (`categorym_id`),
  KEY `subcategorym_id` (`subcategorym_id`),
  KEY `latest_flag` (`latest_flag`),
  KEY `charge_flag` (`charge_flag`),
  KEY `smallcategorym_id` (`smallcategorym_id`),
  FULLTEXT KEY `product_name` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`product_name`,`description_detail`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='商品マスタ';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tProductSwf`
--

DROP TABLE IF EXISTS `tProductSwf`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tProductSwf` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `productm_id` int(10) unsigned NOT NULL,
  `swf` mediumblob NOT NULL COMMENT 'フラッシュファイル',
  `mime_type` char(60) character set sjis NOT NULL,
  `file_size` char(8) NOT NULL default '0' COMMENT 'ファイルサイズ',
  `height` char(8) NOT NULL default '0',
  `width` char(8) NOT NULL default '0' COMMENT 'フラッシュの幅',
  PRIMARY KEY  (`productm_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='フラッシュファイル格納テーブル';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tProductViewLogF`
--

DROP TABLE IF EXISTS `tProductViewLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tProductViewLogF` (
  `in_date` date NOT NULL COMMENT 'DATE yyyy-mm',
  `carrier` tinyint(1) unsigned NOT NULL,
  `product_id` char(30) NOT NULL,
  `product_name` text,
  `pvcount` int(10) unsigned default '0',
  `last_view` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`in_date`,`carrier`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tSiteImageM`
--

DROP TABLE IF EXISTS `tSiteImageM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tSiteImageM` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `image` mediumblob,
  `width` tinyint(3) unsigned default NULL,
  `height` tinyint(3) unsigned default NULL,
  `mime_type` char(20) character set sjis NOT NULL,
  `description` char(60) character set sjis default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tSmallCategoryM`
--

DROP TABLE IF EXISTS `tSmallCategoryM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tSmallCategoryM` (
  `smallcategory_id` int(10) unsigned NOT NULL auto_increment,
  `categorym_id` int(10) unsigned NOT NULL,
  `subcategorym_id` int(10) unsigned NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT '親のフラグが更新されるとこのフラグも更新',
  `smallcategory_name` char(40) NOT NULL,
  `subcategory_name` char(30) NOT NULL,
  `category_name` char(20) NOT NULL,
  `description` char(100) NOT NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`smallcategory_id`),
  KEY `categorym_id` (`categorym_id`),
  KEY `subcategorym_id` (`subcategorym_id`),
  KEY `status_flag` (`status_flag`),
  CONSTRAINT `tSmallCategoryM_ibfk_1` FOREIGN KEY (`categorym_id`) REFERENCES `tSubCategoryM` (`categorym_id`) ON UPDATE CASCADE,
  CONSTRAINT `tSmallCategoryM_ibfk_2` FOREIGN KEY (`subcategorym_id`) REFERENCES `tSubCategoryM` (`subcategory_id`) ON UPDATE CASCADE,
  CONSTRAINT `tSmallCategoryM_ibfk_3` FOREIGN KEY (`status_flag`) REFERENCES `tSubCategoryM` (`status_flag`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tSubCategoryM`
--

DROP TABLE IF EXISTS `tSubCategoryM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tSubCategoryM` (
  `subcategory_id` int(10) unsigned NOT NULL auto_increment,
  `categorym_id` int(10) unsigned NOT NULL,
  `status_flag` tinyint(3) unsigned NOT NULL,
  `subcategory_name` char(30) NOT NULL,
  `category_name` char(20) NOT NULL,
  `description` char(100) NOT NULL,
  `registration_date` datetime NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`subcategory_id`),
  KEY `categorym_id` (`categorym_id`),
  KEY `status_flag` (`status_flag`),
  CONSTRAINT `tSubCategoryM_ibfk_1` FOREIGN KEY (`categorym_id`) REFERENCES `tCategoryM` (`category_id`) ON UPDATE CASCADE,
  CONSTRAINT `tSubCategoryM_ibfk_2` FOREIGN KEY (`status_flag`) REFERENCES `tCategoryM` (`status_flag`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=sjis;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tTmpltFileF`
--

DROP TABLE IF EXISTS `tTmpltFileF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tTmpltFileF` (
  `tmpltfile_id` int(10) unsigned NOT NULL auto_increment,
  `tmpltm_id` int(10) unsigned default NULL COMMENT '親レコード参照ID',
  `status_flag` tinyint(2) unsigned default '1' COMMENT '無効 1 現在 2 スタンバイ3 未定4',
  `activation_date` datetime default NULL,
  `tmplt_docomo` mediumtext COMMENT 'DoCoMoのテンプレート',
  `tmplt_softbank` mediumtext COMMENT 'SoftBankのテンプレート',
  `tmplt_au` mediumtext COMMENT 'AUのテンプレート',
  `registration_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`tmpltfile_id`),
  KEY `status_flag` (`status_flag`),
  KEY `tmpltm_id` (`tmpltm_id`,`lastupdate_date`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='テンプレートHTMLコードテーブル。tTmptlMを参照';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tTmpltM`
--

DROP TABLE IF EXISTS `tTmpltM`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tTmpltM` (
  `tmplt_id` int(10) unsigned NOT NULL auto_increment,
  `tmplt_name` char(30) NOT NULL default '' COMMENT 'アクションパラメータ a の値と連動させるときの識別に使用',
  `status_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT '無効１有効２スタンバイ4未定8未定',
  `summary` char(20) default NULL COMMENT '日本語で何のページわかるように',
  `registration_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`tmplt_id`),
  UNIQUE KEY `tmplt_name` (`tmplt_name`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='テンプレートマスター。';
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tUserRegistLogF`
--

DROP TABLE IF EXISTS `tUserRegistLogF`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tUserRegistLogF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `owid` int(10) unsigned NOT NULL,
  `guid` char(30) NOT NULL COMMENT 'DCMGUID',
  `subno` char(30) NOT NULL COMMENT '携帯端末番号',
  `carrier` tinyint(2) unsigned NOT NULL default '1',
  `status_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT '2==登録 4==退会 以外は未確定',
  `acd` char(10) default NULL,
  `intr_id` char(32) default NULL COMMENT 'if you are registrating from from friends invitation',
  `date_of_transaction` datetime default NULL COMMENT '実行処理された日',
  PRIMARY KEY  (`id`),
  KEY `owid` (`owid`),
  KEY `guid` (`guid`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='会員入退会ログ';
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-03-26 10:12:25
