working_directory <- 'C:/Users/mathi/Desktop/Datenanalyse/2021-12-13 Bike share company/Data'
setwd(working_directory)

library(lubridate)
library(dplyr)
library(ggplot2)

Sys.setlocale('LC_TIME', 'English')

###reading the data

#gets all files (months) from the folder
file_list <- list.files(path=working_directory)
print(file_list)

#checking the first file
first_file <- read.csv(file_list[1])
str(first_file)

#counts and returns the number of rows/entries per file and over all
number_of_rows <- 0

for (file in file_list)
{
  temp_df <- read.csv(file)
  print(paste(file, ': ', format(nrow(temp_df), big.mark=','), ' entries', sep=''))
  number_of_rows <- number_of_rows + nrow(temp_df)
  rm(temp_df)
}
print(paste('Total rows: ', format(number_of_rows, big.mark=',')))

#gets the column names from the first file and delets first_file
columns <- colnames(first_file)
rm(first_file)

#for loop:
#checks, if all files have the same columns (number, order, labeling/spelling)
mismatches <- 0

for (file in file_list)
{
  temp_columns <- colnames(read.csv(file))
  if (any(temp_columns!=columns)){
    output <- 'mismatch'
    mismatches=mismatches+1
  } else {
    output <- 'ok'
  }
  print(paste(file, output, sep=': '))
  rm(temp_columns)
}
print('All columns checked')
print(paste('Number of mismatches:', mismatches))

#dataframe for the actual data for further processing
df <- data.frame(matrix(ncol=length(columns), nrow=0))
colnames(df) <- columns
print(df)

#joins all files into one dataframe
for (file in file_list)
{
  temp_df <- read.csv(file)
  df <- rbind(df, temp_df)
  rm(temp_df)
  print(paste(file, ': inserted', sep=''))
}
print('All data inserted')

###Cleaning and transformation

#function will return how many rows were removed from df since the function was last applied
#will be used to keep track on were how many entries were removed
removed_rows <- function(){
  new_number_of_rows <- nrow(df)
  removed_rows <- number_of_rows-new_number_of_rows
  number_of_rows <<- new_number_of_rows
  print(paste('Removed rows:', format(removed_rows, big.mark=',')))
}

str(df)

#replaces empty values with NA
df[df==''] <- NA

#removes rows where no start station or end station is given or the start or end date is missing
df <- df %>% 
  filter_at(vars(start_station_name, start_station_id), any_vars(!is.na(.))) %>% 
  filter_at(vars(end_station_name, end_station_id), any_vars(!is.na(.))) %>%
  filter_at(vars(started_at, ended_at), all_vars(!is.na(.)))
removed_rows()

#typecasting: character too date time
df$started_at <- as.POSIXct(df$started_at, format='%Y-%m-%d %H:%M:%S', tz='GMT')
df$ended_at <- as.POSIXct(df$ended_at, format='%Y-%m-%d %H:%M:%S', tz='GMT')

#transformation of 'rideable_type'
df <- df %>% rename(bike_type=rideable_type) 
df %>% distinct(bike_type)
df$bike_type[df$bike_type=='classic_bike'] <- 'classic'
df$bike_type[df$bike_type=='electric_bike'] <- 'electric'
df$bike_type[df$bike_type=='docked_bike'] <- 'docked'
df %>% distinct(bike_type)

#additional columns which might be interesting for analysis
df$month <- format(as.Date(df$started_at), '%Y-%m-01')
df$hour <- hour(df$started_at)
df$day_of_week <- wday(df$started_at, label=TRUE, week_start=getOption('lubridate.week.start', 1)) 
df$trip_duration <- as.double(difftime(df$ended_at, df$started_at, units = 'mins'))

df <- select(df, -start_lat, -start_lng, -end_lat, -end_lng)

df %>% distinct(member_casual)
df <- df %>% rename(user_type=member_casual)

str(df)

summary(df)

df <- df %>% filter(trip_duration>0)
removed_rows()
df <- df %>% filter(trip_duration>2)
df <- df %>% filter(trip_duration<(24*60))
removed_rows()  

summary(df)

head(df) 

#counts distinct values per column
sapply(df, n_distinct)
  
#stations only in start/end
setdiff(df$start_station_name, df$end_station_name)
setdiff(df$end_station_name, df$start_station_name)

setdiff(df$start_station_id, df$end_station_id)
setdiff(df$end_station_id, df$start_station_id)


###Analysis and Visualization

#summarized by different time columns for further analysis
df_summarized_by_time <- df %>%
  group_by(user_type, month, day_of_week, hour) %>%
  summarize(ride_count=n(), duration=sum(trip_duration))

#Rides by month and user_type
df_summarized_by_time %>%
  group_by(user_type, month) %>%
  summarize(ride_count=sum(ride_count)) %>%
  ggplot(aes(x=as.Date(month, '%Y-%m-%d'), y=ride_count, group=user_type, color=user_type))+
  geom_line(size=1)+
  geom_point(aes(color=user_type), shape=18, size=3)+
  scale_y_continuous(breaks=scales::breaks_extended(n=10))+
  ggtitle('Rides by Month')+
  theme_bw()+
  theme(plot.title=element_text(hjust=0.5))+
  ylab('Number of Rides')+
  xlab('Month')+
  labs(color='User Type')+
  scale_x_date(date_labels='%b \n %Y', date_breaks='1 month', minor_breaks=NULL)

