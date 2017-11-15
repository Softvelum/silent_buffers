use Getopt::Long;

my ($fileName, $output, $arrayName, $typecast, $arrtype) = (undef, "output.h", "noName", "", "static const unsigned char");

GetOptions("type:s"        => \$frameType,
           "t:s"           => \$frameType,
           "filename:s"    => \$input,
           "f:s"           => \$input,
           "outfilename:s" => \$output,
           "o:s",          => \$output,
           "arrayname:s"   => \$arrayName,
           "a:s"           => \$arrayName,
           "typecast:s"    => \$typecast,
           "c:s"           => \$typecast,
           "adts"          => \$adts);

print "use --type or --t options to specify either aac or mp3 frame type\n" and exit(1) unless $frameType;
print "only aac and mp3 frame types are supported\n" and exit(1) if (('aac' cmp $frameType) != 0 && ('mp3' cmp $frameType) != 0);
print "use --filename or --f options to specify filename to be processed\n" and exit(1) unless $input;

open(OUTPUT, ">>$output") or die "Can't open output file = $output\n";
open(BINARY_FILE, $input) or die "Can't open input file = $input\n";
binmode BINARY_FILE;

$arrayName =~ s/\./_/g;
print OUTPUT "var $arrayName = new Uint8Array(\[";

$prev_ff = -1;
$last_ff_position = -1;
$cur_position = 0;
$secondMatch = ('aac' cmp $frameType) == 0 ? 0xf1 : 0xfb;
while(read(BINARY_FILE, $curByte, 1)) {
    if (ord($curByte) == 0xff) {
        $prev_ff = $cur_position;
    } elsif (ord($curByte) == $secondMatch && $prev_ff != -1) {
        $last_ff_position = $cur_position - 1;
        $prev_ff = -1;
    } else {
        $prev_ff = -1;
    }
    ++$cur_position;
}

print "cannot find $frameType frame\n" and exit(1) if $last_ff_position == -1;

if( ('aac' cmp $frameType) == 0 ) {
  $last_ff_position += 7 unless $adts;
}
seek(BINARY_FILE, $last_ff_position, SEEK_SET) or die "Can't seek in input file = $input\n";

$first = 1;
while(read(BINARY_FILE, $curByte, 1)) {
    print OUTPUT ', ' unless $first;

    $s = sprintf "%s%#vx", $typecast, $curByte;
    print  OUTPUT $s;
    
    $first = 0;
}

print  OUTPUT "]);\n";

close OUTPUT;
close BINARY_FILE;
