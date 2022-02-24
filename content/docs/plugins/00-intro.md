---
title: 'Introduction to plugins'
date: 2022-02-23T13:14:39+10:00
weight: 1
---


Plugin format is `.plg` (XML)

Example with [Community Application](https://github.com/Squidly271/community.applications/blob/master/plugins/community.applications.plg)
```xml

<?xml version='1.0' standalone='yes'?>
<!DOCTYPE PLUGIN [
<!ENTITY name      "community.applications">
<!ENTITY author    "Andrew Zawadzki">
<!ENTITY version   "2022.02.06">
<!ENTITY md5       "f35abba3fe809c2d193fd407487b591b">
<!ENTITY launch    "Apps">
<!ENTITY plugdir   "/usr/local/emhttp/plugins/&name;">
<!ENTITY github    "Squidly271/community.applications">
<!ENTITY pluginURL "https://raw.githubusercontent.com/&github;/master/plugins/&name;.plg">
]>

<PLUGIN name="&name;" author="&author;" version="&version;" launch="&launch;" pluginURL="&pluginURL;" min="6.9.0" support="https://lime-technology.com/forums/topic/38582-plug-in-community-applications/" icon="users">

<CHANGES>
###2022.02.06
- Added: Date updated for docker containers
- Changed: Graphs going forward will now only populate to 7 months
- Fixed: Not all dates present in the sidebar would get translated
- Added: Ability in additional requirements to have a link for CA to perform a search
- Added: Support for additional moderation options
- Fixed: Install Multiple containers progress window was displaying white text on a white background (RC3 and possibly RC1/2)

###2015.05.28###
- Initial Release
</CHANGES>

<!-- The 'pre-install' script. -->
<FILE Run="/usr/bin/php">
<INLINE>
<![CDATA[
<?
  $version = parse_ini_file("/etc/unraid-version");

  if ( version_compare($version['version'],"6.9.0", "<") )
  {
    echo "********************************************************************\n";
    echo "\n";
    echo "Community Applications Requires unRaid version 6.9.0 or greater to run\n";
    echo "\n";
    echo "********************************************************************\n";
    exit(1);
  }
  echo "Cleaning Up Old Versions\n";
  if ( is_file("/usr/local/emhttp/plugins/community.applications/scripts/removeCron.php") ) {
    exec("/usr/local/emhttp/plugins/community.applications/scripts/removeCron.php");
  }
  exec("rm -rf /usr/local/emhttp/plugins/community.applications");
  @unlink("/etc/cron.daily/updateApplications.sh");

	exec("rm -rf /tmp/ca_notices");

	echo "Fixing pinned apps\n";
	if ( is_file("/boot/config/plugins/community.applications/pinned_appsV2.json") ) {
	  $original = json_decode(file_get_contents("/boot/config/plugins/community.applications/pinned_appsV2.json"),true);
		if ( is_array($original) ) {
			foreach ($original as $app) {
				$amp = strpos($app,"&");
				$new = substr($app,0,$amp).str_replace("-"," ",substr($app,$amp));
				$pin[$new]=$new;
			}
		}
		file_put_contents("/boot/config/plugins/community.applications/pinned_appsV2.json",json_encode($pin,JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT));
	}

	echo "Setting up cron for background notifications\n";
	$cron = rand(0,59)." * * * * php /usr/local/emhttp/plugins/community.applications/scripts/notices.php > /dev/null 2>&1";
	@file_put_contents("/boot/config/plugins/community.applications/notification_scan.cron","\n# CRON for CA background scanning of applications\n$cron\n\n");
	exec("/usr/local/sbin/update_cron");
?>
]]>
</INLINE>
</FILE>

<FILE Run="/bin/bash">
<INLINE>
# Remove old 'source' files
rm -f $(ls /boot/config/plugins/&name;/&name;*.txz 2>/dev/null &#124; grep -v '&version;')
if [[ -d /boot/config/plugins/repo.update ]]; then rm -rf /boot/config/plugins/repo.update; fi
if [[ -d /usr/local/emhttp/plugins/repo.update ]]; then rm -rf /usr/local/emhttp/plugins/repo.update; fi
if [[ -n $(ls /boot/config/plugins/repo.update*.plg 2>/dev/null) ]]; then rm /boot/config/plugins/repo.update*.plg; fi

if [[ -e /tmp/community.applications/tempFiles/templates.json ]]; then rm /tmp/community.applications/tempFiles/templates.json; fi
/usr/local/sbin/update_cron
</INLINE>
</FILE>

<!--
The 'source' file.
-->
<FILE Name="/boot/config/plugins/&name;/&name;-&version;-x86_64-1.txz" Run="upgradepkg --install-new --reinstall">
<URL>https://raw.githubusercontent.com/&github;/master/archive/&name;-&version;-x86_64-1.txz</URL>
<MD5>&md5;</MD5>
</FILE>

<!--
The 'post-install' script
-->
<FILE Run="/bin/bash">
<INLINE>
echo "Creating Directories"
rm -rf /tmp/community.applications/tempFiles
mkdir -p /tmp/community.applications/tempFiles
mkdir -p /boot/config/plugins/community.applications
rm -rf /usr/local/emhttp/plugins/community.applications/CA.page
echo ""
# Adjust icon depending on unRaid version
echo "Adjusting icon for unRaid version"
if [[ -e /usr/local/emhttp/plugins/dynamix/styles/font-cases.ttf ]]; then sed -i 's/f0db/e942/g' /usr/local/emhttp/plugins/community.applications/Apps.page; fi
if [[ ! -e /usr/local/emhttp/plugins/dynamix/styles/font-cases.ttf ]]; then sed -i 's/e942/f0db/g' /usr/local/emhttp/plugins/community.applications/Apps.page; fi
echo ""
echo "----------------------------------------------------"
echo " &name; has been installed."
echo " Copyright 2015-2022, Andrew Zawadzki"
echo " Version: &version;"
echo "----------------------------------------------------"
echo ""
</INLINE>
</FILE>

<!--
The 'remove' script.
-->
<FILE Run="/bin/bash" Method="remove">
<INLINE>
removepkg &name;-&version;-x86_64-1
rm -rf &plugdir;
rm -rf /boot/config/plugins/&name;
rm -rf /var/lib/docker/unraid/templates-community
</INLINE>
</FILE>
</PLUGIN>
```

### File breakdown

* `name` - this is the name of you plugin.  This name should be the sub-directory for you plugin off the /usr/local/emhttp/plugins/ directory and is where your plugin files are located.  Plgman uses the name to find your plugin, and the icon associated with the plugin.  The icon should be named `name.png`.  Plgman uses this information to display information about your plugin.

* `author` - Information field for plgman to display.

* `version` - Plgman displays the version and uses this version to check for an updated version in your repository.  The convention is year.month.day.  If several releases occur in the same day, use the convention year.month.day-x, where x-=1,2,...

* `pluginURL` - The is the web URL to the repository where your plugin is stored.  Plgman uses it to look for the latest version of your plugin.  It is best to use a generic name for your plugin and not have the name include a version.  The versioning is done inside the plugin.

---

* Free form comment section


---

* ```
    <FILE Name="/boot/packages/<package-name-on-disk>.txz" Run="upgradepkg --install-new">
    <URL>http://slackware.oregonstate.edu/<path>/<to>/<package-name>.txz</URL>
    <MD5>de646f44d881b6c4292e353b717792cd</MD5>
    </FILE>
  ```

  This is the `<package-name>` package that is installed.  This could be a tar bundle that you expand into the the /usr/local/enhttp/plugins/name.

  > :point_up: If you download a tar bundle, **store a copy on the flash at** `/boot/config/plugins/name` so it doesn't have to be downloaded each time the plugin is installed. **Packages are stored on the flash at** `/boot/packages`.

* ```
  <FILE Name="/boot/config/plugins/&name;/ntfs-3g.png">
  <URL>https://github.com/dlandon/unraid-snap/raw/master/ntfs-3g.png</URL>
  </FILE>
  ```

  This is the icon used for the ntfs-3g plugin.  I would recommend that you put this into the bundle for the plugin structure you download if possible.


---

* `Page file`: The page file is used by emhttp to display and render your webpage. **The page file must begin with a capital letter**, and your php included in the page file.  This is the page file from the Apcupsd plugin as an example.  The `Menu` setting is important because this is the area in `Settings` where emhttp will install the icon.

