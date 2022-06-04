#! /usr/bin/perl 
######################################################################
#   Calculate bonding pads location from placed def   
#   Generate ECO file for SOC Encounter
#   Version 2.0
#                                         Nian Shyang Chang 071225
######################################################################
#Modify
# v3.20100525 clhuang NOT Perform linear place with inner pad at side
# v3.20100109	Neal		Bug fix
# v3.20091023 clhuang add routing blockage and output addRouteBlk.cmd 
# v3.20100308 clhuang write out bonding info to bonding company
#To do
# v3.20091023 clhunag power label for multi-domain vdd
# v3.20091023 clhuang fix routing blockage top metel info. in io_B.list
# v3.5 20101123 nschang fix bugs, re-coding add bonding info
#use FileHandle;

&print_usage if(@ARGV == 0);

my $iolist="io_D.list"; #default name
for (my $i=0;$i<@ARGV;$i++){
    if($ARGV[$i] =~ /-io/){
        $i++;
        $iolist=$ARGV[$i];
    }elsif($ARGV[$i] =~ /-h/){
        &print_usage;
    }else{
        $defName=$ARGV[$i] ;
    }
}


# $chipLeft $chipRight $chipUp $chipDown $designName
# $Blklayers $unitdm 
my ($ioPadDB,$BPadDB,$BPadSetting,$BlkLayers) = readIOPadList("$iolist");

my ($WestPads,$EastPads,$NorthPads,$SouthPads,$chipLeft,$chipRight,$chipUp,
    $chipDown,$designName,$unitdm)=readDEF($defName,$ioPadDB,$BPadSetting);

my %BPadLoc;
calBPadLoc($WestPads, $EastPads, $NorthPads, $SouthPads, $BPadSetting,$BPadDB,$ioPadDB,\%BPadLoc);

print("\n");
createAddBPadFile($BPadSetting,\%BPadLoc);
my $bondinfofile= createBondXYFile($BPadSetting,\%BPadLoc,$designName);

#To write bonding info gds, uncomment below
#system("perl bondingdraw_b1.pl  $bondinfofile -gds");

#To write bonding info png and gds, uncomment below
#system("perl bondingdraw_b1.pl  $bondinfofile");

createRouteBlkFile($chipUp,$chipDown,$chipLeft,$chipRight,$BPadSetting,$BlkLayers);

print("\n");
exit(0);

#=========     main program end ==========

