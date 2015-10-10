-- 2010/06/28 --
-- 位置登録情報関連 --


DROP TABLE IF EXISTS `tIchiLogF`;
CREATE TABLE  `tIchiLogF` (
 `ichi_id` int unsigned NOT NULL AUTO_INCREMENT,
 `owid` int unsigned NOT NULL,
 `distance` CHAR(6) COMMENT '移動距離',
 `iArea_code` tinyint unsigned NOT NULL COMMENT 'ドコモフルエリアコード(area_id+sub_areaid)',
 `iArea_areaid` tinyint unsigned NOT NULL COMMENT 'ドコモのエリアID　3桁',
 `iArea_sub_areaid` tinyint unsigned NOT NULL COMMENT 'ドコモのサブエリアID　2桁',
 `iArea_region` CHAR(40) COMMENT '地域名',
 `iArea_name` CHAR(40) COMMENT 'エリア名',
 `iArea_prefecture` CHAR(40) COMMENT '都道府県',
 `startpoint_ido` CHAR(20) COMMENT '開始緯度',
 `startpoint_keido` CHAR(20) COMMENT '開始経度',
 `endpoint_ido` CHAR(20) COMMENT '終了緯度',
 `endpoint_keido` CHAR(20) COMMENT '終了経度',
 `registration_date` DATETIME NOT NULL,
 PRIMARY KEY (`owid`,`ichi_id`)
) ENGINE=MyIsam DEFAULT CHARSET=sjis COMMENT='位置情報登録テーブル';