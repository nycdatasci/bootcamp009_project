# @author Scott Dobbins
# @version 0.9.7
# @date 2017-07-28 17:30


### Complete tonnage 1 ------------------------------------------------------

# complete tonnage when undefined across all groups but only one group has a weapon listed

WW2_bombs[Weapon_Expl_Type != "" & 
            Weapon_Incd_Type == "" & 
            Weapon_Frag_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Frag_Tons), 
          `:=`(Weapon_Expl_Pounds = Weapon_Weight_Tons * 2000, 
               Weapon_Expl_Tons = Weapon_Weight_Tons)]
WW2_bombs[Weapon_Incd_Type != "" & 
            Weapon_Expl_Type == "" & 
            Weapon_Frag_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Frag_Tons), 
          `:=`(Weapon_Incd_Pounds = Weapon_Weight_Tons * 2000, 
               Weapon_Incd_Tons = Weapon_Weight_Tons)]
WW2_bombs[Weapon_Frag_Type != "" & 
            Weapon_Expl_Type == "" & 
            Weapon_Incd_Type == "" & 
            !is.na(Weapon_Weight_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons), 
          `:=`(Weapon_Frag_Pounds = Weapon_Weight_Tons * 2000, 
               Weapon_Frag_Tons = Weapon_Weight_Tons)]


