#!/usr/bin/perl -w
use strict;
use warnings;

# TODO:
# on hl : oh my bot !
# hl la personne
# NEED
# /invite
# bite du bot / balembot bite
# FIXME:
# regex avec hash map sur quote 

# Module IRC
use POE;
use POE::Component::IRC;
use List::Util qw(shuffle);

# Vars
my $tps_jizzception = 0;
my $tps_dick_in_a_box = 0;
my $tps_jizz = 0;
my $tps_coucou = 0;
my $user_coucou = '';
my $id_coucou = 0;
my $bot_owner = 'Skelz0r';
my $last_msg = "";
my $last_kick_user = '';

my $file_dir = "txt";
my $file_quotes = "$file_dir/quotes_balemboy.txt";
my $file_coucou = "$file_dir/coucou.txt";
my $file_fu = "$file_dir/fu.txt";
my $file_jizz = "$file_dir/jizz.txt";
my %colors = (
	0 => 15,
	1 => 1,
	2 => 2,
	3 => 3,
	4 => 4,
	5 => 5,
	6 => 6,
	7 => 7,
	8 => 7,
	9 => 3,
	10 => 10,
	11 => 10,
	12 => 2,
	13 => 6,
	14 => 1,
	15 => 15,
);

my @coucou_non = ("Tss", "Eoh, tu vas te clamer stp merci", "JUST CORN!", "Pas cool :(", "Genre !", ":(", "T'as peur hein ? ;D", "Pffff", "T'as bien raison :)","FU","Noob","Just LOL","Tocard ..");
my @insultes = ("pute",,"trainée","raclure","michou","fiente","salaud", "batard","vtff","rage","connard","non","kill","kick","ban","oui","gueule","sale","fat","gros","tg","noob","enfoiré","espèce de","enfoirayd","n00b","boufon","tu");
my @hl_bot = ("Arrête tes bétises stp", "OH MY BOT !", "Oui ?", "Comment ?", "Mais qu'est-ce que tu racontes ?","Tu sais que tu parles à un robot ? TOCARD !", "N'impZ", "Non", "Wtf ?", "Je ne sais pas", "Oui", "Ta gueule un peu pour voir ?", "RAF", "TG n00b","LOL","WHAAAAAT ?","FU","Arrête de faire ton kevin ..","Seriously ..", "Tocard", "gizmo: Kick le, il sert à rien", "Idiot");
my @need = ("ableton", "rhum","bière", "vodka", "apéro", "drogue", "clope", "sexe", "anna", "leffe", "cognac", "whisky", "vin", "gin", "fête", "soirée","pipe","fellation","sodomie","porn","feriel","weed","cigarette","anna","marvin","tabac","café","cafe", "guinness", "whiskey", "beer");
my @cla_array = ("RINETTE", "FOUTI", "non", "SSIQUE", "MARD", "VICULE", "PET", "BOTER", "MANT", "MÉ", "BAUD", "BAUDAGE", "MSER", "POTAGE", "QUE", "QUETTE", "KEKETTE", "RIFIER", "SH", "VECIN", "VIER", "YON", "YETTE", "QUÉ", "PIR");
my @bonhomme_tete = ('&','#','@','§','o','ô','$','()','[]','{}','0','8','<>');
my @bonhomme_bras_g = ('\\','\\\\',' ','_','/','\\');
my @bonhomme_bras_d = ('/',' ','//','_','/','\\');
my $bbb = 0;
my $bbb_rand = 0;
my $bbb_cpt = 0;

### FONCTIONS
## Récupération des données d'un fichier + nombre de données
# Arg : file_path [, compte_donnee]
# compte_donnee = 0 ou 1
sub recup_donnees_text
{
	my ($file,$bool_compte_donnees) = @_;

	# Stockage des données
	open(DONNEES,$file) or die ("Impossible d'ouvrir $file");
	my @donnees = <DONNEES>;
	chomp(@donnees);
	close(DONNEES);

	# Si on compte les données
	if ( $bool_compte_donnees == 1 )
	{
		my $nbr_donnees = 0;

		open(NBR_DONNEES, $file) or die ("Impossible d'ouvrir $file");
		while ( <NBR_DONNEES> ) { $nbr_donnees++; }
		close(NBR_DONNEES);

		return ($nbr_donnees,@donnees);
	}
	else
	{
		return (@donnees);
	}
}

