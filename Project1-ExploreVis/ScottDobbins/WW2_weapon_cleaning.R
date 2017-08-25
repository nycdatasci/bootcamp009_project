# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Complete pounds ---------------------------------------------------------

WW2_bombs[is.na(Weapon_Weight_Pounds) & !is.na(Weapon_Weight_Tons), 
          `:=`(Weapon_Weight_Pounds = round_to_int(Weapon_Weight_Tons * 2000))]


### Complete tonnage 1 ------------------------------------------------------

# complete tonnage when undefined across all groups but only one group has a weapon listed

WW2_bombs[Weapon_Expl_Type != "" & 
            Weapon_Incd_Type == "" & 
            Weapon_Frag_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Frag_Tons), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Weight_Tons * 2000), 
               Weapon_Expl_Tons = Weapon_Weight_Tons)]
WW2_bombs[Weapon_Incd_Type != "" & 
            Weapon_Expl_Type == "" & 
            Weapon_Frag_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Frag_Tons), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Weight_Tons * 2000), 
               Weapon_Incd_Tons = Weapon_Weight_Tons)]
WW2_bombs[Weapon_Frag_Type != "" & 
            Weapon_Expl_Type == "" & 
            Weapon_Incd_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Weight_Tons * 2000), 
               Weapon_Frag_Tons = Weapon_Weight_Tons)]


### Weapon_Expl cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[!near(Weapon_Expl_Pounds, Weapon_Expl_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[!near(Weapon_Expl_Pounds, Weapon_Expl_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[!near(Weapon_Expl_Pounds, Weapon_Expl_Tons * 2000, tol = near_tolerance) & 
            !is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Num * Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[!near(Weapon_Expl_Pounds, Weapon_Expl_Tons * 2000, tol = near_tolerance) , 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]

# if only pounds is defined, update tons
WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Num * Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type if undefined) and tons
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Unit_Weight = round_to_int(Weapon_Expl_Pounds / Weapon_Expl_Num), 
               Weapon_Expl_Type = if_else(Weapon_Expl_Type == "", paste0(as.character(round(Weapon_Expl_Pounds / Weapon_Expl_Num)), " LB HE"), as.character(Weapon_Expl_Type)), 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = round_to_int(Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            is_NA_or_0(Weapon_Expl_Tons) & 
            !near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Num * Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons) & 
            !near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Expl_Num = round_to_int(Weapon_Expl_Tons * 2000 / Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]

# if num and tons are defined, update unit weight (and type if undefined) and pounds
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Unit_Weight = round_to_int(Weapon_Expl_Tons * 2000 / Weapon_Expl_Num), 
               Weapon_Expl_Type = if_else(Weapon_Expl_Type == "", paste0(as.character(round(Weapon_Expl_Tons * 2000 / Weapon_Expl_Num)), " LB HE"), as.character(Weapon_Expl_Type)), 
               Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = round_to_int(Weapon_Expl_Tons * 2000 / Weapon_Expl_Unit_Weight), 
               Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]

# if only tons is defined, update pounds
WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Pounds = round_to_int(Weapon_Expl_Tons * 2000))]

# if num doesn't match, then update it
WW2_bombs[!near(Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight, Weapon_Expl_Num, tol = near_tolerance), 
          `:=`(Weapon_Expl_Num = round_to_int(Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight))]


### Weapon_Incd cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[!near(Weapon_Incd_Pounds, Weapon_Incd_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[!near(Weapon_Incd_Pounds, Weapon_Incd_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[!near(Weapon_Incd_Pounds, Weapon_Incd_Tons * 2000, tol = near_tolerance) & 
            !is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Num * Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[!near(Weapon_Incd_Pounds, Weapon_Incd_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]

# if only pounds is defined, update tons
WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Num * Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type if undefined) and tons
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Unit_Weight = round_to_int(Weapon_Incd_Pounds / Weapon_Incd_Num), 
               Weapon_Incd_Type = if_else(Weapon_Incd_Type == "", paste0(as.character(round(Weapon_Incd_Pounds / Weapon_Incd_Num)), " LB INCENDIARY"), as.character(Weapon_Incd_Type)), 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Num = round_to_int(Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            is_NA_or_0(Weapon_Incd_Tons) & 
            !near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Num * Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons) & 
            !near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Incd_Num = round_to_int(Weapon_Incd_Tons * 2000 / Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]

