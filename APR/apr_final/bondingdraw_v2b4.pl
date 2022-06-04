#!/usr/bin/perl
# bonding info file format : from addbonding_v3.5.pl or addbonding_v3.6.pl
#==== change the values below as you wish
my %paddrawlayer=(#type => gdslayer,  for gds onley
              I=>1,
              O=>1,
              B=>1,
              CPwr=>4,
              CGnd=>5,
              IOPwr=>6,
              IOGnd=>7,
              Other=>8
             );

my %paddrawcolor =(#type => color, for png only 
                  I=>'greenyellow',
                  O=>'green',
                  B=>'lime',
                  CPwr=>'red',
                  CGnd=>'blue',
                  IOPwr=>'magenta',
                  IOGnd=>'cyan',
                  background=>'black',
                  Other=>'orange'
                  );
my $honor_extend="no";
my %textextend=( # effect only when $honor_extend="yes"
                inner=>40,
                outer=>240
               );

my $shrink=2;  #down scale, for png only
my $fontsize=20;

#==== program start

if (@ARGV < 1) {
    &print_usage;
}

my $write_gds=0;
my $write_png=0;
for ($i=0;$i<@ARGV;$i++){
    if($ARGV[$i] =~ /-gds/i){
        $write_gds=1;
    }elsif($ARGV[$i] =~ /-png/i){
        $write_png=1;
    }elsif($ARGV[$i] =~ /-h/i){
        &print_usage;
    }else{
        $bondinfofile=$ARGV[$i];
    }
}
if($write_gds==0 && $write_png==0){
    $write_gds=1;
    $write_png=1;
}


$bondinfofile =~ /(\S+)\./;
my $topcellname = $1."bonding";

open (bondinfo,"<$bondinfofile") or die ("Failed to open bondinfo $bondinfofile\n");
my @bond=();
while(<bondinfo>){
    chomp;
    s/#.*//;
    s/^\s+//;
    next if (/^$/);
    my %tmp;
    @tmp{"name","cntrx","cntry","width","side","row","iotype"}=split(/\s+/);
    push (@bond,\%tmp);
}
close(bondinfo);

my $maxx=-10000;
my $minx=10000;
my $maxy=-10000;
my $miny=10000;
my $maxeb=-10000;
my $minwb=0;
my $maxnb=-10000;
my $minsb=10000;
my $e_inner_txt_max_lnth=0;
my $w_inner_txt_max_lnth=0;
my $n_inner_txt_max_lnth=0;
my $s_inner_txt_max_lnth=0;
my $e_outer_txt_max_lnth=0;
my $w_outer_txt_max_lnth=0;
my $n_outer_txt_max_lnth=0;
my $s_outer_txt_max_lnth=0;