### RÉCUPÉRATION DES DONNÉES
my ($nbr_quotes,@quotes) = recup_donnees_text($file_quotes,1);

my ($nbr_coucou,@coucou_tmp) = recup_donnees_text($file_coucou,1);
my @coucou = ();
my @coucou_lien = ();

# Identifiants
my (@ids) = recup_donnees_text("password.txt",0);

my $serveur = 'IRC.iiens.net';
my $nick = @ids[0];
my $port = 6667;

my $ircname = 'I\'m your master !';
my $username = @ids[0];
my $password = @ids[1];

my @channels = ('#balemboy','#anarchiie');

## CONNEXION 
my ($irc) = POE::Component::IRC->spawn();


foreach (@coucou_tmp)
{
	my @tmp_split = split(/\|/,$_);

	push(@coucou,$tmp_split[0]);
	push(@coucou_lien,$tmp_split[1]);
}

my ($nbr_FU,@FU) = recup_donnees_text($file_fu,1);
my ($nbr_jizz,@JIZZ) = recup_donnees_text($file_jizz,1);

## Fonction qui match sur un tableau
sub match_tab
{
	my ($expr,@tab) = @_;

	foreach(@tab)
	{
		return 1 if ( $expr =~ m/$_/i );
	}

	return 0;
}

## Fonction kick safe
sub kick
{
	my ($kernel,$chan,$user,$msg) = @_;

	if ($user ne 'gizmo' && $user ne 'Skelz0r' && $user ne 'Lix')
	{
		$irc->yield(kick => $chan => $user => $msg);
		$last_kick_user = $user;
	}
}
## Affichage d'une quote
sub aff_quote
{
	my ($kernel,$chan,$param) = @_;

	# Cas d'une quote spécifique
	if ( $param =~ m/^\d+$/ )
	{
		$irc->yield(privmsg => $chan,"\x039#$param\x03 : $quotes[$param-1]");
	}
	# Cas d'une chaine
	else
	{
		# Nettoyage de $param
		$param =~ s/\*//i;
		my @tab = grep(/$param/i,@quotes);
		my $taille_tab = scalar @tab;
		my $nbr_rand = int(rand($taille_tab-1));
		my $quote = $tab[$nbr_rand-1];

		if ( $quote !~ m/^$/ )
		{	
			# Récupération de l'id
			my $i = 0;

			foreach(@quotes)
			{
				$i++;
				last if ( $_ eq $quote );
			}

			$irc->yield(privmsg => $chan,"\x039#$i\x03 : $quote");
		}
		else
		{
			$irc->yield(privmsg => $chan,"J'ai pas ce genre de chose en stock, peut-être dtc ?");
		}
	}
}

## Ajout d'une quote
sub add_quote
{
	my ($kernel,$chan,$user,@quote_a_add) = @_;

	my $quote = join(" ",@quote_a_add);

	# Ajout de la quote dans le fichier
	open(ADD_QUOTE,">>$file_quotes");
	print(ADD_QUOTE "$quote\n");
	close(ADD_QUOTE);

	# Ajout dans le tableau
	push(@quotes,$quote);
	$nbr_quotes++;

	# Special BALEMBOY
	if ( $quote =~ m/balemboy/i )
	{
		$irc->yield(privmsg => $chan,"C'est bien jeune pad à wan, une vraie quote contient forcément un BALEMBOY !");
	}
	else
	{
		$irc->yield(privmsg => $chan,"C'est quoi cette quote à deux balles ? Pas de balemboy ?");
		kick($kernel, $chan, $user, "Et bah tu sors !");
		$irc->delay([ctcp => $chan => 'ACTION est outré :o'],1);
		$irc->delay([invite => $user => $chan],5);
	}
}
## Affichage du "Tu veux voir * ?"
sub aff_coucou
{
	my ($kernel,$chan,$user) = @_;
	my $nbr_rand = int(rand($nbr_coucou-1));

	$irc->delay([privmsg => $chan,"$user: Tu veux voir $coucou[$nbr_rand] ?"],2);

	sleep 1;

	$tps_coucou = time;
	$user_coucou = $user;
	$id_coucou = $nbr_rand;
}