# if num and tons are defined, update unit weight (and type if undefined) and pounds
WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Unit_Weight = round_to_int(Weapon_Incd_Tons * 2000 / Weapon_Incd_Num), 
               Weapon_Incd_Type = if_else(Weapon_Incd_Type == "", paste0(as.character(round(Weapon_Incd_Tons * 2000 / Weapon_Incd_Num)), " LB INCENDIARY"), as.character(Weapon_Incd_Type)), 
               Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Num = round_to_int(Weapon_Incd_Tons * 2000 / Weapon_Incd_Unit_Weight), 
               Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]

# if only tons is defined, update pounds
WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Tons * 2000))]

# if num doesn't match, then update it
WW2_bombs[!near(Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight, Weapon_Incd_Num, tol = near_tolerance), 
          `:=`(Weapon_Incd_Num = round_to_int(Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight))]


### Weapon_Frag cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[!near(Weapon_Frag_Pounds, Weapon_Frag_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[!near(Weapon_Frag_Pounds, Weapon_Frag_Tons * 2000, tol = near_tolerance) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[!near(Weapon_Frag_Pounds, Weapon_Frag_Tons * 2000, tol = near_tolerance) & 
            !is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Num * Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[!near(Weapon_Frag_Pounds, Weapon_Frag_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]

# if only pounds is defined, update tons
WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Num * Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type if undefined) and tons
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Unit_Weight = round_to_int(Weapon_Frag_Pounds / Weapon_Frag_Num), 
               Weapon_Frag_Type = if_else(Weapon_Frag_Type == "", paste0(as.character(round(Weapon_Frag_Pounds / Weapon_Frag_Num)), " LB FRAG"), as.character(Weapon_Frag_Type)), 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Num = round_to_int(Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            is_NA_or_0(Weapon_Frag_Tons) & 
            !near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds, tol = near_tolerance), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Num * Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons) & 
            !near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000, tol = near_tolerance), 
          `:=`(Weapon_Frag_Num = round_to_int(Weapon_Frag_Tons * 2000 / Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]

# if num and tons are defined, update unit weight (and type if undefined) and pounds
WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Unit_Weight = round_to_int(Weapon_Frag_Tons * 2000 / Weapon_Frag_Num), 
               Weapon_Frag_Type = if_else(Weapon_Frag_Type == "", paste0(as.character(round(Weapon_Frag_Tons * 2000 / Weapon_Frag_Num)), " LB FRAG"), as.character(Weapon_Frag_Type)), 
               Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Num = round_to_int(Weapon_Frag_Tons * 2000 / Weapon_Frag_Unit_Weight), 
               Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]

# if only tons is defined, update pounds
WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Pounds = round_to_int(Weapon_Frag_Tons * 2000))]

# if num doesn't match, then update it
WW2_bombs[!near(Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight, Weapon_Frag_Num, tol = near_tolerance), 
          `:=`(Weapon_Frag_Num = round_to_int(Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight))]


### Complete tonnage 2 ------------------------------------------------------

WW2_bombs[is_NA_or_0(Weapon_Weight_Tons) & 
            !is_NA_or_0L(Weapon_Weight_Pounds), 
          `:=`(Weapon_Weight_Tons = Weapon_Weight_Pounds / 2000)]

