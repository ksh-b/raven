import 'package:raven/model/publisher.dart';
import 'package:raven/repository/news/custom/morss.dart';
import 'package:raven/repository/news/custom/rss.dart';
import 'package:raven/repository/news/general/national/bangladesh/prothamalo.dart';
import 'package:raven/repository/news/general/national/bangladesh/prothamalo_english.dart';
import 'package:raven/repository/news/general/national/china/rfa_cantonese.dart';
import 'package:raven/repository/news/general/national/china/rfa_mandarin.dart';
import 'package:raven/repository/news/general/national/china/rfa_tibetan.dart';
import 'package:raven/repository/news/general/national/india/thehindu.dart';
import 'package:raven/repository/news/general/national/india/theindianexpress.dart';
import 'package:raven/repository/news/general/national/india/thequint.dart';
import 'package:raven/repository/news/general/national/india/thewire.dart';
import 'package:raven/repository/news/general/national/myanmar/rfa_burmese.dart';
import 'package:raven/repository/news/general/world/aljazeera.dart';
import 'package:raven/repository/news/general/world/apnews.dart';
import 'package:raven/repository/news/general/world/bbc.dart';
import 'package:raven/repository/news/general/world/cnn.dart';
import 'package:raven/repository/news/general/world/rfa_english.dart';
import 'package:raven/repository/news/general/world/theguardian.dart';
import 'package:raven/repository/news/technology/androidpolice.dart';
import 'package:raven/repository/news/technology/arstechnica.dart';
import 'package:raven/repository/news/technology/bleepingcomputer.dart';
import 'package:raven/repository/news/technology/engadget.dart';
import 'package:raven/repository/news/technology/theverge.dart';
import 'package:raven/repository/news/technology/torrentfreak.dart';
import 'package:raven/repository/news/technology/xdadevelopers.dart';

Map<String, Publisher> publishers = {
  for (var publisher in [
    // technology
    AndroidPolice(),
    ArsTechnica(),
    BleepingComputer(),
    Engadget(),
    TheVerge(),
    TorrentFreak(),
    XDAdevelopers(),

    // world
    AlJazeera(),
    APNews(),
    BBC(),
    CNN(),
    RfaEnglish(),
    TheGuardian(),

    // custom
    Morss(),
    RSSFeed(),

    // bangladesh
    ProthamAlo(),
    ProthamAloEn(),

    // china
    RfaCantonese(),
    RfaMandarin(),
    RfaTibetan(),

    // india
    TheIndianExpress(),
    TheHindu(),
    TheWire(),
    TheQuint(),

    // myanmar
    RfaBurmese(),
  ])
    publisher.name: publisher,
};