if($write_png==1){
    if($honor_extend eq "no"){
        #find boundary and max text length
        my $virtualimg = GD::Simple->new(10, 10);
        $virtualimg->font("Times:italic");
        $virtualimg->fontsize($fontsize);
        foreach my $bd (@bond){
            my $text_length=$virtualimg->stringWidth($bd->{name});
            my $width_h=$bd->{width}/2;
            if($bd->{side} =~ /east/i){
                if($bd->{row} =~ /in/i){
                   $e_inner_txt_max_lnth= $text_length if ($text_length>$e_inner_txt_max_lnth); 
                }else{
                   $e_outer_txt_max_lnth= $text_length if ($text_length>$e_outer_txt_max_lnth); 
                }
                my $eb = ($bd->{cntrx}+$width_h)/$shrink;
                $maxeb = $eb if ($eb>$maxeb);
            }elsif($bd->{side} =~ /west/i){
                if($bd->{row} =~ /in/i){
                   $w_inner_txt_max_lnth= $text_length if ($text_length>$w_inner_txt_max_lnth); 
                }else{
                   $w_outer_txt_max_lnth= $text_length if ($text_length>$w_outer_txt_max_lnth); 
                }
                my $wb = ($bd->{cntrx}-$width_h)/$shrink;
                $minwb = $wb if ($wb<$minwb);
            }elsif($bd->{side} =~ /south/i){
                if($bd->{row} =~ /in/i){
                   $s_inner_txt_max_lnth= $text_length if ($text_length>$s_inner_txt_max_lnth); 
                }else{
                   $s_outer_txt_max_lnth= $text_length if ($text_length>$s_outer_txt_max_lnth); 
                }
                my $sb = ($bd->{cntry}-$width_h)/$shrink;
                $minsb = $sb if ($sb<$minsb);
            }elsif($bd->{side} =~ /north/i){
                if($bd->{row} =~ /in/i){
                   $n_inner_txt_max_lnth= $text_length if ($text_length>$n_inner_txt_max_lnth); 
                }else{
                   $n_outer_txt_max_lnth= $text_length if ($text_length>$n_outer_txt_max_lnth); 
                }
                my $nb = ($bd->{cntry}+$width_h)/$shrink;
                $maxnb = $nb if ($nb>$maxnb);
            }
        }
        $maxx=$maxeb+$e_inner_txt_max_lnth+$e_outer_txt_max_lnth+22;
        $minx=$minwb-$w_inner_txt_max_lnth-$w_outer_txt_max_lnth-22;
        $maxy=$maxnb+$n_inner_txt_max_lnth+$n_outer_txt_max_lnth+22;
        $miny=$minsb-$s_inner_txt_max_lnth-$s_outer_txt_max_lnth-22;
    }else{
        #find boundary
        foreach my $bd (@bond){
            my $extend=$textextend{$bd->{row}};
            my $text_length=length($bd->{name});
            if($bd->{side} =~ /east/i){
                my $rr = $bd->{cntrx}/$shrink+$extend+$text_length*$fontsize ;
                $maxx = $rr if ($rr>$maxx);
            }elsif($bd->{side} =~ /west/i){
                my $ll = $bd->{cntrx}/$shrink-$extend-$text_length*$fontsize ;
                $minx = $ll if ($ll<$minx);
            }elsif($bd->{side} =~ /south/i){
                my $dd = $bd->{cntry}/$shrink-$extend-$text_length*$fontsize ;
                $miny = $dd if ($dd<$miny);
            }elsif($bd->{side} =~ /north/i){
                my $uu = $bd->{cntry}/$shrink+$extend+$text_length*$fontsize ;
                $maxy = $uu if ($uu>$maxy);
            }
        }
    }

    my $imgwidth=int($maxx-$minx)+1;
    my $imglength=int($maxy-$miny)+1;
    my $xoffset=$minx-1;
    my $yoffset=$miny-1;
    use GD::Simple;
    my $img = GD::Simple->new($imgwidth, $imglength);
    $img->bgcolor($paddrawcolor{background});
    $img->clear;
    foreach my $bd(@bond){
        my $width_h=$bd->{width}/2;
        my $lx=int(($bd->{cntrx}-$width_h)/$shrink-$xoffset);
        my $ty=int($imglength-($bd->{cntry}-$width_h)/$shrink+$yoffset);
        my $rx=int(($bd->{cntrx}+$width_h)/$shrink-$xoffset);
        my $dy=int($imglength-($bd->{cntry}+$width_h)/$shrink+$yoffset);
        $img->bgcolor(undef);
        $img->fgcolor($paddrawcolor{$bd->{iotype}});
        $img->penSize(1,1);
        $img->rectangle($lx,$dy,$rx,$ty);
        if($bd->{iotype} =~ /(CPwr|CGnd|IOPwr|IOGnd)/){
            $img->bgcolor($paddrawcolor{$bd->{iotype}});
            $img->rectangle($lx+3,$dy+3,$rx-3,$ty-3);
        }
        my $curx,$cury;
        if($honor_extend eq "no"){
            if($bd->{side} =~ /south/i){
                $img->angle(90);
                if($bd->{row} =~ /in/){
                    $cury=$imglength-$minsb+10+$yoffset;
                }else{
                    $cury=$imglength-$minsb+$s_inner_txt_max_lnth+20+$yoffset;
                }
                $curx=$bd->{cntrx}/$shrink-$xoffset
            }elsif($bd->{side} =~ /east/i){
                $img->angle(0);
                if($bd->{row} =~ /in/){
                    $curx=$maxeb+10-$xoffset;
                }else{
                    $curx=$maxeb+$e_inner_txt_max_lnth+20-$xoffset;
                }
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset
            }elsif($bd->{side} =~ /north/i){
                $img->angle(-90);
                if($bd->{row} =~ /in/){
                    $cury=$imglength-$maxnb-10+$yoffset;
                }else{
                    $cury=$imglength-$maxnb-$n_inner_txt_max_lnth-20+$yoffset;
                }
                $curx=$bd->{cntrx}/$shrink-$xoffset
            }elsif($bd->{side} =~ /west/i){
                $img->angle(180);
                if($bd->{row} =~ /in/){
                    $curx=$minwb-10-$xoffset;
                }else{
                    $curx=$minwb-$w_inner_txt_max_lnth-20-$xoffset;
                }
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset
            }else{
                print("unknow side $bd->{side}\n");
            }
        }else{
            my $extend=$textextend{$bd->{row}};
            if($bd->{side} =~ /south/i){
                $img->angle(90);
                $curx=$bd->{cntrx}/$shrink-$xoffset;
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset+$extend;
            }elsif($bd->{side} =~ /east/i){
                $curx=$bd->{cntrx}/$shrink+$extend-$xoffset ;
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset;
                $img->angle(0);
            }elsif($bd->{side} =~ /north/i){
                $curx=$bd->{cntrx}/$shrink-$xoffset ;
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset-$extend;
                $img->angle(-90);
            }elsif($bd->{side} =~ /west/i){
                #my $delta_x=$img->stringWidth($bd->{name});
                #print("$bd->{name} $delta_x\n");
                $curx=$bd->{cntrx}/$shrink-$extend-$xoffset;
                $cury=$imglength-$bd->{cntry}/$shrink+$yoffset;
                $img->angle(180);
            }else{
                print("unknow side $bd->{side}\n");
            }
        }
        $img->bgcolor($paddrawcolor{$bd->{iotype}});
        $img->rectangle($curx-1,$cury-1,$curx+1,$cury+1);
        $img->moveTo($curx,$cury);
        $img->font("Times:italic");
        $img->fontsize($fontsize);
        $img->string($bd->{name});
    }
    
    my $imgname = $topcellname.".png";
    open (imgfd,">$imgname");
    print imgfd ($img->png);
    close(imgfd);
    print("\nbonding picture saved: $imgname\n");
}