sub readIOPadList(){
    my ($padListFile) = @_;
    open (ioPadList, $padListFile)|| die ("Error: Failed to open pad description file: $padListFile\n");
    my %ioPadDB = ();
    my $innerBPad;
    my $outerBPad;
    my $linearBPad;
    my %BPadSetting = ();
    my $innerBPadName;
    my $outerBPadName;
    my $linearBPadName;
    my @BlkLayers;
    while (<ioPadList>){
        chomp;
        s/#.*$//;
        next if(/^[\s\t]*$/);
        ($keyword,@par)=split(/[\s\t]+/);
        if ($keyword =~ /VERSION/) {
            $version = $par[0];
        }elsif ($keyword =~ /Linear_IOPad_Length/i) {
            $linearIOPadLength = $par[0];
        }elsif ($keyword =~ /Stagger_IOPad_Length/i) {
            $staggerIOPadLength = $par[0];
        }elsif($keyword =~ /Inner_Bond_Name/i){
            $BPadSetting{"inner"} = $par[0];
        }elsif($keyword =~ /Outer_Bond_Name/i){
            $BPadSetting{"outer"} = $par[0];
        }elsif($keyword =~ /Linear_Bond_Name/i){
            $BPadSetting{"linear"} = $par[0];
        }elsif($keyword =~ /South_Start/i){
            $BPadSetting{south}->{start} = $par[0];
        }elsif($keyword =~ /North_Start/i){
            $BPadSetting{north}->{start} = $par[0];
        }elsif($keyword =~ /West_Start/i){
            $BPadSetting{west}->{start} = $par[0];
        }elsif($keyword =~ /East_Start/i){
            $BPadSetting{east}->{start} = $par[0];
        }elsif($keyword =~ /North_Pad_Use/i){
            $BPadSetting{north}->{type} = $par[0];
        }elsif($keyword =~ /West_Pad_Use/i){
            $BPadSetting{west}->{type} = $par[0];
        }elsif($keyword =~ /East_Pad_Use/i){
            $BPadSetting{east}->{type} = $par[0];
        }elsif($keyword =~ /South_Pad_Use/i){
            $BPadSetting{south}->{type} = $par[0];
        }elsif($keyword =~ /Route_Blockage_layer/i){
            push(@BlkLayers,@par); 
        }elsif($keyword =~ /\w+/){
            if ($keyword =~ /$BPadSetting{"outer"}/){
                $BPadDB{$keyword}={"name"=>$keyword, "length"=>$par[0], "width"=>$par[1],
                                   "lin_pitch"=>$par[2], "stg_pitch"=>$par[3],
                                   "ovlap"=>$par[4], "cntr_offset"=>$par[5],
                                   "passx"=>$par[6], "passy"=>$par[7],
                                   "pass_width"=>$par[8],"row"=>"outer"};
                next;
            } elsif ($keyword =~ /$BPadSetting{"inner"}|$BPadSetting{"linear"}/){
                $BPadDB{$keyword}={"name"=>$keyword, "length"=>$par[0], "width"=>$par[1],
                                   "lin_pitch"=>$par[2], "stg_pitch"=>$par[3],
                                   "ovlap"=>$par[4], "cntr_offset"=>$par[5],
                                   "passx"=>$par[6], "passy"=>$par[7],
                                   "pass_width"=>$par[8],"row"=>"inner"};
                next;
            }
            $ioPadDB{$keyword} = {slot=>$par[0],fstpin_cntr=>$par[1],sndpin_cntr=>$par[2],width=>$par[3],type=>$par[4]};
        }
    }
    close(ioPadList);
    if($BPadSetting{east}->{type} =~ /Linear/i){
        $BPadSetting{east}->{IOLength}=$linearIOPadLength;
    }else{
        $BPadSetting{east}->{IOLength}=$staggerIOPadLength;
    }
    if($BPadSetting{west}->{type} =~ /Linear/i){
        $BPadSetting{west}->{IOLength}=$linearIOPadLength;
    }else{
        $BPadSetting{west}->{IOLength}=$staggerIOPadLength;
    }
    if($BPadSetting{south}->{type} =~ /Linear/i){
        $BPadSetting{south}->{IOLength}=$linearIOPadLength;
    }else{
        $BPadSetting{south}->{IOLength}=$staggerIOPadLength;
    }
    if($BPadSetting{north}->{type} =~ /Linear/i){
        $BPadSetting{north}->{IOLength}=$linearIOPadLength;
    }else{
        $BPadSetting{north}->{IOLength}=$staggerIOPadLength;
    }
    if($version != 3.6){
        print("\nERROR, io_B.list VERSION inconsistence. Required version: 3.6\n\n");
        exit;
    }
       
    return(\%ioPadDB,\%BPadDB,\%BPadSetting,\@BlkLayers);
}

