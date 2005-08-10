package XML::WBXML::SyncML;

our $VERSION = '0.01';

use warnings;
use strict;
use Carp;

use XML::DOM;
use XML::SAX::Writer;

use WAP::wbxml;
use WAP::SAXDriver::wbxml;


=head1 NAME

XML::WBXML::SyncML - Convert SyncML messages between XML and WBXML


=head1 SYNOPSIS

    use XML::WBXML::SyncML;
    
    $wbxml = XML::WBXML::SyncML::xml_to_wbxml($xml);
    $xml = XML::WBXML::SyncML::wbxml_to_xml($wbxml);

=head1 DESCRIPTION

This module provides two functions to convert SyncML messages between the XML
and the Wireless Binary XML (WBXML) formats.  It is implemented as a wrapper around
Francois Perrad's L<WAP::wbxml> and L<WAP::SAXDriver::wbxml> modules.

=head1 FUNCTIONS

=cut

my $syncml_rules_for_w2x =
bless( {'App' => {'-//SYNCML//DTD DevInf 1.0//EN' => bless( {'TAG' => {'33' => 'Tx','32' => 'SyncType','21' => 'Mod','7' => 'DataStore','26' => 'Rx-Pref','17' => 'Man','18' => 'MaxGUIDSize','30' => 'SwV','16' => 'HwV','27' => 'SharedMem','25' => 'Rx','28' => 'Size','14' => 'Ext','20' => 'MaxMem','24' => 'PropName','10' => 'DevInf','31' => 'SyncCap','35' => 'ValEnum','11' => 'DevTyp','22' => 'OEM','13' => 'DSMem','23' => 'ParamName','29' => 'SourceRef','6' => 'CTType','39' => 'Xval','36' => 'VerCT','9' => 'DevID','12' => 'DisplayName','15' => 'FwV','38' => 'Xnam','8' => 'DataType','34' => 'Tx-Pref','37' => 'VerDTD','19' => 'MaxID','5' => 'CTCap'},'systemid' => 'http://www.syncml.org/docs/devinf_v101_20010530.dtd'}, 'App' ),'-//SYNCML//DTD DevInf 1.1//EN' => bless( {'TAG' => {'33' => 'Tx','32' => 'SyncType','21' => 'Mod','7' => 'DataStore','26' => 'Rx-Pref','17' => 'Man','18' => 'MaxGUIDSize','30' => 'SwV','16' => 'HwV','27' => 'SharedMem','25' => 'Rx','28' => 'Size','40' => 'UTC','14' => 'Ext','20' => 'MaxMem','24' => 'PropName','10' => 'DevInf','31' => 'SyncCap','35' => 'ValEnum','11' => 'DevTyp','42' => 'SupportLargeObjs','22' => 'OEM','13' => 'DSMem','23' => 'ParamName','29' => 'SourceRef','6' => 'CTType','39' => 'Xval','36' => 'VerCT','9' => 'DevID','41' => 'SupportNumberOfChanges','12' => 'DisplayName','15' => 'FwV','38' => 'Xnam','8' => 'DataType','34' => 'Tx-Pref','37' => 'VerDTD','19' => 'MaxID','5' => 'CTCap'},'systemid' => 'http://www.openmobilealliance.org/tech/DTD/OMA-SyncML-DevInfo-DTD-V1_1_2-20030505-D.dtd'}, 'App' ),'-//SYNCML//DTD SyncML 1.0//EN' => bless( {'TAG' => {'274' => 'Size','33' => 'RespURI','32' => 'Replace','276' => 'Version','21' => 'Lang','7' => 'Archive','26' => 'Meta','17' => 'Exec','18' => 'Final','30' => 'NoResults','264' => 'FreeID','16' => 'Delete','44' => 'SyncHdr','27' => 'MsgID','25' => 'MapItem','272' => 'NextNonce','28' => 'MsgRef','40' => 'SourceRef','273' => 'SharedMem','268' => 'MaxMsgSize','14' => 'Cred','20' => 'Item','49' => 'VerDTD','24' => 'Map','10' => 'Cmd','31' => 'Put','271' => 'Next','35' => 'Search','11' => 'CmdID','267' => 'Mark','266' => 'Last','263' => 'Format','262' => 'EMI','269' => 'Mem','42' => 'Sync','22' => 'LocName','46' => 'Target','275' => 'Type','13' => 'Copy','23' => 'LocURI','29' => 'NoResp','6' => 'Alert','50' => 'VerProto','261' => 'Anchor','39' => 'Source','36' => 'Sequence','9' => 'Chal','41' => 'Status','12' => 'CmdRef','47' => 'TargetRef','15' => 'Data','38' => 'SftDel','8' => 'Atomic','265' => 'FreeMem','34' => 'Results','45' => 'SyncML','37' => 'SessionID','43' => 'SyncBody','19' => 'Get','270' => 'MetInf','5' => 'Add'},'systemid' => 'http://www.syncml.org/docs/syncml_represent_v101_20010615.dtd'}, 'App' ),'-//SYNCML//DTD SyncML 1.1//EN' => bless( {'TAG' => {'33' => 'RespURI','32' => 'Replace','276' => 'Version','21' => 'Lang','7' => 'Archive','26' => 'Meta','18' => 'Final','264' => 'FreeID','16' => 'Delete','44' => 'SyncHdr','27' => 'MsgID','272' => 'NextNonce','277' => 'MaxObjSize','20' => 'Item','10' => 'Cmd','31' => 'Put','35' => 'Search','11' => 'CmdID','266' => 'Last','263' => 'Format','275' => 'Type','29' => 'NoResp','50' => 'VerProto','261' => 'Anchor','39' => 'Source','41' => 'Status','12' => 'CmdRef','15' => 'Data','52' => 'MoreData','45' => 'SyncML','19' => 'Get','274' => 'Size','17' => 'Exec','30' => 'NoResults','25' => 'MapItem','28' => 'MsgRef','40' => 'SourceRef','273' => 'SharedMem','268' => 'MaxMsgSize','14' => 'Cred','49' => 'VerDTD','24' => 'Map','271' => 'Next','267' => 'Mark','262' => 'EMI','22' => 'LocName','42' => 'Sync','269' => 'Mem','46' => 'Target','23' => 'LocURI','13' => 'Copy','6' => 'Alert','36' => 'Sequence','9' => 'Chal','51' => 'NumberOfChanges','47' => 'TargetRef','8' => 'Atomic','38' => 'SftDel','34' => 'Results','265' => 'FreeMem','37' => 'SessionID','43' => 'SyncBody','270' => 'MetInf','5' => 'Add'},'systemid' => 'http://www.openmobilealliance.org/tech/DTD/OMA-SyncML-RepPro-DTD-V1_1_2-20030505-D.dtd'}, 'App' )},'PublicIdentifier' => {'4052' => '-//SYNCML//DTD DevInf 1.1//EN','11' => '-//WAPFORUM//DTD PROV 1.0//EN','7' => '-//WAPFORUM//DTD CO 1.0//EN','4050' => '-//SYNCML//DTD DevInf 1.0//EN','17' => '-//OMA//DTD WV-CSP 1.2//EN','2' => '-//WAPFORUM//DTD WML 1.0//EN','4611' => '-//SYNCML//DTD DevInf 1.2//EN','4051' => '-//SYNCML//DTD SyncML 1.1//EN','16' => '-//WIRELESSVILLAGE//DTD CSP 1.1//EN','13' => '-//WAPFORUM//DTD EMN 1.0//EN','6' => '-//WAPFORUM//DTD SL 1.0//EN','4610' => '-//SYNCML//DTD MetaInf 1.2//EN','4609' => '-//SYNCML//DTD SyncML 1.2//EN','9' => '-//WAPFORUM//DTD WML 1.2//EN','12' => '-//WAPFORUM//DTD WTA-WML 1.2//EN','14' => '-//OMA//DTD DRMREL 1.0//EN','15' => '-//WIRELESSVILLAGE//DTD CSP 1.0//EN','8' => '-//WAPFORUM//DTD CHANNEL 1.1//EN','4' => '-//WAPFORUM//DTD WML 1.1//EN','4049' => '-//SYNCML//DTD SyncML 1.0//EN','10' => '-//WAPFORUM//DTD WML 1.3//EN','5' => '-//WAPFORUM//DTD SI 1.0//EN'}}, 'Rules' );