WW2_bombs[if_else(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
            if_else(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
            if_else(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons) > Weapon_Weight_Tons, 
          `:=`(Weapon_Weight_Tons = if_else(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
                 if_else(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
                 if_else(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons))]

# update missing ton values if others are known
WW2_bombs[is.na(Weapon_Expl_Tons) & 
            (Weapon_Incd_Tons + Weapon_Frag_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Expl_Tons = Weapon_Weight_Tons - Weapon_Incd_Tons - Weapon_Frag_Tons, 
               Weapon_Expl_Pounds = round_to_int((Weapon_Weight_Tons - Weapon_Incd_Tons - Weapon_Frag_Tons) * 2000))]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            (Weapon_Expl_Tons + Weapon_Frag_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Incd_Tons = Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Frag_Tons, 
               Weapon_Incd_Pounds = round_to_int((Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Frag_Tons) * 2000))]
WW2_bombs[is.na(Weapon_Frag_Tons) & 
            (Weapon_Expl_Tons + Weapon_Incd_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Frag_Tons = Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Incd_Tons, 
               Weapon_Frag_Pounds = round_to_int((Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Incd_Tons) * 2000))]

# update further data since tons and pounds may now be known
WW2_bombs[!is_NA_or_0L(Weapon_Expl_Num) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Unit_Weight = round_to_int(Weapon_Expl_Pounds / Weapon_Expl_Num), 
               Weapon_Expl_Type = paste0(as.character(round(Weapon_Expl_Pounds / Weapon_Expl_Num)), " LB HE"))]
WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Expl_Pounds) & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = round_to_int(Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight))]

WW2_bombs[!is_NA_or_0L(Weapon_Incd_Num) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Unit_Weight = round_to_int(Weapon_Incd_Pounds / Weapon_Incd_Num), 
               Weapon_Incd_Type = paste0(as.character(round(Weapon_Incd_Pounds / Weapon_Incd_Num)), " LB HE"))]
WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Incd_Pounds) & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Num = round_to_int(Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight))]

WW2_bombs[!is_NA_or_0L(Weapon_Frag_Num) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Unit_Weight = round_to_int(Weapon_Frag_Pounds / Weapon_Frag_Num), 
               Weapon_Frag_Type = paste0(as.character(round(Weapon_Frag_Pounds / Weapon_Frag_Num)), " LB HE"))]
WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            !is_NA_or_0L(Weapon_Frag_Pounds) & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Num = round_to_int(Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight))]


### Setting zeros -----------------------------------------------------------

WW2_bombs[is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Incd_Tons + Weapon_Frag_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Expl_Num) & 
            Weapon_Expl_Type == "", 
          `:=`(Weapon_Expl_Num = 0L, 
               Weapon_Expl_Pounds = 0L, 
               Weapon_Expl_Tons = 0)]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons + Weapon_Frag_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Incd_Num) & 
            Weapon_Incd_Type == "", 
          `:=`(Weapon_Incd_Num = 0L, 
               Weapon_Incd_Pounds = 0L, 
               Weapon_Incd_Tons = 0)]
WW2_bombs[is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons + Weapon_Incd_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Frag_Num) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Frag_Num = 0L, 
               Weapon_Frag_Pounds = 0L, 
               Weapon_Frag_Tons = 0)]

WW2_bombs[is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Frag_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Expl_Num) & 
            Weapon_Expl_Type == "" & 
            is_NA_or_0L(Weapon_Incd_Num) & 
            Weapon_Incd_Type == "", 
          `:=`(Weapon_Expl_Num = 0L, 
               Weapon_Expl_Pounds = 0L, 
               Weapon_Expl_Tons = 0, 
               Weapon_Incd_Num = 0L, 
               Weapon_Incd_Pounds = 0L, 
               Weapon_Incd_Tons = 0)]
WW2_bombs[is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Incd_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Expl_Num) & 
            Weapon_Expl_Type == "" & 
            is_NA_or_0L(Weapon_Frag_Num) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Expl_Num = 0L, 
               Weapon_Expl_Pounds = 0L, 
               Weapon_Expl_Tons = 0, 
               Weapon_Frag_Num = 0L, 
               Weapon_Frag_Pounds = 0L, 
               Weapon_Frag_Tons = 0)]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons, Weapon_Weight_Tons, tol = near_tolerance) & 
            is_NA_or_0L(Weapon_Incd_Num) & 
            Weapon_Incd_Type == "" & 
            is_NA_or_0L(Weapon_Frag_Num) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Incd_Num = 0L, 
               Weapon_Incd_Pounds = 0L, 
               Weapon_Incd_Tons = 0, 
               Weapon_Frag_Num = 0L, 
               Weapon_Frag_Pounds = 0L, 
               Weapon_Frag_Tons = 0)]

