-- 位置登録・マイリンク関連テーブル --
-- 2010/07/06 --

-- このテーブルへのデータ挿入は近所のときだけ --
CREATE TABLE `tMyMessageBoardF` (
  `msg_id` int(10) unsigned NOT NULL auto_increment COMMENT '勵尚灼の連番',
  `toid` int(10) unsigned NOT NULL COMMENT '板主の会員ID',
  `owid` int(10) unsigned NOT NULL COMMENT '板に書き込みする会員のID',
  `private_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT '私信フラグ。 1は通常で私信オフ 2の場合は私信オンで板主と書き込み者だけが閲覧できる',
  `message` text,
  `neighbor_nickname` char(40) NOT NULL COMMENT 'リンク先のニックネーム',
  `registration_date` datetime default NULL,
  PRIMARY KEY  (`toid`,`msg_id`),
  KEY `owid` (`owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='マイリンクのテーブル';



CREATE TABLE `tMyIchi` (
  `owid` int(10) unsigned NOT NULL,
  `ichi_id` int(10) unsigned NOT NULL,
  `distance` char(6) default NULL COMMENT '移動距離',
  `iArea_code` tinyint(5) unsigned zerofill NOT NULL,
  `iArea_areaid` tinyint(3) unsigned zerofill NOT NULL,
  `iArea_sub_areaid` tinyint(2) unsigned zerofill NOT NULL,
  `iArea_region` char(40) default NULL COMMENT '地域名',
  `iArea_name` char(40) default NULL COMMENT 'エリア名',
  `iArea_prefecture` char(40) default NULL COMMENT '都道府県',
  `startpoint_ido` char(20) default NULL COMMENT '開始緯度',
  `startpoint_keido` char(20) default NULL COMMENT '開始経度',
  `endpoint_ido` char(20) default NULL COMMENT '終了緯度',
  `endpoint_keido` char(20) default NULL COMMENT '終了経度',
  `registration_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`owid`),
  KEY `iArea_areaid` (`iArea_areaid`),
  KEY `iArea_sub_areaid` (`iArea_sub_areaid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='位置情報登録テーブル';



CREATE TABLE `tMyLinkListF` (
  `owid` int(10) unsigned NOT NULL COMMENT '自分の会員ID',
  `toid` int(10) unsigned NOT NULL COMMENT 'リンク先の会員ID',
  `neighbor_nickname` char(40) NOT NULL COMMENT 'リンク先のニックネーム',
  `registration_date` datetime default NULL,
  PRIMARY KEY  (`owid`,`toid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='マイリンクのテーブル';



CREATE TABLE `tProfilePageSettingM` (
  `owid` int(10) unsigned NOT NULL COMMENT 'ユーザーのtMemberM.owid',
  `nickname` char(40) default NULL,
  `profile_bit` int(10) unsigned NOT NULL default '1' COMMENT '公開プロフィール項目のビット合計値',
  `tuserimagef_id` int(10) unsigned default NULL COMMENT 'ﾌﾟﾛﾌに使用する画像id',
  `selfintroduction` text,
  `designtmplt_flag` tinyint(3) unsigned NOT NULL COMMENT 'ﾃﾞｻﾞｲﾝテンプレの利用有無',
  `designtmplt_filename` char(12) default NULL COMMENT 'ﾃﾞｻﾞｲﾝテンプレートのファイル名',
  `designtmplt_description` varchar(20) NOT NULL COMMENT '着せ替えテンプレートの呼び名',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '最終更新日',
  PRIMARY KEY  (`owid`),
  KEY `designtmplt_flag` (`designtmplt_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='デフォルトﾌﾟﾛﾌｨｰﾙの設定';