if($write_gds==1){
    use Math::BigFloat;
    #Math::BigFloat->accuracy(30);
    
    $U_UNIT =0.001; #default value for gds
    my $gdsname = $topcellname.".gds";
    open (gds,">$gdsname");
    binmode(gds);
    
    &gds_header();
    &new_lib($topcellname);
    &new_cell($topcellname);
    
    foreach my $bd(@bond){
        my $layer=$paddrawlayer{$bd->{iotype}};
        my $width_h=$bd->{width}/2;
        my $lx=$bd->{cntrx}-$width_h;
        my $dy=$bd->{cntry}-$width_h;
        my $rx=$bd->{cntrx}+$width_h;
        my $ty=$bd->{cntry}+$width_h;
        &create_rect($layer,0,$lx,$dy,$rx,$ty);
        if ($bd->{side} =~ /south/i){
            $textx=$bd->{cntrx};
            $texty=$bd->{cntry}-$textextend{$bd->{row}};
            &create_text($bd->{name},$layer,0,$textx,$texty,$fontsize,0,"R270","left","mid");
        }elsif($bd->{side} =~ /east/i){
            $textx=$bd->{cntrx}+$textextend{$bd->{row}};
            $texty=$bd->{cntry};
            &create_text($bd->{name},$layer,0,$textx,$texty,$fontsize,0,"R0","left","mid");
        }elsif($bd->{side} =~ /north/i){
            $textx=$bd->{cntrx};
            $texty=$bd->{cntry}+$textextend{$bd->{row}};
            &create_text($bd->{name},$layer,0,$textx,$texty,$fontsize,0,"R90","left","mid");
        }elsif($bd->{side} =~ /west/i){
            $textx=$bd->{cntrx}-$textextend{$bd->{row}};
            $texty=$bd->{cntry};
            &create_text($bd->{name},$layer,0,$textx,$texty,$fontsize,0,"MY","left","mid");
        }else{
            print("unknow side: $bd->{side}\n");
        }
    }
    &endcell();
    &endlib();
    close(bondinfo);
    close(gds);
    print <<INFO;
    
bonding gds saved :$gdsname
This GDS is for bonding view only. Please do not merge it with your tapeout gds.

INFO
}
exit;