my $syncml_rules_for_x2w =
bless( {'App' => {'-//SYNCML//DTD DevInf 1.0//EN' => bless( {'variableSubs' => '','TagTokens' => [bless( {'name' => 'CTCap','ext_token' => 5}, 'TagToken' ),bless( {'name' => 'CTType','ext_token' => 6}, 'TagToken' ),bless( {'name' => 'DataStore','ext_token' => 7}, 'TagToken' ),bless( {'name' => 'DataType','ext_token' => 8}, 'TagToken' ),bless( {'name' => 'DevID','ext_token' => 9}, 'TagToken' ),bless( {'name' => 'DevInf','ext_token' => 10}, 'TagToken' ),bless( {'name' => 'DevTyp','ext_token' => 11}, 'TagToken' ),bless( {'name' => 'DisplayName','ext_token' => 12}, 'TagToken' ),bless( {'name' => 'DSMem','ext_token' => 13}, 'TagToken' ),bless( {'name' => 'Ext','ext_token' => 14}, 'TagToken' ),bless( {'name' => 'FwV','ext_token' => 15}, 'TagToken' ),bless( {'name' => 'HwV','ext_token' => 16}, 'TagToken' ),bless( {'name' => 'Man','ext_token' => 17}, 'TagToken' ),bless( {'name' => 'MaxGUIDSize','ext_token' => 18}, 'TagToken' ),bless( {'name' => 'MaxID','ext_token' => 19}, 'TagToken' ),bless( {'name' => 'MaxMem','ext_token' => 20}, 'TagToken' ),bless( {'name' => 'Mod','ext_token' => 21}, 'TagToken' ),bless( {'name' => 'OEM','ext_token' => 22}, 'TagToken' ),bless( {'name' => 'ParamName','ext_token' => 23}, 'TagToken' ),bless( {'name' => 'PropName','ext_token' => 24}, 'TagToken' ),bless( {'name' => 'Rx','ext_token' => 25}, 'TagToken' ),bless( {'name' => 'Rx-Pref','ext_token' => 26}, 'TagToken' ),bless( {'name' => 'SharedMem','ext_token' => 27}, 'TagToken' ),bless( {'name' => 'Size','ext_token' => 28}, 'TagToken' ),bless( {'name' => 'SourceRef','ext_token' => 29}, 'TagToken' ),bless( {'name' => 'SwV','ext_token' => 30}, 'TagToken' ),bless( {'name' => 'SyncCap','ext_token' => 31}, 'TagToken' ),bless( {'name' => 'SyncType','ext_token' => 32}, 'TagToken' ),bless( {'name' => 'Tx','ext_token' => 33}, 'TagToken' ),bless( {'name' => 'Tx-Pref','ext_token' => 34}, 'TagToken' ),bless( {'name' => 'ValEnum','ext_token' => 35}, 'TagToken' ),bless( {'name' => 'VerCT','ext_token' => 36}, 'TagToken' ),bless( {'name' => 'VerDTD','ext_token' => 37}, 'TagToken' ),bless( {'name' => 'Xnam','ext_token' => 38}, 'TagToken' ),bless( {'name' => 'Xval','ext_token' => 39}, 'TagToken' )],'AttrValueTokens' => [],'publicid' => '-//SYNCML//DTD DevInf 1.0//EN','skipDefault' => '','textualExt' => 'xml','xmlSpace' => 'preserve','tokenisedExt' => 'wbxml','AttrStartTokens' => []}, 'WbRulesApp' ),'-//SYNCML//DTD DevInf 1.1//EN' => bless( {'variableSubs' => '','TagTokens' => [bless( {'name' => 'CTCap','ext_token' => 5}, 'TagToken' ),bless( {'name' => 'CTType','ext_token' => 6}, 'TagToken' ),bless( {'name' => 'DataStore','ext_token' => 7}, 'TagToken' ),bless( {'name' => 'DataType','ext_token' => 8}, 'TagToken' ),bless( {'name' => 'DevID','ext_token' => 9}, 'TagToken' ),bless( {'name' => 'DevInf','ext_token' => 10}, 'TagToken' ),bless( {'name' => 'DevTyp','ext_token' => 11}, 'TagToken' ),bless( {'name' => 'DisplayName','ext_token' => 12}, 'TagToken' ),bless( {'name' => 'DSMem','ext_token' => 13}, 'TagToken' ),bless( {'name' => 'Ext','ext_token' => 14}, 'TagToken' ),bless( {'name' => 'FwV','ext_token' => 15}, 'TagToken' ),bless( {'name' => 'HwV','ext_token' => 16}, 'TagToken' ),bless( {'name' => 'Man','ext_token' => 17}, 'TagToken' ),bless( {'name' => 'MaxGUIDSize','ext_token' => 18}, 'TagToken' ),bless( {'name' => 'MaxID','ext_token' => 19}, 'TagToken' ),bless( {'name' => 'MaxMem','ext_token' => 20}, 'TagToken' ),bless( {'name' => 'Mod','ext_token' => 21}, 'TagToken' ),bless( {'name' => 'OEM','ext_token' => 22}, 'TagToken' ),bless( {'name' => 'ParamName','ext_token' => 23}, 'TagToken' ),bless( {'name' => 'PropName','ext_token' => 24}, 'TagToken' ),bless( {'name' => 'Rx','ext_token' => 25}, 'TagToken' ),bless( {'name' => 'Rx-Pref','ext_token' => 26}, 'TagToken' ),bless( {'name' => 'SharedMem','ext_token' => 27}, 'TagToken' ),bless( {'name' => 'Size','ext_token' => 28}, 'TagToken' ),bless( {'name' => 'SourceRef','ext_token' => 29}, 'TagToken' ),bless( {'name' => 'SwV','ext_token' => 30}, 'TagToken' ),bless( {'name' => 'SyncCap','ext_token' => 31}, 'TagToken' ),bless( {'name' => 'SyncType','ext_token' => 32}, 'TagToken' ),bless( {'name' => 'Tx','ext_token' => 33}, 'TagToken' ),bless( {'name' => 'Tx-Pref','ext_token' => 34}, 'TagToken' ),bless( {'name' => 'ValEnum','ext_token' => 35}, 'TagToken' ),bless( {'name' => 'VerCT','ext_token' => 36}, 'TagToken' ),bless( {'name' => 'VerDTD','ext_token' => 37}, 'TagToken' ),bless( {'name' => 'Xnam','ext_token' => 38}, 'TagToken' ),bless( {'name' => 'Xval','ext_token' => 39}, 'TagToken' ),bless( {'name' => 'UTC','ext_token' => 40}, 'TagToken' ),bless( {'name' => 'SupportNumberOfChanges','ext_token' => 41}, 'TagToken' ),bless( {'name' => 'SupportLargeObjs','ext_token' => 42}, 'TagToken' )],'AttrValueTokens' => [],'publicid' => '-//SYNCML//DTD DevInf 1.1//EN','skipDefault' => '','textualExt' => 'xml','xmlSpace' => 'preserve','tokenisedExt' => 'wbxml','AttrStartTokens' => []}, 'WbRulesApp' ),'-//SYNCML//DTD SyncML 1.0//EN' => bless( {'variableSubs' => '','TagTokens' => [bless( {'name' => 'Add','ext_token' => 5}, 'TagToken' ),bless( {'name' => 'Alert','ext_token' => 6}, 'TagToken' ),bless( {'name' => 'Archive','ext_token' => 7}, 'TagToken' ),bless( {'name' => 'Atomic','ext_token' => 8}, 'TagToken' ),bless( {'name' => 'Chal','ext_token' => 9}, 'TagToken' ),bless( {'name' => 'Cmd','ext_token' => 10}, 'TagToken' ),bless( {'name' => 'CmdID','ext_token' => 11}, 'TagToken' ),bless( {'name' => 'CmdRef','ext_token' => 12}, 'TagToken' ),bless( {'name' => 'Copy','ext_token' => 13}, 'TagToken' ),bless( {'name' => 'Cred','ext_token' => 14}, 'TagToken' ),bless( {'name' => 'Data','ext_token' => 15}, 'TagToken' ),bless( {'name' => 'Delete','ext_token' => 16}, 'TagToken' ),bless( {'name' => 'Exec','ext_token' => 17}, 'TagToken' ),bless( {'name' => 'Final','ext_token' => 18}, 'TagToken' ),bless( {'name' => 'Get','ext_token' => 19}, 'TagToken' ),bless( {'name' => 'Item','ext_token' => 20}, 'TagToken' ),bless( {'name' => 'Lang','ext_token' => 21}, 'TagToken' ),bless( {'name' => 'LocName','ext_token' => 22}, 'TagToken' ),bless( {'name' => 'LocURI','ext_token' => 23}, 'TagToken' ),bless( {'name' => 'Map','ext_token' => 24}, 'TagToken' ),bless( {'name' => 'MapItem','ext_token' => 25}, 'TagToken' ),bless( {'name' => 'Meta','ext_token' => 26}, 'TagToken' ),bless( {'name' => 'MsgID','ext_token' => 27}, 'TagToken' ),bless( {'name' => 'MsgRef','ext_token' => 28}, 'TagToken' ),bless( {'name' => 'NoResp','ext_token' => 29}, 'TagToken' ),bless( {'name' => 'NoResults','ext_token' => 30}, 'TagToken' ),bless( {'name' => 'Put','ext_token' => 31}, 'TagToken' ),bless( {'name' => 'Replace','ext_token' => 32}, 'TagToken' ),bless( {'name' => 'RespURI','ext_token' => 33}, 'TagToken' ),bless( {'name' => 'Results','ext_token' => 34}, 'TagToken' ),bless( {'name' => 'Search','ext_token' => 35}, 'TagToken' ),bless( {'name' => 'Sequence','ext_token' => 36}, 'TagToken' ),bless( {'name' => 'SessionID','ext_token' => 37}, 'TagToken' ),bless( {'name' => 'SftDel','ext_token' => 38}, 'TagToken' ),bless( {'name' => 'Source','ext_token' => 39}, 'TagToken' ),bless( {'name' => 'SourceRef','ext_token' => 40}, 'TagToken' ),bless( {'name' => 'Status','ext_token' => 41}, 'TagToken' ),bless( {'name' => 'Sync','ext_token' => 42}, 'TagToken' ),bless( {'name' => 'SyncBody','ext_token' => 43}, 'TagToken' ),bless( {'name' => 'SyncHdr','ext_token' => 44}, 'TagToken' ),bless( {'name' => 'SyncML','ext_token' => 45}, 'TagToken' ),bless( {'name' => 'Target','ext_token' => 46}, 'TagToken' ),bless( {'name' => 'TargetRef','ext_token' => 47}, 'TagToken' ),bless( {'name' => 'VerDTD','ext_token' => 49}, 'TagToken' ),bless( {'name' => 'VerProto','ext_token' => 50}, 'TagToken' ),bless( {'name' => 'Anchor','ext_token' => 261}, 'TagToken' ),bless( {'name' => 'EMI','ext_token' => 262}, 'TagToken' ),bless( {'name' => 'Format','ext_token' => 263}, 'TagToken' ),bless( {'name' => 'FreeID','ext_token' => 264}, 'TagToken' ),bless( {'name' => 'FreeMem','ext_token' => 265}, 'TagToken' ),bless( {'name' => 'Last','ext_token' => 266}, 'TagToken' ),bless( {'name' => 'Mark','ext_token' => 267}, 'TagToken' ),bless( {'name' => 'MaxMsgSize','ext_token' => 268}, 'TagToken' ),bless( {'name' => 'Mem','ext_token' => 269}, 'TagToken' ),bless( {'name' => 'MetInf','ext_token' => 270}, 'TagToken' ),bless( {'name' => 'Next','ext_token' => 271}, 'TagToken' ),bless( {'name' => 'NextNonce','ext_token' => 272}, 'TagToken' ),bless( {'name' => 'SharedMem','ext_token' => 273}, 'TagToken' ),bless( {'name' => 'Size','ext_token' => 274}, 'TagToken' ),bless( {'name' => 'Type','ext_token' => 275}, 'TagToken' ),bless( {'name' => 'Version','ext_token' => 276}, 'TagToken' )],'AttrValueTokens' => [],'publicid' => '-//SYNCML//DTD SyncML 1.0//EN','skipDefault' => '','textualExt' => 'xml','xmlSpace' => 'preserve','tokenisedExt' => 'wbxml','AttrStartTokens' => []}, 'WbRulesApp' ),'-//SYNCML//DTD SyncML 1.1//EN' => bless( {'variableSubs' => '','TagTokens' => [bless( {'name' => 'Add','ext_token' => 5}, 'TagToken' ),bless( {'name' => 'Alert','ext_token' => 6}, 'TagToken' ),bless( {'name' => 'Archive','ext_token' => 7}, 'TagToken' ),bless( {'name' => 'Atomic','ext_token' => 8}, 'TagToken' ),bless( {'name' => 'Chal','ext_token' => 9}, 'TagToken' ),bless( {'name' => 'Cmd','ext_token' => 10}, 'TagToken' ),bless( {'name' => 'CmdID','ext_token' => 11}, 'TagToken' ),bless( {'name' => 'CmdRef','ext_token' => 12}, 'TagToken' ),bless( {'name' => 'Copy','ext_token' => 13}, 'TagToken' ),bless( {'name' => 'Cred','ext_token' => 14}, 'TagToken' ),bless( {'name' => 'Data','ext_token' => 15}, 'TagToken' ),bless( {'name' => 'Delete','ext_token' => 16}, 'TagToken' ),bless( {'name' => 'Exec','ext_token' => 17}, 'TagToken' ),bless( {'name' => 'Final','ext_token' => 18}, 'TagToken' ),bless( {'name' => 'Get','ext_token' => 19}, 'TagToken' ),bless( {'name' => 'Item','ext_token' => 20}, 'TagToken' ),bless( {'name' => 'Lang','ext_token' => 21}, 'TagToken' ),bless( {'name' => 'LocName','ext_token' => 22}, 'TagToken' ),bless( {'name' => 'LocURI','ext_token' => 23}, 'TagToken' ),bless( {'name' => 'Map','ext_token' => 24}, 'TagToken' ),bless( {'name' => 'MapItem','ext_token' => 25}, 'TagToken' ),bless( {'name' => 'Meta','ext_token' => 26}, 'TagToken' ),bless( {'name' => 'MsgID','ext_token' => 27}, 'TagToken' ),bless( {'name' => 'MsgRef','ext_token' => 28}, 'TagToken' ),bless( {'name' => 'NoResp','ext_token' => 29}, 'TagToken' ),bless( {'name' => 'NoResults','ext_token' => 30}, 'TagToken' ),bless( {'name' => 'Put','ext_token' => 31}, 'TagToken' ),bless( {'name' => 'Replace','ext_token' => 32}, 'TagToken' ),bless( {'name' => 'RespURI','ext_token' => 33}, 'TagToken' ),bless( {'name' => 'Results','ext_token' => 34}, 'TagToken' ),bless( {'name' => 'Search','ext_token' => 35}, 'TagToken' ),bless( {'name' => 'Sequence','ext_token' => 36}, 'TagToken' ),bless( {'name' => 'SessionID','ext_token' => 37}, 'TagToken' ),bless( {'name' => 'SftDel','ext_token' => 38}, 'TagToken' ),bless( {'name' => 'Source','ext_token' => 39}, 'TagToken' ),bless( {'name' => 'SourceRef','ext_token' => 40}, 'TagToken' ),bless( {'name' => 'Status','ext_token' => 41}, 'TagToken' ),bless( {'name' => 'Sync','ext_token' => 42}, 'TagToken' ),bless( {'name' => 'SyncBody','ext_token' => 43}, 'TagToken' ),bless( {'name' => 'SyncHdr','ext_token' => 44}, 'TagToken' ),bless( {'name' => 'SyncML','ext_token' => 45}, 'TagToken' ),bless( {'name' => 'Target','ext_token' => 46}, 'TagToken' ),bless( {'name' => 'TargetRef','ext_token' => 47}, 'TagToken' ),bless( {'name' => 'VerDTD','ext_token' => 49}, 'TagToken' ),bless( {'name' => 'VerProto','ext_token' => 50}, 'TagToken' ),bless( {'name' => 'NumberOfChanges','ext_token' => 51}, 'TagToken' ),bless( {'name' => 'MoreData','ext_token' => 52}, 'TagToken' ),bless( {'name' => 'Anchor','ext_token' => 261}, 'TagToken' ),bless( {'name' => 'EMI','ext_token' => 262}, 'TagToken' ),bless( {'name' => 'Format','ext_token' => 263}, 'TagToken' ),bless( {'name' => 'FreeID','ext_token' => 264}, 'TagToken' ),bless( {'name' => 'FreeMem','ext_token' => 265}, 'TagToken' ),bless( {'name' => 'Last','ext_token' => 266}, 'TagToken' ),bless( {'name' => 'Mark','ext_token' => 267}, 'TagToken' ),bless( {'name' => 'MaxMsgSize','ext_token' => 268}, 'TagToken' ),bless( {'name' => 'MaxObjSize','ext_token' => 277}, 'TagToken' ),bless( {'name' => 'Mem','ext_token' => 269}, 'TagToken' ),bless( {'name' => 'MetInf','ext_token' => 270}, 'TagToken' ),bless( {'name' => 'Next','ext_token' => 271}, 'TagToken' ),bless( {'name' => 'NextNonce','ext_token' => 272}, 'TagToken' ),bless( {'name' => 'SharedMem','ext_token' => 273}, 'TagToken' ),bless( {'name' => 'Size','ext_token' => 274}, 'TagToken' ),bless( {'name' => 'Type','ext_token' => 275}, 'TagToken' ),bless( {'name' => 'Version','ext_token' => 276}, 'TagToken' )],'AttrValueTokens' => [],'publicid' => '-//SYNCML//DTD SyncML 1.1//EN','skipDefault' => '','textualExt' => 'xml','xmlSpace' => 'preserve','tokenisedExt' => 'wbxml','AttrStartTokens' => []}, 'WbRulesApp' )},'version' => 3,'DefaultApp' => bless( {'variableSubs' => '','TagTokens' => [],'AttrValueTokens' => [],'publicid' => 'DEFAULT','skipDefault' => '','textualExt' => 'xml','xmlSpace' => 'preserve','tokenisedExt' => 'wbxml','AttrStartTokens' => []}, 'WbRulesApp' ),'PublicIdentifiers' => {'-//SYNCML//DTD SyncML 1.1//EN' => 4051,'-//OMA//DTD WV-CSP 1.2//EN' => 17,'-//WAPFORUM//DTD WML 1.0//EN' => 2,'-//WAPFORUM//DTD WML 1.1//EN' => 4,'-//SYNCML//DTD DevInf 1.1//EN' => 4052,'-//WAPFORUM//DTD SL 1.0//EN' => 6,'-//WAPFORUM//DTD WML 1.2//EN' => 9,'-//SYNCML//DTD MetaInf 1.2//EN' => 4610,'-//WAPFORUM//DTD CHANNEL 1.1//EN' => 8,'-//SYNCML//DTD DevInf 1.0//EN' => 4050,'-//WAPFORUM//DTD PROV 1.0//EN' => 11,'-//WIRELESSVILLAGE//DTD CSP 1.1//EN' => 16,'-//WAPFORUM//DTD CO 1.0//EN' => 7,'-//WAPFORUM//DTD WML 1.3//EN' => 10,'-//WAPFORUM//DTD WTA-WML 1.2//EN' => 12,'-//WAPFORUM//DTD EMN 1.0//EN' => 13,'-//OMA//DTD DRMREL 1.0//EN' => 14,'-//SYNCML//DTD DevInf 1.2//EN' => 4611,'-//WIRELESSVILLAGE//DTD CSP 1.0//EN' => 15,'-//WAPFORUM//DTD SI 1.0//EN' => 5,'-//SYNCML//DTD SyncML 1.0//EN' => 4049,'-//SYNCML//DTD SyncML 1.2//EN' => 4609}}, 'WbRules' );

