# @author Scott Dobbins
# @version 0.9.7.2
# @date 2017-07-29 20:00


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

upper_case_abbreviations <- c("AAA", "HQ", "RR")
upper_case_abbreviations_lower <- tolower(upper_case_abbreviations)
upper_case_set <- unique(c(directions, countries, services, roman_numerals, upper_case_abbreviations))
upper_case_set_lower <- tolower(upper_case_set)

WW1_aircraft_letters <- c()
WW2_aircraft_letters <- c("SBD", "TBF")
Korea_aircraft_letters <- c()
Vietnam_aircraft_letters <- c()
aircraft_letters <- unique(c(WW1_aircraft_letters, WW2_aircraft_letters, Korea_aircraft_letters, Vietnam_aircraft_letters, roman_numerals))

stop_words <- c("and", "at", "aux", "di", "el", "in", "la", "le", "no", "not", "of", "on", "or", "the", "to", "sur")
measurement_units <- c("km", "m", "cm", "mm", "mi", "in", "ft", "kg")
ordinal_markers <- c("st", "nd", "rd", "th")

lower_case_set <- c(stop_words, measurement_units, ordinal_markers)
lower_case_set_upper <- toupper(lower_case_set)

unusual_plural_set <- c("anti-aircraft", "aircraft", "ammunition", "ammo", "personnel")
vowel_set <- c('a', 'e', 'i', 'o', 'u')


### Capitalize Functions ----------------------------------------------------

capitalize <- function(words) {
  return (paste0(toupper(substring(words, 1, 1)), substring(words, 2)))
}

capitalize_phrase <- function(line) {
  return (paste(capitalize(strsplit(line, split = ' ')[[1]]), collapse = ' '))
}

