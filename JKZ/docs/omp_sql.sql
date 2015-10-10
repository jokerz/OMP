-- 2010/06/11 --

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityAdmissionF`
--

DROP TABLE IF EXISTS `tCommunityAdmissionF`;
CREATE TABLE `tCommunityAdmissionF` (
  `community_id` int(10) unsigned NOT NULL,
  `owid` int(10) unsigned NOT NULL COMMENT 'Q‰ÁŠó–]Òowid',
  `status_flag` tinyint(3) unsigned default NULL COMMENT 'ó‘Ô@NULL¨–¢³”F@2¨³”FOK@1¨³”FNG',
  `nickname` char(20) NOT NULL COMMENT 'Q‰ÁŠó–]ÒƒjƒbƒNƒl[ƒ€',
  `id` char(20) NOT NULL COMMENT '‰ïˆõ‚ÌID',
  `apply_date` datetime NOT NULL COMMENT '\¿“ú',
  `admission_date` datetime NOT NULL COMMENT '³”F“ú',
  PRIMARY KEY  (`community_id`,`owid`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒB[Q‰ÁŠó–]³”Fƒe[ƒuƒ‹';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityCategoryM`
--

DROP TABLE IF EXISTS `tCommunityCategoryM`;
CREATE TABLE `tCommunityCategoryM` (
  `community_category_id` int(10) unsigned NOT NULL auto_increment COMMENT 'ƒRƒ~ƒ…ƒjƒeƒBƒJƒeƒSƒŠ‚ÌID',
  `community_category_logid` bigint(20) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒBƒJƒeƒSƒŠ‚ÌPOW‚µ‚½ID',
  `community_category_name` char(20) NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[‚ÌƒJƒeƒSƒŠ–¼',
  PRIMARY KEY  (`community_category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒB[ƒJƒeƒSƒŠƒ}ƒXƒ^';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityM`
--

DROP TABLE IF EXISTS `tCommunityM`;
CREATE TABLE `tCommunityM` (
  `community_id` int(10) unsigned NOT NULL auto_increment COMMENT 'ƒRƒ~ƒ…ƒjƒeƒBID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT 'ó‘Ô@—LŒø‚Í‚Q',
  `community_name` char(100) NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB–¼',
  `community_category_id` smallint(5) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[ƒJƒeƒSƒŠ',
  `community_description` text NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB‚Ìà–¾•¶i‘S•¶ŒŸõ‚É‚à—˜—pj',
  `community_image_id` int(10) unsigned NOT NULL,
  `community_member_flag` tinyint(3) unsigned NOT NULL COMMENT 'Q‰ÁƒŒƒxƒ‹ƒtƒ‰ƒO',
  `community_topic_flag` tinyint(3) unsigned NOT NULL COMMENT 'ƒgƒsƒbƒNì¬Œ ŒÀƒtƒ‰ƒO',
  `community_admin_owid` int(10) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[ŠÇ—Ò‚Ìowid',
  `community_admin_nickname` char(40) NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[ŠÇ—Ò‚ÌƒjƒbƒNƒl[ƒ€',
  `community_admin_id` char(20) NOT NULL COMMENT 'ŠÇ—Ò‚ÌID(URL‚É‚Â‚­‚â‚Â)',
  `community_total_member` int(10) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[‚ÉQ‰Ál”',
  `registration_date` date NOT NULL COMMENT 'ì¬“ú',
  `expire_date` date default NULL COMMENT '–³Œø‚É‚È‚Á‚½“ú',
  PRIMARY KEY  (`community_id`),
  KEY `community_category_id` (`community_category_id`),
  FULLTEXT KEY `community` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_name`,`community_description`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒB[ƒ}ƒXƒ^[';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityMemberM`
--

DROP TABLE IF EXISTS `tCommunityMemberM`;
CREATE TABLE `tCommunityMemberM` (
  `community_id` int(10) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[‚ÌID(•¡‡‚ÌåƒL[)',
  `community_member_owid` int(10) unsigned NOT NULL,
  `community_member_nickname` char(40) NOT NULL,
  `community_member_id` char(20) NOT NULL COMMENT '‰ïˆõ‚ÌID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT 'ó‘Ô',
  `community_admin_flag` tinyint(3) unsigned default NULL COMMENT 'Œ ŒÀƒtƒ‰ƒO 2‚ÍŠÇ—l null‚Í’Êí',
  `registration_date` date NOT NULL COMMENT '“o˜^“úiQ‰Áj',
  `withdraw_date` date NOT NULL COMMENT '‘Ş‰ï“ú',
  PRIMARY KEY  (`community_member_owid`,`community_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒB[Q‰ÁÒƒ}ƒXƒ^';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityTopicCommentF`
--

DROP TABLE IF EXISTS `tCommunityTopicCommentF`;
CREATE TABLE `tCommunityTopicCommentF` (
  `community_comment_id` int(10) unsigned NOT NULL auto_increment COMMENT 'ƒRƒƒ“ƒg‚ÌID(•¡‡åƒL[)',
  `community_id` int(10) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[‚ÌID',
  `community_topic_id` int(10) unsigned NOT NULL COMMENT 'ƒgƒsƒbƒN‚ÌID',
  `community_comment` text NOT NULL COMMENT 'ƒRƒƒ“ƒg–{•¶',
  `commentater_owid` int(10) unsigned NOT NULL COMMENT 'ƒRƒƒ“ƒgå‚Ìowid',
  `commentater_nickname` char(40) NOT NULL COMMENT 'ƒRƒƒ“ƒgå‚ÌƒjƒbƒNƒl[ƒ€',
  `commentater_id` char(20) NOT NULL COMMENT 'ƒRƒƒ“ƒg‚µ‚½‰ïˆõ‚ÌID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'ÅIXV“ú',
  PRIMARY KEY  (`community_id`,`community_topic_id`,`community_comment_id`),
  KEY `commentater_owid` (`commentater_owid`),
  FULLTEXT KEY `community_comment` USING MECAB, NORMALIZE, 512 (`community_comment`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒBƒgƒsƒbƒN‚É‘Î‚·‚éƒRƒƒ“ƒg';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tCommunityTopicF`
--

DROP TABLE IF EXISTS `tCommunityTopicF`;
CREATE TABLE `tCommunityTopicF` (
  `community_topic_id` int(10) unsigned NOT NULL auto_increment COMMENT 'ƒgƒsƒbƒN‚ÌIDi•¡‡åƒL[j',
  `community_id` int(10) unsigned NOT NULL COMMENT 'ƒRƒ~ƒ…ƒjƒeƒB[‚ÌID',
  `community_topic_title` char(60) NOT NULL COMMENT 'ƒgƒsƒbƒN‘è–¼',
  `community_topic` text NOT NULL COMMENT 'ƒgƒsƒbƒN–{•¶',
  `community_topicowner_owid` int(10) unsigned NOT NULL COMMENT 'ƒgƒsåowid',
  `community_topicowner_nickname` char(40) NOT NULL COMMENT 'ƒgƒsåƒjƒbƒNƒl[ƒ€',
  `community_topicowner_id` char(20) NOT NULL COMMENT 'ÄËßå‚Ì‰ïˆõID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'ÅIXV“ú',
  PRIMARY KEY  (`community_id`,`community_topic_id`),
  KEY `community_topicowner_owid` (`community_topicowner_owid`),
  FULLTEXT KEY `community_topic_title` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_topic_title`,`community_topic`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ƒRƒ~ƒ…ƒjƒeƒB[‚ÌƒgƒsƒbƒNƒe[ƒuƒ‹';

-- --------------------------------------------------------


--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tUserImageF`
--

DROP TABLE IF EXISTS `tUserImageF`;
CREATE TABLE `tUserImageF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `owid` int(10) NOT NULL COMMENT '‰ïˆõ‚ÌƒVƒXƒeƒ€id',
  `image` mediumblob NOT NULL COMMENT 'Œ³‰æ‘œ',
  `thumbnail_320` mediumblob NOT NULL COMMENT '320x240',
  `thumbnail_200` mediumblob NOT NULL COMMENT '120x200‚Ì‰æ‘œ',
  `thumbnail_64` mediumblob NOT NULL COMMENT '64x64',
  `mime_type` char(20) NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '‚±‚ÌƒŒƒR[ƒh‚É‰½‚ç‚©‚Ì•ÏX‚ª‚ ‚Á‚½ê‡‚É©“®“I‚É“ú•t‚ªXV‚³‚ê‚éB',
  PRIMARY KEY  (`owid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='‰ïˆõ—pƒ[ƒ‹‚Å‰æ‘œƒAƒbƒvƒ[ƒhŠi”[ƒe[ƒuƒ‹';


--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tProfilePageSettingM`
--

DROP TABLE IF EXISTS `tProfilePageSettingM`;
CREATE TABLE `tProfilePageSettingM` (
  `owid` int(10) unsigned NOT NULL COMMENT 'ƒ†[ƒU[‚ÌtMemberM.owid',
  `profile_bit` int(10) unsigned NOT NULL default '1' COMMENT 'ŒöŠJƒvƒƒtƒB[ƒ‹€–Ú‚Ìƒrƒbƒg‡Œv’l',
  `tuserimagef_id` int(10) unsigned default NULL COMMENT 'ÌßÛÌ‚Ég—p‚·‚é‰æ‘œid',
  `designtmplt_flag` tinyint(3) unsigned NOT NULL COMMENT 'ÃŞ»Ş²İƒeƒ“ƒvƒŒ‚Ì—˜—p—L–³',
  `designtmplt_filename` char(12) default NULL COMMENT 'ÃŞ»Ş²İƒeƒ“ƒvƒŒ[ƒg‚Ìƒtƒ@ƒCƒ‹–¼',
  `designtmplt_description` varchar(20) NOT NULL COMMENT '’…‚¹‘Ö‚¦ƒeƒ“ƒvƒŒ[ƒg‚ÌŒÄ‚Ñ–¼',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'ÅIXV“ú',
  PRIMARY KEY  (`owid`),
  KEY `designtmplt_flag` (`designtmplt_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='ƒfƒtƒHƒ‹ƒgÌßÛÌ¨°Ù‚Ìİ’è';

-- --------------------------------------------------------



--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tMessageInBoxF`
--

DROP TABLE IF EXISTS `tMessageInBoxF`;
CREATE TABLE `tMessageInBoxF` (
  `message_id` char(20) NOT NULL COMMENT '³ÿMƒƒbƒZ[ƒWID(‘—Mƒ{ƒbƒNƒX‚ÌƒƒbƒZ[ƒWIDj',
  `status_flag` tinyint(3) unsigned default NULL COMMENT '–¢“Çƒtƒ‰ƒO NULL‚Í–¢“Ç. ‚P‚ÍŠù“Ç 2‚Í•ÔMÏ‚İ(‚Æ‚è‚ ‚¦‚¸)',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '·ol(‘—MÒ)‚Ìowid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT 'óæl(óMÒ)‚Ìowid',
  `sender_nickname` char(40) NOT NULL COMMENT '·ol‚Ì‚ÌƒjƒbƒNƒl[ƒ€',
  `subject` char(40) default NULL COMMENT 'Œ–¼',
  `message` text COMMENT 'ƒƒbƒZ[ƒW‚Ì–{•¶(“à—e)',
  `received_date` datetime NOT NULL COMMENT 'ƒƒbƒZ[ƒWóM“ú',
  `message_read_date` datetime default NULL COMMENT 'ƒƒbƒZ[ƒW‚ªŠù“Ç‚É‚È‚Á‚½“ú',
  `image_flag` tinyint(3) unsigned default NULL COMMENT '‰æ‘œ•tƒƒbƒZ‚Ìê‡‚Í”’l‚ª‚ ‚é',
  PRIMARY KEY  (`message_id`),
  KEY `status_flag` (`status_flag`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ƒ[ƒ‹ƒƒbƒZ[ƒWóMƒ{ƒbƒNƒX';

-- --------------------------------------------------------

--
-- ƒe[ƒuƒ‹‚Ì\‘¢ `tMessageOutBoxF`
--

DROP TABLE IF EXISTS `tMessageOutBoxF`;
CREATE TABLE `tMessageOutBoxF` (
  `message_id` char(20) NOT NULL COMMENT '‘—MƒƒbƒZ[ƒWID',
  `reply_message_id` char(20) default NULL COMMENT 'óM‚µ‚½ƒƒbƒZ[ƒW‚É•ÔM‚µ‚½‚Æ‚«‚ÌóMƒƒbƒZ[ƒWID.Å‰‚Ì‘—M‚Í‚±‚±‚ÍNULL‚É‚È‚éB',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '·ol(‘—MÒ)‚Ìowid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT 'óæl(óMÒ)‚Ìowid',
  `recipient_nickname` char(40) NOT NULL COMMENT 'ó‚¯æ‚èl‚Ì‚ÌƒjƒbƒNƒl[ƒ€',
  `subject` char(40) default 'no subject' COMMENT 'Œ–¼',
  `message` text COMMENT 'ƒƒbƒZ[ƒW‚Ì–{•¶(“à—e)',
  `send_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`message_id`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='ƒ[ƒ‹ƒƒbƒZ[ƒW‘—Mƒ{ƒbƒNƒX';

-- --------------------------------------------------------