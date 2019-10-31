#!/usr/bin/env perl

use strict;
use MongoDB;
use JSON;
require 'mongoDBconnect.pl';


# Mongo Connection variables;
my $mongoHost = get_mongoHost();
my $mongoPort = get_mongoPort();
my $mongoDatabase = get_mongoDatabase();
my $mongoCollection = get_mongoCollection();

# Mongo init;
my $client = MongoDB->connect("mongodb://$mongoHost:$mongoPort");
my $db = $client->get_database( "$mongoDatabase" );
my $collection = $db->get_collection( 'txidsProgress' );

my $checkLastBlockResult;

# Mongo query;
sub mongoQueryLastBlock {
   $checkLastBlockResult = $collection->find({})->fields({ lastblock => 1, _id => 0 });
   return $checkLastBlockResult;
}

sub checkIfDBAlive {
mongoQueryLastBlock();
while (my $object = $checkLastBlockResult->next) {
    my $json = encode_json $object;
    my $decoded = decode_json($json);
    my $result = ($decoded->{'lastblock'});
        if ( $result lt 0 ) {
            print "FATAL. Database not working?";
            exit 42;
	}
  }
}

sub checkLatestBlock {
mongoQueryLastBlock();
while (my $object = $checkLastBlockResult->next) {
    my $json = encode_json $object;
    my $decoded = decode_json($json);
    my $result = ($decoded->{'lastblock'});
    return print $result;
  }
}

checkIfDBAlive();
checkLatestBlock();