sub create_text(){
    my ($string,$layer,$datatype,$x,$y,$size,$font,$ori,$hjst,$vjst)=@_;
    # x and y in micron
    # ori: R0,R90,R180,R270,MX,MX90,MY,MY90
    # hjst: left,middle,right
    # vjst: top,middle,bottom
    print gds pack("H8","00040c00");  #text definition
    my $layer_hex=sprintf("%4x",$layer);
    print gds pack("H12","00060d02".$layer_hex);
    my $datatype_hex=sprintf("%4x",$datatype);
    print gds pack("H12","00061602".$datatype_hex); #texttype (purpose)
    my $presentation=$font*16;
    if($vjst =~ /top/i){
        $presentation=$presentation+0*4;
    }elsif($vjst =~ /bottom/i){
        $presentation=$presentation+2*4;
    }else{  # middle:  default
        $presentation=$presentation+1*4;
    }
    if($hjst =~ /left/i){
        $presentation=$presentation+0;
    }elsif($hjst =~ /right/i){
        $presentation=$presentation+2;
    }else{  # middle:  default
        $presentation=$presentation+1;
    }
    my $prest_hex=sprintf("%04x",$presentation);
    print gds pack("H12","00061701".$prest_hex); #presentation (org at middle)
    if($ori =~ /\b(R0|R90|R180|R270)\b/){ #no reflection
        print gds pack("H12","00061A010006"); #strans (abs loc and abs angle)
    }else{
        print gds pack("H12","00061A018006"); #strans (reflect, abs loc and abs angle)
    }
    my $size_string=&float($size,8);
    print gds pack("H24","000c1b05".$size_string); #mag (size)
    my $angle;
    if($ori =~ /\b(R0|MX)\b/){
        $angle=0;
    }elsif($ori =~ /\b(R90|MX90)\b/){
        $angle=90;
    }elsif($ori =~ /\b(R180|MY)\b/){
        $angle=180;
    }elsif($ori =~ /\b(R270|MY90)\b/){
        $angle=270;
    }
    my $angle_string=&float($angle,8);
    print gds pack("H24","000c1c05".$angle_string); #angle 
    my $x_m=Math::BigFloat->new($x /$U_UNIT);
    my $y_m=Math::BigFloat->new($y /$U_UNIT);
    my $x_hex=substr(sprintf("%8x",$x_m),-8);
    my $y_hex=substr(sprintf("%8x",$y_m),-8);
    #my $x_hex=substr(sprintf("%8x",sprintf("%s",$x /$U_UNIT)),-8);
    #my $y_hex=substr(sprintf("%8x",sprintf("%s",$y /$U_UNIT)),-8);
    print gds pack("H24","000c1003".$x_hex.$y_hex); #xy
    my $string_length=length($string);
    if ($string_length%2 ==0){
        my $record_lentgh_hex=sprintf("%4x",$string_length+4);
        print gds pack("H8",$record_lentgh_hex."1906");
        print gds ($string);
    }else{
        my $record_lentgh_hex=sprintf("%4x",$string_length+5);
        print gds pack("H8",$record_lentgh_hex."1906");
        print gds ($string);
        print gds pack("H2","00");
    }
    print gds pack("H8","00041100"); #end element
}

sub create_rect(){
    my ($layer,$datatype,$lx,$by,$rx,$ty)=@_;
    &create_polygon($layer,$datatype,$lx,$by,$rx,$by,$rx,$ty,$lx,$ty);
}

sub create_polygon(){
    my ($layer,$datatype,@xy)=@_;
    print gds pack("H8","00040800"); #boundary define
    my $layer_hex=sprintf("%4x",$layer);
    print gds pack("H12","00060d02".$layer_hex); #layer
    my $datatype_hex=sprintf("%4x",$datatype);
    print gds pack("H12","00060e02".$datatype_hex);
    my @xy_hex=();
    for(my $i=0;$i<@xy;$i++){
        my $xy_m=Math::BigFloat->new($xy[$i]/$U_UNIT);
        my $xy_mint=int($xy_m);
        printf("ERROR, %s not fit user unit: $U_UNIT .\n",$xy[$i]) if($xy_m != $xy_mint);
        #$xy_hex[$i]=substr(sprintf("%8x",sprintf("%s",$xy[$i]/$U_UNIT)),-8);
        $xy_hex[$i]=substr(sprintf("%8x",$xy_m),-8); #substr -8 is required for negative value
    }
    my $xy_join=join("",@xy_hex,$xy_hex[0],$xy_hex[1]);
    my $total_char=length($xy_join)+8; #8 is for record header
    my $total_char_hex=sprintf("%4x",$total_char/2);
    print gds pack("H$total_char", $total_char_hex."1003".$xy_join);
    my $endel = "00041100";
    print gds pack("H8",$endel);  #end element
}
sub new_lib(){
    my ($libname)=@_;
    my $timeform=&time_form;
    print gds pack("H56","001c0102".$timeform.$timeform); #bgnlib
    my $libname_length=length($libname);
    if ($libname_length%2 ==0){
        my $record_lentgh_hex=sprintf("%4x",$libname_length+4);
        print gds pack("H8",$record_lentgh_hex."0206");
        print gds ($libname);
    }else{
        my $record_lentgh_hex=sprintf("%4x",$libname_length+5);
        print gds pack("H8",$record_lentgh_hex."0206");
        print gds ($libname);
        print gds pack("H2","00");
    }

    my $generation = "000622020003"; #fix
    print gds pack("H12",$generation);
    my $user_unit=&float($U_UNIT,8);
    #my $user_unit="3e4189374bc6a7ef";   #0.001 
    my $database_unit=&float(0.000000001,8);
    #my $database_unit="3944b82fa09b5a51"; # 0.000000001 meter
    print gds pack("H40","00140305".$user_unit.$database_unit);
}
sub new_cell(){
    my ($cellname)=@_;
    my $timeform=&time_form;
    print gds pack("H56","001c0502".$timeform.$timeform); #bgnstr
    my $cellname_length=length($cellname);
    if ($cellname_length%2 ==0){
        my $record_lentgh_hex=sprintf("%4x",$cellname_length+4);
        print gds pack("H8",$record_lentgh_hex."0606");
        print gds ($cellname);
    }else{
        my $record_lentgh_hex=sprintf("%4x",$cellname_length+5);
        print gds pack("H8",$record_lentgh_hex."0606");
        print gds ($cellname);
        print gds pack("H2","00");
    }
}

