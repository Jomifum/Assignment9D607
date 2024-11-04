---
  title: "Assignment 9 - Web APIs"
author: "Jose Fuentes"
date: "2024-11-03"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

The New York Times web site provides a rich set of APIs, as described here: https://developer.nytimes.com/apis
You’ll need to start by signing up for an API key.
Your task is to choose one of the New York Times APIs, construct an interface in R to read in the JSON data, and
transform it into an R DataFrame.

For this assignment the web api I used was Books API.

In this first steps we proceeded to install the necessary packages and load libraries:
  ```{r packages}
# Install necessary packages if not already installed
if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("dplyr")) install.packages("dplyr")

# Load packages
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

```

We fetch the current hardcover fiction bestsellers from the New York Times Books API. By defining a custom function, we construct the API request, handle the response, and extract relevant book information such as title, author, publisher, description, rank, and weeks on the list. The data is then transformed into a DataFrame for easy analysis and display.

```{r get-data}
# Define your API key (replace with your actual API key)
api_key <- "lodjVtf8J4YFDAAiNW3mGkmtHG75NBvQ"

# Function to fetch data from NYT Books API for current hardcover fiction bestsellers
fetch_bestsellers <- function() {
  url <- paste0("https://api.nytimes.com/svc/books/v3/lists/current/hardcover-fiction.json?api-key=", api_key)
  
  # Make the GET request
  response <- GET(url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Parse JSON content
    content <- content(response, as = "text", encoding = "UTF-8")
    json_data <- fromJSON(content)
    
    # Extract relevant information into a DataFrame
    books_df <- json_data$results$books %>%
      select(title, author, publisher, description, rank, weeks_on_list)
    
    return(books_df)
  } else {
    stop("Failed to fetch data. Status code: ", status_code(response))
  }
}

# Call the function and display the DataFrame
bestsellers_df <- fetch_bestsellers()
print(bestsellers_df)

```


```{r fetch-transform}
bestsellers_summary <- bestsellers_df %>%
  group_by(weeks_on_list) %>%
  summarise(count = n())

# Print the summary for inspection
print(bestsellers_summary)

```

## Including Plots

You can also embed plots

```{r plots}
# Plot a bar chart showing the number of books per duration on the list
ggplot(bestsellers_summary, aes(x = weeks_on_list, y = count)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme_minimal() +
  labs(title = "Number of Books by Weeks on Bestsellers List",
       x = "Weeks on List",
       y = "Number of Books")

```


```{r plots2}
# Count how many times each publisher appears
publisher_count <- bestsellers_df %>%
  group_by(publisher) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

# Plot the most common publishers
ggplot(publisher_count, aes(x = reorder(publisher, -count), y = count)) +
  geom_bar(stat = "identity", fill = "lightgreen") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top Publishers on NYT Bestsellers List",
       x = "Publisher",
       y = "Number of Books")

```


Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
