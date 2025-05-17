import redis
import os


REDIS_HOST = os.getenv("REDIS_HOST", "cashing")  
REDIS_PORT = int(os.getenv("REDIS_PORT", 6370))  
REDIS_DB = int(os.getenv("REDIS_DB", 0))        

redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)