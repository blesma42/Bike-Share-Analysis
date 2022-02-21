# Bike Share Company

> **Google-Data-Analyticst-Capstone**
> This was the Capstone project of the Google Data Analytics Certificate.

## Introduction

Cyclist’s finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, Management believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Management believes there is a very good chance to convert casual riders into members. Management notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.
A more detailed description is availible in [Setup.pdf](Setup.pdf).


## Leading Questions

- How do regular users (members) and casual users differ in their use of bikes?
- Do members drive during different days or times?
- Do members dirve longer?
- Do members drive with different like types?
- How could causal users motivated to become members?

## Data

For this project publicly avaiaible data from the [divvy-tripdata-set](https://divvy-tripdata.s3.amazonaws.com/index.html) was used. The data has been made available by Motivate International Inc. under this [license](https://ride.divvybikes.com/data-license-agreement). For this case study data from January 2021 till December 2021 (12 months) was used.

## Analysis

All data was read, cleaned, and analyzed with an [R-Script](Bike share.R). For better understanding, the script was then converted into an [R-Markdown file](Bike share.Rmd). For accessibility the markdown was knitted into an [html-file](Bike Share Analysis.html)

## Results

For detailed results check the [html-file](Bike Share Analysis.html).  

The time of the day and day of the week indicate, that most members use bikes for there way to or from work, while casual users use bikes for freetime activities, mainly during the weekend.  
The majority of both user types prefer classic bikes over other bike types (member: 78%, casual: 62%). While roughly one fifth of both user types use electric bikes (member: 22%, casual: 23%), only casual users use docked bikes at all (member: 0%, casual: 15%).  
The average trip duration is longer for casual users (members: 13.6 min, casual: 28.7 min), but there are some differences dependend on the bike type.  

## Conclusion

The analysis provided some insights into the differences between the user types. However, these are not enough to create n action plan to convince more casual users to become members.
Intead, a deeper analysis should be perfomed with user specific data (eg. how often does a causal user use the bike). To get insights in customer behavior, awarness of the member option, and there expectations, a surey is recommended.

## Project Files

|File|Discription|
|-|-|
|[Bike Share Analysis.html](master/Bike%20Share%20Analysis.html)| Final report to view for interested persons   |
|[Setup.pdf](master/Setup.pdf)                                  | Explenation of the Capstone project           |
|[Bike share.R](master/Bike%20share.R)                          | Source code                                   |
|[Bike share.Rmd](master/Bike%20share.Rmd)                      | Markdown source code                          |
|[README.md](master/README.md)                                  | Project information                           |
