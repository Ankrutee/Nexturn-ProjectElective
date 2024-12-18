from transformers import AutoTokenizer, AutoModelForCausalLM
import mysql.connector
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import torch
import os
from huggingface_hub import login
import openai
import streamlit as st

# Streamlit App Title
st.title("Analytic Agent for Banking Data")

# OpenAI API Key Configuration
openai.api_key = "<INSERT YOUR KEY HERE>"

# HuggingFace Hub Login
login(token="<INSERT YOUR KEY HERE>")

# Device Configuration
device = "cpu"

# Load and Configure the Tokenizer and Model
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
tokenizer.add_special_tokens({'pad_token': '[PAD]', 'eos_token': '[EOS]'})
model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1", return_dict_in_generate=True, output_hidden_states=True
)
model = model.to(device)
model.resize_token_embeddings(len(tokenizer))
model.config.pad_token_id = tokenizer.pad_token_id
model.config.eos_token_id = tokenizer.eos_token_id

# MySQL Database Connection
def connect_to_mysql():
    try:
        connection = mysql.connector.connect(
            host="<INSERT>",
            user="<INSERT>",
            password="<INSERT>",
            database="bank"
        )
        return connection
    except mysql.connector.Error as err:
        st.error(f"Database connection error: {err}")
        return None

# Fetch Queries from Database
def fetch_queries_from_db():
    connection = connect_to_mysql()
    if not connection:
        return []
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT description, sql_query FROM queries")
        queries = cursor.fetchall()
        return queries
    finally:
        cursor.close()
        connection.close()

# Generate Embeddings
def get_embeddings(texts):
    embeddings = []
    for text in texts:
        inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512).to(device)
        outputs = None
        with torch.no_grad():
            outputs = model(**inputs)
        last_hidden_state = outputs.hidden_states[-1]
        embedding = last_hidden_state.mean(dim=1).cpu().detach().numpy()
        embeddings.append(embedding)
    return np.vstack(embeddings)

# Find Relevant Queries
def find_relevant_queries(input_prompt, queries, query_embeddings):
    inputs = tokenizer(input_prompt, return_tensors="pt", truncation=True, padding=True, max_length=512).to(device)
    outputs = None
    with torch.no_grad():
        outputs = model(**inputs)
    last_hidden_state = outputs.hidden_states[-1]
    input_prompt_embedding = last_hidden_state.mean(dim=1).cpu().detach().numpy()
    cosine_similarities = cosine_similarity(input_prompt_embedding, query_embeddings)[0]
    top_n_indices = cosine_similarities.argsort()[-3:][::-1]
    relevant_queries = [(queries[i][0], queries[i][1]) for i in top_n_indices]
    return relevant_queries

# Generate SQL Query with OpenAI
def generate_sql_query_with_openai(input_prompt, relevant_queries, schema_file_path):
    try:
        with open(schema_file_path, "r") as schema_file:
            schema_details = schema_file.read()
    except FileNotFoundError:
        st.error(f"Schema file not found at {schema_file_path}.")
        return None

    relevant_queries_text = "\n".join([f"Description: {desc}\nSQL: {sql}" for desc, sql in relevant_queries])
    prompt = f"""
    Below is the database schema for the banking platform:

    {schema_details}

    Here are some relevant SQL queries that match the user's request:

    {relevant_queries_text}

    User Prompt: {input_prompt}

    Based on the above, generate a new SQL query to answer the user's prompt.
    Return the required SQL query in the following format:
    Question = <The user prompt> = Question
    Answer#for#question = <The required SQL query> = Answer#for#question
    """

    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "system", "content": "You are an expert SQL query generator."},
                      {"role": "user", "content": prompt}],
            max_tokens=512
        )
        generated_sql_query = response["choices"][0]["message"]["content"]
        try:
            generated_sql_query = generated_sql_query.split(" = Answer#for#question")[0].split("Answer#for#question = ")[1]
        except IndexError:
            st.error("Failed to extract the SQL query from the OpenAI model output.")
            return None
        return generated_sql_query.strip()
    except Exception as e:
        st.error(f"Error generating SQL query with OpenAI: {e}")
        return None

# Execute SQL Query
def execute_sql_query(sql_query, params=None):
    connection = connect_to_mysql()
    if not connection:
        return []
    try:
        cursor = connection.cursor()
        if params:
            cursor.execute(sql_query, params)
        else:
            cursor.execute(sql_query)
        return cursor.fetchall()
    finally:
        cursor.close()
        connection.close()

# Main Function
def main():
    input_prompt = st.text_input("Enter your query:")
    schema_file_path = "schemaBank.txt"
    
    if st.button("Generate SQL"):
        if not input_prompt:
            st.error("Please enter a query.")
            return
        
        # Fetch Queries
        queries = fetch_queries_from_db()
        if not queries:
            st.error("No queries found in the database.")
            return
        
        # Generate Embeddings
        query_texts = [query[0] for query in queries]
        query_embeddings = get_embeddings(query_texts)
        
        # Find Relevant Queries
        relevant_queries = find_relevant_queries(input_prompt, queries, query_embeddings)
        st.subheader("Relevant Queries:")
        for desc, sql in relevant_queries:
            st.text(f"Description: {desc}")
            st.text(f"SQL: {sql}")
        
        # Generate SQL Query
        generated_sql_query = generate_sql_query_with_openai(input_prompt, relevant_queries, schema_file_path)
        st.subheader("Generated SQL Query:")
        st.code(generated_sql_query)
        
        # Execute the SQL Query
        try:
            result = execute_sql_query(generated_sql_query)
            st.subheader("Query Result:")
            st.write(result)
        except Exception as e:
            st.error(f"Error executing SQL query: {e}")

# Run the Streamlit App
if __name__ == "__main__":
    main()