=head2 wbxml_to_xml $wbxml

Converts the SyncML WBXML message C<$wbxml> to XML.

=cut

sub wbxml_to_xml {
    my $in_wbxml = shift;

    my $consumer = XML::SAX::Writer::StringConsumer->new;
    my $handler = XML::SAX::Writer->new(Writer => 'XML::WBXML::SyncML::WriterXML', Output => $consumer);
    my $error = XML::WBXML::SyncML::ErrorHandler->new;

    $WAP::SAXDriver::wbxml::rules = $syncml_rules_for_w2x;
    my $parser = WAP::SAXDriver::wbxml->new(Handler => $handler, ErrorHandler => $error);

    my $doc = $parser->parse( Source => { String => $in_wbxml } );

    return ${ $consumer->finalize };
} 


=head2 xml_to_wbxml $xml

Converts the SyncML XML message C<$xml> to WBXML.

=cut

sub xml_to_wbxml {
    my $in_xml = shift;

    my $parser = XML::DOM::Parser->new;
    my $doc_xml = $parser->parse($in_xml);

    my $wbxml = WbXml->new($syncml_rules_for_x2w, '-//SYNCML//DTD SyncML 1.1//EN');
    my $out_wbxml = $wbxml->compile($doc_xml, 'UTF-8');

    return $out_wbxml;
} 



