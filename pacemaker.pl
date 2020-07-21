#!/usr/bin/perl

use strict;

my $discover = 0;
my $zserver  = $ARGV[0];
my $hostname = $ARGV[1];
my $discover = ( defined( $ARGV[2] ) && $ARGV[2] =~ /discover/ );

open( my $fh, '-|', '/usr/sbin/crm_resource' ) or die $!;
my ( $resname, $crmtype, $status );

my $discoverline = "";
while ( my $line = <$fh> ) {
    $line =~ s/^\s*//;
    ( $resname, $crmtype, $status ) = split( /\s/, $line );
    $discoverline .= "{\"{#RESOURCE}\":\"$resname\"},";
    my $res_status = `/usr/sbin/crm_resource --locate --resource '$resname'`;
    $res_status =~s/.*is running on: //;
    my $send_res =
`/usr/bin/zabbix_sender -z $zserver --host "$hostname" -k 'resourcelocation[$resname]' -o '$res_status'`
      if ( !$discover );
}
close($fh);

$discoverline =~ s/,$//;
my $send_res =
`/usr/bin/zabbix_sender -z $zserver --host "$hostname" -k 'resourcename[{#RESOURCE}]' -o '[$discoverline]'`
  if ($discover);