sub readDEF(){
    my ($defName,$ioPadDB,$BPadSetting) = @_;
    my $unit_distance_microns = 0;
    open (routedDef, $defName) || die ("Error: Failed to open $defName\n");
    while (<routedDef>){
        chomp;
        if(/^UNITS DISTANCE MICRONS/i){
            s/\s+/ /g;
            $unit_distance_microns = (split(/\s/))[3]; 
            last;
        }
    }
    close (routedDef);
    if ($unit_distance_microns ==0){
        printf ("Error, Can't find UNIT DISTANCE MICRONS in def, set to 1000\n");
        $unit_distance_microns=1000;
    }

    open (routedDef, $defName) || die ("Error: Failed to open $defName\n");
    my @WestPads = ();
    my @EastPads = ();
    my @NorthPads = ();
    my @SouthPads = ();
    my $componentSection=0;
    my $componentLine = "";
    my $eastIOLength=$BPadSetting->{east}->{IOLength};
    my $northIOLength=$BPadSetting->{north}->{IOLength};

    while (<routedDef>){
        chomp;
        if(/^DIEAREA/i){
            s/[();]//g;
            ($keywork, $chipLeft, $chipDown, $chipRight, $chipUp)= split(/\s+/);
            $chipLeft=$chipLeft*1000/$unit_distance_microns;
            $chipDown=$chipDown*1000/$unit_distance_microns;
            $chipRight=$chipRight*1000/$unit_distance_microns;
            $chipUp=$chipUp*1000/$unit_distance_microns;
        }
        if(/^DESIGN\s+(\w+)\s+\;/i){
            $designName = $1;
        }
        $componentSection = 0 if(/^END COMPONENTS/i);
        if($componentSection == 1){
            $componentLine = $componentLine.$_;
            if(/\;\s*$/){
                print "Err! def error at $.\n" if($componentLine !~ /^\s*\-/);

                my @terms = split(/\s\+\s/,$componentLine);
                my ($instance, $cell, $status, $locX, $locY, $direction);

                foreach my $term (@terms){
                    if($term =~ /\B- /){
                        my $dash;
                       ($dash,$instance,$cell) = split(/ +/,$term);
                    }elsif($term =~ /(FIXED|PLACED)/){
                        $term =~ s/[();]//g;
                        $term =~ s/\s+/ /g;
                        ($status,$locX,$locY,$direction) = split(/\s+/,$term);
                        $locX=$locX*1000/$unit_distance_microns;
                        $locY=$locY*1000/$unit_distance_microns;
                    }
                }
                #print ("$instance,$cell,$status,$locX,$locY,$direction\n");

                if (defined $ioPadDB->{$cell}){
                    if(($status !~ /PLACED/i) && ($status !~ /FIXED/i)){
                        print "Error!! $. : $cell must be PLACED or FIXED\n"; 
                    }

                    #print ("$instance,$cell,$status,$locX,$locY,$direction,$chipRight\n");			
                    my $Pin1Offset;
                    my $Pin2Offset;
                    if($ioPadDB->{$cell}->{slot}== 1){
                        $Pin1Offset=$ioPadDB->{$cell}->{fstpin_cntr};
                        $Pin2Offset="nil";
                    }
                    if($ioPadDB->{$cell}->{slot}== 2){
                        if($direction =~ /\b(FW|W|FS|N)\b/){
                            $Pin1Offset=$ioPadDB->{$cell}->{fstpin_cntr};
                            $Pin2Offset=$ioPadDB->{$cell}->{sndpin_cntr};
                        }else{ # $direction =~ /E|FE|S|FN/
                               # swap pin1 and pin2 order
                            $Pin1Offset=$ioPadDB->{$cell}->{sndpin_cntr};
                            $Pin2Offset=$ioPadDB->{$cell}->{fstpin_cntr};
                        }
                    } 
                    my $padWidth=$ioPadDB->{$cell}->{width};
                    my $iotype=$ioPadDB->{$cell}->{type};
                       $iotype="NA" if ($iotype eq "");

                    if (($locX == $chipLeft) &&  ($direction eq "E")){
                        # west side 
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$padWidth-$Pin1Offset,
                                       dir=> $direction, instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$padWidth-2000, 
                                       dir=> $direction, instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$padWidth-$Pin2Offset, 
                                       dir=> $direction, instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$padWidth-2000, 
                                       dir=> $direction, instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }
                    }elsif (($locX == $chipLeft) && ($direction eq "FW")){
                        # west side 
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$Pin1Offset,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+2000, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+$Pin2Offset, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX,
                                       Y=> $locY+2000, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@WestPads , $tmp);
                        }
                    }elsif (($locX == $chipRight - $eastIOLength) && ($direction eq "W")){ 
                        # east side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$Pin1Offset,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@EastPads , $tmp);
				#print ("1.$instance,$cell,$status,$locX,$locY,$direction,$chipRight,$tmp\n");
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+2000, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$Pin2Offset, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+2000, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }
                    }elsif (($locX == $chipRight - $eastIOLength) && ($direction eq "FE")){ 
                        # east side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$padWidth-$Pin1Offset,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$padWidth-2000, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$padWidth-$Pin2Offset, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$eastIOLength,
                                       Y=> $locY+$padWidth-2000, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@EastPads , $tmp);
                        }
                    }elsif (($locY == $chipUp - $northIOLength) && ($direction eq "S")){ 
                        #north side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-$Pin1Offset,
                                       Y=> $locY+$northIOLength,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-2000,
                                       Y=> $locY+$northIOLength, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-$Pin2Offset,
                                       Y=> $locY+$northIOLength, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-2000,
                                       Y=> $locY+$northIOLength, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }
                    }elsif (($locY == $chipUp - $northIOLength) && ($direction eq "FS")){ 
                        #north side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$Pin1Offset,
                                       Y=> $locY+$northIOLength,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+2000,
                                       Y=> $locY+$northIOLength, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$Pin2Offset,
                                       Y=> $locY+$northIOLength, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+2000,
                                       Y=> $locY+$northIOLength, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@NorthPads , $tmp);
                        }
                    }elsif (($locY == $chipDown) && ($direction eq "N")){ 
                        #south side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$Pin1Offset,
                                       Y=> $locY,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+2000,
                                       Y=> $locY, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$Pin2Offset,
                                       Y=> $locY, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+2000,
                                       Y=> $locY, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }
                    }elsif (($locY == $chipDown) && ($direction eq "FN")){ 
                        #south side
                        if($Pin1Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-$Pin1Offset,
                                       Y=> $locY,dir=> $direction,
                                       instname=> $instance,
                                       place=>"yes",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }elsif($Pin1Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-2000,
                                       Y=> $locY, dir=> $direction ,
                                       instname=> $instance,
                                       place=>"no",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }
                        if($Pin2Offset =~ /\d+/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-$Pin2Offset,
                                       Y=> $locY, dir=> $direction,
                                       instname=> $instance."_2",
                                       place=>"yes",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }elsif($Pin2Offset =~ /skip/){
                            my $tmp = {type=>$cell,X=>$locX+$padWidth-2000,
                                       Y=> $locY, dir=> $direction ,
                                       instname=> $instance."_2",
                                       place=>"no",iotype=>$iotype};
                            push (@SouthPads , $tmp);
                        }
                    }else{
                        print "Warning !! $.: IO PAD not on the chip boundary or direction error. \n";
                        print ("$instance,$cell($locX,$locY)$direction,$chipLeft,$chipDown,$chipUp,$chipRight\n");
                    }
                }
                $componentLine = "";
            }
        } # if componentSection
        $componentSection = 1 if(/^COMPONENTS/i);
    } # while route.def
    close (routedDef);
    # sort pad sequence in counterclockwise direction
    # north pads are sorted from right 2 left
    # west pads are sorted from up 2 down
    my @sortedWestPads = sort{$b->{Y} <=> $a->{Y}} @WestPads;
    my @sortedEastPads = sort{$a->{Y} <=> $b->{Y}} @EastPads;
    my @sortedNorthPads = sort{$b->{X} <=> $a->{X}} @NorthPads;
    my @sortedSouthPads = sort{$a->{X} <=> $b->{X}} @SouthPads;
    return(\@sortedWestPads,\@sortedEastPads,\@sortedNorthPads,\@sortedSouthPads,
            $chipLeft,$chipRight,$chipUp,$chipDown,$designName,
            $unit_distance_microns);
}


