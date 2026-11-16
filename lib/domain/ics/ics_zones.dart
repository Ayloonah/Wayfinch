import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Converts calendar times given in a named time zone (`TZID=...`) to the
/// computer's local time.
///
/// Understands IANA names ("America/Toronto") through the `timezone`
/// database, and the Windows names Outlook writes ("Eastern Standard Time").
class IcsZones {
  IcsZones._();

  static bool _loaded = false;

  static void _ensureLoaded() {
    if (_loaded) return;
    tzdata.initializeTimeZones();
    _loaded = true;
  }

  /// The IANA name for [tzid], or null when it isn't recognized.
  static String? ianaName(String tzid) {
    _ensureLoaded();
    var id = tzid.trim();
    if (id.startsWith('"') && id.endsWith('"') && id.length > 1) {
      id = id.substring(1, id.length - 1);
    }
    // Some exporters prefix a slash or a vendor path ("/mozilla.org/.../X").
    final candidates = <String>[
      id,
      if (id.startsWith('/')) id.substring(1),
      if (id.contains('/')) ...[
        id.split('/').reversed.take(2).toList().reversed.join('/'),
      ],
    ];
    for (final c in candidates) {
      if (tz.timeZoneDatabase.locations.containsKey(c)) return c;
    }
    return _windowsZones[id];
  }

  /// The local time of wall-clock time [wall] (fields only) in zone [tzid],
  /// or null when the zone isn't recognized.
  static DateTime? toLocal(DateTime wall, String tzid) {
    final name = ianaName(tzid);
    if (name == null) return null;
    final location = tz.getLocation(name);
    final zoned = tz.TZDateTime(
      location,
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
    );
    return DateTime.fromMillisecondsSinceEpoch(zoned.millisecondsSinceEpoch);
  }
}

/// Windows time zone ids (as written by Outlook and Exchange) mapped to IANA
/// names, from the Unicode CLDR "windowsZones" table (primary zones).
const _windowsZones = <String, String>{
  'Dateline Standard Time': 'Etc/GMT+12',
  'UTC-11': 'Etc/GMT+11',
  'Hawaiian Standard Time': 'Pacific/Honolulu',
  'Alaskan Standard Time': 'America/Anchorage',
  'Pacific Standard Time (Mexico)': 'America/Tijuana',
  'Pacific Standard Time': 'America/Los_Angeles',
  'US Mountain Standard Time': 'America/Phoenix',
  'Mountain Standard Time (Mexico)': 'America/Mazatlan',
  'Mountain Standard Time': 'America/Denver',
  'Central America Standard Time': 'America/Guatemala',
  'Central Standard Time': 'America/Chicago',
  'Central Standard Time (Mexico)': 'America/Mexico_City',
  'Canada Central Standard Time': 'America/Regina',
  'SA Pacific Standard Time': 'America/Bogota',
  'Eastern Standard Time (Mexico)': 'America/Cancun',
  'Eastern Standard Time': 'America/New_York',
  'US Eastern Standard Time': 'America/Indianapolis',
  'Venezuela Standard Time': 'America/Caracas',
  'Atlantic Standard Time': 'America/Halifax',
  'SA Western Standard Time': 'America/La_Paz',
  'Pacific SA Standard Time': 'America/Santiago',
  'Newfoundland Standard Time': 'America/St_Johns',
  'E. South America Standard Time': 'America/Sao_Paulo',
  'SA Eastern Standard Time': 'America/Cayenne',
  'Argentina Standard Time': 'America/Buenos_Aires',
  'Greenland Standard Time': 'America/Godthab',
  'Montevideo Standard Time': 'America/Montevideo',
  'UTC-02': 'Etc/GMT+2',
  'Azores Standard Time': 'Atlantic/Azores',
  'Cape Verde Standard Time': 'Atlantic/Cape_Verde',
  'UTC': 'Etc/UTC',
  'GMT Standard Time': 'Europe/London',
  'Greenwich Standard Time': 'Atlantic/Reykjavik',
  'Morocco Standard Time': 'Africa/Casablanca',
  'W. Europe Standard Time': 'Europe/Berlin',
  'Central Europe Standard Time': 'Europe/Budapest',
  'Romance Standard Time': 'Europe/Paris',
  'Central European Standard Time': 'Europe/Warsaw',
  'W. Central Africa Standard Time': 'Africa/Lagos',
  'GTB Standard Time': 'Europe/Bucharest',
  'Middle East Standard Time': 'Asia/Beirut',
  'Egypt Standard Time': 'Africa/Cairo',
  'E. Europe Standard Time': 'Europe/Chisinau',
  'South Africa Standard Time': 'Africa/Johannesburg',
  'FLE Standard Time': 'Europe/Kiev',
  'Israel Standard Time': 'Asia/Jerusalem',
  'Jordan Standard Time': 'Asia/Amman',
  'Arabic Standard Time': 'Asia/Baghdad',
  'Turkey Standard Time': 'Europe/Istanbul',
  'Arab Standard Time': 'Asia/Riyadh',
  'Russian Standard Time': 'Europe/Moscow',
  'E. Africa Standard Time': 'Africa/Nairobi',
  'Iran Standard Time': 'Asia/Tehran',
  'Arabian Standard Time': 'Asia/Dubai',
  'Azerbaijan Standard Time': 'Asia/Baku',
  'Georgian Standard Time': 'Asia/Tbilisi',
  'Afghanistan Standard Time': 'Asia/Kabul',
  'West Asia Standard Time': 'Asia/Tashkent',
  'Pakistan Standard Time': 'Asia/Karachi',
  'India Standard Time': 'Asia/Calcutta',
  'Sri Lanka Standard Time': 'Asia/Colombo',
  'Nepal Standard Time': 'Asia/Katmandu',
  'Central Asia Standard Time': 'Asia/Almaty',
  'Bangladesh Standard Time': 'Asia/Dhaka',
  'Myanmar Standard Time': 'Asia/Rangoon',
  'SE Asia Standard Time': 'Asia/Bangkok',
  'China Standard Time': 'Asia/Shanghai',
  'Singapore Standard Time': 'Asia/Singapore',
  'Taipei Standard Time': 'Asia/Taipei',
  'W. Australia Standard Time': 'Australia/Perth',
  'Korea Standard Time': 'Asia/Seoul',
  'Tokyo Standard Time': 'Asia/Tokyo',
  'Cen. Australia Standard Time': 'Australia/Adelaide',
  'AUS Central Standard Time': 'Australia/Darwin',
  'E. Australia Standard Time': 'Australia/Brisbane',
  'AUS Eastern Standard Time': 'Australia/Sydney',
  'West Pacific Standard Time': 'Pacific/Port_Moresby',
  'Tasmania Standard Time': 'Australia/Hobart',
  'New Zealand Standard Time': 'Pacific/Auckland',
  'Fiji Standard Time': 'Pacific/Fiji',
  'Tonga Standard Time': 'Pacific/Tongatapu',
  'Samoa Standard Time': 'Pacific/Apia',
};
