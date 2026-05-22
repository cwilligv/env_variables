library(shiny)
library(bslib)

ui <- page_navbar(
  title = "Environment Variables Viewer",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2C3E50",
    base_font = font_google("Inter")
  ),

  nav_panel(
    title = "Environment Variables",
    icon = icon("key"),

    layout_columns(
      col_widths = c(12),
      card(
        card_header(
          "Current Environment",
          class = "bg-primary text-white"
        ),
        card_body(
          verbatimTextOutput("current_env")
        )
      )
    ),

    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header(
          "Database Configuration",
          class = "bg-info text-white"
        ),
        card_body(
          tableOutput("db_config")
        )
      ),
      card(
        card_header(
          "API & Authentication",
          class = "bg-warning"
        ),
        card_body(
          tableOutput("api_config")
        )
      )
    ),

    layout_columns(
      col_widths = c(12),
      card(
        card_header(
          "Email Configuration",
          class = "bg-success text-white"
        ),
        card_body(
          tableOutput("email_config")
        )
      )
    ),

    layout_columns(
      col_widths = c(12),
      card(
        card_header(
          "Raw Environment Variables",
          class = "bg-primary text-white"
        ),
        card_body(
          verbatimTextOutput("raw_env")
        )
      )
    )
  )
)