sub aff_coucou_lien
{
	my ($kernel,$chan) = @_;

	$irc->delay([privmsg => $chan,"$user_coucou: $coucou_lien[$id_coucou]"],1) if ( $tps_coucou >= time - 10 );

	$tps_coucou -= 10;
}

sub aff_coucou_non
{
	my ($kernel,$chan) = @_;
	my $nbr_rand = int ( rand ( scalar @coucou_non ) + 1 );

	if ( $tps_coucou >= time-10 )
	{
		if ( $nbr_rand == (scalar @coucou_non) )
		{	
			kick($kernel, $chan, $user_coucou, "On ne parle pas comme ça au $username !");
		}
		else
		{
			$irc->delay([privmsg => $chan, "$user_coucou: $coucou_non[$nbr_rand]"],1);
			$irc->delay([invite => $user_coucou => $chan],5);
		}
	}

	$tps_coucou -= 10;
}

## Affichage du FU
sub aff_FU
{
	my ($kernel,$chan) = @_;
	my $nbr_rand = int(rand($nbr_FU-1));

	$irc->yield(privmsg => $chan,"$FU[$nbr_rand]");
}

## Affichage de l'aide
sub aff_help
{
	my ($kernel,$user) = @_;

	$irc->yield(privmsg => $user,"!balemboy: La bonne parole de notre cher maître te guidera vers le droit chemin.")}

## gmab
sub gmab
{
	my ($kernel,$chan) = @_;
	my $fg = int rand 15;
	my $bg = int rand 15;

	while($colors{$bg} == $fg)
	{
		$bg = int rand 15;
	}

	$irc->yield(privmsg => $chan,"\x03".$fg.",".$bg."BALEMBOY !");
}

## jizz
sub aff_jizz_1
{
	my ($kernel,$chan) = @_;

	$irc->delay([privmsg => $chan,"IN"],1);
	sleep 1;
	$tps_jizz = time;
}

sub aff_jizz_2
{
	my ($kernel,$chan) = @_;
	my $nbr_rand = int(rand($nbr_jizz-1));
	my $jizz_sentence = $JIZZ[$nbr_rand];
 	if ( $tps_jizz >= time - 10 )
	{
		$irc->delay([privmsg => $chan,"$jizz_sentence"],1);
		if ($jizz_sentence eq "JIZZ")
		{
			$tps_jizzception = time+10;
		}
		if ($jizz_sentence eq "DICK")
		{
			$tps_dick_in_a_box = time+10;
		}
			
	}

	$tps_jizz -= 10;
}

sub aff_jizz_3
{
	my ($kernel,$chan) = @_;

	$irc->delay([privmsg => $chan,"MY"],1) if ( $tps_jizzception > time );
	$tps_jizzception = time-10;
}

sub aff_dick_box
{
	my ($kernel,$chan) = @_;
	#my @dick_article = ["the", "a", "an"];

	$irc->delay([privmsg => $chan,"A"],1) if ( $tps_dick_in_a_box > time );
	$tps_dick_in_a_box = time-10;
}
## and_again
sub aff_and_again
{
	my ($kernel,$chan) = @_;

	$irc->delay([privmsg => $chan,"AND AGAIN !"],1);
}

## \o/
sub aff_bonhomme
{
	my ($kernel,$chan) = @_;
	my $nbr_rand_1 = int rand 20;
	my $nbr_rand_2 = ( int rand ( scalar @bonhomme_tete ) );
	my $nbr_rand_3 = ( int rand ( scalar @bonhomme_bras_g ) );
	my $str = "";

	for ( my $i = 0 ; $i < $nbr_rand_1 ; $i++ )
	{
		$str .= $bonhomme_bras_g[$nbr_rand_3] . $bonhomme_tete[$nbr_rand_2] . $bonhomme_bras_d[$nbr_rand_3] . " ";
		$nbr_rand_2 = ( int rand ( scalar @bonhomme_tete ) );
		$nbr_rand_3 = ( int rand ( scalar @bonhomme_bras_g ) );
	}

	$irc->delay([privmsg => $chan, $str],1);
}

