# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Local Values ------------------------------------------------------------

directions <- c("E", "N", "NE", "NW", "S", "SE", "SW", "W")
WW1_countries <- c("UK", "USA")
WW1_service <- c("GAR", "RAF", "USAAS")
WW2_countries <- c("UK", "USA")
WW2_service <- c("AF", "RAF", "RAAF", "RNZAF", "SAAF", "TAC")
Korea_countries <- c("USA")
Korea_service <- c()
Vietnam_countries <- c("USA")
Vietnam_service <- c("KAF", "RAAF", "RLAF", "USA", "USAF", "USMC", "USN", "VNAF")
countries <- unique(c(WW1_countries, WW2_countries, Korea_countries, Vietnam_countries))
services <- unique(c(WW1_service, WW2_service, Korea_service, Vietnam_service))
roman_numerals <- c("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII")

upper_case_abbreviations <- c("AAA", "HQ", "RR", "USS")
upper_case_abbreviations_lower <- tolower(upper_case_abbreviations)
upper_case_set <- unique(c(directions, countries, services, roman_numerals, upper_case_abbreviations))
upper_case_set_lower <- tolower(upper_case_set)

WW1_aircraft_letters <- c()
WW2_aircraft_letters <- c("SBD", "TBF")
Korea_aircraft_letters <- c()
Vietnam_aircraft_letters <- c()
aircraft_letters <- unique(c(WW1_aircraft_letters, WW2_aircraft_letters, Korea_aircraft_letters, Vietnam_aircraft_letters, roman_numerals))

stop_words <- c("and", "at", "aux", "di", "el", "en", "in", "la", "le", "les", "no", "not", "of", "on", "or", "the", "to", "sur")
measurement_units <- c("km", "m", "cm", "mm", "mi", "in", "ft", "kg")
ordinal_markers <- c("st", "nd", "rd", "th")

lower_case_set <- c(stop_words, measurement_units, ordinal_markers)
lower_case_set_upper <- toupper(lower_case_set)

unusual_plural_set <- c("anti-aircraft", "aircraft", "ammunition", "ammo", "personnel")
vowel_set <- c("a", "e", "i", "o", "u")


### Named Vectors -----------------------------------------------------------

months <- c("January" = 1L, 
            "February" = 2L, 
            "March" = 3L, 
            "April" = 4L, 
            "May" = 5L, 
            "June" = 6L, 
            "July" = 7L, 
            "August" = 8L, 
            "September" = 9L, 
            "October" = 10L, 
            "November" = 11L, 
            "December" = 12L)

visibility_categorizations <- c("good" = "good|clear|excellent|undercast", 
                                "poor" = "poor|clouds|overcast", 
                                "fair" = "fair|layers|scattered", 
                                "poor" = "very")

target_categorizations <- c("town"           = "town|business|city|house|huts|market|monastery|town|urban|village", 
                            "factory"        = "factory|assembly|blast|construction|engine|furnace|gasoline|hydroelectric|manufacturing|plant|power|refinery|works", 
                            "airfield"       = "airfield|airdrome|runway", 
                            "aircraft"       = "aircraft|airframes|mig|seaplanes", 
                            "headquarters"   = "communications|compound|facility|government|headquarters|management", 
                            "defenses"       = "defenses|anti-aircraft|battery|defensive|emplacement|gun|installation|pillbox|tower", 
                            "base"           = "base|aresenal|barracks|buildings|camp", 
                            "harbor"         = "harbor|barges|boats|coastal|dock|ferry|jetty|shipyard|vessels|waterfront|wharf", 
                            "munitions"      = "munitions|ammunition|explosive", 
                            "infrastructure" = "bridge|canal|river crossing|tunnel", 
                            "rail"           = "rail|junction|marshalling|railroad|railway|station|trains|yard", 
                            "road"           = "road|highway|locomotives|transportation|trucks|vehicles", 
                            "supplies"       = "supplies|dump|equipment|rations|shipping|storage|warehouse", 
                            "troops"         = "troops|artillery|concentration|enemy|japanese|personnel|support", 
                            "area"           = "area|hill|location|place|point|position|tactical|target")

