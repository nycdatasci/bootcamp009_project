library(data.table)
library(dplyr)
library(googleVis)
library(plotly)
library(akima)
library(shinydashboard)
library(leaflet)

setwd('~/Desktop/nycdsa/shiny_comet/meteor_app/')

#Full data sets
small_body_dt <- fread(file = "./small_body_dt.dt")
small_body_join <- fread(file = "./small_body_join.dt")
sentry_dt <- fread(file = "./sentry_dt.dt")
sbdt_summary <- fread(file = "./sbdt_summary.dt")
#mba_dt <- fread(file = "./mba_dt.dt")

#For class information page
meteor_descriptions <- fread(file = "./meteor_descriptions")

#For crater formation
impactor <- fread(file = "./impactor")
materials <- fread(file = "./materials")
city_dt <- fread(file = "./city_dt.dt")

#Commonly used color map
class_temp <- unique(small_body_join$class)
col_temp <- heat.colors(length(class_temp), alpha=NULL)
class_col <- c(class_temp=col_temp)

#Crater formation equation
crater_formation <- function(a_s, u_s, rho_t, delta_s, y_t, mu, nu, k_1, k_2, k_r, k_d){
  g = 980.7 #cm/s^2
  #Coefficient calc pi_2
  pi_2 <- g*a_s/u_s**2
  
  #Coefficient calc pi_3
  pi_3 <- y_t/(rho_t*u_s**2)
  
  #Coefficient calc pi_v
  pi_v <- k_1*(pi_2*(rho_t/delta_s)**((6*nu-2-mu)/(3*mu)) +
                 (k_2*pi_3*(rho_t/delta_s)**((6*nu-2)/(3*mu)))**((2+mu)/2))**(-3*mu/(2+mu))
  
  #Crater volume V_cr
  V_cr <- pi_v*(pi*(4/3)*(a_s)**3 * delta_s)/rho_t
  
  #Crater radius r_cr
  r_cr <- k_r*V_cr**(1/3)
  
  #Crater depth d_cr
  d_cr <- k_d*V_cr**(1/3)
  
  V_ej = 0.8*V_cr #ejected volume
  
  T_form = 0.8*(V_cr**(1/3)/g)**0.5 #Formation time
  
  value_cm <- c(V_cr, V_ej, r_cr, d_cr, T_form)
  value_km <- value_cm*c((1e-5)**3, (1e-5)**3, 1e-5, 1e-5, 1)
  value_mi <- value_km*c(0.6124**3, 0.6124**3, 0.6124, 0.6124, 1)
  
  output <- data.frame(name=c('V_cr', 'V_ej', 'r_cr', 'd_cr', 'T_form'),
                       value_cm=value_cm,
                       value_km=value_km,
                       value_mi=value_mi,
                       stringsAsFactors = F)
  
  return(output)
}

#Ellipse plotting function
ellipse_create <- function(a, q, phi_len = 100){
  phi <- seq(-pi,pi,length.out = phi_len)
  e <- (q/a) - 1
  
  out1 <- a*(cos(phi)-e)
  out2 <- a*(1-e**2)**0.5 * sin(phi)
  df <- data.frame(out1, out2)
}
#sun visualization df
df_sun <- ellipse_create(a = 0.1, q = 0.1)
df_earth <- ellipse_create(a = 1, q = 1)
df_mars <- ellipse_create(a = 1.3813, q = 1.5237)
df_jupiter <- ellipse_create(a = 4.952, q = 5.203)

#Base plot for orbits
orbital_plot <- ggplot(data = NULL, aes(x=out1, y=out2)) +
  geom_polygon(data = df_sun, fill='yellow') +
  geom_path(data = df_earth, color = 'blue') +
  geom_path(data = df_mars, color = 'red') + 
  geom_path(data = df_jupiter, color = 'purple') +
  coord_fixed() + labs(x='', y='') +
  theme_minimal() +
  theme(axis.title=element_blank(),
        axis.text=element_blank(),
        panel.grid=element_blank())

add_to_orbit <- function(class_name){
  geom_path(data = ellipse_create(a = sbdt_summary[class==class_name]$avg_a,
                                  q = sbdt_summary[class==class_name]$avg_q),
            color = 'black')
}