sub time_form(){
    my ($sec,$min,$hour,$mday,$mon,$year) =localtime(time);
    $mon++;
    my $timeform=sprintf("%4x%4x%4x%4x%4x%4x",$year,$mon,$mday,$hour,$min,$sec);
    return($timeform);
}

sub float(){
    #translate a fixpoint value to 8/4 byte floating point representation
    # 8byte representation:
    # seeeeeee mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm
    # 4byte representation:
    # seeeeeee mmmmmmmm mmmmmmmm mmmmmmmm 
    # value = (1-s) M*16^E  , 1 > M >= 1/16
    # type: 8 or 4 (8byte or 4byte)
    my ($value,$type)=@_;
    $type=8 if ($type=="");
    my @dec2hex=("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
    if($value ==0){
        return("0000000000000000") if($type==8);
        return("00000000") if($type==4);
        die("Illegal float length:$type\n");
    }
    my $sign=0;
    if($value<0){
        $value= abs($value);
        $sign=1; 
    }
    my $value_t=$value;
    my $power;
    my $value_exp;
    my $value_manti;
    if($value_t>=1){
        $power=1;
        $value_exp=0;
        while($value_t>=1){
            $value_t=$value_t/16;
            $value_exp++;
            $power=$power*16;
        }
        $value_manti=$value /$power;
    }else{
        $power=1/16;
        $value_exp=1;
        while($value_t<1){
            $value_t=$value_t*16;
            $value_exp--;
            $power=$power*16;
        }
        $value_manti=$value*$power;
    }
    #my $mantissz="00000000000000";
    my $mantissz="";
    my $mantilength=$type*2-2;
    for(my $i=0; $i<$mantilength ; $i++){
        my $value_manti_mtply16=Math::BigFloat->new(16*$value_manti);
        my $integer=int($value_manti_mtply16);
        my $fraction=$value_manti_mtply16-$integer;
        #substr($mantissz,$i,1)=$dec2hex[$integer];
        $mantissz=$mantissz.$dec2hex[$integer];
        $value_manti=$fraction;
    }
    my $exp_norm=$value_exp+64;

    $exp_norm=$exp_norm+128 if ($sign==1); #neg value
    my $exp_hex=sprintf("%2x",$exp_norm);
    my $total=$exp_hex.$mantissz;
    return($total);
}

sub gds_header(){
    my $header = "000600020005"; #version 5 
    print gds pack("H12",$header);
}
sub endcell(){
    my $endstr="00040700";  
    print gds pack ("H8",$endstr);
}
sub endlib(){
    my $endlib="00040400";
    print gds pack ("H8",$endlib);
}

sub print_usage(){
    print <<USAGE;

    Usage: $0 bondinfo_file [-gds] [-png]\n
    If neither -gds nor -png specified,both gds and png are writed by default.
    To write gds only, use -gds option.
    To write png, You must have installed perl GD module.
    Download perl GD module : http://search.cpan.org/~lds/GD/

USAGE
exit;
}