target_rules <- c(                        "/?ETC", 
                                          "[?.]", 
                  " "                   = " +-? *", 
                  "ADMINISTRATIVE"      = "\\b(ADM(IN[A-Z]*)?)\\b", 
                  "AIRCRAFT"            = "\\b(AC|A C)(RFT)?\\b", 
                  "AIRDROME"            = "\\b(AERO?D?|AIRODROM|AIRDROM|AIDROM|AIR DROM)[A-Z]*\\b", 
                  "AIRFIELD"            = "\\b(AIR FIELDS?|AIRFLD|AIRFIEL|AIRFIELDS)\\b", 
                  "AIRFRAMES"           = "\\b(AIR FRAMES?)\\b", 
                  "AMMUNITION"          = "\\b(AMMO|AMMUN[A-Z]*)\\b", 
                  "ANTI-AIRCRAFT"       = "\\b(AA|ANTIAIRCRAFT|ANTI AIRCRAFT|ANTI AIR CRAFT)\\b", 
                  "AREA"                = "\\b(ARES?|ABEAS?|APEAS?|AREAS)\\b", 
                  "ARSENAL"             = "\\b(ARSENALS)\\b", 
                  "ARTILLERY"           = "\\b(ARTILLER)\\b", 
                  "ASSEMBLY"            = "\\b(ASSBLY)\\b", 
                  "BARGES"              = "\\b(BRAGES?|BARGE)\\b", 
                  "BARRACKS"            = "\\b(BR?KS?|BARRAC.*)\\b", 
                  "BASE"                = "\\b(BASFS?|BASES)\\b", 
                  "BATTERY"             = "\\b(BTY|BRTY|BTRY)\\b", 
                  "BEARINGS"            = "\\b(BEARING)\\b", 
                  "BLAST"               = "\\b(BLST)\\b", 
                  "BOATS"               = "\\b(BOAT)\\b", 
                  "BRIDGE"              = "\\b(BR|BR?D?GE?S?|BRID ES?|8RIDGES?|GRIDGES?|BOIDGES?|BIRDGES?|BRIDGES)\\b", 
                  "BUILDINGS"           = "\\b(BLDGS?|BUILD|BUILOING|BUILDING)\\b", 
                  "BUNKER"              = "\\b(BNKR)\\b", 
                  "BUSINESS"            = "\\b(BUSIHESS)\\b", 
                  "CAMP"                = "\\b(CAMPS)\\b", 
                  "CANAL"               = "\\b(CANAI|CANALS)\\b", 
                  "CENTER"              = "\\b(CENTRE?|CENTERS)\\b", 
                  "CHEMICAL"            = "\\b(CHEM)\\b", 
                  "CITY"                = "\\b(CIIY)\\b", 
                  "CIVILIAN"            = "\\b(CIV)\\b", 
                  "COASTAL"             = "\\b(COAST|COASTAL[A-Z]*)\\b", 
                  "COMMERCIAL"          = "\\b(COM)\\b", 
                  "COMMAND"             = "\\b(COMM|COMD)\\b", 
                  "COMMUNICATIONS"      = "\\b(COMMUNICATION)\\b", 
                  "COMPONENTS"          = "\\b(COMPONENT)\\b", 
                  "COMPOUND"            = "\\b(CONPOUNDS?|CPMPOUNDS?|COMPOU[A-Z]*)\\b", 
                  "CONCENTRATION"       = "\\b(CONCT?S?|CONCENT[A-Z]*|CONSTRATIONS?|CONTRATIONS?|CQNCENTRATIONS?)\\b", 
                  "CONSTRUCTION"        = "\\b(CONST)\\b", 
                  "DEFENSES"            = "\\b(DEFENCE?S|DEFENSE)\\b", 
                  "DEFENSIVE"           = "\\b(DEF)\\b", 
                  "DOCK"                = "\\b(DDCKS?|DOCKS)\\b", 
                  "DUMP"                = "\\b(DIMPS?|DOOPS?|DUMPS)\\b", 
                  "ELECTRIC"            = "\\b(ELCT|ELECT?)\\b", 
                  "EMPLACEMENT"         = "\\b(EMP|EMPL|EMPLACEMENTO|EMPLACEMENTS|IMPLACEMENTS?)\\b", 
                  "ENEMY"               = "\\b(EN|ENEMIES)\\b", 
                  "ENGINE"              = "\\b(ENG)\\b", 
                  "EQUIPMENT"           = "\\b(EQUIPT?)\\b", 
                  "EXPLOSIVE"           = "\\b(EXPLOSIVES)\\b", 
                  "FACILITY"            = "\\b(FACILIT[A-Z]*)\\b", 
                  "FACTORY"             = "\\b(FAC?T?|FCTY|FACTO|FACTOR[A-Z]+)\\b", 
                  "FERRY"               = "\\b(FERRIES)\\b", 
                  "GASOLINE"            = "\\b(GAS)\\b", 
                  "GOVERNMENT"          = "\\b(GOVT|GOVERMENT)\\b", 
                  "GUN"                 = "\\b(GUM)\\b", 
                  "HARBOR"              = "\\b(HARBDR|HARBOURS?|HARBORS)\\b", 
                  "HEADQUARTERS"        = "\\b(HDOS?|HDQR?S?|HQ ?S?|HEADQUARTER)\\b", 
                  "HEAVY"               = "\\b(HVY)\\b", 
                  "HIGHWAY"             = "\\b(HWY?S?|HTGHWAYS?|HIWAYS?|HIGHWAYS)\\b", 
                  "HILL"                = "\\b(HILLSIDE|HILLS)\\b", 
                  "HOUSES"              = "\\b(HOUSES)\\b", 
                  "HUTS"                = "\\b(HUYS?|HUT)\\b", 
                  "HYDROELECTRIC"       = "\\b(HYDRIELECTRIC|HYDRO ELECTRIC)\\b", 
                  "INSTALLATION"        = "\\b(INST[A-Z]*)\\b", 
                  "JAPANESE"            = "\\b(JAPS?|JAPANSE)\\b", 
                  "JETTY"               = "\\b(JETTIES)\\b", 
                  "JUNCTION"            = "\\b(JTNS?|JCTS?|JUNC|JUNCT[A-Z]*)\\b", 
                  "LAUNCHER"            = "\\b(LNCHR)\\b", 
                  "LIGHT"               = "\\b(LGT)\\b", 
                  "LOCATION"            = "\\b(LOCS?)\\b", 
                  "LOCOMOTIVES"         = "\\b(LOCOS?|LOCOMOTIVE)\\b", 
                  "LOOKOUT"             = "\\b(LKOUT)\\b", 
                  "MANAGEMENT"          = "\\b(MGMT)\\b", 
                  "MANUFACTURING"       = "\\b(MFG)\\b", 
                  "MARKET"              = "\\b(MKT)\\b", 
                  "MARSHALL"            = "\\b(MARSHALLIN ?G)\\b", 
                  "MARSHALLING YARD"    = "\\b(M[/ ]Y(ARD)?)\\b", 
                  "MISCELLANEOUS"       = "\\b(MISCEL[A-Z]*)\\b", 
                  "MONASTERY"           = "\\b(MONASTARY)\\b", 
                  "MUNITIONS"           = "\\b(MUNITION)\\b", 
                  "PARK/STOP"           = "\\b(PRK[ /]ST)\\b", 
                  "PARK"                = "\\b(PRK)\\b", 
                  "PERSONNEL"           = "\\b(PERONN?EL|PERSONN[A-Z]*)\\b", 
                  "PETROL"              = "\\b(POL)\\b", 
                  "PILLBOXES"           = "\\b(PILL BOX[A-Z]*)\\b", 
                  "PLACE"               = "\\b(PL)\\b", 
                  "PLANT"               = "\\b(PLTS?|PLANTS)\\b", 
                  "POINT"               = "\\b(PT|POINTS)\\b", 
                  "POPULATION"          = "\\b(POP[A-Z]*N)\\b", 
                  "POSITION"            = "\\b(POS|P0SI[A-Z]*|PDSI[A-Z]*|POSI[A-Z]*|POSTIONS?)\\b", 
                  "\\1 \\2"             = "\\b(POWER)([A-Z]+)\\b", 
                  "POWER"               = "\\b(PWR)\\b", 
                  "RAILROAD"            = "\\b(R ?R|HAILROAD|RAIL ROAD|RAILROADS)\\b", 
                  "RAILWAY"             = "\\b(RLWY|RAILWAYS)\\b", 
                  "RATIONS"             = "\\b(RATION)\\b", 
                  "RED"                 = "\\bRED[A-Z]*", 
                  "REFINERY"            = "\\b(REF)\\b", 
                  "REPORTED"            = "\\b(RPTD)\\b", 
                  "RIVER CROSSING"      = "\\b(RIV[A-Z]* CR[A-Z]*|RIV[A-Z]* CROSS NG)\\b", 
                  "ROAD"                = "\\b(RD)\\b", 
                  "ROCKET"              = "\\b(RCKT)\\b", 
                  "RUNWAY"              = "\\b(RWY|RWAY|RUNWAYS)\\b", 
                  "SEAPLANES"           = "\\b(SEAPIANES?|SEA PLANES?|SEAPLANE)\\b", 
                  "SHIPPING"            = "\\b(SHIPP[A-Z]*)\\b", 
                  "SHIPYARD"            = "\\b(SHIPVARDS?|SHIP YARDS?)\\b", 
                  "SIDING"              = "\\b(SIDINQS?|SIDINGS)\\b", 
                  "SOREHEAD"            = "\\bSOREHEAD?[A-Z]*", 
                  "STATION"             = "\\b(STAS?|STNS?|STATIONS)\\b", 
                  "STORAGE"             = "\\b(STOR|STGE)\\b", 
                  "SUPPLIES"            = "\\b(BUPPLIES)\\b", 
                  "SUPPORT"             = "\\b(SUPPOER)\\b", 
                  "SUSPECTED"           = "\\b(SUSP)\\b", 
                  "SYNTHETIC"           = "\\b(SYN)\\b", 
                  "TACTICAL"            = "\\b(TA?CT)\\b", 
                  "TANKS"               = "\\b(TNKS?|TANK)\\b", 
                  "TARGET"              = "\\b(TGTS?|TARGETS)\\b", 
                  "TOWER"               = "\\b(TOWENS)\\b", 
                  "TOWN"                = "\\b(TDWNS?|TOWMS?|TOWNS)\\b", 
                  "TRAILER"             = "\\b(TRLR)\\b", 
                  "TRANSSHIPMENT POINT" = "\\b(TRANS POINT)\\b", 
                  "TRANSSHIPMENT"       = "\\b(TRANSHIPMENT)\\b", 
                  "TRANSPORTATION"      = "\\b(TRANS|TRANSPORT|TRASNPORT|TRANPORTATION)\\b", 
                  "TROOPS"              = "\\b(IROOPS?|TOOOO|TROOP)\\b", 
                  "TRUCKS"              = "\\b(TRK|TRUCK)\\b", 
                  "TUNNEL"              = "\\b(TUNNELS)\\b", 
                  "UNIDENTIFIED"        = "\\b(UNIDENT)\\b", 
                  "UNKNOWN"             = "\\b(UNK)\\b", 
                  "URBAN"               = "\\b(URSAN)\\b", 
                  "VEHICLES"            = "\\b(VEHICLE)\\b", 
                  "VESSELS"             = "\\b(VESSEL)\\b", 
                  "VILLAGE"             = "\\b(VILIAGES?|VILLAGES)\\b", 
                  "WAREHOUSE"           = "\\b(WARE[A-Z]? HOUSES?|WAREHOUSES)\\b", 
                  "WATERFRONT"          = "\\b(WATER FRONT)\\b", 
                  "WHARF"               = "\\b(WHARVES|WHARFS)\\b", 
                  "WORKS"               = "\\b(WR?KS?)\\b", 
                  "YARD"                = "\\b(YDS?|YARUS?|YARDS)\\b")

