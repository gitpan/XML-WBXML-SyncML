use Test::More tests => 72;

BEGIN { use_ok 'XML::WBXML::SyncML' }
BEGIN { use_ok 'Test::XML' }

ok( defined &XML::WBXML::SyncML::xml_to_wbxml, "x2w defined in package" );
ok( defined &XML::WBXML::SyncML::wbxml_to_xml, "w2x defined in package" );

# no exports
ok( (not defined &xml_to_wbxml), "x2w not exported" );
ok( (not defined &wbxml_to_xml), "w2x not exported" );

sub slurp {
  my $filename = "t/test-docs/" . shift;
  open my $fh, "<", $filename or die "can't open $filename: $!";
  # think about encodings?
  my $slurped = do { local $/; <$fh> };
  return $slurped;
} 


for my $test (qw/001 002 005 006 007 008 009 010 012 013 014/) {
  my $in_xml = slurp("syncml-$test.xml");
  my $expected_wbxml = slurp("my-$test.wbxml");

  like( $in_xml, qr/^<\?xml/, "input looks like XML" );
  like( $expected_wbxml, qr/^[\001-\007]/, "expected value looks like WBXML" );

  is( XML::WBXML::SyncML::xml_to_wbxml($in_xml), $expected_wbxml, "x2w converted correctly" );
}

for my $test (qw/001 002 005 006 007 008 009 010 012 013 014/) {
  my $in_wbxml = slurp("my-$test.wbxml");
  my $expected_xml = slurp("syncml-$test.xml");

  like( $in_wbxml, qr/^[\001-\007]/, "input looks like WBXML" );
  like( $expected_xml, qr/^<\?xml/, "expected value looks like XML" );

  is_xml( XML::WBXML::SyncML::wbxml_to_xml($in_wbxml), $expected_xml, "w2x converted correctly" );
}
