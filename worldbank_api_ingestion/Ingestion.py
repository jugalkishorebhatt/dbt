# !/usr/bin/python

############################################################################################
# file_name: Ingestion.py
# Objective: Extract Worldbank API data 
#
# References:
# 
# https://stackoverflow.com/questions/8134602/psycopg2-insert-multiple-rows-with-one-query
# https://tutswiki.com/read-write-yaml-config-file-in-python/
#
############################################################################################

import logging
import psycopg2
import requests
import json
import sys
import yaml
import ast

"""
Main Ingestion Job
"""
class IngestJob:

    def __init__(self):
        pass
    
if __name__ == "__main__":

    logging.basicConfig(
    format = '[[%(filename)s:%(lineno)s :] %(asctime)s, %(name)s, %(levelname)s, %(message)s', 
    datefmt = '%Y-%m-%d %H:%M:%S', 
    level = logging.INFO)
    
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)


    
    try:
        with open("config.yaml", "r") as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
        print(config)
    except Exception as e:
            logger.error("Config loading failed")
            logger.error(e)
            sys.exit(1)

    try:
        conn = psycopg2.connect(database=config['database'], 
                                user=config['user'], 
                                password=config['password'], 
                                host=config['host'], 
                                port=config['port'], 
                                )
        api_url = config['api_url']
        
        cursor = conn.cursor()

        for page in range(1,101):
            print("========Page Number============>{}".format(page))
            data = requests.get(api_url, params={'page': page}).json()
        
            for a in data[1]:
                print(json.dumps(a))
                cursor.execute("INSERT into postgres.public.worldbank(value) VALUES (%s)",(json.dumps(a),))
                conn.commit()
        conn.close()
    except Exception as e:
            logger.error("Ingestion Job Failed")
            print(e)
            sys.exit(1)