Vietnam_operation_rules <- c(                    " ?[%&].*", 
                                                 "NOT APPLICABLE|UNK", 
                                                 "\\b(- )", 
                                                 " ?(UT.*|QR.*|NRB.*)", 
                             "\\2"             = "\\b(HJ|XT)([A-Z]+)", 
                             " \\1"            = "[/&-](\\d)", 
                             "\\1 \\2"         = "([A-Z])(\\d+)", 
                             "HAWK"            = "AHWK|KAWK|HAWL|HAWKK", 
                             "ROLLING THUNDER" = "ROLLING THUND?", 
                             "SUN"             = "SVN", 
                             "AEROSOL"         = "\\bAER[LOST]*[A-Z]*", 
                             "ALASH"           = "\\bALA?SH[A-Z]*", 
                             "AMTRACK"         = "\\bA?MTRACK[A-Z]*", 
                             "ARGON"           = "\\b[AS]?RG[NOB]*[A-Z]*", 
                             "BABBIT"          = "\\b(BABB|BABBUT)[A-Z]*", 
                             "BAFFLE"          = "\\bJ?BAFFLE[A-Z]*", 
                             "BERSERK"         = "\\b(RERSERK|BSRAERK|J?BE[FR]S[ERK]+[A-Z]*)", 
                             "BLABBER"         = "\\bBLABBER[A-Z]*", 
                             "BLADE"           = "\\bBLAD[A-Z]*", 
                             "BLUE TREE"       = "\\bBLUE ?T[RE]EE[A-Z]*", 
                             "BOBCAT"          = "\\bBOBCAT[A-Z]*", 
                             "BRAVO"           = "\\bBRAV[A-Z]*", 
                             "BUCKSHOT"        = "\\bBUC[KH]SHOT[A-Z]*", 
                             "BULLWHIP"        = "\\bB?ULLWH[A-Z]*", 
                             "CHARLIE"         = "\\bCHARLIE[A-Z]*", 
                             "COBRA"           = "\\bC?OBRA[A-Z]*", 
                             "COMBAT SKYSPOT"  = "\\bCOMBAT ?[SKYPORT]+[A-Z]*", 
                             "COMBO"           = "\\bJ?C?OMBO[A-Z]*", 
                             "COMFORT"         = "\\bC?OMFORT[A-Z]*", 
                             "DAD"             = "\\bDAD[A-Z]*", 
                             "DAMSEL"          = "\\bDA[MN][SEL]+[A-Z]*", 
                             "DEVIL"           = "\\bDEVIL[A-Z]*", 
                             "DOWNY"           = "\\bDOWNE?Y[A-Z]*", 
                             "ECHO"            = "\\bECHO[A-Z]*", 
                             "ELECTRA"         = "\\bJ?E?LECTRA", 
                             "GINKO"           = "\\b[JX]G[I1]?NKO[A-Z]*", 
                             "GOLF"            = "\\bGOLF[A-Z]*", 
                             "HAGGLE"          = "\\b[HA]+GGLE[A-Z]*", 
                             "HEMP"            = "\\bHEMP[A-Z]*", 
                             "HILLSBRO"        = "\\bHILLSB[A-Z]*", 
                             "HIPSTER"         = "\\bH?[UI]PST[A-Z]*", 
                             "HOTEL"           = "\\bHOTEL[A-Z]*", 
                             "ICON"            = "\\bI[OC]+N[A-Z]*", 
                             "INDIA"           = "\\bINDIA[A-Z]*", 
                             "JALOPY"          = "\\b[HJ]ALOPY[A-Z]*", 
                             "JIM"             = "\\bJ[IU]M[A-Z]*", 
                             "JULIET"          = "\\bJULIE[A-Z]*", 
                             "JUNK"            = "\\bJ?[4J]UNK[A-Z]*", 
                             "KING COBRA"      = "\\bK?ING COBRA[A-Z]*", 
                             "KINGDOM"         = "\\b(K?I[NM]G[DL]|KINDOM)[A-Z]*", 
                             "LAOS VIETNAM"    = "\\b[AJ]?L[A-Z0-9/]*[ 0]*[VI][A-Z0-9]*[TN][A-Z]*", 
                             "LAOS VIETNAM"    = "\\bA[LAOUS]* VI[RTNAM]*[A-Z]*", 
                             "LAOS"            = "\\bLA[OUS]+[A-Z]*", 
                             "LASH"            = "\\bLAS[A-Z]*", 
                             "LEOTARD"         = "\\bL[EO/]+TARD[A-Z]*", 
                             "LIMA"            = "\\bLIMA[A-Z]*", 
                             "MIKE"            = "\\bMIKE[A-Z]*", 
                             "NAPALM"          = "\\b[J]?NAP[ALM]+[A-Z]*", 
                             "NOVEMBER"        = "\\b(NOV[EMBR]+[A-Z]*|N\\/VEMBER[A-Z]*)", 
                             "OSCAR"           = "\\bOSCAR[A-Z]*", 
                             "OXFORD"          = "\\bOXFO[ERD]+[A-Z]*", 
                             "PANAMA"          = "\\bPA?NAMA[A-Z]*", 
                             "PAPA"            = "\\bPAPA[A-Z]*", 
                             "PAVEN"           = "\\bPAVEN[A-Z]*", 
                             "PETRO"           = "\\bPE[TY]RO[A-Z]*", 
                             "PETTICOAT"       = "\\bP?ETTI[A-Z]*T[A-Z]*", 
                             "POLKA DOT"       = "\\bPOLKADOT[A-Z]*", 
                             "PULLOVER"        = "\\bULLOVER[A-Z]*", 
                             "QUEBEC"          = "\\bQUEBIC[A-Z]*", 
                             "RAMROD"          = "\\bR?AMROD[A-Z]*", 
                             "RED CROWN"       = "\\bRED ?CR[OWN]+[A-Z]*", 
                             "REDNECK"         = "\\bREDN[A-Z]*K[A-Z]*", 
                             "ROMEO"           = "\\bRO[MEO]+[A-Z]*", 
                             "REUBEN"          = "\\bR[EU]+BEN[A-Z]*", 
                             "SABRE"           = "\\bS[AZ]B[RE]*[A-Z]*", 
                             "SHADOW"          = "\\b[SW]HADOW[A-Z]*", 
                             "SHELLAC"         = "\\bS?[HN]ELLAC[A-Z]*", 
                             "SIERRA"          = "\\bS[IERA]{4,}[A-Z]*", 
                             "SINFUL"          = "\\bSIN[DF]UL[A-Z]*", 
                             "SLOVAK"          = "\\bSLOVA[CK]+[A-Z]*", 
                             "SNAIL"           = "\\bSNAIL?[A-Z]*", 
                             "SOUTH VIETNAM"   = "\\bS(VSTH)? VIETNAM[A-Z]*", 
                             "STORMY"          = "\\b[GFJ]*STORM[ Y]+[A-Z]*", 
                             "SUN DOG"         = "\\bSUN DO[BG][A-Z]*", 
                             "THERMAL"         = "\\bT?HERMAL[A-Z]*", 
                             "TIGER CUB"       = "\\bT?IGER CUB[A-Z]*", 
                             "TRICYCLE"        = "\\bT?R[IU]C[UY]CLE[A-Z]*", 
                             "TRUMP"           = "\\bTRUM?P[A-Z]*", 
                             "UNIFORM"         = "\\bUNI[FORM]+[A-Z]*", 
                             "VACCUUM"         = "\\bJ?VAC[CUM]+[A-Z]*", 
                             "VERMIN"          = "\\bVERMIN[A-Z]*", 
                             "VICE SQUAD"      = "\\bVICE ?SQ[UAD]+[A-Z]*", 
                             "VIETNAM"         = "\\bA?VIETNAM[A-Z]*", 
                             "YANKEE"          = "\\bYANKEE[A-Z]*", 
                             "YELLOW JACKET"   = "\\bYELLOW JACK[A-Z]*", 
                             "YOUNG TIGER"     = "\\b(Y?OUNG|YOUMG|YONUG|YPUNG) T[IU]GER[A-Z]*", 
                             "YOYO"            = "\\bJ?(Y-Y-|YOYO|YOUO|UOUO|UOYO|OOYO)[A-Z]*", 
                             "WATERBOY"        = "\\bWA?TERB[A-Z]*", 
                             "WHISKEY"         = "\\bWHIS[KEY]+[A-Z]*", 
                             "ZULU"            = "\\bZULU[A-Z]*", 
                                                 " +$")