sub calBPadLoc() {
    my ($WestPads,$EastPads,$NorthPads,$SouthPads,$BPadSetting,$BPadDB,$ioPadDB,$BPadLoc) = @_;
    my $addInst;
    my $valid=1;
    my $linearBPad=$BPadDB{$BPadSetting->{linear}};
    my $innerBPad=$BPadDB{$BPadSetting->{inner}};
    my $outerBPad=$BPadDB{$BPadSetting->{outer}};
    foreach my $side ( qw (south east north west) ){
        my $curPads;
        $curPads = $WestPads if ($side eq "west");
        $curPads = $EastPads if ($side eq "east");
        $curPads = $SouthPads if ($side eq "south");
        $curPads = $NorthPads if ($side eq "north");

        if($BPadSetting->{$side}->{type} =~ /Linear/i){
            my ($BPadList,$valid)=calBPadLocInLinear($curPads,$linearBPad,$side);
            if($valid==1){
                $BPadLoc->{$side}=$BPadList;
            }else{
                print("********************************************************************\n");
                print("** Error!! Pad pitch violation near ($BPadList) at $side side \n");
                print("********************************************************************\n\n");
            }
        }else{   #$BPadSetting->{$side}->{type} =~ /Sgatter/
            if($BPadSetting->{$side}->{start} =~ /Outer/){
                ($BPadList,$valid)= calBPadLocInStagger($curPads,$outerBPad,$innerBPad,$side);
            }else{ #Inner
                ($BPadList,$valid)= calBPadLocInStagger($curPads,$innerBPad,$outerBPad,$side);
            }
            if($valid==1){
                $BPadLoc->{$side}=$BPadList;
            }else{
                print("********************************************************************\n");
                print("** Error!! Pad pitch violation near ($BPadList) at $side side \n");
                print("********************************************************************\n\n");
                exit(0);
            }
        }
    }
}

