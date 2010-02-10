use strict;
use warnings;
use IO::All;

my @file_names = @ARGV;
my $subs = {};
my @arrays;

for my $file_name (@file_names) {
    my $text = io($file_name)->all;
    $text = add_ids($text);
    io($file_name)->print($text);
}

sub add_ids {
    my $text = shift;
    sub store {
        my $t = shift;
        my $a = [$t];
        push @arrays, $a;
        $subs->{$a} = $t;
        return "=>$a\n";
    }
    sub id {
        my $t = shift;
        return '' if $t =~ /^(TIP|CAUTION)\b/;
        $t = lc($t);
        $t =~ s/\s+/_/g;
        $t =~ s/[^a-z_]/_/g;
        $t =~ s/_{2,}/_/g;
        $t = substr($t, 0, 25) if length($t) > 25;
        $t =~ s/_$//;
        return "[[para_$t]]\n";
    }
    $text =~ s{^(-+\n.*?\n-+\n)}{store("$1")}mesg;
    $text =~ s{^\n([A-Za-z].*)\n}{"\n" . id("$1") . "$1\n"}meg;
    $text =~ s[^=>(.*)\n][$subs->{"$1"}]meg;
    return $text;
}