# BIM BAM BOOM
sub bbb
{
	my ($kernel,$chan,$user,$msg) = @_;

	$bbb_rand = ( int rand 10 ) + 1  if ( $bbb_cpt == 0 );

	$bbb_cpt++ if ( ( $bbb_cpt % 3 == 0 && $msg =~ m/b+i+m+/i ) || ( $bbb_cpt % 3 == 1 && $msg =~ m/b+a+m+/i ) || ( $bbb_cpt % 3 == 2 && $msg =~ m/b+o+m+/i ) );
	if ( $bbb_cpt == 1 && $bbb == 0 )
	{
		$bbb = 1;
		$irc->yield(privmsg => $chan => "C'est parti pour le BIM BAM BOOM !"); 
	}

	if ( $bbb_cpt == $bbb_rand )
	{
		$bbb_cpt = 0;
		$bbb = 0;
		kick($kernel, $chan, $user, "BANG");
	}
}

## GESTION EVENTS
# Evenements que le bot va gérer
POE::Session->create(
	inline_states => {
		_start     => \&bot_start,
		irc_001    => \&on_connect,
		irc_public => \&on_speak,
		irc_join => \&on_join,
	},
);

sub bot_start {
	$irc->yield(register => "all");
	$irc->yield(
		connect => {
			Nick     => $nick,
			Username => $username, 
			Ircname  => $ircname,
			Server   => $serveur,
			Port     => $port,
		}
	);
}


# A la connection
sub on_connect
{
	my ($chan1, $chan2) = @channels;

	$irc->yield(privmsg => 'nickserv',"identify $password"); # identification
	sleep 1;
	$irc->yield(join => $chan1);
	$irc->yield(join => $chan2);
	$irc->yield(privmsg => $chan1,"COUCOU, TU VEUX VOIR MON BYTE?");
}

# Quand un user arrive sur le chan
sub on_join
{
	my ($kernel,$user_) = @_[KERNEL,ARG0];
	my @chan = @_[ARG1];
	my $user = ( split(/!/,$user_) )[0];

	my $fg = int rand 15;
	my $bg = int rand 15;

	while($colors{$bg} == $fg)
	{
		$bg = int rand 15;
	}

	if ($user eq $last_kick_user)
	{
		$irc->yield(privmsg => $chan[0],"\x03".$fg.",".$bg."UMAD ".$user."?") if ( $user ne $username );
		$last_kick_user = '';
	}
	else
	{
		$irc->yield(privmsg => $chan[0],"\x03".$fg.",".$bg."JOYEUX BALEMBOY ".$user." !") if ( $user ne $username );
	}

	#$irc->yield(kick => $chan[0] => $user => "AU REVOIR :P") if ( $user eq 'Barberose' );


#	$irc->yield(mode => $chan[0] => '+v' => $user) if ( $user ne $username );
}

sub counter_kick
{
	my ($kernel,$chan) = @_;
	
	for ( my $i = 0 ; $i < 10 ; $i++ )
	{
		#system("sleep 0.6 ; ./counterkick.pl $i &");
	}

}