#Rides by hour and user_type
df_summarized_by_time %>%
  group_by(user_type, hour) %>%
  summarize(ride_count=sum(ride_count)) %>%
  mutate(hour=factor(hour)) %>%
  ggplot(aes(x=hour, y=ride_count, group=user_type, color=user_type))+
  geom_line(size=1)+
  geom_point(aes(color=user_type), shape=18, size=3)+
  scale_y_continuous(breaks=scales::breaks_extended(n=10))+
  ggtitle('Rides by Time of the Day')+
  theme_bw()+
  theme(plot.title=element_text(hjust=0.5))+
  ylab('Number of Rides')+
  xlab('Time of the Day')+
  labs(color='User Type')

#Rides by days of week and user_type
df_summarized_by_time %>%
  group_by(user_type, day_of_week) %>%
  summarize(ride_count=sum(ride_count)) %>%
  #mutate(day=factor(day_of_week)) %>%
  ggplot(aes(x=day_of_week, y=ride_count, group=user_type, color=user_type))+
  geom_line(size=1)+
  geom_point(aes(color=user_type), shape=18, size=3)+
  scale_y_continuous(breaks=scales::breaks_extended(n=10))+
  ggtitle('Rides by Day of Week')+
  theme_bw()+
  theme(plot.title=element_text(hjust=0.5))+
  ylab('Number of Rides')+
  xlab('Day of the Week')+
  labs(color='User Type')

#heatmap for summerization (hour, day, number of rides)
df_summarized_by_time %>%
  group_by(user_type, day_of_week, hour) %>%
  summarize(ride_count=sum(ride_count)) %>%
  mutate(hour=factor(hour)) %>%
  ggplot(aes(x=hour, y=reorder(day_of_week, desc(day_of_week)), fill=ride_count))+
  geom_tile(color='black', size=0.1)+
  scale_fill_gradient(low='white', high='red')+
  theme(panel.grid=element_blank(), 
        panel.background=element_blank(), 
        strip.background=element_rect(fill='#ccff66'),
        strip.text.y=element_text(angle=0, face='bold'))+
  facet_grid(rows=vars(user_type))+
  ylab('Day of the Week')+
  xlab('Time of the Day')+
  labs(fill='Number of Rides')+
  ggtitle('Rides by Time of the Day, Day of the Week, and User Type')+
  theme(plot.title=element_text(hjust=0.5))



df_summarized_by_biketype_duration <- df %>%
  mutate(trip_duration_rounded=round((trip_duration+5), digits=-1)) %>%
  group_by(user_type, bike_type, trip_duration_rounded) %>%
  summarize(ride_count=n(), duration=sum(trip_duration))

#user_type and bike type

df_summarized_by_biketype_duration %>%
  group_by(user_type, bike_type) %>%
  summarize(ride_count=sum(ride_count)) %>%
  mutate(proportion=ride_count/sum(ride_count)) %>%
  ggplot(aes(fill=bike_type, y=proportion, x=user_type), position='fill')+
  geom_col(position='fill')+
  ylab('Proportion of Rides')+
  xlab('User Type')+
  labs(fill='Bike Type')+
  geom_text(aes(label=scales::percent(proportion)), position=position_stack(0.5))+  
  ggtitle('Bike Type by User Type')+
  theme(plot.title=element_text(hjust=0.5))+
  coord_flip()

#summarization of the trip duration
df%>%
  group_by(user_type) %>%
  summarize(ride_count=n(), average_length=mean(trip_duration))

df %>%
  group_by(user_type, bike_type) %>%
  summarize(ride_count=sum(ride_count), duration=sum(duration)) %>%
  mutate(average_ride_duration=round(duration/ride_count, 2)) %>%
  ggplot(aes(y=average_ride_duration, x=user_type, fill=bike_type))+
  geom_bar(stat='identity', color='black', position=position_dodge())+
  ylab('Average Ride Duration [min]')+
  xlab('User Type')+
  labs(fill='Bike Type')+
  ggtitle('Average Ride Duration by Bike and User Type')+
  theme_bw()+
  geom_text(size=3, aes(label=paste(average_ride_duration, 'min')), position=position_dodge(0.9), vjust=-0.5)+
  theme(plot.title=element_text(hjust=0.5))

df_summarized_by_biketype_duration %>%
  filter(trip_duration_rounded<=180) %>%
  ggplot(aes(x=trip_duration_rounded, y=ride_count))+
  geom_bar(stat='identity', width=10, color='black', fill='#99ccff' ,position=position_nudge(x=-5))+
  facet_grid(user_type ~ bike_type)+
  ylab('Number of Rides')+
  xlab('Ride Duration [min]')+
  ggtitle('Distribution of Ride Duration by Bike and User Type')+
  theme_light()+
  theme(strip.text=element_text(color='black'))+
  theme(strip.background=element_rect(fill='#ccffcc'))+
  theme(plot.title=element_text(hjust=0.5))

#Top 10 stations with most rides
#start stations
df %>%
  mutate(member=ifelse(user_type=='member', 1, 0), casual=ifelse(user_type=='casual', 1, 0)) %>%
  group_by(start_station_name) %>%
  summarize(ride_count=n(), member=sum(member), casual=sum(casual)) %>% 
  mutate(proportion_member=paste(round(member/ride_count*100, 2), '%')) %>% 
  arrange(desc(ride_count), .group_by=TRUE) %>%
  filter(rank(desc(ride_count))<11)

#end stations
df %>%
  mutate(member=ifelse(user_type=='member', 1, 0), casual=ifelse(user_type=='casual', 1, 0)) %>%
  group_by(end_station_name) %>%
  summarize(ride_count=n(), member=sum(member), casual=sum(casual)) %>%
  mutate(proportion_member=paste(round(member/ride_count*100, 2), '%')) %>% 
  arrange(desc(ride_count), .group_by=TRUE) %>%
  filter(rank(desc(ride_count))<11)
