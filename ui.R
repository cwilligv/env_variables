library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Environment Variables Viewer"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Environment Variables", tabName = "env_vars", icon = icon("key"))
    )
  ),

  dashboardBody(
    tabItems(
      tabItem(
        tabName = "env_vars",

        fluidRow(
          box(
            title = "Current Environment",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("current_env")
          )
        ),

        fluidRow(
          box(
            title = "Database Configuration",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            tableOutput("db_config")
          ),

          box(
            title = "API & Authentication",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            tableOutput("api_config")
          )
        ),

        fluidRow(
          box(
            title = "Email Configuration",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            tableOutput("email_config")
          )
        ),

        fluidRow(
          box(
            title = "Raw Environment Variables",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("raw_env")
          )
        )
      )
    )
  )
)