Vietnam_operation_rules2 <- c(        " ?- ?.*", 
                                      " ?\\d.*", 
                                      " ?ZERO|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|SIXTY|([IVX]+\\b)", 
                              "\\3" = "((ARC|FINE|SUN|[LR][IU]GHT) )?([A-Z]* ?[A-Z]*)( (DUPT|SUPR|SUPT))?", 
                                      "SSY", 
                                      " +$", 
                                      " .{1,2}$", 
                                      "^.{1,2}$")


### Capitalize Functions ----------------------------------------------------

capitalize <- function(words) {
  return (paste0(toupper(substring(words, 1, 1)), substring(words, 2)))
}

capitalize_phrase <- function(line) {
  return (paste(capitalize(strsplit(line, split = " ")[[1]]), collapse = " "))
}

capitalize_phrase_vectorized <- function(lines) {
  lines_mod <- if_else(lines == "", "`", tolower(lines))
  num_lines <- length(lines)
  
  split_result <- strsplit(lines_mod, split = " ")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = " ")
  
  return (if_else(lines == "", "", lines_reduced))
}

capitalize_from_caps <- function(words) {
  return (paste0(substring(words, 1, 1), tolower(substring(words, 2))))
}


### Proper Noun Functions ---------------------------------------------------

proper_noun_first <- function(word) {
  word = tolower(word)
  return (proper_noun(word))
}

