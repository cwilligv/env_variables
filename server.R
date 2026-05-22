server <- function(input, output, session) {

  # Get config based on R_CONFIG_ACTIVE environment variable
  cfg <- config::get()

  # Current environment
  output$current_env <- renderText({
    env_active <- Sys.getenv("R_CONFIG_ACTIVE", "default")
    paste0("Active Environment: ", toupper(env_active), "\n",
           "Config ENV value: ", cfg$ENV)
  })

  # Database configuration
  output$db_config <- renderTable({
    data.frame(
      Variable = c("MySQL_HOST", "MySQL_USER", "MySQL_PASS", "MySQL_DB", "MySQL_PORT"),
      Value = c(
        ifelse(is.null(cfg$MySQL_HOST), "Not Set", mask_secret(cfg$MySQL_HOST)),
        ifelse(is.null(cfg$MySQL_USER), "Not Set", cfg$MySQL_USER),
        ifelse(is.null(cfg$MySQL_PASS), "Not Set", mask_secret(cfg$MySQL_PASS)),
        ifelse(is.null(cfg$MySQL_DB), "Not Set", cfg$MySQL_DB),
        ifelse(is.null(cfg$MySQL_PORT), "Not Set", as.character(cfg$MySQL_PORT))
      ),
      stringsAsFactors = FALSE
    )
  }, bordered = TRUE, striped = TRUE)

  # API & Authentication configuration
  output$api_config <- renderTable({
    data.frame(
      Variable = c("P_API_KEY", "AUTH0_USER", "AUTH0_KEY", "AUTH0_SECRET", "LLM_API"),
      Value = c(
        ifelse(is.null(cfg$P_API_KEY), "Not Set", mask_secret(cfg$P_API_KEY)),
        ifelse(is.null(cfg$AUTH0_USER), "Not Set", cfg$AUTH0_USER),
        ifelse(is.null(cfg$AUTH0_KEY), "Not Set", mask_secret(cfg$AUTH0_KEY)),
        ifelse(is.null(cfg$AUTH0_SECRET), "Not Set", mask_secret(cfg$AUTH0_SECRET)),
        ifelse(is.null(cfg$LLM_API), "Not Set", mask_secret(cfg$LLM_API))
      ),
      stringsAsFactors = FALSE
    )
  }, bordered = TRUE, striped = TRUE)

  # Email configuration
  output$email_config <- renderTable({
    data.frame(
      Variable = c("EMAIL_USERNAME", "EMAIL_PWD", "EMAIL_PAGOS_USER", "EMAIL_PAGOS_PWD", "EMAIL_SMTP"),
      Value = c(
        ifelse(is.null(cfg$EMAIL_USERNAME), "Not Set", cfg$EMAIL_USERNAME),
        ifelse(is.null(cfg$EMAIL_PWD), "Not Set", mask_secret(cfg$EMAIL_PWD)),
        ifelse(is.null(cfg$EMAIL_PAGOS_USER), "Not Set", cfg$EMAIL_PAGOS_USER),
        ifelse(is.null(cfg$EMAIL_PAGOS_PWD), "Not Set", mask_secret(cfg$EMAIL_PAGOS_PWD)),
        ifelse(is.null(cfg$EMAIL_SMTP), "Not Set", cfg$EMAIL_SMTP)
      ),
      stringsAsFactors = FALSE
    )
  }, bordered = TRUE, striped = TRUE)

  # Raw environment variables (masked)
  output$raw_env <- renderText({
    env_vars <- c(
      "MySQL_HOST", "MySQL_USER", "MySQL_PASS", "MySQL_DB", "MySQL_PORT",
      "P_API_KEY", "EMAIL_USERNAME", "EMAIL_PWD", "EMAIL_PAGOS_USER",
      "EMAIL_PAGOS_PWD", "EMAIL_SMTP", "AUTH0_USER", "AUTH0_KEY",
      "AUTH0_SECRET", "LLM_API"
    )

    output_text <- "Direct Environment Variables:\n\n"
    for (var in env_vars) {
      value <- Sys.getenv(var, "")
      if (value != "") {
        output_text <- paste0(output_text, var, " = ", mask_secret(value), "\n")
      } else {
        output_text <- paste0(output_text, var, " = Not Set\n")
      }
    }
    output_text
  })

  # Helper function to mask secrets
  mask_secret <- function(secret) {
    if (is.null(secret) || secret == "" || is.na(secret)) {
      return("Not Set")
    }
    secret_str <- as.character(secret)
    if (nchar(secret_str) <= 4) {
      return("****")
    }
    paste0(substr(secret_str, 1, 2), "...", substr(secret_str, nchar(secret_str)-1, nchar(secret_str)))
  }
}
