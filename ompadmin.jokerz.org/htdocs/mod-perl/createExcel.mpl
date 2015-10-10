
#******************************************************
# @desc		Excelファイル生成
#			
# @package	createExcel.mpl
# @access	
# @author	Iwahase Ryo 
# @create	2009/08/10
# @update	
# @version	1.0
#******************************************************



#my $data = shift;

use Jcode;
use Unicode::String qw(utf8 utf16);
#use utf8;
use Encode;
use Spreadsheet::WriteExcel;

use CGI;


my $q = CGI->new();

my $searchkey = $q->param('s');




my $searchCondition = {
	searchmember	=> {
			table		=> 'tMemberM',
			columns		=> ['mid', 'subno', 'guid', 'memberstatus_flag', 'point', 'carrier', 'mobilemailaddress', 'useragent', 'status_flag', 'registration_date', 'withdraw_date', 'reregistration_date',],
			columnsJP	=> ['ID', 'dcmguid/up_subno', 'subno', '種別', 'ポイント', 'キャリア', 'メールアドレス', 'USERAGENT', '登録状態', '入会日', '退会日', '\再\入会日'],
	},
};


my $cookie = $q->cookie('CMSKKFLA_USERsearchcondition');

## Modified 2009/10/29 BEGIN

#my ($condition, $holder) = split (/,/, $cookie);
#my @placeholder = split(/ /, $holder);

my ($condition_sqlmessage, $holder) = split (/,/, $cookie);
my @placeholder = split(/ /, $holder);
my ($condition, $sqlmessage) = split(/::/, $condition_sqlmessage);

## Modified 2009/10/29 END

my $sql = sprintf("SELECT %s FROM %s WHERE %s", join(', ', @{ $searchCondition->{$searchkey}->{columns} }), $searchCondition->{$searchkey}->{table}, $condition);
my $dbh = JKZ::UsrWebDB::connect();
my $aryref = $dbh->selectall_arrayref($sql, undef, @placeholder);
$dbh->disconnect();


#print $q->header();
#print $q->start_html();
#print $sql;
#print $q->end_html();
#ModPerl::Util::exit();


print CGI::header(-type=>'application/vnd.ms-excel');
binmode(STDOUT);

my $workbook = Spreadsheet::WriteExcel->new(\*STDOUT);

my $format = $workbook->add_format();
## set font type size color and so on
$format->set_font("MS PGothic");
# 文字のサイズ
$format->set_size(9);
# 文字色
$format->set_color('white');
# bold
$format->set_bold();
$format->set_border();
# 文字位置
$format->set_align('center');
# 背景色
$format->set_bg_color(24);


my $format2 = $workbook->add_format();

$format2->set_top(1);
$format2->set_left(4);
$format2->set_right(4);
$format2->set_bottom(1);


# create worksheet  and write info
my $work_sheet = $workbook->add_worksheet(utf8( Jcode->new('シート１')->utf8 )->utf16,1);

## set width of CELL A
$work_sheet->set_column(0, 0, 6);
## set width of CELL B to M
$work_sheet->set_column('B:M', 11);

#$work_sheet->write_unicode(0,0, utf8( Jcode->new("集計データだよーん")->utf8 )->utf16, $format);


foreach (0..$#{ $searchCondition->{$searchkey}->{columnsJP} }) {
	$work_sheet->write_unicode(1, $_, utf8( Jcode->new($searchCondition->{$searchkey}->{columnsJP}->[$_])->utf8 )->utf16, $format);
}


foreach my $loop (0..$#{$aryref}) {
	my $pos = $loop + 1;
	map { $work_sheet->write($pos, $_, $aryref->[$loop]->[$_], $format2) } (0..$#{$aryref->[$loop]});
}



ModPerl::Util::exit();


__END__




=pod
$work_sheet->write_unicode(1,0, utf8( Jcode->new("日付")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,1, utf8( Jcode->new("登録者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,2, utf8( Jcode->new("退会者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,3, utf8( Jcode->new("アクセス数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,4, utf8( Jcode->new("ページビュー")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,5, utf8( Jcode->new("登録者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,6, utf8( Jcode->new("退会者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,7, utf8( Jcode->new("アクセス数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,8, utf8( Jcode->new("ページビュー")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,9, utf8( Jcode->new("登録者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,10,utf8( Jcode->new("退会者数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,11,utf8( Jcode->new("アクセス数")->utf8 )->utf16, $format);
$work_sheet->write_unicode(1,12,utf8( Jcode->new("ページビュー")->utf8 )->utf16, $format);
=cut

=pod
my $data = [
		[qw(2(木) 3 3 65 207 3 3 55 0 0 0 0 0 10)],
		[qw(3(金) 1 1 14 36 1 1 12 0 0 0 0 0 2)],
		[qw(4(土) 0 0 3 7 0 0 0 0 0 0 0 0 3)],
		[qw(5(日) 0 0 1 2 0 0 1 0 0 0 0 0 0)],
		[qw(6(月) 0 0 29 90 0 0 18 0 0 6 0 0 5)],
		[qw(7(火) 0 0 6 8 0 0 6 0 0 0 0 0 0)],
		[qw(8(水) 0 0 3 9 0 0 3 0 0 0 0 0 0)],
		[qw(9(木) 0 0 16 42 0 0 16 0 0 0 0 0 0)],
		[qw(10(金) 0 0 1 4 0 0 1 0 0 0 0 0 0)],
		[qw(12(日) 0 0 1 3 0 0 0 0 0 0 0 0 1)],
		[qw(13(月) 0 0 3 7 0 0 3 0 0 0 0 0 0)],
		[qw(14(火) 0 0 22 25 0 0 22 0 0 0 0 0 0)],
];

foreach (0..$#{$data}) {
	my $pos = $_ + 2;
	$work_sheet->write_unicode($pos, 0,  utf8( Jcode->new($data->[$_]->[0])->utf8 )->utf16, $format);
	$work_sheet->write($pos, 1, $data->[$_]->[1], $format2);
	$work_sheet->write($pos, 2, $data->[$_]->[2], $format2);
	$work_sheet->write($pos, 3, $data->[$_]->[3], $format2);
	$work_sheet->write($pos, 4, $data->[$_]->[4], $format2);
	$work_sheet->write($pos, 5, $data->[$_]->[5], $format2);
	$work_sheet->write($pos, 6, $data->[$_]->[6], $format2);
	$work_sheet->write($pos, 7, $data->[$_]->[7], $format2);
	$work_sheet->write($pos, 8, $data->[$_]->[8], $format2);
	$work_sheet->write($pos, 9, $data->[$_]->[9], $format2);
	$work_sheet->write($pos, 10,$data->[$_]->[10], $format2);
	$work_sheet->write($pos, 11,$data->[$_]->[11], $format2);
	$work_sheet->write($pos, 12,$data->[$_]->[12], $format2);
}

=cut