proper_noun <- function(word) {
  if (word %in% upper_case_set_lower) {
    return (toupper(word))
  } else if (word %in% lower_case_set) {
    return (word)
  } else {
    return (capitalize(word))
  }
}

proper_noun_vectorized <- function(words) {
  return (if_else(words %in% upper_case_set_lower, 
                  toupper(words), 
          if_else(words %in% lower_case_set, 
                  words, 
                  capitalize(words))))
}

proper_noun_from_caps <- function(word) {
  if (word %in% upper_case_set) {
    return (word)
  } else if (word %in% lower_case_set_upper) {
    return (tolower(word))
  } else {
    return (capitalize_from_caps(word))
  }
}

proper_noun_from_caps_vectorized <- function(words) {
  return (if_else(words %in% upper_case_set, 
                  words, 
          if_else(words %in% lower_case_set_upper, 
                  tolower(words), 
                  capitalize_from_caps(words))))
}

proper_noun_aircraft <- function(word) {
  if (word %in% aircraft_letters) {
    return (word)
  } else {
    return (capitalize_from_caps(word))
  }
}

proper_noun_aircraft_vectorized <- function(words) {
  return (if_else(words %in% aircraft_letters | 
                    (regexpr(pattern = "-|\\d", words) > 0L & regexpr(pattern = "[A-Za-z]{6,}", words) == -1L), 
                  words, 
                  capitalize_from_caps(words)))
}

