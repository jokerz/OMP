-- 2010/06/28 --
-- �ʒu�o�^���֘A --


DROP TABLE IF EXISTS `tIchiLogF`;
CREATE TABLE  `tIchiLogF` (
 `ichi_id` int unsigned NOT NULL AUTO_INCREMENT,
 `owid` int unsigned NOT NULL,
 `distance` CHAR(6) COMMENT '�ړ�����',
 `iArea_code` tinyint unsigned NOT NULL COMMENT '�h�R���t���G���A�R�[�h(area_id+sub_areaid)',
 `iArea_areaid` tinyint unsigned NOT NULL COMMENT '�h�R���̃G���AID�@3��',
 `iArea_sub_areaid` tinyint unsigned NOT NULL COMMENT '�h�R���̃T�u�G���AID�@2��',
 `iArea_region` CHAR(40) COMMENT '�n�於',
 `iArea_name` CHAR(40) COMMENT '�G���A��',
 `iArea_prefecture` CHAR(40) COMMENT '�s���{��',
 `startpoint_ido` CHAR(20) COMMENT '�J�n�ܓx',
 `startpoint_keido` CHAR(20) COMMENT '�J�n�o�x',
 `endpoint_ido` CHAR(20) COMMENT '�I���ܓx',
 `endpoint_keido` CHAR(20) COMMENT '�I���o�x',
 `registration_date` DATETIME NOT NULL,
 PRIMARY KEY (`owid`,`ichi_id`)
) ENGINE=MyIsam DEFAULT CHARSET=sjis COMMENT='�ʒu���o�^�e�[�u��';