use inc::Module::Install;

name ('XML-WBXML-SyncML');
author ('David Glasser <glasser@bestpractical.com>');
version_from ('lib/XML/WBXML/SyncML.pm');
abstract_from('lib/XML/WBXML/SyncML.pm');
license('perl');
build_requires('Test::More');
build_requires('Test::XML');
requires('XML::DOM');
requires('XML::SAX::Writer');
requires('WAP::wbxml');
requires('WAP::SAXDriver::wbxml');

&WriteAll;