# Quand un user parle
sub on_speak
{
	my ($kernel,$user_,$msg) = @_[KERNEL, ARG0, ARG2];
	my @chan = @_[ARG1];

	my $user = ( split(/!/,$user_) )[0];

	# Kick BIO
	#$irc->yield(ban => $chan[0][0] => $user) if ( $user eq "Barberose" );
	#$irc->yield(kick => $chan[0][0] => $user => "TG n00b" ) if ( $user eq "Barberose" );
#	$irc->yield(kick => $chan[0][0] => $user => "TG n00b" ) if ( $user eq "Twibby" );
	
	# Disjonction des cas suivants ce qui est demande
	if ( substr($msg,0,1) eq '!' )
	{
		# Recuperation de la commande & parametres
		my $commande = ( $msg =~ m/^!([^ ]*)/ )[0]; 

		my @params = grep {!/^\s*$/} split(/\s+/, substr($msg, length("!$commande")));
		# Gestion commandes
		#aff_help($kernel,$user) if ( $commande eq 'help' );

		if ( $commande eq 'balemboy' )
		{
			# Cas aléatoire ou avec un nombre
			$params[0] = int(rand($nbr_quotes-1)) if ( ( $params[0] =~ m/^$/ || ( $params[0] =~ m/^\d+$/ && $params[0] >= $nbr_quotes && $params[0] < 0 ) ) && ( $params[0] !~ m/\w/ ) );
			$params[0] =~ s/\\//g;

			aff_quote($kernel,$chan[0][0],$params[0]);
		}

		if ( $commande eq 'help' )
		{
			kick($kernel, $chan[0][0], $user, "La sortie c'est par là :]");
		}

		if ( $commande eq "maybe" or $commande eq "yes" or $commande eq "no" )
		{
			if ($user ne 'gizmo' && $user ne 'Skelz0r' && $user ne 'Lix')
			{
				$irc->delay([kick => $chan[0][0] => $user => "SRLY $user ?"],int(rand(60*60*2))) if (int(rand(20)) == 1);
			}
		}

		add_quote($kernel,$chan[0][0],$user,@params) if ( $commande eq 'add_balemboy' && $params[0] !~ m/^$/ );

		gmab($kernel,$chan[0][0]) if ( $commande eq 'gmab' );

		counter_kick($kernel, $chan[0][0]) if ($commande eq 'votekick');
	}
	
	# substitute .. wait ..
	if ( $msg =~ m/^s\/\w*\/\w*\// )
	{
		my @params = ($msg =~ m/^s\/(\w*)\/(\w*)\//);
		my $tmp_last_message = $last_msg;
		$last_msg =~ s/$params[0]/$params[1]/;
		
		if ($tmp_last_message eq $last_msg)
		{
			if ( int(rand(3)) == 1 )
			{
				kick($kernel, $chan[0][0], $user, "TODO");
			}
			else
			{
				$irc->yield(privmsg => $chan[0][0],"TODO");
				$last_msg = "FIXME";
			}
		}
		else
		{
			$irc->yield(privmsg => $chan[0][0],$last_msg);
		}
	}
	else
	{
		$last_msg = $msg;
	}
	

	# BA .. LEMBOY	
	$irc->yield(privmsg => $chan[0][0],'LEMBOY') if ( $msg =~ m/BA+?( |\.)*?$/ );
	
	# tufou? 
	$irc->yield(privmsg => $chan[0][0],'UMAD?') if ( $msg =~ m/tufou\?$/i );

	# WAT IS LOVE 
	$irc->yield(privmsg => $chan[0][0],'IS LUV') if ( $msg =~ m/WAT+?( |\.)*?$/i );
	
	# BABY DON'T HURT ME
	$irc->yield(privmsg => $chan[0][0],'DON\'T HURT ME') if ( $msg =~ m/BABY+?( |\.)*?$/i );

	# DON'T HURT ME
	$irc->yield(privmsg => $chan[0][0],'NO MORE') if ( $msg =~ m/don't hurt me+?( |\.)*?$/i );

	# OKI? 
	$irc->yield(privmsg => $chan[0][0],'OKI') if ( $msg =~ m/OKI\?$/i );

	# COUCOU
	aff_coucou($kernel,$chan[0][0],$user) if ( $msg =~ m/(c+o+u+c+o+u+|kiko+|kikou|y+o+p+|s+a+l+u+t+|s+u+p+)/i );
	aff_coucou_lien($kernel,$chan[0][0]) if ( $user eq $user_coucou &&  $msg =~ m/^ *?(y+o+p+|n+e+d+|o+u+i+|o+w+i+|carrement|trop)/i );
	aff_coucou_non($kernel,$chan[0][0]) if ( $user eq $user_coucou && $msg =~ m/^ *?(n+o+n+|n+a+n+|w+h*a+t+|h+m+) *?$/i );

	# FU
	aff_FU($kernel,$chan[0][0]) if ( $msg =~ m/^F+U+ *?$/i );

	# JIZZ
	if ( $msg =~ m/^(I+|S*H+E+|\w+)* *(TELEVERSER|F+A+R+T+|M+O+O+C+|C+O+R+N+|J+I+ZZ+|K+I+C+K+|B+A+S+|J+S+O+N+|C+A+M+E+|P+O{2,}P+|G+I+C+L+E+|D+O+G+) *$/ )
	{
		if ( int(rand(50)) == 1 )
		{
			kick($kernel, $chan[0][0], $user, "OUT");
		}
		else
		{
			aff_jizz_1($kernel,$chan[0][0]);
		}
	}
	
	if ( $msg =~ m/^(M+Y+|Y*O+U+R+|H+(I+S+|E+R+)|#?\w+ *\w*'(s|S)) *$/ )
	{
		if ( int(rand(100)) == 1 )
		{
			kick($kernel, $chan[0][0], $user, "FREE KICK IS FREE");
		}
		else
		{
			aff_jizz_2($kernel,$chan[0][0]) 
		}
	}


	aff_jizz_3($kernel,$chan[0][0]) if ( $msg =~ m/^I+N+ *$/ );

	# DICK BOX
	aff_dick_box($kernel,$chan[0][0]) if ( $msg =~ m/^I+N+ *$/ );

	# AND AGAIN
	aff_and_again($kernel,$chan[0][0]) if ( $msg =~ m/^ *?(a+n+d+ +a+g+a+i+n+ *!*)+$/i);

	#  \o/
	aff_bonhomme($kernel, $chan[0][0]) if ( $msg =~ m/(\\o\/|\\o_|_o_|o\/\/|_o\/|\\\\o)/ );

	# Insultes sur balembot
	if ( $msg =~ m/$username/i )
	{
		if ( match_tab($msg,@insultes) )
		{
			kick($kernel, $chan[0][0], $user, "Reste comme Pierre");
		}
		else
		{
			my $nbr_rand = int rand scalar @hl_bot;
			$irc->delay([privmsg => $chan[0][0] => $hl_bot[$nbr_rand]],1);
		}
	}

	# ça marche bien
	$irc->delay([privmsg => $chan[0][0] => $msg],1) if ( $msg =~ m/(ç|c|Ç)a (ne )*marche (bien|pas)/i );

	# BIM BAM BOUM
	bbb($kernel,$chan[0][0],$user,$msg) if ( $msg =~ m/b+(i+|o+|a+)m+/i ); 

	# Fail win
	$irc->yield(privmsg => $chan[0][0] => "Sale n00b $user !") if ( $msg =~ m/win \d+ */i );

	# ping
	$irc->yield(privmsg => $chan[0][0] => "pong") if ( $msg =~ m/p.{1}ng/i );

	# NEED
	$irc->delay([privmsg => $chan[0][0] => "NEED !"],1) if ( match_tab($msg,@need) );

	# TA .. GUEULE
	$irc->delay([privmsg => $chan[0][0] => 'GUEULE'],1) if ( $msg =~ m/TA+?( |\.)*?$/ );
	
	# CLA .. SSIQUE
 	if ( $msg =~ m/CLA+?( |\.)*?$/ )
	{
		my $nbr_rand = int rand scalar @cla_array;
	
		$irc->delay([privmsg => $chan[0][0] => $cla_array[$nbr_rand]],1)
	}

	# CI .. MER
	$irc->delay([privmsg => $chan[0][0] => 'MER'],1) if ( $msg =~ m/CI+?( |\.)*?$/ );

	$irc->delay([privmsg => $chan[0][0] => 'PLUS'],1) if ( $msg =~ m/EN+?( |\.)*?$/ );
	# YA .. MOYEN
	$irc->delay([privmsg => $chan[0][0] => 'MOYEN'],1) if ( $msg =~ m/Y+A+?( |\.)*?$/ );
	
	# Random kick is random
	kick($kernel, $chan[0][0], $user, "Problem?") if ( int(rand(2000)) == 42 );
	
	# yo .. plait
	$irc->delay([privmsg => $chan[0][0] => 'plait'],1) if ( $msg =~ m/y+o+?( |\.)*?$/ );
	
	# AUTISME
	$irc->delay([privmsg => $chan[0][0] => 'JUSTICE NULLE PART'],1) if ( $msg =~ m/AUTISME PARTOUT/ && $bot_owner eq $user );

	# SRLY $nick
	$irc->delay([privmsg => $chan[0][0] => "SRLY $user ?"],int(rand(60*60*24))) if ( int(rand(100)) == 1 );
	$irc->delay([privmsg => $chan[0][0] => "Tu te clames $user stp, merci."],int(rand(60*60*2))) if ( int(rand(50)) == 1 );
}

# Boucle des events
$poe_kernel->run();
exit 0;