proper_noun_phrase <- function(line) {
  line <- tolower(line)
  line <- paste(proper_noun_vectorized(strsplit(line, split = " ")[[1]]),   collapse = " ")
  line <- paste(proper_noun_vectorized(strsplit(line, split = "-")[[1]]),   collapse = "-")
  line <- paste(proper_noun_vectorized(strsplit(line, split = "/")[[1]]),   collapse = "/")
  line <- paste(proper_noun_vectorized(strsplit(line, split = "\\(")[[1]]), collapse = "(")
  return (line)
}

proper_noun_phrase_vectorized <- function(lines) {
  lines_mod <- if_else(lines == "", "`", tolower(lines))
  num_lines <- length(lines)
  
  split_result <- strsplit(lines_mod, split = " ")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = " ")
  
  num_lines_reduced <- length(lines_reduced)
  
  split_result <- strsplit(lines_reduced, split = "-")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = "-")
  
  split_result <- strsplit(lines_reduced, split = "/")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = "/")
  
  split_result <- strsplit(lines_reduced, split = "\\(")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = "(")

  return (if_else(lines == "", "", lines_reduced))
}

proper_noun_phrase_aircraft <- function(line) {
  return (paste(proper_noun_aircraft_vectorized(strsplit(line, split = " ")[[1]]), collapse = " "))
}

proper_noun_phrase_aircraft_vectorized <- function(lines) {
  lines_mod <- if_else(lines == "", "`", lines)
  num_lines <- length(lines)
  
  split_result <- strsplit(lines_mod, split = " ")
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_aircraft_vectorized(unlist(split_result, use.names = FALSE)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = " ")
  
  return (if_else(lines == "", "", lines_reduced))
}


### Tooltip Helper Functions ------------------------------------------------

date_string <- function(month_names, day_strings, year_strings) {
  return (paste0("On ", month_names, " ", day_strings, ", ", year_strings, ","))
}

date_time_string <- function(date_strings, time_strings, empty = "") {
  return (if_else(time_strings == empty, 
                  date_strings, 
                  paste0(date_strings, " at ", time_strings, " hours,")))
}

date_period_time_string <- function(date_strings, period_strings, time_strings, empty = "") {
  return (if_else(time_strings == empty, 
                  if_else(period_strings == empty, 
                          date_strings, 
                          paste0(date_strings, " during the ", period_strings, ",")), 
                  paste0(date_strings, " at ", time_strings, " hours,")))
}

bomb_string <- function(weight, bomb, empty = "") {
  if (is.na(weight)) {
    if (bomb == empty) {
      return ("some bombs on")
    } else {
      return (paste0("some ", bomb, " on"))
    }
  } else {
    if (bomb == empty) {
      return (paste0(add_commas(weight), " pounds of bombs on"))
    } else {
      return (paste0(add_commas(weight), " pounds of ", bomb, " on"))
    }
  }
}

bomb_string_vectorized <- function(weights, bombs, empty = "") {
  result <- if_else(is.na(weights), 
                    "some", 
                    add_commas_vectorized(weights))
  return (if_else(bombs == empty, paste0(result, " bombs on"), paste0(result, " ", bombs, " on")))
}

