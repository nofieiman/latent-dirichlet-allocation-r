# Step 1: Load the Necessary Libraries

# Install required packages if not already installed
# install.packages("tidytext")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("wordcloud")
# install.packages("reshape2")

# Load libraries
library(tidytext)
library(dplyr)
library(ggplot2)
library(wordcloud)
library(reshape2)

# Step 2: Load and Inspect the Data

# Download: https://www.kaggle.com/datasets/andrewmvd/trip-advisor-hotel-reviews

# Load the CSV file
reviews <- read.csv("/path/to/tripadvisor_hotel_reviews.csv", stringsAsFactors = FALSE)

# View the first few rows of the dataset
head(reviews)

# Step 3: Preprocess the Text Data

# Assuming the reviews are in a column named 'Review' in the dataset
reviews_clean <- reviews %>%
  select(Review) %>%
  mutate(Review = tolower(Review)) %>%  # Convert text to lowercase
  unnest_tokens(word, Review) %>%       # Tokenize the text into individual words
  anti_join(stop_words)                 # Remove common stop words

# 3a: remove unnecessary words
# Additional words to remove (e.g., "n't", "not", etc.)
additional_stop_words <- c("n't", "not", "just", "also", "did", "still", "one", "can", "really", "no")

# 3b: preprocess again
reviews_clean <- reviews %>%
  select(Review) %>%
  mutate(Review = tolower(Review)) %>%.    # Convert text to lowercase
  unnest_tokens(word, Review) %>%          # Tokenize the text into individual words
  filter(!word %in% additional_stop_words) # Remove additional common words

# Step 4: Conduct Word Frequency Analysis

# Calculate word frequency
word_freq <- reviews_clean %>%
  count(word, sort = TRUE)

# View the most common words
head(word_freq, 10)

# Step 5: Visualize Word Frequency with a Bar Plot

# Plot the top 20 most common words
word_freq %>%
  top_n(20) %>%
  ggplot(aes(x = reorder(word, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Most Common Words in Reviews", x = "Word", y = "Frequency")

# Step 6: Create a Word Cloud

# Plot a word cloud of the most common words
wordcloud(words = word_freq$word, freq = word_freq$n, min.freq = 5,
          max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Dark2"))

# Step 7: Sentiment Analysis

# Perform sentiment analysis
sentiments <- reviews_clean %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE)

# Plot the sentiment analysis results
sentiments %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(word, n), y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ sentiment, scales = "free_y") +
  coord_flip() +
  labs(title = "Top Words by Sentiment", x = "Word", y = "Frequency")

# Step 8: Sentiment Score for Each Review

# Calculate sentiment score for each review
review_sentiment <- reviews %>%
  select(Review) %>%
  mutate(Review = tolower(Review)) %>%
  unnest_tokens(word, Review) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  summarise(sentiment_score = sum(ifelse(sentiment == "positive", 1, -1)))

# View sentiment scores for each review
head(review_sentiment)

# Step 9: Latent Dirichlet Allocation
# Install required packages if not already installed
install.packages("topicmodels")
install.packages("tm")
install.packages("tidytext")

library(topicmodels)
library(tm)
library(tidytext)

# Create a document-term matrix (DTM)
reviews_corpus <- Corpus(VectorSource(reviews_clean))
dtm <- DocumentTermMatrix(reviews_corpus, control = list(wordLengths = c(3, Inf)))

# Run LDA for topic modeling
lda_model <- LDA(dtm, k = 5, control = list(seed = 1234))  # k is the number of topics

# Extract and view topics
topics <- tidy(lda_model, matrix = "beta")
top_terms <- topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup() %>%
  arrange(topic, -beta)

# View top terms for each topic
print(top_terms, n=50)

# Step 10: Interactive visualisation
install.packages("LDAvis")
install.packages("servr")
library(LDAvis)
library(servr)

# Convert the Document-Term Matrix (DTM) to a required format
phi <- posterior(lda_model)$terms   		# Probabilities of terms in topics
theta <- posterior(lda_model)$topics 		# Probabilities of topics in documents
vocab <- colnames(dtm)              		# Vocabulary (terms in the DTM)
doc_length <- rowSums(as.matrix(dtm)) 		# Document lengths
term_frequency <- colSums(as.matrix(dtm)) 	# Term frequencies

# Create a JSON object for LDAvis
json_lda <- createJSON(
  phi = phi, 
  theta = theta, 
  doc.length = doc_length, 
  vocab = vocab, 
  term.frequency = term_frequency
)

# Launch the interactive visualization
serVis(json_lda, out.dir = "LDAvis", open.browser = TRUE)

# Save the visualization as a standalone HTML
serVis(json_lda, out.dir = "LDAvis_output", open.browser = FALSE)
