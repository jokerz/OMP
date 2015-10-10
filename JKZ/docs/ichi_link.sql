-- �ʒu�o�^�E�}�C�����N�֘A�e�[�u�� --
-- 2010/07/06 --

-- ���̃e�[�u���ւ̃f�[�^�}���͋ߏ��̂Ƃ����� --
CREATE TABLE `tMyMessageBoardF` (
  `msg_id` int(10) unsigned NOT NULL auto_increment COMMENT '�����܂̘A��',
  `toid` int(10) unsigned NOT NULL COMMENT '��̉��ID',
  `owid` int(10) unsigned NOT NULL COMMENT '�ɏ������݂�������ID',
  `private_flag` tinyint(1) unsigned NOT NULL default '1' COMMENT '���M�t���O�B 1�͒ʏ�Ŏ��M�I�t 2�̏ꍇ�͎��M�I���Ŕ�Ə������ݎ҂������{���ł���',
  `message` text,
  `neighbor_nickname` char(40) NOT NULL COMMENT '�����N��̃j�b�N�l�[��',
  `registration_date` datetime default NULL,
  PRIMARY KEY  (`toid`,`msg_id`),
  KEY `owid` (`owid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='�}�C�����N�̃e�[�u��';



CREATE TABLE `tMyIchi` (
  `owid` int(10) unsigned NOT NULL,
  `ichi_id` int(10) unsigned NOT NULL,
  `distance` char(6) default NULL COMMENT '�ړ�����',
  `iArea_code` tinyint(5) unsigned zerofill NOT NULL,
  `iArea_areaid` tinyint(3) unsigned zerofill NOT NULL,
  `iArea_sub_areaid` tinyint(2) unsigned zerofill NOT NULL,
  `iArea_region` char(40) default NULL COMMENT '�n�於',
  `iArea_name` char(40) default NULL COMMENT '�G���A��',
  `iArea_prefecture` char(40) default NULL COMMENT '�s���{��',
  `startpoint_ido` char(20) default NULL COMMENT '�J�n�ܓx',
  `startpoint_keido` char(20) default NULL COMMENT '�J�n�o�x',
  `endpoint_ido` char(20) default NULL COMMENT '�I���ܓx',
  `endpoint_keido` char(20) default NULL COMMENT '�I���o�x',
  `registration_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`owid`),
  KEY `iArea_areaid` (`iArea_areaid`),
  KEY `iArea_sub_areaid` (`iArea_sub_areaid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='�ʒu���o�^�e�[�u��';



CREATE TABLE `tMyLinkListF` (
  `owid` int(10) unsigned NOT NULL COMMENT '�����̉��ID',
  `toid` int(10) unsigned NOT NULL COMMENT '�����N��̉��ID',
  `neighbor_nickname` char(40) NOT NULL COMMENT '�����N��̃j�b�N�l�[��',
  `registration_date` datetime default NULL,
  PRIMARY KEY  (`owid`,`toid`)
) ENGINE=MyISAM DEFAULT CHARSET=sjis COMMENT='�}�C�����N�̃e�[�u��';



CREATE TABLE `tProfilePageSettingM` (
  `owid` int(10) unsigned NOT NULL COMMENT '���[�U�[��tMemberM.owid',
  `nickname` char(40) default NULL,
  `profile_bit` int(10) unsigned NOT NULL default '1' COMMENT '���J�v���t�B�[�����ڂ̃r�b�g���v�l',
  `tuserimagef_id` int(10) unsigned default NULL COMMENT '���̂Ɏg�p����摜id',
  `selfintroduction` text,
  `designtmplt_flag` tinyint(3) unsigned NOT NULL COMMENT '�޻޲݃e���v���̗��p�L��',
  `designtmplt_filename` char(12) default NULL COMMENT '�޻޲݃e���v���[�g�̃t�@�C����',
  `designtmplt_description` varchar(20) NOT NULL COMMENT '�����ւ��e���v���[�g�̌Ăі�',
  `lastupdate_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '�ŏI�X�V��',
  PRIMARY KEY  (`owid`),
  KEY `designtmplt_flag` (`designtmplt_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=sjis COMMENT='�f�t�H���g���̨�ق̐ݒ�';