aircraft_numtype_string <- function(num, type, empty = "") {
  if (is.na(num)) {
    if (type == empty) {
      return ("some aircraft")
    } else {
      return (paste0("some ", type, "s"))
    }
  } else if (num == 1) {
    if (type == empty) {
      return ("1 aircraft")
    } else {
      return (paste0("1 ", type))
    }
  } else {
    if (type == empty) {
      return (paste0(as.character(num), " aircraft"))
    } else {
      return (paste0(as.character(num), " ", type, "s"))
    }
  }
}

aircraft_numtype_string_vectorized <- function(nums, types, empty = "") {
  return (if_else(nums == 1, if_else(types == empty, 
                                     "1 aircraft", 
                                     paste0("1 ", types)), 
                             if_else(types == empty, 
                                     paste0(as.character(nums), " aircraft"), 
                                     paste0(as.character(nums), " ", types, "s")), 
                             missing = if_else(types == empty, 
                                               "some aircraft", 
                                               paste0("some ", types, "s"))))
}

aircraft_string <- function(numtype, division, empty = "") {
  if (division == empty) {
    return (paste0(numtype, " dropped"))
  } else {
    return (paste0(numtype, " of the ", division, " dropped"))
  }
}

aircraft_string_vectorized <- function(numtypes, divisions, empty = "") {
  return (if_else(divisions == empty, 
                  paste0(numtypes, " dropped"), 
                  paste0(numtypes, " of the ", divisions, " dropped")))
}

target_type_string <- function(type, empty = "") {
  if (type == empty) {
    return ("a target")
  } else {
    return (fix_articles(type))
  }
}

target_type_string_vectorized <- function(types, empty = "") {
  if (is.factor(types)) {
    return (if_else(types == empty, 
                    "a target", 
                    fix_articles_vectorized(as.character(types))))
  } else {
    return (if_else(types == empty, 
                    "a target", 
                    fix_articles_vectorized(types)))
  }
}

target_area_string <- function(area, empty = "") {
  if (area == empty) {
    return ("in this area")
  } else {
    return (paste0("in ", area))
  }
}

target_area_string_vectorized <- function(areas, empty = "") {
  return (if_else(areas == empty, 
                  "in this area", 
                  paste0("in ", areas)))
}

target_location_string <- function(city, country, empty = "") {
  if (city == empty) {
    if (country == empty) {
      return ("in this area")
    } else {
      return (paste0("in this area of ", country))
    }
  } else {
    if (country == empty) {
      return (paste0("in ", city))
    } else {
      return (paste0("in ", city, ", ", country))
    }
  }
}

target_location_string_vectorized <- function(cities, countries, empty = "") {
  return (if_else(cities == empty, 
                  if_else(countries == empty, 
                          "in this area", 
                          paste0("in this area of ", countries)), 
                  if_else(countries == "", 
                          paste0("in ", cities), 
                          paste0("in ", cities, ", ", countries))))
}


### Fix Articles ------------------------------------------------------------

fix_articles <- function(string) {
  l <- nchar(string)
  if (substr(string, l, l) == "s" | substr(string, 1, 2) == "a " | string %in% unusual_plural_set) {
    return (string)
  } else if (substr(string, 1, 1) %in% vowel_set) {
    return (paste("an", string))
  } else {
    return (paste("a", string))
  }
}

fix_articles_vectorized <- function(strings) {
  lengths <- nchar(strings)
  return (if_else(substr(strings, lengths, lengths) == "s" | 
                    substr(strings, 1, 2) == "a " | 
                    strings %in% unusual_plural_set, 
                  strings, 
                  if_else(substr(strings, 1, 1) %in% vowel_set, 
                          paste("an", strings), 
                          paste("a", strings))))
}


### Add Commas --------------------------------------------------------------

add_commas <- function(number) {
  if (is.finite(number)) {
    abs_number <- abs(number)
    if (abs_number > 1) {
      num_groups <- log(abs_number, base = 1000)
    } else {
      num_groups <- 0
    }
    
    if (num_groups < 1) {
      return (as.character(number))
    } else {
      num_rounds <- floor(num_groups)
      output_string <- ""
      
      for (round in 1:num_rounds) {
        this_group_int <- abs_number %% 1000
        if(this_group_int < 10) {
          output_string <- paste0(",00", as.character(this_group_int), output_string)
        } else if(this_group_int < 100) {
          output_string <- paste0(",0", as.character(this_group_int), output_string)
        } else {
          output_string <- paste0(",", as.character(this_group_int), output_string)
        }
        abs_number <- abs_number %/% 1000
      }
      
      if (number < 0) {
        return (paste0("-", as.character(abs_number), output_string))
      } else {
        return (paste0(as.character(abs_number), output_string))
      }
    }
  } else {
    return (NA_character_)
  }
}