### Weapon_Expl cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[Weapon_Expl_Pounds != Weapon_Expl_Tons * 2000 & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[Weapon_Expl_Pounds != Weapon_Expl_Tons * 2000 & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[Weapon_Expl_Pounds != Weapon_Expl_Tons * 2000 & 
            (!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Num * Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[Weapon_Expl_Pounds != Weapon_Expl_Tons * 2000, 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]

# if only pounds is defined, update tons
WW2_bombs[(is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Num * Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type) and tons
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0), 
          `:=`(Weapon_Expl_Unit_Weight = as.integer(Weapon_Expl_Pounds / Weapon_Expl_Num), 
               Weapon_Expl_Type = paste0(as.character(as.integer(Weapon_Expl_Pounds / Weapon_Expl_Num)), " LB HE"), 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[(is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0), 
          `:=`(Weapon_Expl_Num = Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds), 
          `:=`(Weapon_Expl_Tons = Weapon_Expl_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (is.na(Weapon_Expl_Tons) | Weapon_Expl_Tons == 0) & 
            !near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Pounds), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Num * Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Tons = Weapon_Expl_Num * Weapon_Expl_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0) & 
            near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0) & 
            !near(Weapon_Expl_Num * Weapon_Expl_Unit_Weight, Weapon_Expl_Tons * 2000), 
          `:=`(Weapon_Expl_Num = Weapon_Expl_Tons * 2000 / Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]

# if num and tons are defined, update unit weight and pounds
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0), 
          `:=`(Weapon_Expl_Unit_Weight = as.integer(Weapon_Expl_Tons * 2000 / Weapon_Expl_Num), 
               Weapon_Expl_Type = paste0(as.character(as.integer(Weapon_Expl_Tons * 2000 / Weapon_Expl_Num)), " LB HE"), 
               Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[(is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0), 
          `:=`(Weapon_Expl_Num = Weapon_Expl_Tons * 2000 / Weapon_Expl_Unit_Weight, 
               Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]

# if only tons is defined, update pounds
WW2_bombs[(is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            (is.na(Weapon_Expl_Pounds) | Weapon_Expl_Pounds == 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0), 
          `:=`(Weapon_Expl_Pounds = Weapon_Expl_Tons * 2000)]


### Weapon_Incd cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[Weapon_Incd_Pounds != Weapon_Incd_Tons * 2000 & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[Weapon_Incd_Pounds != Weapon_Incd_Tons * 2000 & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[Weapon_Incd_Pounds != Weapon_Incd_Tons * 2000 & 
            (!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Num * Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[Weapon_Incd_Pounds != Weapon_Incd_Tons * 2000, 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]

# if only pounds is defined, update tons
WW2_bombs[(is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Num * Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type) and tons
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0), 
          `:=`(Weapon_Incd_Unit_Weight = as.integer(Weapon_Incd_Pounds / Weapon_Incd_Num), 
               Weapon_Incd_Type = paste0(as.character(as.integer(Weapon_Incd_Pounds / Weapon_Incd_Num)), " LB INCENDIARY"), 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[(is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0), 
          `:=`(Weapon_Incd_Num = Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds), 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (is.na(Weapon_Incd_Tons) | Weapon_Incd_Tons == 0) & 
            !near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Pounds), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Num * Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Tons = Weapon_Incd_Num * Weapon_Incd_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0) & 
            near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0) & 
            !near(Weapon_Incd_Num * Weapon_Incd_Unit_Weight, Weapon_Incd_Tons * 2000), 
          `:=`(Weapon_Incd_Num = Weapon_Incd_Tons * 2000 / Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]

# if num and tons are defined, update unit weight and pounds
WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0), 
          `:=`(Weapon_Incd_Unit_Weight = as.integer(Weapon_Incd_Tons * 2000 / Weapon_Incd_Num), 
               Weapon_Incd_Type = paste0(as.character(as.integer(Weapon_Incd_Tons * 2000 / Weapon_Incd_Num)), " LB INCENDIARY"), 
               Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[(is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0), 
          `:=`(Weapon_Incd_Num = Weapon_Incd_Tons * 2000 / Weapon_Incd_Unit_Weight, 
               Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]

# if only tons is defined, update pounds
WW2_bombs[(is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            (is.na(Weapon_Incd_Pounds) | Weapon_Incd_Pounds == 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0), 
          `:=`(Weapon_Incd_Pounds = Weapon_Incd_Tons * 2000)]


### Weapon_Frag cleaning ----------------------------------------------------

# if there's a pound-ton mismatch, and pounds is better, update tons accordingly
WW2_bombs[Weapon_Frag_Pounds != Weapon_Frag_Tons * 2000 & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]
# if there's a pound-ton mismatch, and tons is better, update pounds accordingly
WW2_bombs[Weapon_Frag_Pounds != Weapon_Frag_Tons * 2000 & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]
# if there's still a pound-ton mismatch and it can be resolved by num and unit weight, resolve it that way
WW2_bombs[Weapon_Frag_Pounds != Weapon_Frag_Tons * 2000 & 
            (!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Num * Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if there's still a pound-ton mismatch, trust tons over pounds
WW2_bombs[Weapon_Frag_Pounds != Weapon_Frag_Tons * 2000, 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]

# if only pounds is defined, update tons
WW2_bombs[(is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]

# if only num and unit weight are defined, update pounds and tons
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Num * Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if only num and pounds are defined, update unit weight (and type) and tons
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0), 
          `:=`(Weapon_Frag_Unit_Weight = Weapon_Frag_Pounds / Weapon_Frag_Num, 
               Weapon_Frag_Type = paste0(as.character(as.integer(Weapon_Frag_Pounds / Weapon_Frag_Num)), " LB FRAG"), 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if only unit weight and pounds are defined, update num and tons
WW2_bombs[(is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0), 
          `:=`(Weapon_Frag_Num = Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]

# if all but tons are defined and it's consistent, then update tons
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds), 
          `:=`(Weapon_Frag_Tons = Weapon_Frag_Pounds / 2000)]
# if all but tons are defined and it's inconsistent, trust num and unit weight over pounds
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (is.na(Weapon_Frag_Tons) | Weapon_Frag_Tons == 0) & 
            !near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Pounds), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Num * Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Tons = Weapon_Frag_Num * Weapon_Frag_Unit_Weight / 2000)]
# if all but pounds are defined and it's consistent, then update pounds
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0) & 
            near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]
# if all but pounds are defined and it's inconsistent, trust tons and and unit weight over num
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0) & 
            !near(Weapon_Frag_Num * Weapon_Frag_Unit_Weight, Weapon_Frag_Tons * 2000), 
          `:=`(Weapon_Frag_Num = Weapon_Frag_Tons * 2000 / Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]

# if num and tons are defined, update unit weight and pounds
WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Frag_Unit_Weight = as.integer(Weapon_Frag_Tons * 2000 / Weapon_Frag_Num), 
               Weapon_Frag_Type = paste0(as.character(as.integer(Weapon_Frag_Tons * 2000 / Weapon_Frag_Num)), " LB FRAG"), 
               Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]