sub createAddBPadFile(){
    my ($BPadSetting,$BPadLoc) = @_;
    print("==== create SOCE cmd for add bonding pad ====\n");
    open (cmdfile,">addbond.cmd")||die("Error: Failed to open addbond.cmd\n");
    foreach my $side (qw (south east north west)){
        my $BPadList=$BPadLoc->{$side};
        foreach $BPad (@$BPadList){
            my $dir=&compass2dir($BPad->{dir});
            $BPadx =$BPad->{X}/1000;
            $BPady =$BPad->{Y}/1000;
            print cmdfile ("addInst -physical -cell $BPad->{cellname} -inst BPad_$BPad->{instname} -loc $BPadx $BPady -ori $dir\n");
        }
    }
    print cmdfile ("setDrawView place\n");
    print cmdfile ("redraw\n");
    close(cmdfile);
    print ("  -- complete, To add bonding cell, execute commnad below in SOC Encounter terminal\n");
    print ("\n     Encounter> source addbond.cmd\n\n");
}

sub createBondXYFile() {
    my ($BPadSetting,$BPadLoc,$designName) = @_;
    my $filename=$designName.".bondinfo";
    print("==== create Bonding XY file: $filename ====\n");
    open (bondinfofile,">$filename")||die("Error: Failed to open $filename\n");
    #format_name bondinfofile "BONDINFO";
    select((select(bondinfofile),
            $~ = "BONDINFO"
          )[0]);
    print bondinfofile ("#cell                      cntr-x     cntr_y  bond_width side   row  iotype\n");
    foreach my $side (qw (south east north west)){
        print(bondinfofile "#$side side\n");
        my $BPadList=$BPadLoc->{$side};
        foreach $BPad (@$BPadList){
            $BPadx =$BPad->{"X"};
            $BPady =$BPad->{"Y"};
            $BPadcell=$BPad->{"cellname"};
            $BPadinst=$BPad->{"instname"};
            $BPaddir=$BPad->{"dir"};
            $cellpassx=$BPadDB->{$BPadcell}->{"passx"};
            $cellpassy=$BPadDB->{$BPadcell}->{"passy"};
            $cellwidth=$BPadDB->{$BPadcell}->{"width"};
            $celllength=$BPadDB->{$BPadcell}->{"length"};
            $cellrow=$BPadDB->{$BPadcell}->{"row"};
            my $bondx,$bondy;
            if($BPaddir eq "N"){  #south side  R0
                $bondx=$BPadx+$cellpassx;
                $bondy=$BPady+$cellpassy;
            }elsif($BPaddir eq "FN"){ #south side MY
                $bondx=$BPadx+$cellwidth-$cellpassx;
                $bondy=$BPady+$cellpassy;
            }elsif($BPaddir eq "S"){ #north side R180
                $bondx=$BPadx+$cellwidth-$cellpassx;
                $bondy=$BPady+$celllength-$cellpassy;
            }elsif($BPaddir eq "FS"){ #north side MX
                $bondx=$BPadx+$cellpassx;
                $bondy=$BPady+$celllength-$cellpassy;
            }elsif($BPaddir eq "E"){ #west side  R270
                $bondx=$BPadx+$cellpassy;
                $bondy=$BPady+$cellwidth-$cellpassx;
            }elsif($BPaddir eq "FW"){ #west side MX90
                $bondx=$BPadx+$cellpassy;
                $bondy=$BPady+$cellpassx;
            }elsif($BPaddir eq "W"){ #east side R90
                $bondx=$BPadx+$celllength-$cellpassy;
                $bondy=$BPady+$cellpassx;
            }elsif($BPaddir eq "FE"){ #east side MY90
                $bondx=$BPadx+$celllength-$cellpassy;
                $bondy=$BPady+$cellwidth-$cellpassx;
            }
            my $bondx_n=$bondx/1000;
            my $bondy_n=$bondy/1000;
            $BPad->{bondcntrx}=$bondx;
            $BPad->{bondcntry}=$bondy;
            $cellpasswidth=$BPadDB->{$BPadcell}->{"pass_width"}/1000;
            $BPad->{"pass_width"}=$cellpasswidth;
            my $iotype=$BPad->{iotype};
            write (bondinfofile);

format BONDINFO =
@<<<<<<<<<<<<<<<<<<<<<<< @####.### @####.### @>>>>>>>  @>>>>>  @>>>> @>>>>>
$BPadinst     $bondx_n   $bondy_n   $cellpasswidth   $side $cellrow $iotype 
.
        }
    }
    close(bondinfofile);
    print("  -- complete\n");
    return($filename);
}


