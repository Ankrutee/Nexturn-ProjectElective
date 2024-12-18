from transformers import AutoTokenizer, AutoModelForCausalLM
import mysql.connector
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import torch
import os
from huggingface_hub import login
import sys
import openai

# Set your OpenAI API key
openai.api_key = "<INSERT YOUR KEY HERE>"

login(token="<INSERT YOUR KEY HERE>")

# Setting device
device = "cpu"
# Load and configure the tokenizer
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
tokenizer.add_special_tokens({'pad_token': '[PAD]', 'eos_token': '[EOS]'})

# Load the model and resize token embeddings to account for added special tokens
model = AutoModelForCausalLM.from_pretrained("mistralai/Mistral-7B-v0.1", return_dict_in_generate=True, output_hidden_states=True)
model = model.to(device)
model.resize_token_embeddings(len(tokenizer))

# Explicitly set pad_token_id and eos_token_id in the model configuration
model.config.pad_token_id = tokenizer.pad_token_id
model.config.eos_token_id = tokenizer.eos_token_id

def connect_to_mysql():
    """Establish a connection to the MySQL database."""
    try:
        connection = mysql.connector.connect(
            host="<INSERT>",
            user="<INSERT>",
            password="<INSERT>",
            database="bank"
        )
        return connection
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None

# Fetch all SQL queries and their descriptions
def fetch_queries_from_db():
    """Fetch descriptions and SQL queries from the database."""
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

# Generate embeddings using the Mistral model
def get_embeddings(texts):
    """
    Generate embeddings for the provided texts using the Mistral model.
    
    Args:
        texts (list): List of strings to embed.
        
    Returns:
        np.ndarray: Array of embeddings.
    """
    embeddings = []
    for text in texts:
        inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512).to(device)
        outputs = None
        with torch.no_grad():
            outputs = model(**inputs)
        last_hidden_state = outputs.hidden_states[-1]
        # Use the mean pooling of the last hidden state as the embedding
        embedding = last_hidden_state.mean(dim=1).cpu().detach().numpy()
        embeddings.append(embedding)
    return np.vstack(embeddings)

# Calculate cosine similarity between the input prompt and stored queries
def find_relevant_queries(input_prompt, queries, query_embeddings):
    """
    Find the most relevant queries for the input prompt using cosine similarity.
    
    Args:
        input_prompt (str): User's input prompt.
        queries (list): List of queries from the database.
        query_embeddings (np.ndarray): Embeddings of the database queries.
        
    Returns:
        list: List of top 3 relevant queries (description, SQL query).
    """
    inputs = tokenizer(input_prompt, return_tensors="pt", truncation=True, padding=True, max_length=512).to(device)
    outputs=None
    with torch.no_grad():
        outputs = model(**inputs)
    last_hidden_state = outputs.hidden_states[-1]
    input_prompt_embedding = last_hidden_state.mean(dim=1).cpu().detach().numpy()
    
    cosine_similarities = cosine_similarity(input_prompt_embedding, query_embeddings)[0]
    top_n_indices = cosine_similarities.argsort()[-3:][::-1]
    relevant_queries = [(queries[i][0], queries[i][1]) for i in top_n_indices]
    return relevant_queries

def generate_sql_query_with_openai(input_prompt, relevant_queries, schema_file_path):
    """
    Generate a new SQL query using OpenAI GPT model based on the input prompt,
    relevant queries, and database schema.
    
    Args:
        input_prompt (str): User's input prompt.
        relevant_queries (list): List of relevant queries (description, SQL query).
        schema_file_path (str): Path to the schema file.
        
    Returns:
        str: Generated SQL query.
    """
    # Load the schema file
    try:
        with open(schema_file_path, "r") as schema_file:
            schema_details = schema_file.read()
    except FileNotFoundError:
        print(f"Schema file not found at {schema_file_path}.")
        return None
    
    # Prepare the relevant queries text
    relevant_queries_text = "\n".join([f"Description: {desc}\nSQL: {sql}" for desc, sql in relevant_queries])
    
    # Prepare the prompt for OpenAI GPT
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
    
    # Use OpenAI GPT model to generate the SQL query
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "system", "content": "You are an expert SQL query generator."},
                      {"role": "user", "content": prompt}],
            max_tokens=512
        )
        generated_sql_query = response["choices"][0]["message"]["content"]
        
        # Extract the SQL query
        try:
            generated_sql_query = generated_sql_query.split(" = Answer#for#question")[0].split("Answer#for#question = ")[1]
        except IndexError:
            print("Failed to extract the SQL query from the OpenAI model output.")
            return None
        
        return generated_sql_query.strip()
    
    except Exception as e:
        print(f"Error generating SQL query with OpenAI: {e}")
        return None

def execute_sql_query(sql_query, params=None):
    """
    Execute the given SQL query on the MySQL database.
    
    Args:
        sql_query (str): SQL query to execute.
        params (tuple, optional): Parameters for the SQL query.
        
    Returns:
        list: Query result.
    """
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

# Main function
def main(input_prompt):
    """
    Main function to handle the entire flow: fetching queries, generating embeddings,
    finding relevant queries, generating SQL, and executing it.
    
    Args:
        input_prompt (str): User's input prompt.
    """
    # Step 1: Fetch SQL queries and their descriptions
    queries = fetch_queries_from_db()
    if not queries:
        print("No queries found in the database.")
        return

    # Step 2: Generate embeddings for stored queries
    query_texts = [query[0] for query in queries]  # Use descriptions as input
    query_embeddings = get_embeddings(query_texts)

    # Step 3: Find the most relevant queries for the input prompt
    relevant_queries = find_relevant_queries(input_prompt, queries, query_embeddings)
    
    print("Relevant Queries:")
    for desc, sql in relevant_queries:
        print(f"Description: {desc}\nSQL: {sql}\n")
    
    # Step 4: Generate a new SQL query using the LLM
    generated_sql_query = generate_sql_query_with_openai(input_prompt, relevant_queries, schema_file_path)
    print(f"Generated SQL Query: {generated_sql_query}")
    
    # Step 5: Execute the generated SQL query on the database and return the result
    try:
        result = execute_sql_query(generated_sql_query)
        print(f"Query Result: {result}")
    except Exception as e:
        print(f"Error executing SQL query: {e}")

if __name__ == "__main__":
    while True:
        schema_file_path ="schemaBank.txt"
        input_prompt = None
        if len(sys.argv) >= 2:
            input_prompt = sys.argv[1]
        else:
             input_prompt = input("Enter your query (or type 'exit' to quit): ")
        if input_prompt.lower() == "exit":
            print("Exiting the application.")
            break

        main(input_prompt)

