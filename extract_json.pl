#!/usr/bin/perl

#*****************************************************
# File: extract_json.pl
# Author: Junte Zhang (2013) for EHRI project
# Purpose: extracting information from JSON file
#
# Distributed under the GNU General Public Licence
#*****************************************************
use strict;

use Data::Dumper;
use Time::Piece;
use utf8;
use Encode;

use HTML::Restrict;
use HTML::Strip;

use HTML::Tidy::libXML;

use WWW::Curl::Easy;

use XML::LibXML;
use XML::LibXML::XPathContext;

use JSON qw( decode_json );
use XML::Simple;
use XML::XSLT;

#*************************************
# Configuration of global variables
# Make sure the correct paths are set
#*************************************
my $found;
my $json_file = "../data/documentaryUnit.json";
my $output_dir = "../data/documentaryUnit_split";
my $xml_file = "../data/documentaryUnit.xml";
my $xsl_file = "extract_json.xsl";
my $saxon = "/Software/saxonb9-1-0-8j/saxon9.jar";

#***********************************
# get command line parameter value
#***********************************
my $param_1 = $ARGV[0];

#***********************************
# check for valid param
#***********************************
if($param_1 eq "--convert") # convert JSON to XML
{
  convert_json_to_xml();
}
elsif($param_1 eq "--extractByField") # extract all by field
{
  extract_all_by_field();
}
elsif($param_1 eq "--extractByID") # extract all by ID
{
  transform_with_xsl();
}
elsif($param_1 eq "--help") # help function
{
  print "\n";
  print "PURPOSE: extracting information from JSON file.\n";
  print "USAGE: perl extract_json.pl [arguments]\n";
  print "\n";
  printf "%-30s\t%-30s", "--convert", "convert JSON to XML\n";
  print "\n";
  printf "%-30s\t%-30s", "--extractByField", "extract information from JSON file per field\n";
  print "\n";
  printf "%-30s\t%-30s", "--extractByID", "extract information from JSON file by record ID\n";  
  print "\n";
  print "For more information, you can contact juntezhang\@gmail.com\n";
  print "\n";
}
else # catch invalid param
{
  print "\n";
  print "You have not entered a valid parameter.\n";
  print "MORE INFORMATION: perl extract_json.pl --help\n";
  print "\n";
}

#****************************************
# convert JSON to XML
#****************************************
sub convert_json_to_xml 
{
  my @lines = read_file($json_file);
  my $xml_code = json_to_xml(@lines);
  
  # save to XML
  open(OUT_XML, ">:encoding(utf8)", $xml_file) or die("Could not open $xml_file!\n");
  $xml_code =~ s/\n\n/&#10;/g;
  $xml_code =~ s/([.?!])\n/$1&#10;/g;
  print OUT_XML "$xml_code";
  close(OUT_XML);
}

#****************************************
# extract text nodes merged by field
#****************************************
sub extract_all_by_field 
{
  unless(-e $json_file) # only if the JSON file does not exist yet
  {
    convert_json_to_xml();  
  }
  
  my $xml_code = "";
  open(IN_XML, "<:encoding(utf8)", $xml_file) or die("Could not open $xml_file");
  my @lines_xml = <IN_XML>;
  my $xml_string = join(/\n/, @lines_xml);
  close(IN_XML);
  
  my $parser = XML::LibXML->new();
  $parser->keep_blanks(0);   
  my $dom = $parser->parse_string($xml_string);
  my $xpc = XML::LibXML::XPathContext->new($dom);  
  
  my $archivalHistory = $xpc->findnodes('//describes/data/@archivalHistory');
  $archivalHistory = node_to_literal_join_by_space($archivalHistory);

  my $biographicalHistory = $xpc->findnodes('//describes/data/@biographicalHistory');
  $biographicalHistory = node_to_literal_join_by_space($biographicalHistory);
  
  my $scopeAndContent = $xpc->findnodes('//describes/data/@scopeAndContent');
  $scopeAndContent = node_to_literal_join_by_space($scopeAndContent);
  
  my $describes_data_name = $xpc->findnodes('//relationships/describes/data/@name');
  $describes_data_name = node_to_literal_join_by_space($describes_data_name);
    
  my $ead_archdesc_did_abstract_ = $xpc->findnodes('//data/@ead_archdesc_did_abstract_');
  $ead_archdesc_did_abstract_ = node_to_literal_join_by_space($ead_archdesc_did_abstract_);
  
  my $relatesTo_data_name = $xpc->findnodes('//relatesTo/data/@name');
  $relatesTo_data_name = node_to_literal_join_by_space($relatesTo_data_name);
  
  my %file_names = (
    $archivalHistory => "../data/archivalHistory.txt", 
    $biographicalHistory => "../data/biographicalHistory.txt", 
    $scopeAndContent => "../data/scopeAndContent.txt", 
    $describes_data_name => "../data/describes_data_name.txt", 
    $ead_archdesc_did_abstract_ => "../data/ead_archdesc_did_abstract_.txt",
    $relatesTo_data_name => "../data/relatesTo_data_name.txt"
    );
  
  foreach my $key (keys %file_names) 
  {
    print $file_names{$key} . "\n";
    open(OUT, ">:encoding(utf8)", $file_names{$key}) or die("Could not open  $file_names{$key}");
    print OUT "$key";
    close(OUT);
  }
}

#****************************************
# read lines in file and store in array
#****************************************
sub read_file 
{
  my $file = $_[0];
  
  open(FILE, "<:encoding(utf8)", $file) or die("Could not open $file!\n");
  my @json_lines = <FILE>;
  close(FILE);
  
  return @json_lines;
}

#**********************
# convert JSON to XML
#**********************
sub json_to_xml 
{
  my (@lines) = @_;

  my $json = join(/\n/, @lines); 
  
  my $decoded_json = decode_json($json);    
  my $xml = XMLout($decoded_json);
  
  return $xml;
}

#**********************
# convert JSON to XML
#**********************
sub node_to_literal_join_by_space 
{
  my $node = $_[0];
  my $string_new = "";
  foreach my $value ($node->to_literal_list()) 
  {
    $string_new .= $value . "\n";
  }
  return $string_new;
}

#**************************************************************************************
# doing a system call in Saxon, since I cannot the LibXSLT module installed on MacOSX
#**************************************************************************************
sub transform_with_xsl 
{    
  # clean existing directory
  if(-e $output_dir) 
  {
    system("rm -rf $output_dir");
    system("mkdir $output_dir");
  }
  else 
  {
    system("mkdir $output_dir");
  }
  
  # using a system call, because the XSLT is 2.0
  system("java -Xmx1g -jar $saxon $xml_file $xsl_file");                       
}