sub calBPadLocInLinear() {
    my ($IOPadlocs,$BPad,$side) = @_;
    my $BPadx;
    my $BPady;
    my $pitch= $BPad->{lin_pitch};
    my $cell=$BPad->{name};
    my $prepoint=-999999;
    my $curpoint;
    my @BPadList=();
    foreach $pad (@$IOPadlocs){
        if($side eq "west"){
            $BPadx = $pad->{X}-$BPad->{"length"}+ $BPad->{ovlap};
            if($pad->{dir} eq "E"){
                $BPady = $pad->{Y}+$BPad->{cntr_offset}-$BPad->{width};
            }elsif($pad->{dir} eq "FW"){
                $BPady = $pad->{Y}-$BPad->{cntr_offset};
            }
            $curpoint=$BPady;
        }elsif($side eq "east"){
	    $BPadx = $pad->{X}-$BPad->{ovlap};
            if($pad->{dir} eq "FE"){
                $BPady = $pad->{Y}+$BPad->{cntr_offset}-$BPad->{width};
            }elsif($pad->{dir} eq "W"){
                $BPady = $pad->{Y}-$BPad->{cntr_offset};
            }
            $curpoint=$BPady;
        }elsif($side eq "north"){
            $BPady = $pad->{Y}-$BPad->{ovlap};
            if($pad->{dir} eq "S"){
                $BPadx = $pad->{X}+$BPad->{cntr_offset}-$BPad->{width};
            }elsif($pad->{dir} eq "FS"){
                $BPadx = $pad->{X}-$BPad->{cntr_offset};
            }
            $curpoint=$BPadx;
        }elsif($side eq "south"){
	        $BPady = $pad->{Y}-$BPad->{"length"}+$BPad->{ovlap};
          
            if($pad->{dir} eq "FN"){
                $BPadx = $pad->{X}+$BPad->{cntr_offset}-$BPad->{width};
            }elsif($pad->{dir} eq "N"){
                $BPadx = $pad->{X}-$BPad->{cntr_offset};
            }
            $curpoint=$BPadx;
        }
        if($pad->{place} eq "yes"){
            my %tmp=(instname=>$pad->{instname},cellname=>$cell,
                     X=>$BPadx,Y=>$BPady,dir=>$pad->{dir},
                     iotype=>$pad->{iotype},row=>$BPad->{row});
            push (@BPadList,\%tmp);
            if(abs($curpoint-$prepoint)<$pitch){
                my $errorx=$pad->{X}/1000;
                my $errory=$pad->{Y}/1000;
                my $errorloc="$errorx,$errory";
                return ($errorloc,0) 
            }
        }
        $prepoint=$curpoint;
    }
return (\@BPadList,1); 
}

