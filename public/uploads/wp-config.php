<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpressdb');

/** MySQL database username */
define('DB_USER', 'jonesax');

/** MySQL database password */
define('DB_PASSWORD', 'Trinity1');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '8.)DPK.Gr_D!#a^0`_Y07O5|-l+-=K3JcRv[8|}elL[aCN@GcXnEPYCOG*Rsz&r@');
define('SECURE_AUTH_KEY',  '.^gj4uy9: DXn_~[c`z$7ES$RI;[oI)i#z9vX.AR|c#R~K{hXUt3?Qh?g|4yr-+.');
define('LOGGED_IN_KEY',    't_:VMKDlo|){ jrg%+^! spOnF6cq>3!:DL*>=m}8+u|!GH!N<J)|-a`[^B/+/S?');
define('NONCE_KEY',        'wIY]e?BQ@MiNMAgVj2{SvGRg&;8Pc]p+/pJr</ge|Z57YE<}tdr{e7xqD8$O*I7!');
define('AUTH_SALT',        'W=+a4Pv,)?C)!X|S/sKS`7y5/iS,je1gjwLh80_VhzBs>%waS}sp2wOu@NxtX`d*');
define('SECURE_AUTH_SALT', '|x*f#TDg)7QuGc{_`i|XwS2yTTsY|4vg;}laR`<gn@9Pm7~*3.YCf-(}rLP.+^W|');
define('LOGGED_IN_SALT',   'c$Y&.2,#>N0:n!UvV[%|QC=kxBHcdf;=v?S(|!dG9+gA)S|*NS=&[w$Z/+.:E?En');
define('NONCE_SALT',       'vAM)b6wQIp_%C6^uN!GsyTWR<|B[5vT~|D  NX8.2yG|s+||7z>-4QHx(J@^-:MO');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
