
package Finance::Bank::POST::TW;
our $VERSION = '0.01';
use strict;
use Carp;
use utf8;
use pQuery;

use WWW::Mechanize;
use Inline::Java;

our $ua = WWW::Mechanize->new(
    env_proxy => 1,
    keep_alive => 1,
    timeout => 120,
);

sub check_balance {
	my ($u,$p,$a) = @_;
	my $credit;
	my $creditsub;
	my $date;
	my $balance;

	my $ePin;
	my $eKey;
	my $usercode_ePin;
	my $usercode_eKey;

	croak "Must provide a username" unless $u;
	croak "Must provide a password" unless $p;
	croak "Must provide a account number" unless $a;

	my $login_url='https://ipost.post.gov.tw/web/CSController';

	#create ePin

	#create eKey
	

	#https://postserv.prsb.gov.tw/web/index.htm
	#https://ipost.post.gov.tw/web/index.htm
	#https://ipost.post.gov.tw/web/login.htm
	#https://ipost.post.gov.tw/web/CSController

	#https://ipost.post.gov.tw/web/ChunghwaPost.jar

	$ua->get($login_url);

	$ua->submit_form( form_name=>'MainForm',
			  fields => {	cmd=>'POS0000_2',
			  		chgUserIdFalg=>'0',
					isPWDNum=>'1',
					ePin=>"$ePin",
					eKey=>"$eKey",
					usercode_ePin=>"$usercode_ePin",
					usercode_eKey=>"$usercode_eKey",
					oldUSERTYPE=>'1',
					USERTYPE=>'1',
					USERID=>"$u",
					PWD=>"$p",
					USERCODE=>"$a", }
			);



	$ua->get("$login_url?cmd=CUR1002_1&_ACTIVE_ID=2");

	my $content = $ua->content;

	# logout
	$ua->get("$login_url?cmd=POS0000_5");

	# parse html
	pQuery("td", $content)->each(sub {
		my $i = shift;
		if ($i==48) { # the line included all information
			if ( pQuery($_)->text() =~ m{局號：\ dispBranch\('([\d]+?)'\)\ 帳號：\ dispAcctNo\('([\d]+?)'\)\ 查詢日期時間：\ dispFormatDateTimeRoc\('([\d]+?)'\)\ 截至目前之可用餘額：\ dispComma\('([\d,.]+?)',[\d]+?\)}s ) {
				$credit=$1;
				$creditsub=$2;
				$date=$3;
				$balance=$4;
			}
		}
	});

	return {
		credit => $credit,
		creditsub => $creditsub,
		date => $date,
		account => $a,
		balance => $balance,	
	}; 


}

__END__

=head1 NAME

Finance::Bank::POST::TW - Check POST accounts from Perl

=head1 SYNOPSIS

    use Finance::Bank::POST::TW;

    my $post = Finance::Bank::POST::TW::check_balance($username,$password,$account);

    foreach (keys %$post) {
        print "$_ : " . $post->{$_}. "\n";
    }

=head1 DESCRIPTION

This module provides a rudimentary interface to the Fubon eBank
banking system at L<http://ipost.post.gov.tw/>.

You will need either B<Crypt::SSLeay> or B<IO::Socket::SSL> installed
for HTTPS support to work with LWP.

You will also need B<Inline::Java> to support ePin, eKey, usercode_ePin,
usercode_eKey computing from ChunghwaPost.jar which published by ipost.

=head1 CLASS METHODS

    check_balance(username => $u, password => $p, account=>$a );

Return your balance information for account number $a.

=head1 WARNING

This is code for B<online banking>, and that means B<your money>, and
that means B<BE CAREFUL>. You are encouraged, nay, expected, to audit
the source of this module yourself to reassure yourself that I am not
doing anything untoward with your banking data. This software is useful
to me, but is provided under B<NO GUARANTEE>, explicit or implied.

=head1 AUTHORS

Macpaul Lin E<lt>macpaul@gmail.comE<gt>

Based on B<Finance::Bank::LloydTSB> by Simon Cozens C<simon@cpan.org>,
and B<Finance::Bank::Fubon::TW> by Autrijus Tang C<autrijus@autrijus.org>,
and B<Finance::Bank::SCSB::TW> by Kang-min Liu E<lt>gugod@gugod.orgE<gt>

=head1 COPYRIGHT

Copyright 2008 by Macpaul Lin E<lt>macpaul@gmail.comE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

