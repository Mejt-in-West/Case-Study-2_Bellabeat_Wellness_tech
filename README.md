Case Study 2: How can a Wellness technology company play it smart?

--Study & resources provided by Google Data Analytics Professional Certificate

Scenario:
I’m a junior data analyst working on the marketing analyst team at Bellabeat, a high-tech manufacturer of health-focused products for women. Bellabeat is a successful small company, but they have the potential to become a larger player in the global smart device market. Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. I’ve been asked to focus on one of Bellabeat’s products and analyze smart device data to gain insight into how consumers are using their smart devices. The insights I discover will then help guide marketing strategy for the company. I will present your analysis to the Bellabeat executive team along with your high-level recommendations for Bellabeat’s marketing strategy.

Bellabeat Products:
- Bellabeat membership: Bellabeat offers a subscription-based membership program for users. Membership gives users 24/7 access to fully personalized guidance on nutrition, activity, sleep, health and beauty, and mindfulness based on their lifestyle and goals.
- Bellabeat app: The Bellabeat app provides users with health data related to their activity, sleep, stress, menstrual cycle, and mindfulness habits. This data can help users better understand their current habits and make healthy decisions. The Bellabeat app connects to their line of smart wellness products.
- Leaf: Bellabeat’s classic wellness tracker can be worn as a bracelet, necklace, or clip. The Leaf tracker connects to the Bellabeat app to track activity, sleep, and stress.
- Time(Fitbit): This wellness watch combines the timeless look of a classic timepiece with smart technology to track user activity, sleep, and stress. The Time watch connects to the Bellabeat app to provide you with insights into your daily wellness.
- Spring: This is a water bottle that tracks daily water intake using smart technology to ensure that you are appropriately hydrated throughout the day. The Spring bottle connects to the Bellabeat app to track your hydration levels.

Available Data Sources:
I’ve been encouraged you to use public data that explores smart device users’ daily habits, by Bellabeat’s cofounder and Chief Creative Officer, where she’s pointed me to a specific dataset that she wish me to use  for my analysis:
FitBit Fitness Tracker Data (CC0: Public Domain, dataset made available through Mobius): This data set contains personal fitness tracker data from thirty Fitbit users. Thirty eligible Fitbit users consented to the submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring. It includes information about daily activity, steps, and heart rate that can be used to explore users’ habits.

To help guide the marketing strategies for this company, we’re going to take the data available through the 6 Data Analysis process phase:
- Phase 1: ASK - Define the problem and confirm stakeholders' expectations
- Phase 2: PREPARE - Collect and store data for analysis
- Phase 3: PROCESS - Clean and transform data to ensure integrity
- Phase 4: ANALYSE - Use data analysis tools to draw conclusions
- Phase 5: SHARE - Interpret and communicate results to others to make data-driven decisions
- Phase 6: ACT - Put my insight to work in order to solve the original problem


ASK:
Bellabeat’s cofounder and Chief Creative Officer has asked me to analyse smart device usage data in order to gain insight into how consumers use non-Bellabeat smart devices. I’ve then been asked to select one Bellabeat product to apply these insights to in my presentation:
1. What are some trends in smart device usage?
2. How could these trends apply to Bellabeat customers?
3. How could these trends help influence Bellabeat marketing strategy?

PREPARE:
The data used in this analysis comes from a public dataset made available by Mobius. It includes 11 CSV files containing information on daily activity, heart rate, calories, intensities, steps, sleep, and weight.

Determine Credibility of data Using ROCCC.
- Reliable: The dataset includes information from only 30 Fitbit users, which is a limited sample size. It also lacks demographic details and other variables that would allow for a broader and more representative analysis.
- Original: The dataset is not original to Bellabeat; it was collected through a survey distributed on Amazon Mechanical Turk between April and May 2016. This raises potential concerns about bias and reliability. The entries are identified through export session IDs or timestamps, with variations reflecting differences in Fitbit models used and individual tracking habits or preferences.
- Comprehensive: The dataset is incomplete, as it excludes key details that could affect the analysis of fitness and health behaviors, such as user age. Additionally, it does not contain data related to Bellabeat’s Spring product or mobile app, restricting the evaluation to the Time smart device alone.
- Current: The dataset is outdated, as it originates from 2016. Therefore, the findings may not align with present-day patterns in wearable device use.
- Cited: Yes, the origin of where the data was collected is disclosed.

PROCESS:
What tools am I using for my analysis, and why?
- SQL: SQL is a database programming language used to communicate with databases to analyse data. Since there's 11 datasets to work with in this casestudy, all with various timelapses (minute, hour, & day), I'll be analysing the data via Visual Studio Code, with ssms for database, which allows users to manipulate and reorganize larger data as needed to aid analysis.
- Tableau: Since SQL does not offer a visual alternative in it's programming language, I'll be framing the results via Tableau <https://public.tableau.com/app/profile/lisa.westin/vizzes>.
- R Programming: R is a general-purpose programming language used for statistical analysis, visualisation, and other data analysis. I'll be cooperating the same steps used in SQL via R, as it provides an accessible language to organize, modify, and clean data frames, and create insightful data visualizations. I'll be using R studio to process my code.

TBC...