# note: this assumes non-negative finite integers as inputs
add_commas_vectorized <- function(numbers) {
  numbers_strings <- as.character(numbers)
  nums_digits <- if_else(numbers < 10, 1, ceiling(log10(numbers)))
  max_digits <- max(nums_digits, na.rm = TRUE)
  num_rounds <- ceiling(max_digits / 3) - 1
  
  head_lengths <- 3 - (-nums_digits %% 3)
  tail_positions <- head_lengths + 1
  results <- substr(numbers_strings, 1, head_lengths)
  
  for (round in 1:num_rounds) {
    needs_more <- nums_digits > (3*round)
    results <- if_else(needs_more, paste0(results, ",", substr(numbers_strings, tail_positions+(3*(round-1)), tail_positions+(3*round))), results)
  }
  return (results)
}


### Formatting --------------------------------------------------------------

format_aircraft_types <- function(types) {
  return (gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)(.*)", replacement = "\\1-\\2", types))
}

format_military_times <- function(digits) {
  return (gsub(pattern = "^(\\d)$", replacement = "\\1:00", 
          gsub(pattern = "^(\\d)(\\d)$", replacement = "\\1:\\20", 
          gsub(pattern = "^(1[0-9]|2[0-3])$", replacement = "\\1:00", 
          gsub(pattern = "^(\\d)([03])$", replacement = "\\1:\\20", 
          gsub(pattern = "^(\\d{1,2})(\\d{2})", replacement = "\\1:\\2", 
          gsub(pattern = "^(\\d{1,2}):(\\d{2}):(\\d{2})", replacement = "\\1:\\2", digits)))))))
}

ampm_to_24_hour <- function(times) {
  return (gsub(pattern = "^12:(\\d{2}) ?[Pp][Mm]", replacement = "00:\\1", 
          gsub(pattern = "^11:(\\d{2}) ?[Pp][Mm]", replacement = "23:\\1", 
          gsub(pattern = "^10:(\\d{2}) ?[Pp][Mm]", replacement = "22:\\1", 
          gsub(pattern = "^0?9:(\\d{2}) ?[Pp][Mm]", replacement = "21:\\1", 
          gsub(pattern = "^0?8:(\\d{2}) ?[Pp][Mm]", replacement = "20:\\1", 
          gsub(pattern = "^0?7:(\\d{2}) ?[Pp][Mm]", replacement = "19:\\1", 
          gsub(pattern = "^0?6:(\\d{2}) ?[Pp][Mm]", replacement = "18:\\1", 
          gsub(pattern = "^0?5:(\\d{2}) ?[Pp][Mm]", replacement = "17:\\1", 
          gsub(pattern = "^0?4:(\\d{2}) ?[Pp][Mm]", replacement = "16:\\1", 
          gsub(pattern = "^0?3:(\\d{2}) ?[Pp][Mm]", replacement = "15:\\1", 
          gsub(pattern = "^0?2:(\\d{2}) ?[Pp][Mm]", replacement = "14:\\1", 
          gsub(pattern = "^0?1:(\\d{2}) ?[Pp][Mm]", replacement = "13:\\1", 
          gsub(pattern = " ?[Aa][Mm]", replacement = "", times))))))))))))))
}

format_day_periods <- function(periods) {
  return (if_else(periods == "D", "day", 
          if_else(periods == "N", "night", 
          if_else(periods == "M", "morning", 
          if_else(periods == "E", "evening", 
          "")))))
}

remove_parentheticals <- function(strings) {
  return (grem(pattern = " ?\\([^\\)]*\\)", strings))
}

fix_parentheses <- function(strings) {
  return (gsub(pattern = "(\\w)\\(", replacement = "\\1 \\(", strings))
}

remove_quotes <- function(strings) {
  return (grem(pattern = "\"", strings))
}

remove_nonASCII_chars <- function(strings) {
  return (grem(pattern = "[^ -~]+", strings))
}

remove_extra_whitespace <- function(strings) {
  return (gsub(pattern = "\\s{2,}", replacement = " ", strings))
}

remove_bad_formatting <- trimws %.% remove_extra_whitespace %.% remove_quotes %.% remove_nonASCII_chars

month_num_to_name <- function(month_strings) {
  month_ints <- as.integer(month_strings)
  results <- rep("", length(month_strings))
  month_names <- names(months)
  for (month_name in month_names) {
    results[month_ints == months[[month_name]]] <- month_name
  }
  return (results)
}


### Ordering Function -------------------------------------------------------

ordered_empty_at_end <- function(column, empty_string) {
  ordered_levels <- sort(levels(column))
  if ("" %c% ordered_levels) {
    ordered_levels <- c(ordered_levels %[!=]% "", empty_string)
    return (ordered(replace_level(column, from = "", to = empty_string), levels = ordered_levels))
  } else if (empty_string %c% ordered_levels) {
    ordered_levels <- c(ordered_levels %[!=]% empty_string, empty_string)
    return (ordered(column, levels = ordered_levels))
  } else {
    return (ordered(column, levels = ordered_levels))
  }
}

refactor_and_order <- function(column, empty_string, drop_to = "") {
  if (drop_to %c% missing_levels(column)) {
    return (ordered_empty_at_end(column = droplevels(column), empty_string = empty_string))
  } else {
    return (ordered_empty_at_end(column = drop_missing_levels(column, to = drop_to), empty_string = empty_string))
  }
}