sub calBPadLocInStagger() {
    #The BPad1 in parameter2 will used as started BPad
    my ($IOPadlocs,$BPad1,$BPad2,$side) = @_;

    my $BPadx;
    my $BPady;
    my $countNum= 0;
    my $cell;
    my $prepoint=-999999;
    my $curpoint;
    my $stgpitch;
    my @BPadList=();
    #print("$BPad1->{stg_pitch} , $BPad2->{stg_pitch}\n");
    if($BPad1->{stg_pitch}>$BPad2->{stg_pitch}){
        $stgpitch=$BPad1->{stg_pitch};
    }else{
        $stgpitch=$BPad2->{stg_pitch};
    }
    my $BPad1_prepoint=-999999;
    my $BPad2_prepoint=-999999;
    foreach $pad (@$IOPadlocs){
        my $period = $countNum%2;
        if($side eq "west"){
            if ($period == 0){
                $BPadx = $pad->{X}-$BPad1->{"length"}+$BPad1->{ovlap};
                if($pad->{dir} eq "E"){
                    $BPady = $pad->{Y}+$BPad1->{cntr_offset}-$BPad1->{width};
                }elsif($pad->{dir} eq "FW"){
                    $BPady = $pad->{Y}-$BPad1->{cntr_offset};
                }
                $cell = $BPad1->{name};
            }else{
                $BPadx = $pad->{X}-$BPad2->{"length"}+$BPad2->{ovlap};
                if($pad->{dir} eq "E"){
                    $BPady = $pad->{Y}+$BPad2->{cntr_offset}-$BPad2->{width};
                }elsif($pad->{dir} eq "FW"){
                    $BPady = $pad->{Y}-$BPad2->{cntr_offset};
                }
                $cell = $BPad2->{name};
            }
            $curpoint=$BPady;
        }elsif($side eq "east"){
            if ($period == 0){
                $BPadx = $pad->{X}-$BPad1->{ovlap};
                if($pad->{dir} eq "FE"){
                    $BPady = $pad->{Y}+$BPad1->{cntr_offset}-$BPad1->{width};
                }elsif($pad->{dir} eq "W"){
                    $BPady = $pad->{Y}-$BPad1->{cntr_offset};
                }
                $cell = $BPad1->{name};
            }else {
                $BPadx = $pad->{X}-$BPad2->{ovlap};
                if($pad->{dir} eq "FE"){
                    $BPady = $pad->{Y}+$BPad2->{cntr_offset}-$BPad2->{width};
                }elsif($pad->{dir} eq "W"){
                    $BPady = $pad->{Y}-$BPad2->{cntr_offset};
                }
                $cell = $BPad2->{name};
            }
            $curpoint=$BPady;
        }elsif($side eq "north"){
            if ($period == 0){
                $BPady = $pad->{Y}-$BPad1->{ovlap};
                if($pad->{dir} eq "S"){
                    $BPadx = $pad->{X}+$BPad1->{cntr_offset}-$BPad1->{width};
                }elsif($pad->{dir} eq "FS"){
                    $BPadx = $pad->{X}-$BPad1->{cntr_offset};
                }
                $cell = $BPad1->{name};
            }else {
                $BPady = $pad->{Y}-$BPad2->{ovlap};
                if($pad->{dir} eq "S"){
                    $BPadx = $pad->{X}+$BPad2->{cntr_offset}-$BPad2->{width};
                }elsif($pad->{dir} eq "FS"){
                    $BPadx = $pad->{X}-$BPad2->{cntr_offset};
                }
                $cell = $BPad2->{name};
            }
            $curpoint=$BPadx;
        }elsif($side eq "south"){
            if ($period == 0){
                $BPady = $pad->{Y}-$BPad1->{"length"}+$BPad1->{ovlap};
                if($pad->{dir} eq "FN"){
                    $BPadx = $pad->{X}+$BPad1->{cntr_offset}-$BPad1->{width};
                }elsif($pad->{dir} eq "N"){
                    $BPadx = $pad->{X}-$BPad1->{cntr_offset};
                }
                $cell = $BPad1->{name};
            }else {
                $BPady = $pad->{Y}-$BPad2->{"length"}+$BPad2->{ovlap};
                if($pad->{dir} eq "FN"){
                    $BPadx = $pad->{X}+$BPad2->{cntr_offset}-$BPad2->{width};
                }elsif($pad->{dir} eq "N"){
                    $BPadx = $pad->{X}-$BPad2->{cntr_offset};
                }
                $cell = $BPad2->{name};
            }
            $curpoint=$BPadx;
        }
        my $row;
        if ($period == 0){
            $row=$BPad1->{row};
        }else{
            $row=$BPad2->{row};
        }

        if($pad->{place} eq "yes"){	
            my %tmp=(instname=>$pad->{instname},cellname=>$cell,
                     X=>$BPadx,Y=>$BPady,dir=>$pad->{dir},
                     iotype=>$pad->{iotype},row=>$row);
            push (@BPadList,\%tmp);
            my $errorx=$BPadx/1000;
            my $errory=$BPady/1000;
            my $errorloc="$errorx,$errory";
            return ($errorloc,0) if(abs($curpoint-$prepoint)<$stgpitch);
            $prepoint=$curpoint;
            if ($period ==0){
                return ($errorloc,0) if(abs($curpoint-$BPad1_prepoint)<$BPad1->{lin_pitch});
                $BPad1_prepoint=$curpoint;
            }else{
                return ($errorloc,0) if(abs($curpoint-$BPad2_prepoint)<$BPad2->{lin_pitch});
                $BPad2_prepoint=$curpoint;
            }
        }
        $countNum++;
    }
    return (\@BPadList,1);
}