# if unit weight and tons are defined, update num and pounds
WW2_bombs[(is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Frag_Num = Weapon_Frag_Tons * 2000 / Weapon_Frag_Unit_Weight, 
               Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]

# if only tons is defined, update pounds
WW2_bombs[(is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            (is.na(Weapon_Frag_Pounds) | Weapon_Frag_Pounds == 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Frag_Pounds = Weapon_Frag_Tons * 2000)]


### Complete tonnage 2 ------------------------------------------------------

WW2_bombs[is.na(Weapon_Weight_Tons | Weapon_Weight_Tons == 0) & 
            !is.na(Weapon_Weight_Pounds) & Weapon_Weight_Pounds != 0, 
          `:=`(Weapon_Weight_Tons = Weapon_Weight_Pounds / 2000)]

WW2_bombs[ifelse(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
            ifelse(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
            ifelse(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons) > Weapon_Weight_Tons, 
          `:=`(Weapon_Weight_Tons = ifelse(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
                 ifelse(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
                 ifelse(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons))]

# update missing ton values if others are known
WW2_bombs[is.na(Weapon_Expl_Tons) & 
            (Weapon_Incd_Tons + Weapon_Frag_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Expl_Tons = Weapon_Weight_Tons - Weapon_Incd_Tons - Weapon_Frag_Tons, 
               Weapon_Expl_Pounds = (Weapon_Weight_Tons - Weapon_Incd_Tons - Weapon_Frag_Tons) * 2000)]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            (Weapon_Expl_Tons + Weapon_Frag_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Incd_Tons = Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Frag_Tons, 
               Weapon_Incd_Pounds = (Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Frag_Tons) * 2000)]
WW2_bombs[is.na(Weapon_Frag_Tons) & 
            (Weapon_Expl_Tons + Weapon_Incd_Tons < Weapon_Weight_Tons), 
          `:=`(Weapon_Frag_Tons = Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Incd_Tons, 
               Weapon_Frag_Pounds = (Weapon_Weight_Tons - Weapon_Expl_Tons - Weapon_Incd_Tons) * 2000)]

# update further data since tons and pounds may now be known
WW2_bombs[(!is.na(Weapon_Expl_Num) & Weapon_Expl_Num != 0) & 
            is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0), 
          `:=`(Weapon_Expl_Unit_Weight = as.integer(Weapon_Expl_Pounds / Weapon_Expl_Num), 
               Weapon_Expl_Type = paste0(as.character(as.integer(Weapon_Expl_Pounds / Weapon_Expl_Num)), " LB HE"))]
WW2_bombs[(is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            !is.na(Weapon_Expl_Unit_Weight) & 
            (!is.na(Weapon_Expl_Pounds) & Weapon_Expl_Pounds != 0) & 
            (!is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0), 
          `:=`(Weapon_Expl_Num = Weapon_Expl_Pounds / Weapon_Expl_Unit_Weight)]

WW2_bombs[(!is.na(Weapon_Incd_Num) & Weapon_Incd_Num != 0) & 
            is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0), 
          `:=`(Weapon_Incd_Unit_Weight = as.integer(Weapon_Incd_Pounds / Weapon_Incd_Num), 
               Weapon_Incd_Type = paste0(as.character(as.integer(Weapon_Incd_Pounds / Weapon_Incd_Num)), " LB HE"))]
WW2_bombs[(is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            !is.na(Weapon_Incd_Unit_Weight) & 
            (!is.na(Weapon_Incd_Pounds) & Weapon_Incd_Pounds != 0) & 
            (!is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0), 
          `:=`(Weapon_Incd_Num = Weapon_Incd_Pounds / Weapon_Incd_Unit_Weight)]

WW2_bombs[(!is.na(Weapon_Frag_Num) & Weapon_Frag_Num != 0) & 
            is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Frag_Unit_Weight = as.integer(Weapon_Frag_Pounds / Weapon_Frag_Num), 
               Weapon_Frag_Type = paste0(as.character(as.integer(Weapon_Frag_Pounds / Weapon_Frag_Num)), " LB HE"))]
WW2_bombs[(is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            !is.na(Weapon_Frag_Unit_Weight) & 
            (!is.na(Weapon_Frag_Pounds) & Weapon_Frag_Pounds != 0) & 
            (!is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Frag_Num = Weapon_Frag_Pounds / Weapon_Frag_Unit_Weight)]


### Setting zeros -----------------------------------------------------------

WW2_bombs[is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Incd_Tons + Weapon_Frag_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            Weapon_Expl_Type == "", 
          `:=`(Weapon_Expl_Num = 0, 
               Weapon_Expl_Pounds = 0, 
               Weapon_Expl_Tons = 0)]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons + Weapon_Frag_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            Weapon_Incd_Type == "", 
          `:=`(Weapon_Incd_Num = 0, 
               Weapon_Incd_Pounds = 0, 
               Weapon_Incd_Tons = 0)]
WW2_bombs[is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons + Weapon_Incd_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Frag_Num = 0, 
               Weapon_Frag_Pounds = 0, 
               Weapon_Frag_Tons = 0)]

WW2_bombs[is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Frag_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            Weapon_Expl_Type == "" & 
            (is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            Weapon_Incd_Type == "", 
          `:=`(Weapon_Expl_Num = 0, 
               Weapon_Expl_Pounds = 0, 
               Weapon_Expl_Tons = 0, 
               Weapon_Incd_Num = 0, 
               Weapon_Incd_Pounds = 0, 
               Weapon_Incd_Tons = 0)]
WW2_bombs[is.na(Weapon_Expl_Tons) & 
            is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Incd_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Expl_Num) | Weapon_Expl_Num == 0) & 
            Weapon_Expl_Type == "" & 
            (is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Expl_Num = 0, 
               Weapon_Expl_Pounds = 0, 
               Weapon_Expl_Tons = 0, 
               Weapon_Frag_Num = 0, 
               Weapon_Frag_Pounds = 0, 
               Weapon_Frag_Tons = 0)]
WW2_bombs[is.na(Weapon_Incd_Tons) & 
            is.na(Weapon_Frag_Tons) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Weight_Tons) & 
            near(Weapon_Expl_Tons, Weapon_Weight_Tons) & 
            (is.na(Weapon_Incd_Num) | Weapon_Incd_Num == 0) & 
            Weapon_Incd_Type == "" & 
            (is.na(Weapon_Frag_Num) | Weapon_Frag_Num == 0) & 
            Weapon_Frag_Type == "", 
          `:=`(Weapon_Incd_Num = 0, 
               Weapon_Incd_Pounds = 0, 
               Weapon_Incd_Tons = 0, 
               Weapon_Frag_Num = 0, 
               Weapon_Frag_Pounds = 0, 
               Weapon_Frag_Tons = 0)]

WW2_bombs[(is.na(Weapon_Weight_Tons) | Weapon_Weight_Tons == 0) & 
            !is.na(Weapon_Expl_Tons) & 
            !is.na(Weapon_Incd_Tons) & 
            !is.na(Weapon_Frag_Tons) & 
            (Weapon_Expl_Tons != 0 | Weapon_Incd_Tons != 0 | Weapon_Frag_Tons != 0), 
          `:=`(Weapon_Weight_Tons = ifelse(is.na(Weapon_Expl_Tons), 0, Weapon_Expl_Tons) + 
                 ifelse(is.na(Weapon_Incd_Tons), 0, Weapon_Incd_Tons) + 
                 ifelse(is.na(Weapon_Frag_Tons), 0, Weapon_Frag_Tons))]

WW2_bombs[!near(Weapon_Weight_Pounds / 2000, Weapon_Weight_Tons), 
          `:=`(Weapon_Weight_Pounds = as.integer(round(Weapon_Weight_Tons * 2000)))]
