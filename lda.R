############################################
# Step 1: Install and Load Required Packages
############################################

# Install necessary libraries (if not already installed)
install.packages(c("tidyverse", "tidytext", "tm", "topicmodels", "LDAvis", "pdftools"))

# Load the libraries
library(tidyverse)
library(tidytext)
library(tm)
library(topicmodels)
library(LDAvis)
library(pdftools)


#############################################
# Step 2: Import and Preprocess the Text Data
#############################################

# Read the PDF content
# https://www.dropbox.com/scl/fi/z2qwvgck3iszrpx75ikz7/Disertasi-Bahlil-Lahadalia-Sidang-Promosi_Final.pdf

file_path <- "/path/to/Disertasi Bahlil Lahadalia - Sidang Promosi_Final.pdf"
text <- pdf_text(file_path) %>% paste(collapse = " ")

# Convert to a data frame
docs <- data.frame(text = text, stringsAsFactors = FALSE)

# Clean the text data
docs$text <- tolower(docs$text)                    # Convert to lowercase
docs$text <- removePunctuation(docs$text)          # Remove punctuation
docs$text <- removeNumbers(docs$text)              # Remove numbers
docs$text <- removeWords(docs$text, stopwords("en")) # Remove English stopwords
docs$text <- stripWhitespace(docs$text)            # Remove extra whitespace


##################################################
# Step 3: Tokenize and Create Document-Term Matrix
##################################################

# Additional words to remove
additional_stop_words <- c("di", "yang", "dan", "dari", "ini", "ke", "itu", "saat", "untuk", "juga", "hal", "oleh", "atau", "dapat", "dalam", "ada", "pada", "dengan", "akan", "seperti", "lebih", "sehingga", "tersebut", "tidak")

# Add document ID and tokenize text
docs <- docs %>%
  mutate(doc_id = row_number())  # Add document identifier

# Tokenize and create the document-term matrix
docs_tokens <- docs %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%           # Remove stop words
  count(doc_id, word, sort = TRUE) %>%
  filter(n > 1) %>%                   # Filter terms that appear more than once
  filter(!word %in% additional_stop_words) %>% # Remove additional common words
  cast_dtm(document = doc_id, term = word, value = n)  # Create Document-Term Matrix


###########################
# Step 4: Fit the LDA Model
###########################

# Set number of topics
k <- 5

# Fit the LDA model
lda_model <- LDA(docs_tokens, k = k, control = list(seed = 1234))

# Extract the topics and terms
topics <- tidy(lda_model, matrix = "beta")


##################################
# Step 5: Visualise in a Wordcloud
##################################

# Get the top 100 terms across all topics
top_100_terms <- topics %>%
  group_by(term) %>%
  summarise(total_beta = sum(beta)) %>%
  arrange(desc(total_beta)) %>%
  slice_max(total_beta, n = 100) %>%
  ungroup()

# Load necessary libraries
library(wordcloud)
library(RColorBrewer)

# Set up colors
colors <- brewer.pal(8, "Dark2")

par(mar = c(1, 1, 1, 1))  # Adjust margins if needed
# Generate the word cloud for the top 100 terms
wordcloud(
  words = top_100_terms$term,
  freq = top_100_terms$total_beta,
  min.freq = 1,
  max.words = 100,
  random.order = FALSE,
  rot.per = 0.35,
  colors = colors,
  scale = c(2.5, 0.5))

title("Top 100 Words Across Dr. Bahlil Lahadalia's Dissertation")


##############################
# Step 6: Visualize the Topics
##############################

# Top Terms for Each Topic:

# Find top 10 terms for each topic
top_terms <- topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Plot top terms for each topic
ggplot(top_terms, aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  labs(title = "Top Terms in Each Topic", y = "Importance (beta)", x = NULL) +
  theme_minimal()


###############################################
# Step 6: Interactive Visualization with LDAvis
###############################################

# Prepare LDAvis data
lda_json <- createJSON(
  phi = posterior(lda_model)$terms,
  theta = posterior(lda_model)$topics,
  doc.length = rowSums(as.matrix(docs_tokens)),
  vocab = colnames(docs_tokens),
  term.frequency = colSums(as.matrix(docs_tokens))
)

# Visualize
serVis(lda_json)
