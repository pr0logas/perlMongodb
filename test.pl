#!/usr/bin/env perl

use strict;
use MongoDB;
use JSON;
use Try::Tiny;
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
my $checkInitOnceResult = 0;



# Mongo query;
sub mongoQueryLastBlock {
	try {
		$checkLastBlockResult = $collection->find({})->fields({ lastblock => 1, _id => 0 });
	} catch {
        warn "caught error: $_";
	};
}
sub updateTxidsProgress {
		print "\n$_[0]";
        print "\n$_[1]";
	try {
    	$collection->update_many({ lastblock => "$_[1]"}, { '$set' => { lastblock => "$_[0]"}});
	} catch {
		warn "caught error: $_";
	}
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

sub checkInitOnceLatestBlock {
mongoQueryLastBlock();
while (my $object = $checkLastBlockResult->next) {
    my $json = encode_json $object;
    my $decoded = decode_json($json);
    my $result = ($decoded->{'lastblock'});
		if ( $result eq 0 ) {
			return $checkInitOnceResult += 0;
		} else {
			return $checkInitOnceResult += 1;
		}
	}
}

sub checkLatestBlock {
mongoQueryLastBlock();
while (my $object = $checkLastBlockResult->next) {
    my $json = encode_json $object;
    my $decoded = decode_json($json);
    my $result = ($decoded->{'lastblock'});
    return $checkLastBlockResult = $result;
  }
}

checkIfDBAlive();
checkInitOnceLatestBlock();
checkLatestBlock();
updateTxidsProgress($checkLastBlockResult,($checkInitOnceResult + $checkLastBlockResult));
