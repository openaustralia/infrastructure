<?php

define('DEVSITE', {{ devsite }});

// Paths
define('VHOST_DIR', '/srv/www/{{ stage }}');
define('ROOT_DIR', VHOST_DIR . '/current');
define('INCLUDE_DIR', ROOT_DIR . '/includes');
define('PEAR_DIR', INCLUDE_DIR . '/PEAR');
define('DATA_DIR', ROOT_DIR . '/data');
define('IMAGES_DIR', DATA_DIR . '/images');
define('TEMP_DIR', DATA_DIR . '/temp');
define('DOC_DIR' , ROOT_DIR . '/docs');
define('TOOLS_DIR' , ROOT_DIR . '/tools');
define('CONFIG_DIR' , ROOT_DIR . '/config');
define('TMP_DIR', ROOT_DIR . '/tmp');
define('LOG_DIR', ROOT_DIR . '/logs');
define('SMARTY_PATH', DATA_DIR . '/smarty_compile');
define('TEMPLATE_DIR', ROOT_DIR . '/templates');
define('CACHE_DIR', DATA_DIR . '/cache');

// *******************************************************************************
// MySQL database.
define ("DB_HOST", "{{ mysql_host }}");
define ("DB_USER", "el-{{ stage }}");
define ("DB_PASSWORD", "{{ db_password }}");
define ("DB_PASS", "{{ db_password }}");
define ("DB_NAME", "el-{{ stage }}");
define('DATETIMEFORMAT_SQL',	"Y-m-d H:i:s"); // 2006-06-02 12:23:23
define('SQL_DEBUG_LEVEL', 0); // sets DB_DataObject::debug_level; set to 0 for prod

// *******************************************************************************


define("CURRENT_ELECTION", "7");
define("BANNER", true);

//urls
define("DOMAIN", "www.{{ domain }}");
define("WWW_SERVER", "https://" . DOMAIN );
define("ADMIN_SERVER", "https://" . DOMAIN );

//confirmation
define("CONFIRMATION_BASE_URL", WWW_SERVER . '/confirmed.php?q=');
define("CONFIRMATION_EMAIL", 'confirm@' . DOMAIN);

//Email titles
define("EMAIL_PREFIX", '[election leaflet] ');
define("BUG_EMAIL_PREFIX", '[election leaflet bug]');

//Email addresses
define("CONTACT_EMAIL", 'team@electionleaflets.org.au');
define("BUG_FROM_EMAIL", 'bugs@' . DOMAIN);
define("BUG_TO_EMAIL", 'web-administrators@electionleaflets.org.au');
define("LEAFLETS_EMAIL", 'leaflets{{ email_suffix }}@electionleaflets.org.au');

//Site name
define("SITE_NAME", "ElectionLeaflets.org.au");
define("SITE_TAG_LINE", "not your average election website");

//session stuff
define('SESSION_COOKIE_LIFETIME', 0);
define('SESSION_COOKIE_PATH', '/');
define('SESSION_COOKIE_DOMAIN', null);

//cache
define('CACHE_TIME', 0);

//image sizes
define('IMAGE_THUMBNAIL_SIZE', 140);
define('IMAGE_SMALL_SIZE', 120);
define('IMAGE_MEDIUM_SIZE', 300);
define('IMAGE_LARGE_SIZE', 1024);

//scraping
define('SCRAPE_METHOD', 'PEAR');

//encryption
define("USER_SALT", "{{ user_salt }}");

//Searching
define('MAX_DISTANCE_SEARCH', 30); //km

//APIs
define("API_SLEEP", 0.5); //time to wait between api calls

//Maps
define("GOOGLE_MAPS_KEY", '{{ google_maps_key }}');
define("MAP_PROVIDER", "google");
//Enable the link to the Django map
define("MAP_ENABLED", false);

//cookies
define("LOGIN_COOKIE_NAME", "electionleafletlogin");
define("LOGIN_COOKIE_EXPIRE_DAYS", 14);

// TheyWorkForYou API
define("THEYWORKFORYOU_API_KEY", 'YOUR KEY');

//AWS API
define("AWS_KEY",'{{ aws_key }}');
define("AWS_SECRET",'{{ aws_secret }}');
define("S3_BUCKET",'{{ s3_bucket }}');

//Storage
define("STORAGE_STRATEGY",'s3');  //or 's3'

//image upload by email
define("UPLOAD_MAIL_SERVER", '{{ upload_mail_server }}'); //imap server
define("UPLOAD_MAIL_USER", '{{ upload_mail_user }}');
define("UPLOAD_MAIL_PASSWORD", '{{ upload_mail_password }}');

define("STAT_ZERO_DATE", '2010-01-01');

define("PAGE_ITEMS_COUNT",9);
define("RSS_ITEMS_COUNT",5000);

//Localisation
define("COUNTRY",13); // see db, country_id=13 Australia
define("COUNTRY_ISO", "AU");
// Country Code Top Level Domain as defined here http://code.google.com/apis/maps/documentation/geocoding/v2/index.html#CountryCodes
define("COUNTRY_CODE_TLD", "au");
// The area name, like 'constituencies' or 'electorates'. Needs approprate .htaccess rules for the URL
define("AREA_NAMES", 'electorates');
// google analytics
define("GOOGLE_ANALYTICS_TRACKER",'{{ analytics }}');

// Admin area username and password
define("ADMIN_USERNAME", '{{ admin_username }}');
define("ADMIN_PASSWORD", '{{ admin_password }}');

?>