WW2_bombs[is_NA_or_0(Weapon_Weight_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            (Weapon_Expl_Tons != 0 | Weapon_Incd_Tons != 0 | Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Weight_Tons = if_else(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
                                    if_else(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
                                    if_else(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons))]

WW2_bombs[!near(Weapon_Weight_Pounds / 2000, Weapon_Weight_Tons, tol = near_tolerance) | 
            (!is.na(Weapon_Weight_Tons) & is.na(Weapon_Weight_Pounds)), 
          `:=`(Weapon_Weight_Pounds = round_to_int(Weapon_Weight_Tons * 2000))]

WW2_bombs[Weapon_Expl_Tons == 0, 
          `:=`(Weapon_Expl_Num = 0L)]
WW2_bombs[Weapon_Incd_Tons == 0, 
          `:=`(Weapon_Incd_Num = 0L)]
WW2_bombs[Weapon_Frag_Tons == 0, 
          `:=`(Weapon_Frag_Num = 0L)]


### Set NAs -----------------------------------------------------------------

WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            Weapon_Expl_Type == "" & 
            is_NA_or_0(Weapon_Expl_Tons) & 
            is_NA_or_0L(Weapon_Incd_Num) & 
            Weapon_Incd_Type == "" & 
            is_NA_or_0(Weapon_Incd_Tons) & 
            is_NA_or_0L(Weapon_Frag_Num) & 
            Weapon_Frag_Type == "" & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Expl_Num = NA_integer_, 
               Weapon_Expl_Pounds = NA_integer_, 
               Weapon_Expl_Tons = NA_real_, 
               Weapon_Incd_Num = NA_integer_, 
               Weapon_Incd_Pounds = NA_integer_, 
               Weapon_Incd_Tons = NA_real_, 
               Weapon_Frag_Num = NA_integer_, 
               Weapon_Frag_Pounds = NA_integer_, 
               Weapon_Frag_Tons = NA_real_)]

WW2_bombs[Weapon_Expl_Type != "" & 
            is_NA_or_0L(Weapon_Expl_Num) & 
            is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = NA_integer_, 
               Weapon_Expl_Pounds = NA_integer_, 
               Weapon_Expl_Tons = NA_real_)]

WW2_bombs[Weapon_Incd_Type != "" & 
            is_NA_or_0L(Weapon_Incd_Num) & 
            is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Num = NA_integer_, 
               Weapon_Incd_Pounds = NA_integer_, 
               Weapon_Incd_Tons = NA_real_)]

WW2_bombs[Weapon_Frag_Type != "" & 
            is_NA_or_0L(Weapon_Frag_Num) & 
            is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Num = NA_integer_, 
               Weapon_Frag_Pounds = NA_integer_, 
               Weapon_Frag_Tons = NA_real_)]

WW2_bombs[is_NA_or_0L(Weapon_Expl_Num) & 
            Weapon_Expl_Type == "" & 
            !is_NA_or_0(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = NA_integer_)]

WW2_bombs[is_NA_or_0L(Weapon_Incd_Num) & 
            Weapon_Incd_Type == "" & 
            !is_NA_or_0(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Num = NA_integer_)]

WW2_bombs[is_NA_or_0L(Weapon_Frag_Num) & 
            Weapon_Frag_Type == "" & 
            !is_NA_or_0(Weapon_Frag_Tons), 
          `:=`(Weapon_Frag_Num = NA_integer_)]

WW2_bombs[is_NA_or_0(Weapon_Weight_Tons), 
          `:=`(Weapon_Weight_Pounds = NA_integer_, 
               Weapon_Weight_Tons = NA_real_)]
