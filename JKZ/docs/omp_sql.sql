-- 2010/06/11 --

--
-- �e�[�u���̍\�� `tCommunityAdmissionF`
--

DROP TABLE IF EXISTS `tCommunityAdmissionF`;
CREATE TABLE `tCommunityAdmissionF` (
  `community_id` int(10) unsigned NOT NULL,
  `owid` int(10) unsigned NOT NULL COMMENT '�Q����]��owid',
  `status_flag` tinyint(3) unsigned default NULL COMMENT '��ԁ@NULL�������F�@2�����FOK�@1�����FNG',
  `nickname` char(20) NOT NULL COMMENT '�Q����]�҃j�b�N�l�[��',
  `id` char(20) NOT NULL COMMENT '�����ID',
  `apply_date` datetime NOT NULL COMMENT '�\����',
  `admission_date` datetime NOT NULL COMMENT '���F��',
  PRIMARY KEY  (`community_id`,`owid`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�[�Q����]���F�e�[�u��';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tCommunityCategoryM`
--

DROP TABLE IF EXISTS `tCommunityCategoryM`;
CREATE TABLE `tCommunityCategoryM` (
  `community_category_id` int(10) unsigned NOT NULL auto_increment COMMENT '�R�~���j�e�B�J�e�S����ID',
  `community_category_logid` bigint(20) unsigned NOT NULL COMMENT '�R�~���j�e�B�J�e�S����POW����ID',
  `community_category_name` char(20) NOT NULL COMMENT '�R�~���j�e�B�[�̃J�e�S����',
  PRIMARY KEY  (`community_category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�[�J�e�S���}�X�^';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tCommunityM`
--

DROP TABLE IF EXISTS `tCommunityM`;
CREATE TABLE `tCommunityM` (
  `community_id` int(10) unsigned NOT NULL auto_increment COMMENT '�R�~���j�e�BID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT '��ԁ@�L���͂Q',
  `community_name` char(100) NOT NULL COMMENT '�R�~���j�e�B��',
  `community_category_id` smallint(5) unsigned NOT NULL COMMENT '�R�~���j�e�B�[�J�e�S��',
  `community_description` text NOT NULL COMMENT '�R�~���j�e�B�̐������i�S�������ɂ����p�j',
  `community_image_id` int(10) unsigned NOT NULL,
  `community_member_flag` tinyint(3) unsigned NOT NULL COMMENT '�Q�����x���t���O',
  `community_topic_flag` tinyint(3) unsigned NOT NULL COMMENT '�g�s�b�N�쐬�����t���O',
  `community_admin_owid` int(10) unsigned NOT NULL COMMENT '�R�~���j�e�B�[�Ǘ��҂�owid',
  `community_admin_nickname` char(40) NOT NULL COMMENT '�R�~���j�e�B�[�Ǘ��҂̃j�b�N�l�[��',
  `community_admin_id` char(20) NOT NULL COMMENT '�Ǘ��҂�ID(URL�ɂ����)',
  `community_total_member` int(10) unsigned NOT NULL COMMENT '�R�~���j�e�B�[�ɎQ���l��',
  `registration_date` date NOT NULL COMMENT '�쐬��',
  `expire_date` date default NULL COMMENT '�����ɂȂ�����',
  PRIMARY KEY  (`community_id`),
  KEY `community_category_id` (`community_category_id`),
  FULLTEXT KEY `community` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_name`,`community_description`)
) ENGINE=MyISAM  DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�[�}�X�^�[';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tCommunityMemberM`
--

DROP TABLE IF EXISTS `tCommunityMemberM`;
CREATE TABLE `tCommunityMemberM` (
  `community_id` int(10) unsigned NOT NULL COMMENT '�R�~���j�e�B�[��ID(�����̎�L�[)',
  `community_member_owid` int(10) unsigned NOT NULL,
  `community_member_nickname` char(40) NOT NULL,
  `community_member_id` char(20) NOT NULL COMMENT '�����ID',
  `status_flag` tinyint(3) unsigned NOT NULL COMMENT '���',
  `community_admin_flag` tinyint(3) unsigned default NULL COMMENT '�����t���O 2�͊Ǘ��l null�͒ʏ�',
  `registration_date` date NOT NULL COMMENT '�o�^���i�Q���j',
  `withdraw_date` date NOT NULL COMMENT '�މ��',
  PRIMARY KEY  (`community_member_owid`,`community_id`),
  KEY `status_flag` (`status_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�[�Q���҃}�X�^';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tCommunityTopicCommentF`
--

DROP TABLE IF EXISTS `tCommunityTopicCommentF`;
CREATE TABLE `tCommunityTopicCommentF` (
  `community_comment_id` int(10) unsigned NOT NULL auto_increment COMMENT '�R�����g��ID(������L�[)',
  `community_id` int(10) unsigned NOT NULL COMMENT '�R�~���j�e�B�[��ID',
  `community_topic_id` int(10) unsigned NOT NULL COMMENT '�g�s�b�N��ID',
  `community_comment` text NOT NULL COMMENT '�R�����g�{��',
  `commentater_owid` int(10) unsigned NOT NULL COMMENT '�R�����g���owid',
  `commentater_nickname` char(40) NOT NULL COMMENT '�R�����g��̃j�b�N�l�[��',
  `commentater_id` char(20) NOT NULL COMMENT '�R�����g���������ID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '�ŏI�X�V��',
  PRIMARY KEY  (`community_id`,`community_topic_id`,`community_comment_id`),
  KEY `commentater_owid` (`commentater_owid`),
  FULLTEXT KEY `community_comment` USING MECAB, NORMALIZE, 512 (`community_comment`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�g�s�b�N�ɑ΂���R�����g';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tCommunityTopicF`
--

DROP TABLE IF EXISTS `tCommunityTopicF`;
CREATE TABLE `tCommunityTopicF` (
  `community_topic_id` int(10) unsigned NOT NULL auto_increment COMMENT '�g�s�b�N��ID�i������L�[�j',
  `community_id` int(10) unsigned NOT NULL COMMENT '�R�~���j�e�B�[��ID',
  `community_topic_title` char(60) NOT NULL COMMENT '�g�s�b�N�薼',
  `community_topic` text NOT NULL COMMENT '�g�s�b�N�{��',
  `community_topicowner_owid` int(10) unsigned NOT NULL COMMENT '�g�s��owid',
  `community_topicowner_nickname` char(40) NOT NULL COMMENT '�g�s��j�b�N�l�[��',
  `community_topicowner_id` char(20) NOT NULL COMMENT '��ߎ�̉��ID',
  `registration_date` datetime default NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '�ŏI�X�V����',
  PRIMARY KEY  (`community_id`,`community_topic_id`),
  KEY `community_topicowner_owid` (`community_topicowner_owid`),
  FULLTEXT KEY `community_topic_title` USING MECAB, NORMALIZE, SECTIONALIZE, 512 (`community_topic_title`,`community_topic`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='�R�~���j�e�B�[�̃g�s�b�N�e�[�u��';

-- --------------------------------------------------------


--
-- �e�[�u���̍\�� `tUserImageF`
--

DROP TABLE IF EXISTS `tUserImageF`;
CREATE TABLE `tUserImageF` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `owid` int(10) NOT NULL COMMENT '����̃V�X�e��id',
  `image` mediumblob NOT NULL COMMENT '���摜',
  `thumbnail_320` mediumblob NOT NULL COMMENT '320x240',
  `thumbnail_200` mediumblob NOT NULL COMMENT '120x200�̉摜',
  `thumbnail_64` mediumblob NOT NULL COMMENT '64x64',
  `mime_type` char(20) NOT NULL,
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '���̃��R�[�h�ɉ��炩�̕ύX���������ꍇ�Ɏ����I�ɓ��t���X�V�����B',
  PRIMARY KEY  (`owid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='����p���[���ŉ摜�A�b�v���[�h�i�[�e�[�u��';


--
-- �e�[�u���̍\�� `tProfilePageSettingM`
--

DROP TABLE IF EXISTS `tProfilePageSettingM`;
CREATE TABLE `tProfilePageSettingM` (
  `owid` int(10) unsigned NOT NULL COMMENT '���[�U�[��tMemberM.owid',
  `profile_bit` int(10) unsigned NOT NULL default '1' COMMENT '���J�v���t�B�[�����ڂ̃r�b�g���v�l',
  `tuserimagef_id` int(10) unsigned default NULL COMMENT '���̂Ɏg�p����摜id',
  `designtmplt_flag` tinyint(3) unsigned NOT NULL COMMENT '�޻޲݃e���v���̗��p�L��',
  `designtmplt_filename` char(12) default NULL COMMENT '�޻޲݃e���v���[�g�̃t�@�C����',
  `designtmplt_description` varchar(20) NOT NULL COMMENT '�����ւ��e���v���[�g�̌Ăі�',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '�ŏI�X�V��',
  PRIMARY KEY  (`owid`),
  KEY `designtmplt_flag` (`designtmplt_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='�f�t�H���g���̨�ق̐ݒ�';

-- --------------------------------------------------------



--
-- �e�[�u���̍\�� `tMessageInBoxF`
--

DROP TABLE IF EXISTS `tMessageInBoxF`;
CREATE TABLE `tMessageInBoxF` (
  `message_id` char(20) NOT NULL COMMENT '���M���b�Z�[�WID(���M�{�b�N�X�̃��b�Z�[�WID�j',
  `status_flag` tinyint(3) unsigned default NULL COMMENT '���ǃt���O NULL�͖���. �P�͊��� 2�͕ԐM�ς�(�Ƃ肠����)',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '���o�l(���M��)��owid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT '���l(��M��)��owid',
  `sender_nickname` char(40) NOT NULL COMMENT '���o�l�̂̃j�b�N�l�[��',
  `subject` char(40) default NULL COMMENT '����',
  `message` text COMMENT '���b�Z�[�W�̖{��(���e)',
  `received_date` datetime NOT NULL COMMENT '���b�Z�[�W��M��',
  `message_read_date` datetime default NULL COMMENT '���b�Z�[�W�����ǂɂȂ�������',
  `image_flag` tinyint(3) unsigned default NULL COMMENT '�摜�t���b�Z�̏ꍇ�͐��l������',
  PRIMARY KEY  (`message_id`),
  KEY `status_flag` (`status_flag`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='���[�����b�Z�[�W��M�{�b�N�X';

-- --------------------------------------------------------

--
-- �e�[�u���̍\�� `tMessageOutBoxF`
--

DROP TABLE IF EXISTS `tMessageOutBoxF`;
CREATE TABLE `tMessageOutBoxF` (
  `message_id` char(20) NOT NULL COMMENT '���M���b�Z�[�WID',
  `reply_message_id` char(20) default NULL COMMENT '��M�������b�Z�[�W�ɕԐM�����Ƃ��̎�M���b�Z�[�WID.�ŏ��̑��M���͂�����NULL�ɂȂ�B',
  `sender_owid` int(10) unsigned NOT NULL COMMENT '���o�l(���M��)��owid',
  `recipient_owid` int(10) unsigned NOT NULL COMMENT '���l(��M��)��owid',
  `recipient_nickname` char(40) NOT NULL COMMENT '�󂯎��l�̂̃j�b�N�l�[��',
  `subject` char(40) default 'no subject' COMMENT '����',
  `message` text COMMENT '���b�Z�[�W�̖{��(���e)',
  `send_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`message_id`),
  KEY `sender_owid` (`sender_owid`),
  KEY `recipient_owid` (`recipient_owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='���[�����b�Z�[�W���M�{�b�N�X';

-- --------------------------------------------------------