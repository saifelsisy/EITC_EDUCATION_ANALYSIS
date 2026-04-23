# Earned Income Tax Credit's Effect on Education Outcomes 

This project was created for my capstone class senior year in Economics

## Author
 Saif Elsisy

<!-- 
## Plans for Development:

## PowerPoint Presentation
-->

## Visuals

![High School Completion Plot](HS_Completion_Plot.png)

![College Attendance Plot](College_Attendance_Plot.png)

![College Completion Plot](Bachelors_Completion_Plot.png)

These plots all display the change in education success by EITC exposure. The group that is below the phaseout ceiling (in red) is qualified to recieve the tax credit since their income is sufficiently low while the group in blue are unqualified since their income is too high. If the tax credit has a positive impact on education success, as we would expect based on economic theory, the red line should have an upward trend while the blue line should have a relatively flatter slope. None of these plots, nor the regression results within the "Regressions" folder tells this story though. This is easily explained by the low R squared values within the models (around 0.1) which just means that the models only explain around 10% of the variability in education outcomes. This means that there could be some variable unaccounted for which negatively affects education but is correlated with the tax credit which is skewing the results. 