sub compass2dir() {
    my $compass=uc(shift);
    my %com2dir = (
        "N" => "R0",
        "W" => "R90",
        "S" => "R180",
        "E" => "R270",
        "FS" => "MX",
        "FW" => "MX90",
        "FN" => "MY",
        "FE" => "MY90"
    );
    if (defined $com2dir{$compass}){
        return($com2dir{$compass});
    }else{
        printf("Undefined direction : $compass\n");
        return("$compass");
    }
}

sub getBPadPar() {
    my ($BPadPar ,$BPadHash) = @_;
    if (defined ($BPadHash->{$BPadPar})){
        return($BPadHash->{$BPadPar});
    }else{
       print ("Error!! , $BPadPar not defined\n");
    }
}


sub createRouteBlkFile() {
    my ($chipUp,$chipDown,$chipLeft,$chipRight,$BPadSetting,$BlkLayers)=@_;
    print("==== create SOCE cmd for add routing blockage on IO Pad ====\n");
    my $rsizechipup = $chipUp/1000;
    my $rsizechipdown = $chipDown/1000;
    my $rsizechipright = $chipRight/1000;
    my $rsizechipleft = $chipLeft/1000;
    my $rsizeEastIOPadLength = $BPadSetting->{east}->{IOLength}/1000;
    my $rsizeWestIOPadLength = $BPadSetting->{west}->{IOLength}/1000;
    my $rsizeNorthIOPadLength = $BPadSetting->{north}->{IOLength}/1000;
    my $rsizeSouthIOPadLength = $BPadSetting->{south}->{IOLength}/1000;

    my $routeBlk_E = $rsizechipright - $rsizeEastIOPadLength;
    my $routeBlk_N = $rsizechipup - $rsizeNorthIOPadLength;

    my $eastString,$westString,$northString,$southString;
    foreach my $layer (@$BlkLayers){
        $westString= $westString."createRouteBlk -box $rsizechipleft $rsizechipdown $rsizeWestIOPadLength $rsizechipup -layer $layer -name WRouteblk$layer\n";
        $southString= $southString."createRouteBlk -box $rsizechipleft $rsizechipdown $rsizechipright $rsizeSouthIOPadLength -layer $layer -name SRouteblk$layer\n";
        $northString= $northString."createRouteBlk -box $rsizechipleft $routeBlk_N $rsizechipright $rsizechipup -layer $layer -name NRouteblk$layer\n";
        $eastString= $eastString."createRouteBlk -box $routeBlk_E $rsizechipdown $rsizechipright $rsizechipup -layer $layer -name ERouteblk$layer\n";
    }

    open (cmdfile,">addRouteBlk.cmd")||die("Error: Failed to open addRouteBlk.cmd\n");
    print cmdfile ("$westString$southString$eastString$northString");
    print cmdfile ("setDrawView place\n");
    print cmdfile ("redraw\n");
    close(cmdfile);
    print "  -- complete, to add blockage, execute command below in SOC Encounter terminal: \n";
    print "\n     Encounter> source addbond.cmd\n";
}

sub print_usage(){
    print <<USAGE_doc;

**********************************************************************
**     Before using this program, you must prepare an IO pad list file 
** named io_B.list. This file list all the io pads in the IO library.
** You can find it in the design kit library. 
**
**     Function available
**     -- SOCE add bonding pad cmd
**     -- SOCE add routing blockage cmd
**     -- write bond(passivation) coordinate file
**********************************************************************

    Usage: $0 routed_def [-iolist io_list_file]

USAGE_doc
exit(1);
}      