=head1 CONFIGURATION AND ENVIRONMENT

XML::WBXML::SyncML requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<WAP::wbxml>, L<WAP::SAXDriver::wbxml>, L<XML::DOM>, and L<XML::SAX::Writer>.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS


No bugs have been reported.

Please report any bugs or feature requests to
C<bug-xml-wbxml-syncml@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

David Glasser  C<< <glasser@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2005, Best Practical Solutions, LLC.  All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

package XML::WBXML::SyncML::ErrorHandler;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    return bless {}, $class;
}

sub fatal_error {
	my $self = shift;
	my ($hash) = @_;
	die __PACKAGE__,": Fatal error\n\tat position $hash->{BytePosition}.\n";
}

sub error {
	my $self = shift;
	my ($hash) = @_;
	warn __PACKAGE__,": Error: $hash->{Message}\n\tat position $hash->{BytePosition}\n";
}

sub warning {
	my $self = shift;
	my ($hash) = @_;
	warn __PACKAGE__,": Warning: $hash->{Message}\n\tat position $hash->{BytePosition}\n";
}


package XML::WBXML::SyncML::WriterXML;

use base qw(XML::SAX::Writer::XML);

sub characters {
	my $self = shift;
	my $data = shift;
	$self->_output_element;

	my $char = $data->{Data};
	my $first = ord $char;
	if ($first <= 03) {
		# WBXML inner
		my $doc = XML::WBXML::SyncML::wbxml_to_xml($char);

		$char = '<![CDATA[' . $doc . ']]>';
	} else {
		if ($self->{InCDATA}) {
			# we must scan for ]]> in the CDATA and escape it if it
			# is present by close--opening
			# we need to have buffer text in front of this...
			$char = join ']]>]]&lt;<![CDATA[', split ']]>', $char;
		}
		else {
			$char = $self->escape($char);
		}
	}
	$char = $self->{Encoder}->convert($char);
	$self->{Consumer}->output($char);
}

1;
