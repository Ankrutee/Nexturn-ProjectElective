# Nexturn-ProjectElective

Project Overview
The Nexturn-ProjectElective is designed to develop an Analytic Agent for Banking Data. It is a terminal-based application that simplifies SQL query generation based on user input. By integrating Natural Language Processing (NLP) capabilities, this application enhances banking data analysis, making it more intuitive for users to interact with SQL queries. Additionally, the project features a Streamlit-based web application for improved user interaction.

Files in this Repository
This repository contains the following files:
1. main.py: The terminal-based application that handles user input, generates SQL queries, and interacts with the database.
2. bank.sql: The banking database schema used in the application.
3. schemaBank.txt: The schema details of the banking database, used for generating SQL queries.
4. app.py: The Streamlit application that provides a user-friendly interface for interacting with the SQL query generator.
5. requirements.txt: A list of Python dependencies required to run the project.
6. trialQueries.txt: Various SQL queries tested on the code to ensure accuracy and functionality.

Setup Instructions
Prerequisites
Before running this project, make sure you have the following installed:
1. Python 3.6 or higher
2. MySQL database server (configured and running)
3. OpenAI API key (for GPT model usage) and MistralAI key
4. Necessary Python libraries (listed in requirements.txt)

Installing Dependencies
1. To install the required dependencies, use the following command:
pip install -r requirements.txt
2. Database Setup
Create a MySQL database and import the bank.sql file to set up the required database schema.
3. Update the database connection details in the connect_to_mysql() function (in main.py) with your MySQL credentials.
4. OpenAI API Setup and Mistral AI setup
Sign up for OpenAI API and Mistral AI api access if you don't have an account.
5. Replace the placeholder <INSERT YOUR KEY HERE> in the code with your OpenAI and Mistral AI API key in both main.py and app.py.
6. Running the Application

To run the terminal application:
python main.py

To run the Streamlit web application:
streamlit run app.py

User Input
Upon running the application, you can enter a user query (e.g., "Get the total balance of all active accounts"). The application will generate an appropriate SQL query by fetching relevant queries from the database, generating embeddings, and leveraging the OpenAI GPT model.

Exiting the Application
To exit the terminal application, simply type exit when prompted for a query.

Flexibility with Databases
This application can be used with any database. Simply provide the corresponding .sql file with the database schema and include a few predefined queries in the SQL file. The application will work seamlessly with the new database and schema.

