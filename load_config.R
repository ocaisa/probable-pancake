
# Function to merge two lists (with overrides)
merge_lists <- function(base, override) {
  modifyList(base, override)
}

# Load required package
library(yaml)
# Load primary configuration
config <- yaml.load_file("lesson_config.yaml")
# If 'config' key exists, load the second configuration and merge
if (!is.null(config$main_config) && file.exists(config$main_config)) {
  override_config <- yaml.load_file(config$main_config)
  config <- merge_lists(config, override_config)
}

snippets <- paste('files/snippets/', config$snippets, sep='')

# Extract main and fallback paths from config
main_snippets <- config$main_snippets
fallback_snippets <- config$fallback_snippets

# Function to choose the correct document path (or return NULL if neither exists)
choose_doc <- function(child_file) {
  # Get the current document name (without extension)
  current_doc <- tools::file_path_sans_ext(knitr::current_input(dir = TRUE))
  
  # Build paths for the child document inside subdirectories
  doc_paths <- list(
    main = file.path(current_doc, main_snippets, child_file),
    fallback = file.path(current_doc, fallback_snippets, child_file)
  )
  print(doc_paths)
  print(getwd())
  # Return the valid path, or NULL if neither exists
  if (file.exists(doc_paths$main)) {
    print("Returning")
    print(doc_paths$main)
    return(doc_paths$main)
  } else if (file.exists(doc_paths$fallback)) {
    print("Returning")
    print(doc_paths$fallback)
    return(doc_paths$fallback)
  } else {
    print("Returning NULL")
    return(NULL)  # Return NULL if neither path exists
  }
}