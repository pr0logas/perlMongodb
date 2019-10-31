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

# Mongo query;
my $check = $collection->find({})->fields({ lastblock => 1, _id => 0 });

my $latestSyncBlockTxids = 0;

sub checkIfDBAlive {
    #debug $check
    while (my $object = $check->next) {
        my $json = encode_json $object;
        my $decoded = decode_json($json);
        my $result = ($decoded->{'lastblock'});
	    if ( $result lt 0 ) {
	        print "FATAL. Database not working?";
   	        exit 42;
	    }
        return $result;
    }
    print "checkIfDBAlive finished";
}

sub checkLatestBlock {
    #debug $check
    while (my $object = $check->next) {
        my $json = encode_json $object;
        my $decoded = decode_json($json);
        my $result = ($decoded->{'lastblock'});
        return $result;
    }
    print "checkLatestBlock finished";
}

#Pirmą kartą panaudojam $check rezultatą
print checkIfDBAlive();
#Antrą kartą panaudoti $check rezultatą negalime, nes jis pasibaigė, kai naudojom pirmoj funkcijoje
print checkLatestBlock();

#checkLatestBlock();
