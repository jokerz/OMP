#!/usr/bin/perl

#******************************************************
# 
# メルマガ拒否設定（空メール）
# 2008/06/03
#******************************************************

use strict;
use MIME::Parser;
use MIME::WordDecoder;
use POSIX;
use lib qw(/home/vhosts/JKZ);
use JKZ::UsrWebDB;

my $outputdir= '/home/vhosts/hp01.up-stair.jp/local/tmp_pool/';

#########################################
#
#	メールの内容
#
my $mail_from;
my $mail_date;
my $mail_subject;
my $mail_body;
#
#
#########################################

sub dump_entity {
    my ($entity) = @_;

  # HEAD
    $mail_from .= $entity->head->get('from');
    chomp ($mail_from);
    $mail_date .= $entity->head->get('date');
    $mail_subject .= $entity->head->get('subject');

  # BODY
    my @parts = $entity->parts;
    if (@parts) {
    	my $i;
        foreach $i (0 .. $#parts) {       # dump each part...
            dump_entity($parts[$i]);
        }
    }
    1;
}
#------------------------------
#
# main
#

sub main {
  # read STDIN
    my $buf;
    {
        local $/;
        $buf= <>;
    }
  # Parse setting...
    my $parser = new MIME::Parser;
    $parser->output_to_core(1);
    $parser->tmp_recycling(1);
    $parser->tmp_to_core(1);
    $parser->use_inner_files(1);

    my $entity = $parser->parse_data($buf) or die;

    dump_entity($entity);

##################################################
#
#	共通初期設定
#
	my $dev_flg;
	 if ($mail_from =~ /^[^@]+\@docomo\.ne\.jp/) {$dev_flg = 'd';}
	elsif ($mail_from =~ /\@ezweb\.ne\.jp/) {$dev_flg = 'e'; }
	elsif ($mail_from =~ /vodafone\.ne\.jp/) {$dev_flg = 'v'; }
	else {$dev_flg = 'pc';}# if $mail_from !~ /\@docomo\.ne\.jp/ || $mail_from !~ /\@ezweb\.ne\.jp/ || $mail_from !~ /vodafone\.ne\.jp/;


    #####@使用テーブルのhash
	my $Table = 'mail_reject';
    #####@使用SQL
    my %SQL = (
				'inert_reject'	=>	"REPLACE INTO $Table ( mailaddr, dev_flg, regdate ) VALUES( ?, ?, NOW())",
    		  );
#
##################################################

	my $dbh = WebDB::connect ();
    $dbh->do('SET NAMES SJIS');

	##############################3
	#
	#	トランザクション処理
	#
	my $attr_ref = WebDB::TransactInit ($dbh);
	eval {
    	$dbh->do ($SQL{inert_reject},undef,$mail_from,$dev_flg);
    	$dbh->commit ();
	};
	WebDB::TransactFin ($dbh,$attr_ref,$@);

	$dbh->disconnect ();

    1;
}

exit(&main ? 0 : -1);

#------------------------------
1;