capitalize_phrase_vectorized <- function(lines) {
  lines_mod <- ifelse(lines == "", '`', tolower(lines))
  num_lines <- length(lines)
  
  split_result <- strsplit(lines, split = ' ')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = ' ')
  
  return (ifelse(lines == "", "", lines_reduced))
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
  return (ifelse(words %in% upper_case_set_lower, 
                 toupper(words), 
          ifelse(words %in% lower_case_set, 
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
  return (ifelse(words %in% upper_case_set, 
                 words, 
          ifelse(words %in% lower_case_set_upper, 
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
  return (ifelse(words %in% aircraft_letters | 
                   (regexpr(pattern = "-|\\d", words) > 0L & regexpr(pattern = "[A-Za-z]{6,}", words) == -1L), 
                 words, 
                 capitalize_from_caps(words)))
}

proper_noun_phrase <- function(line) {
  line <- tolower(line)
  line <- paste(proper_noun_vectorized(strsplit(line, split = ' ')[[1]]),   collapse = ' ')
  line <- paste(proper_noun_vectorized(strsplit(line, split = '-')[[1]]),   collapse = '-')
  line <- paste(proper_noun_vectorized(strsplit(line, split = '/')[[1]]),   collapse = '/')
  line <- paste(proper_noun_vectorized(strsplit(line, split = '\\(')[[1]]), collapse = '(')
  return (line)
}

proper_noun_phrase_vectorized <- function(lines) {
  lines_mod <- ifelse(lines == "", '`', tolower(lines))
  num_lines <- length(lines)
  
  split_result <- strsplit(lines_mod, split = ' ')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = ' ')
  
  num_lines_reduced <- length(lines_reduced)
  
  split_result <- strsplit(lines_reduced, split = '-')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = '-')
  
  split_result <- strsplit(lines_reduced, split = '/')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = '/')
  
  split_result <- strsplit(lines_reduced, split = '\\(')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_vectorized(unlist(split_result)), rep(1:num_lines_reduced, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = '(')

  return (ifelse(lines == "", "", lines_reduced))
}

proper_noun_phrase_aircraft <- function(line) {
  return (paste(proper_noun_aircraft_vectorized(strsplit(line, split = ' ')[[1]]), collapse = ' '))
}

proper_noun_phrase_aircraft_vectorized <- function(lines) {
  lines_mod <- ifelse(lines == "", '`', lines)
  num_lines <- length(lines)
  
  split_result <- strsplit(lines_mod, split = ' ')
  split_lengths <- lengths(split_result)
  split_result <- split(proper_noun_aircraft_vectorized(unlist(split_result)), rep(1:num_lines, split_lengths))
  lines_reduced <- map_chr(split_result, paste0, collapse = ' ')
  
  return (ifelse(lines == "", "", lines_reduced))
}


### Other Functions ---------------------------------------------------------

remove_quotes <- function(strings) {
  return (gsub(pattern = "\"", replacement = '', strings))
}

remove_nonASCII_chars <- function(strings) {
  return (gsub(pattern = "[^ -~]+", replacement = '', strings))
}


### Tooltip Helper Functions ------------------------------------------------

date_string <- function(month_names, day_strings, year_strings) {
  return (paste0("On ", month_names, " ", day_strings, ", ", year_strings, ","))
}

date_period_time_string <- function(date_strings, period_strings, time_strings) {
  return (ifelse(time_strings == "", 
                 ifelse(period_strings == "", 
                        date_strings, 
                        paste0(date_strings, " during the ", period_strings, ",")), 
                 paste0(date_strings, " at ", time_strings, " hours,")))
}

bomb_weight_string <- function(weight) {
  if (is.na(weight)) {
    return ("some bombs on")
  } else {
    return (paste0(add_commas(weight), " pounds of bombs on"))
  }
}

bomb_weight_string_vectorized <- function(weights) {
  return (ifelse(is.na(weights), 
                 "some bombs on", 
                 paste0(add_commas_vectorized(weights), " pounds of bombs on")))
}

aircraft_numtype_string <- function(num, type) {
  if (is.na(num)) {
    if (type == "") {
      return ("some aircraft")
    } else {
      return (paste0("some ", type, "s"))
    }
  } else if (num == 1) {
    if (type == "") {
      return ("1 aircraft")
    } else {
      return (paste0("1 ", type))
    }
  } else {
    if (type == "") {
      return (paste0(as.character(num), " aircraft"))
    } else {
      return (paste0(as.character(num), " ", type, "s"))
    }
  }
}

aircraft_numtype_string_vectorized <- function(nums, types) {
  return (ifelse(is.na(nums), 
                 ifelse(types == "", 
                        "some aircraft", 
                        paste0("some ", types, "s")), 
                 ifelse(nums == 1, 
                        ifelse(types == "", 
                               "1 aircraft", 
                               paste0("1 ", types)), 
                        ifelse(types == "", 
                               paste0(as.character(nums), " aircraft"), 
                               paste0(as.character(nums), " ", types, "s")))))
}

aircraft_string <- function(numtype, division) {
  if (division == "") {
    return (paste0(numtype, " dropped"))
  } else {
    return (paste0(numtype, " of the ", division, " division dropped"))
  }
}

aircraft_string_vectorized <- function(numtypes, divisions) {
  return (ifelse(divisions == "", 
                 paste0(numtypes, " dropped"), 
                 paste0(numtypes, " of the ", divisions, " division dropped")))
}

target_type_string <- function(type) {
  if (type == "") {
    return ("a target")
  } else {
    return (fix_articles(type))
  }
}

target_type_string_vectorized <- function(types) {
  return (ifelse(types == "", 
                 "a target", 
                 fix_articles_vectorized(types)))
}

target_area_string <- function(area) {
  if (area == "") {
    return ("in this area")
  } else {
    return (paste0("in ", area))
  }
}

target_area_string_vectorized <- function(areas) {
  return (ifelse(areas == "", 
                 "in this area", 
                 paste0("in ", areas)))
}

target_location_string <- function(city, country) {
  if (city == "") {
    if (country == "") {
      return ("in this area")
    } else {
      return (paste0("in this area of ", country))
    }
  } else {
    if (country == "") {
      return (paste0("in ", city))
    } else {
      return (paste0("in ", city, ", ", country))
    }
  }
}

target_location_string_vectorized <- function(cities, countries) {
  return (ifelse(cities == "", 
                 ifelse(countries == "", 
                        "in this area", 
                        paste0("in this area of ", countries)), 
                 ifelse(countries == "", 
                        paste0("in ", cities), 
                        paste0("in ", cities, ", ", countries))))
}


### Fix Articles ------------------------------------------------------------

fix_articles <- function(string) {
  l <- nchar(string)
  if (substr(string, l, l) == 's' | substr(string, 1, 2) == 'a ' | string %in% unusual_plural_set) {
    return (string)
  } else if (substr(string, 1, 1) %in% vowel_set) {
    return (paste("an", string))
  } else {
    return (paste("a", string))
  }
}

fix_articles_vectorized <- function(strings) {
  lengths <- nchar(strings)
  return (ifelse(substr(strings, lengths, lengths) == 's' | substr(strings, 1, 2) == 'a ' | strings %in% unusual_plural_set, 
                 strings, 
                 ifelse(substr(strings, 1, 1) %in% vowel_set, 
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

# note: this assumes non-negative integers as inputs
add_commas_vectorized <- function(numbers) {
  numbers_strings <- as.character(numbers)
  nums_digits <- ifelse(numbers < 10, 1, ceiling(log10(numbers)))
  max_digits <- max(nums_digits, na.rm = TRUE)
  num_rounds <- ceiling(max_digits / 3) - 1
  
  head_lengths <- 3 - (-nums_digits %% 3)
  tail_positions <- head_lengths + 1
  results <- substr(numbers_strings, 1, head_lengths)
  
  for (round in 1:num_rounds) {
    needs_more <- nums_digits > (3*round)
    results <- ifelse(needs_more, paste0(results, ',', substr(numbers_strings, tail_positions+(3*(round-1)), tail_positions+(3*round))), results)
  }
  return (results)
}


### Regexps -----------------------------------------------------------------

format_aircraft_types <- function(types) {
  return (gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)(.*)", replacement = "\\1-\\2", types))
}

format_military_times <- function(digits) {
  return (gsub(pattern = "^(\\d)$", replacement = "\\1:00", 
          gsub(pattern = "^(\\d)(\\d)$", replacement = "\\1:\\20", 
          gsub(pattern = "^(1[0-9]|2[0-3])$", replacement = "\\1:00", 
          gsub(pattern = "^(\\d)([03])$", replacement = "\\1:\\20", 
          gsub(pattern = "^(\\d{1,2})(\\d{2})$", replacement = "\\1:\\2", 
          gsub(pattern = "^(\\d{1,2}):(\\d{2}):(\\d{2})$", replacement = "\\1:\\2", digits)))))))
}

remove_parentheticals <- function(phrases) {
  return (gsub(pattern = " ?\\([^\\)]*\\)", replacement = '', phrases))
}


### Targets -----------------------------------------------------------------

cleanup_targets <- function(targets) {
  targets <- gsub(pattern = " +-? *", replacement = "", targets)
  targets <- gsub(pattern = "\\b(A C)\\b", replacement = "AC", 
             gsub(pattern = "\\b(ADM(IN[A-Z]*)?)\\b", replacement = "ADMINISTRATIVE", 
             gsub(pattern = "\\b(AC|A C)\\b", replacement = "AIRCRAFT", 
             gsub(pattern = "\\b(AERO?DROM[A-Z]*|AIRODROM[A-Z]*|AIRDROM[A-Z]*|AIDROM[A-Z]*|AIR DROM[A-Z]*)\\b", replacement = "AIRDROME", 
             gsub(pattern = "\\b(AIR FIELDS?|AIRFIEL|AIRFIELDS)\\b", replacement = "AIRFIELD", 
             gsub(pattern = "\\b(AIR FRAMES?)\\b", replacement = "AIRFRAME", 
             gsub(pattern = "\\b(AMMO|AMMUN[A-Z]*)\\b", replacement = "AMMUNITION", 
             gsub(pattern = "\\b(AA|ANTIAIRCRAFT|ANTI AIRCRAFT|ANTI AIR CRAFT)\\b", replacement = "ANTI-AIRCRAFT", 
             gsub(pattern = "\\b(ARES?|ABEAS?|APEAS?|AREAS)\\b", replacement = "AREA", 
             gsub(pattern = "\\b(ARSENALS)\\b", replacement = "ARSENAL", 
             gsub(pattern = "\\b(ARTILLER)\\b", replacement = "ARTILLERY", 
             gsub(pattern = "\\b(ASSBLY)\\b", replacement = "ASSEMBLY", 
             gsub(pattern = "\\b(BRAGES?|BARGES)\\b", replacement = "BARGE", 
             gsub(pattern = "\\b(BK?S|BARRAC.*)\\b", replacement = "BARRACKS", 
             gsub(pattern = "\\b(BASFS?|BASES)\\b", replacement = "BASE", 
             gsub(pattern = "\\b(BTY|BRTY|BTRY)\\b", replacement = "BATTERY", 
             gsub(pattern = "\\b(BEARING)\\b", replacement = "BEARINGS", 
             gsbu(pattern = "\\b(BLST)\\b", replacement = "BLAST", 
             gsub(pattern = "\\b(BOATS)\\b", replacement = "BOAT", 
             gsub(pattern = "\\b(BR|BR?DGE?S?|BRID ES?|8RIDGES?|GRIDGES?|BOIDGES?|BIRDGES?|BRIDGES)\\b", replacement = "BRIDGE", 
             gsub(pattern = "\\b(BLDGS?|BUILD|BUILOING|BUILDINGS)\\b", replacement = "BUILDING", 
             gsub(pattern = "\\b(BUSIHESS)\\b", replacement = "BUSINESS", 
             gsub(pattern = "\\b(CAMPS)\\b", replacement = "CAMP", 
             gsub(pattern = "\\b(CANAI|CANALS)\\b", replacement = "CANAL", 
             gsub(pattern = "\\b(CENTRE|CENTERS)\\b", replacement = "CENTER", 
             gsub(pattern = "\\b(CHEM)\\b", replacement = "CHEMICAL", 
             gsub(pattern = "\\b(CIIY)\\b", replacement = "CITY", 
             gsub(pattern = "\\b(COAST|COASTAL[A-Z]*)\\b", replacement = "COASTAL", 
             gsub(pattern = "\\b(COM)\\b", replacement = "COMMERCIAL", 
             gsub(pattern = "\\b(COMM)\\b", replacement = "COMMAND", 
             gsub(pattern = "\\b(COMMUNICATION)\\b", replacement = "COMMUNICATIONS", 
             gsub(pattern = "\\b(COMPONENT)\\b", replacement = "COMPONENTS", 
             gsub(pattern = "\\b(CONPOUNDS?|CPMPOUNDS?|COMPOU[A-Z]*)\\b", replacement = "COMPOUND", 
             gsub(pattern = "\\b(CONCT?S?|CONCENT[A-Z]*|CONSTRATIONS?|CONTRATIONS?|CQNCENTRATIONS?)\\b", replacement = "CONCENTRATION", 
             gsub(pattern = "\\b(CONST)\\b", replacement = "CONSTRUCTION", targets)))))))))))))))))))))))))))))))))))
  targets <- gsub(pattern = "\\b(DEFENCE?S|DEFENSE)\\b", replacement = "DEFENSES", 
             gsub(pattern = "\\b(DEF)\\b", replacement = "DEFENSIVE", 
             gsub(pattern = "\\b(DDCKS?|DOCKS)\\b", replacement = "DOCK", 
             gsub(pattern = "\\b(DIMPS?|DOOPS?|DUMPS)\\b", replacement = "DUMP", 
             gsub(pattern = "\\b(ELCT|ELECT?)\\b", replacement = "ELECTRIC", 
             gsub(pattern = "\\b(EMP|EMPL|EMPLACEMENTO|EMPLACEMENTS|IMPLACEMENTS?)\\b", replacement = "EMPLACEMENT", 
             gsub(pattern = "\\b(EN|ENEMIES)\\b", replacement = "ENEMY", 
             gsub(pattern = "\\b(ENG)\\b", replacement = "ENGINE", 
             gsub(pattern = "\\b(EQUIPT?)\\b", replacement = "EQUIPMENT", 
             gsub(pattern = "\\b(EXPLOSIVES)\\b", replacement = "EXPLOSIVE", 
             gsub(pattern = "\\b(FACILIT[A-Z]*)\\b", replacement = "FACILITY", 
             gsub(pattern = "\\b(FAC?T?|FCTY|FACTO|FACTOR[A-Z]+)\\b", replacement = "FACTORY", 
             gsub(pattern = "\\b(FERRIES)\\b", replacement = "FERRY", 
             gsub(pattern = "\\b(GAS)\\b", replacement = "GASOLINE", 
             gsub(pattern = "\\b(GOVT|GOVERMENT)\\b", replacement = "GOVERNMENT", 
             gsub(pattern = "\\b(GUM)\\b", replacement = "GUN", 
             gsub(pattern = "\\b(HARBDR|HARBOURS?|HARBORS)\\b", replacement = "HARBOR", 
             gsub(pattern = "\\b(HDOS?|HDQR?S?|HQ ?S?|HEADQUARTER)\\b", replacement = "HEADQUARTERS", 
             gsub(pattern = "\\b(HVY)\\b", replacement = "HEAVY", 
             gsub(pattern = "\\b(HWY?S?|HTGHWAYS?|HIWAYS?|HIGHWAYS)\\b", replacement = "HIGHWAY", 
             gsub(pattern = "\\b(HILLSIDE|HILLS)\\b", replacement = "HILL", 
             gsub(pattern = "\\b(HOUSES)\\b", replacement = "HOUSE", 
             gsub(pattern = "\\b(HUYS?|HUTS)\\b", replacement = "HUT", 
             gsub(pattern = "\\b(HYDRIELECTRIC|HYDRO ELECTRIC)\\b", replacement = "HYDROELECTRIC", 
             gsub(pattern = "\\b(INST[A-Z]*)\\b", replacement = "INSTALLATION", 
             gsub(pattern = "\\b(JAPS?|JAPANSE)\\b", replacement = "JAPANESE", 
             gsub(pattern = "\\b(JETTIES)\\b", replacement = "JETTY", 
             gsub(pattern = "\\b(JTNS?|JCTS?|JUNC|JUNCT[A-Z]*)\\b", replacement = "JUNCTION", 
             gsub(pattern = "\\b(LGT)\\b", replacement = "LIGHT", 
             gsub(pattern = "\\b(LOCS?)\\b", replacement = "LOCATION", 
             gsub(pattern = "\\b(LOCOS?|LOCOMOTIVES)\\b", replacement = "LOCOMOTIVE", 
             gsub(pattern = "\\b(MGMT)\\b", replacement = "MANAGEMENT", 
             gsub(pattern = "\\b(MFG)\\b", replacement = "MANUFACTURING", 
             gsub(pattern = "\\b(MKT)\\b", replacement = "MARKET", 
             gsub(pattern = "\\b(MARSHALLIN ?G)\\b", replacement = "MARSHALL", 
             gsub(pattern = "\\b(M[/ ]Y(ARD)?)\\b", replacement = "MARSHALLING YARD", 
             gsub(pattern = "\\b(MISCEL[A-Z]*)\\b", replacement = "MISCELLANEOUS", 
             gsub(pattern = "\\b(MONASTARY)\\b", replacement = "MONASTERY", 
             gsub(pattern = "\\b(MUNITION)\\b", replacement = "MUNITIONS", targets)))))))))))))))))))))))))))))))))))))))
  targets <- gsub(pattern = "\\b(PERONN?EL|PERSONN[A-Z]*)\\b", replacement = "PERSONNEL", 
             gsub(pattern = "\\b(PILL BOX[A-Z]*)\\b", replacement = "PILLBOXES", 
             gsub(pattern = "\\b(PL)\\b", replacement = "PLACE", 
             gsub(pattern = "\\b(PLTS?|PLANTS)\\b", replacement = "PLANT", 
             gsub(pattern = "\\b(PT|POINTS)\\b", replacement = "POINT", 
             gsub(pattern = "\\b(POS|P0SI[A-Z]*|PDSI[A-Z]*|POSI[A-Z]*|POSTIONS?)\\b", replacement = "POSITION", 
             gsub(pattern = "\\b(POWER)([A-Z]+)\\b", replacement = "\\1 \\2", 
             gsub(pattern = "\\b(R ?R|HAILROAD|RAIL ROAD|RAILROADS)\\b", replacement = "RAILROAD", 
             gsub(pattern = "\\b(RLWY|RAILWAYS)\\b", replacement = "RAILWAY", 
             gsub(pattern = "\\b(RATION)\\b", replacement = "RATIONS", 
             gsub(pattern = "\\b(REF)\\b", replacement = "REFINERY", 
             gsub(pattern = "\\b(RIV[A-Z]* CR[A-Z]*|RIV[A-Z]* CROSS NG)\\b", replacement = "RIVER CROSSING", 
             gsub(pattern = "\\b(RD)\\b", replacement = "ROAD", 
             gsub(pattern = "\\b(RWY|RWAY|RUNWAYS)\\b", replacement = "RUNWAY", 
             gsub(pattern = "\\b(SEAPIANES?|SEA PLANES?|SEAPLANE)\\b", replacement = "SEAPLANES", 
             gsub(pattern = "\\b(SHIPP[A-Z]*)\\b", replacement = "SHIPPING", 
             gsub(pattern = "\\b(SHIPVARDS?|SHIP YARDS?)\\b", replacement = "SHIPYARD", 
             gsub(pattern = "\\b(SIDINQS?|SIDINGS)\\b", replacement = "SIDING", 
             gsub(pattern = "\\b(STAS?|STNS?|STATIONS)\\b", replacement = "STATION", 
             gsub(pattern = "\\b(STOR|STGE)\\b", replacement = "STORAGE", 
             gsub(pattern = "\\b(BUPPLIES)\\b", replacement = "SUPPLIES", 
             gsub(pattern = "\\b(SUPPOER)\\b", replacement = "SUPPORT", 
             gsub(pattern = "\\b(SYN)\\b", replacement = "SYNTHETIC", 
             gsub(pattern = "\\b(TA?CT)\\b", replacement = "TACTICAL", 
             gsub(pattern = "\\b(TGTS?|TARGETS)\\b", replacement = "TARGET", 
             gsub(pattern = "\\b(TOWENS)\\b", replacement = "TOWER", 
             gsub(pattern = "\\b(TDWNS?|TOWMS?|TOWNS)\\b", replacement = "TOWN", 
             gsub(pattern = "\\b(TRANSPORT|TRASNPORT|TRANPORTATION)\\b", replacement = "TRANSPORTATION", 
             gsub(pattern = "\\b(IROOPS?|TOOOO|TROOP)\\b", replacement = "TROOPS", 
             gsub(pattern = "\\b(TRUCK)\\b", replacement = "TRUCKS", 
             gsub(pattern = "\\b(TUNNELS)\\b", replacement = "TUNNEL", 
             gsub(pattern = "\\b(URSAN)\\b", replacement = "URBAN", 
             gsub(pattern = "\\b(VEHICLES)\\b", replacement = "VEHICLE", 
             gsub(pattern = "\\b(VESSELS)\\b", replacement = "VESSEL", 
             gsub(pattern = "\\b(VILIAGES?|VILLAGES)\\b", replacement = "VILLAGE", 
             gsub(pattern = "\\b(WARE[A-Z]? HOUSES?|WAREHOUSES)\\b", replacement = "WAREHOUSE", 
             gsub(pattern = "\\b(WATER FRONT)\\b", replacement = "WATERFRONT", 
             gsub(pattern = "\\b(WHARVES|WHARFS)\\b", replacement = "WHARF", 
             gsub(pattern = "\\b(WKS?)\\b", replacement = "WORKS", 
             gsub(pattern = "\\b(YDS?|YARUS?|YARDS)\\b", replacement = "YARD", targets))))))))))))))))))))))))))))))))))))))))
  return (targets)
}


### Month Number to Name ----------------------------------------------------

month_num_to_name <- function(months) {
  return (ifelse(is.na(months), 
                 "", 
          ifelse(months == "1", 
                 "January", 
          ifelse(months == "2", 
                 "February", 
          ifelse(months == "3", 
                 "March", 
          ifelse(months == "4", 
                 "April", 
          ifelse(months == "5", 
                 "May", 
          ifelse(months == "6", 
                 "June", 
          ifelse(months == "7", 
                 "July", 
          ifelse(months == "8", 
                 "August", 
          ifelse(months == "9", 
                 "September", 
          ifelse(months == "10", 
                 "October", 
          ifelse(months == "11", 
                 "November", 
          ifelse(months == "12", 
                 "December", 
          ""))))))))))))))
}

month_num_padded_to_name <- function(months) {
  return (ifelse(is.na(months), 
                 "", 
          ifelse(months == "01", 
                 "January", 
          ifelse(months == "02", 
                 "February", 
          ifelse(months == "03", 
                 "March", 
          ifelse(months == "04", 
                 "April", 
          ifelse(months == "05", 
                 "May", 
          ifelse(months == "06", 
                 "June", 
          ifelse(months == "07", 
                 "July", 
          ifelse(months == "08", 
                 "August", 
          ifelse(months == "09", 
                 "September", 
          ifelse(months == "10", 
                 "October", 
          ifelse(months == "11", 
                 "November", 
          ifelse(months == "12", 
                 "December", 
          ""))))))))))))))
}


### Ordering Function -------------------------------------------------------

ordered_empty_at_end <- function(column, empty_string) {
  ordered_levels <- sort(levels(column))
  if ("" %in% ordered_levels) {
    ordered_levels <- c(ordered_levels[ordered_levels != ""], empty_string)
    return (ordered(fct_other(column, drop = c(""), other_level = empty_string), levels = ordered_levels))
  } else {
    return (ordered(column, levels = ordered_levels))
  }
}
