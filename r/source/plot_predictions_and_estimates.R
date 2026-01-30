#################################
## Plot predictions and estimates
#################################

## Compute predictions
#---------------------

# Define plotting points
sf_plot = st_union( st_line_sample( activate(stream_upstream,"edges"), density=1/1000))
sf_plot = st_cast( sf_plot, "POINT" )

# Format as `newdata` for prediction
for(year_i in seq_times){
  print(year_i)
  newdata = data.frame(
    Count = NA,
    st_coordinates(sf_plot),
    var = "species",  # Univariate model so only one value
    time = year_i,    # no time-dynamics, so only one value
    dist = "obs"    # only one type of sampling in data
  )
  if(year_i == seq_times[1]) newdata_full <- newdata
  if(year_i != seq_times[1]) newdata_full <- rbind(newdata,newdata_full)
}

# Extract predicted spatial variable
predict_df = predict( out, newdata = newdata_full )
predict_df_2 <- newdata_full |> 
  mutate(pred = predict_df)

predict_df_3 <- predict_df_2 |> 
  group_by(time) |> 
  summarise(pred = sum(pred))

## Plot predictions
#------------------
if(make_plots){

  par(mfrow = c(1,1))
  plot(
    stream_upstream,
    main="Plot predictions",cex=0.25
  )
  
  plot(
    st_sf(sf_plot,"pred"=log(predict_df)),
    add=TRUE, pch=19, cex=0.05, pal=viridis 
  )
  
  plot( spp_sf[,"log_effectif"],
        add=TRUE, pch=19, cex=0.5)
  
}

ggplot(predict_df_2)+
  geom_point(aes(x=X,y=Y,col=log(pred)),size = 0.1)+
  scale_color_distiller(palette = "Spectral")+
  facet_wrap(.~ predict_df_2$time)

## Plot temporal effect
#----------------------
index_delta_tc <- which(names(out$sdrep$par.random) == "delta_tc")

df_time_index <- data.frame(year = year_of_interest, 
  delta_tc = out$sdrep$par.random[index_delta_tc],
  sd_delta_tc = out$sdrep$diag.cov.random[index_delta_tc])

delta_tc_plot <- ggplot(data = df_time_index,aes(x=year,y=delta_tc))+
  geom_line()+
  geom_ribbon(aes(ymin = delta_tc - 1.96 * sd_delta_tc,
    ymax = delta_tc + 1.96 * sd_delta_tc), fill = "grey70", alpha=0.25)+
  theme_minimal()

if(make_plots) plot(delta_tc_plot)

## Plot abundance indices
IA_plot <- ggplot(data = predict_df_3,aes(x=time,y=pred))+
  geom_line()+
  theme_minimal()+
  ylim(0,NA)
plot(IA_plot)


# res_lm <- lm(df_time_index$year~df_time_index$delta_tc)
# summary(res_lm)
# plot(res_lm)
