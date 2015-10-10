package JKZ::JKZApp::AppTest;
use base qw( JKZ::JKZApp );
use 5.008005;
our $VERSION = '1.00';
use strict;
use JKZ::JKZDB::Adv;


#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	
# @return	
#******************************************************
sub new {
	my ($class, $cfg) = @_;

	return $class->SUPER::new($cfg);
}

#******************************************************
# @access	public
# @desc		親クラスのメソッド
# @param	
#******************************************************
sub dispatch {
	my $self = shift;

	$self->run_test();
}




sub run_test {
	my $self = shift;

	my $dbh = $self->getDBConnection();
	$self->setDBCharset("sjis");
	$dbh->do("set names sjis");

my $obj = {};
my @tables	= qw/tQuestionnarieM tQuestionnarieF tQuestionnarieElementF tAnswerElementF tQuestionnarieAnswerF tQuestionnarieAnswerDataF/;
my @columns = qw/Field Type Null Key Default Extra Comment/;
my @column_name = ('フィールド名', '型', 'NULL', 'キー', 'デフォルト', 'その他', 'コメント',);
my @records;

my $sql;

my $q = CGI->new();

# Field | Type | Collation | Null | Key | Default | Extra | Privileges Comment
#foreach my $table (@tables) {
my $tabledata;
foreach my $index (0..5) {
	$sql = sprintf("SHOW FULL COLUMNS FROM %s;", $tables[$index]);

	my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} } );

	$tabledata .= $q->Tr($q->th({-colspan=>$#columns+1}, $tables[$index]));
	$tabledata .= $q->Tr($q->th([@column_name]));

	foreach my $ref (@{ $aryref }) {
		$tabledata .= $q->Tr($q->td([map { $ref->{$_} } @columns]));
	}
	$tabledata .= $q->Tr($q->td({-colspan=>$#columns+1}, '<br />'));
}


#	my $C = JKZ::JKZDB::Adv->new($dbh);
#	$C->executeSelect({whereSQL => "acd=?", placeholder => ['sexy01']});

print "Content-type: text/html\n\n";
print <<_HEAD_;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja">
<head>
<title>AccessorTest</title>
<meta http-equiv="Content-type" content="text/html; charset=Shift_JIS">
<style type="text/css">
<!--/* <![CDATA[ */
.datagrid {
    background-color:White;
    border-color:#3366CC;
    border-width:1px;
    border-style:None;
    border-collapse:collapse;
}

table.datagrid td,th {
    width:640px;
    border:1px solid #3366CC;
    /*font-size:0.9em;*/
    font-size:12px;
    padding: 2px 2px 2px 2px;
}
th{
    background-color:#D8DFE7;
    font-weight:normal;
    /*color:#7B869A;*/
    color:#000000;
}

/* ]]> */-->
</style>
</head>
<body>
<i>20090930 アンケート関連DB定義</i>
_HEAD_


print $q->table({-class=>"datagrid"},$tabledata);

#print WebUtil::warnMSGtoBrowser($obj);
#print WebUtil::warnMSGtoBrowser(\@records);


=pod
print $C->id() ,'<hr>';
print $C->acd() ,'<hr>';
print $C->access_url() ,'<hr>';
print $C->comment() ,'<hr>';
=cut
=pod
print $C->col_accessor("id") ,'<hr>';
print $C->col_accessor("acd") ,'<hr>';
print $C->col_accessor("access_url") ,'<hr>';
print $C->col_accessor("comment") ,'<hr>';

my $a = $C->col_accessor();
print map { $_ . '---' . $a->{$_} . '<br />' } keys %{$a};
=cut


print "</body></html>";


}




1;
__END__