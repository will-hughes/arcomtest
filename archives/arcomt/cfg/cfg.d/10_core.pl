# This file was edited from that created by bin/epadmin
# You can regenerate this file by doing ./bin/epadmin config_core arcom but it will overwrite these settings

$c->{host} = 'arcomtest';
$c->{port} = 80;
$c->{aliases} = [
                  {
                    'redirect' => 'yes',
                    'name' => 'arcomtest.com'
                  }
                ];
$c->{securehost} = '';
$c->{secureport} = 443;
$c->{http_root} = undef;
