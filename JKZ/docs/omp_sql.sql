-- 2010/06/11 --

--
-- テーブルの構造 `tCommunityAdmissionF`
--

DROP TABLE IF EXISTS `tCommunityAdmissionF`;
CREATE TABLE `tCommunityAdmissionF` (
  `community_id` int(10) unsigned NOT NULL,
  `owid` int(10) unsigned NOT NULL COMMENT '参加希望者owid',
  `status_flag` tinyint(3) unsigned default NULL COMMENT '状態　NULL→未承認　2→承認OK　1→承認NG',
  `nickname` char(20) NOT NULL COMMENT '参加希望者ニックネーム',
  `id` char(20) NOT NULL COMMENT '会員のID',
  `apply_date` datetime NOT NULL COMMENT '申請日',
  `admission_date` datetime NOT NULL COMMENT '承認日',
  PRIMARY KEY  (`community_id`,`owid`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='コミュニティー参加希望承認テーブル';

-- --------------------------------------------------------

--
-- テーブルの構造 `tCommunityCategoryM`
--

DROP TABLE IF EXISTS `tCommunityCategoryM`;
CREATE TABLE `tCommunityCategoryM` (
  `community_category_id` int(10) unsigned NOT NULL auto_increment COMMENT 'コミュニティカテゴリのID',
  `community_category_logid` bigint(20) unsigned NOT NULL COMMENT 'コミュニティカテゴリのPOWしたID',
  `community_category_name` char(20) NOT NULL COMMENT 'コミュニティーのカテゴリ名',
  PRIMARY KEY  (`community_category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='コミュニティーカテゴリマスタ';

-- --------------------------------------------------------

--
-- テーブルの構造 `tCommunityM`
--

DROP TABLE IF EXISTS `tCommunityM`;
CREATE TABLE `tCommunityM` (
  `community_id` int(10) unsigned NOT NULL auto_increment COMMENT 'コミュニティID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT '状態　有効は２',
  `community_name` char(100) NOT NULL COMMENT 'コミュニティ名',
  `community_category_id` smallint(5) unsigned NOT NULL COMMENT 'コミュニティーカテゴリ',
  `community_description` text NOT NULL COMMENT 'コミュニティの説明文（全文検索にも利用）',
  `community_image_id` int(10) unsigned NOT NULL,
  `community_member_flag` tinyint(3) unsigned NOT NULL COMMENT '参加レベルフラグ',
  `community_topic_flag` tinyint(3) unsigned NOT NULL COMMENT 'トピック作成権限フラグ',
  `community_admin_owid` int(10) unsigned NOT NULL COMMENT 'コミュニティー管理者のowid',
  `community_admin_nickname` char(40) NOT NULL COMMENT 'コミュニティー管理者のニックネーム',
  `community_admin_id` char(20) NOT NULL COMMENT '管理者のID(URLにつくやつ)',
  `community_total_member` int(10) unsigned NOT NULL COMMENT 'コミュニティーに参加人数',
  `registration_date` date NOT NULL COMMENT '作成日',
  `expire_date` date default NULL COMMENT '無効になった日',
  PRIMARY KEY  (`community_id`),
  KEY `community_category_id` (`community_category_id`),
  FULLTEXT KEY `community` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_name`,`community_description`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='コミュニティーマスター';

-- --------------------------------------------------------

--
-- テーブルの構造 `tCommunityMemberM`
--

DROP TABLE IF EXISTS `tCommunityMemberM`;
CREATE TABLE `tCommunityMemberM` (
  `community_id` int(10) unsigned NOT NULL COMMENT 'コミュニティーのID(複合の主キー)',
  `community_member_owid` int(10) unsigned NOT NULL,
  `community_member_nickname` char(40) NOT NULL,
  `community_member_id` char(20) NOT NULL COMMENT '会員のID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT '状態',
  `community_admin_flag` tinyint(3) unsigned default NULL COMMENT '権限フラグ 2は管理人 nullは通常',
  `registration_date` date NOT NULL COMMENT '登録日（参加）',
  `withdraw_date` date NOT NULL COMMENT '退会日',
  PRIMARY KEY  (`community_member_owid`,`community_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='コミュニティー参加者マスタ';

-- --------------------------------------------------------

--
-- テーブルの構造 `tCommunityTopicCommentF`
--

DROP TABLE IF EXISTS `tCommunityTopicCommentF`;
CREATE TABLE `tCommunityTopicCommentF` (
  `community_comment_id` int(10) unsigned NOT NULL auto_increment COMMENT 'コメントのID(複合主キー)',
  `community_id` int(10) unsigned NOT NULL COMMENT 'コミュニティーのID',
  `community_topic_id` int(10) unsigned NOT NULL COMMENT 'トピックのID',
  `community_comment` text NOT NULL COMMENT 'コメント本文',
  `commentater_owid` int(10) unsigned NOT NULL COMMENT 'コメント主のowid',
  `commentater_nickname` char(40) NOT NULL COMMENT 'コメント主のニックネーム',
  `commentater_id` char(20) NOT NULL COMMENT 'コメントした会員のID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`community_id`,`community_topic_id`,`community_comment_id`),
  KEY `commentater_owid` (`commentater_owid`),
  FULLTEXT KEY `community_comment` USING MECAB, NORMALIZE, 512 (`community_comment`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='コミュニティトピックに対するコメント';

-- --------------------------------------------------------

--
-- テーブルの構造 `tCommunityTopicF`
--

DROP TABLE IF EXISTS `tCommunityTopicF`;
CREATE TABLE `tCommunityTopicF` (
  `community_topic_id` int(10) unsigned NOT NULL auto_increment COMMENT 'トピックのID（複合主キー）',
  `community_id` int(10) unsigned NOT NULL COMMENT 'コミュニティーのID',
  `community_topic_title` char(60) NOT NULL COMMENT 'トピック題名',
  `community_topic` text NOT NULL COMMENT 'トピック本文',
  `community_topicowner_owid` int(10) unsigned NOT NULL COMMENT 'トピ主owid',
  `community_topicowner_nickname` char(40) NOT NULL COMMENT 'トピ主ニックネーム',
  `community_topicowner_id` char(20) NOT NULL COMMENT 'ﾄﾋﾟ主の会員ID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日時',
  PRIMARY KEY  (`community_id`,`community_topic_id`),
  KEY `community_topicowner_owid` (`community_topicowner_owid`),
  FULLTEXT KEY `community_topic_title` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_topic_title`,`community_topic`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='コミュニティーのトピックテーブル';

-- --------------------------------------------------------


--
-- テーブルの構造 `tUserImageF`
--

DROP TABLE IF EXISTS `tUserImageF`;
CREATE TABLE `tUserImageF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `owid` int(10) NOT NULL COMMENT '会員のシステムid',
  `image` mediumblob NOT NULL COMMENT '元画像',
  `thumbnail_320` mediumblob NOT NULL COMMENT '320x240',
  `thumbnail_200` mediumblob NOT NULL COMMENT '120x200の画像',
  `thumbnail_64` mediumblob NOT NULL COMMENT '64x64',
  `mime_type` char(20) NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'このレコードに何らかの変更があった場合に自動的に日付が更新される。',
  PRIMARY KEY  (`owid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='会員用メールで画像アップロード格納テーブル';


--
-- テーブルの構造 `tProfilePageSettingM`
--

DROP TABLE IF EXISTS `tProfilePageSettingM`;
CREATE TABLE `tProfilePageSettingM` (
  `owid` int(10) unsigned NOT NULL COMMENT 'ユーザーのtMemberM.owid',
  `profile_bit` int(10) unsigned NOT NULL default '1' COMMENT '公開プロフィール項目のビット合計値',
  `tuserimagef_id` int(10) unsigned default NULL COMMENT 'ﾌﾟﾛﾌに使用する画像id',
  `designtmplt_flag` tinyint(3) unsigned NOT NULL COMMENT 'ﾃﾞｻﾞｲﾝテンプレの利用有無',
  `designtmplt_filename` char(12) default NULL COMMENT 'ﾃﾞｻﾞｲﾝテンプレートのファイル名',
  `designtmplt_description` varchar(20) NOT NULL COMMENT '着せ替えテンプレートの呼び名',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`owid`),
  KEY `designtmplt_flag` (`designtmplt_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='デフォルトﾌﾟﾛﾌｨｰﾙの設定';

-- --------------------------------------------------------



--
-- テーブルの構造 `tMessageInBoxF`
--

DROP TABLE IF EXISTS `tMessageInBoxF`;
CREATE TABLE `tMessageInBoxF` (
  `message_id` char(20) NOT NULL COMMENT 'ｳ�信メッセージID(送信ボックスのメッセージID）',
  `status_flag` tinyint(3) unsigned default NULL COMMENT '未読フラグ NULLは未読. １は既読 2は返信済み(とりあえず)',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '差出人(送信者)のowid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT '受取人(受信者)のowid',
  `sender_nickname` char(40) NOT NULL COMMENT '差出人ののニックネーム',
  `subject` char(40) default NULL COMMENT '件名',
  `message` text COMMENT 'メッセージの本文(内容)',
  `received_date` datetime NOT NULL COMMENT 'メッセージ受信日',
  `message_read_date` datetime default NULL COMMENT 'メッセージが既読になった日時',
  `image_flag` tinyint(3) unsigned default NULL COMMENT '画像付メッセの場合は数値がある',
  PRIMARY KEY  (`message_id`),
  KEY `status_flag` (`status_flag`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='メールメッセージ受信ボックス';

-- --------------------------------------------------------

--
-- テーブルの構造 `tMessageOutBoxF`
--

DROP TABLE IF EXISTS `tMessageOutBoxF`;
CREATE TABLE `tMessageOutBoxF` (
  `message_id` char(20) NOT NULL COMMENT '送信メッセージID',
  `reply_message_id` char(20) default NULL COMMENT '受信したメッセージに返信したときの受信メッセージID.最初の送信時はここはNULLになる。',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '差出人(送信者)のowid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT '受取人(受信者)のowid',
  `recipient_nickname` char(40) NOT NULL COMMENT '受け取り人ののニックネーム',
  `subject` char(40) default 'no subject' COMMENT '件名',
  `message` text COMMENT 'メッセージの本文(内容)',
  `send_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`message_id`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='メールメッセージ送信ボックス';

-- --------------------------------------------------------