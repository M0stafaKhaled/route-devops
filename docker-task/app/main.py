from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal, engine
from app.redis_client import redis_client

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/users/", response_model=schemas.UserOut)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = models.User(name=user.name)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Cache user name in Redis
    redis_client.set(f"user:{db_user.id}", db_user.name)

    return db_user

@app.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    # Try cache
    name = redis_client.get(f"user:{user_id}")
    if name:
        return {"id": user_id, "name": name, "cached": True}

    # Fallback to DB
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Cache it
    redis_client.set(f"user:{user.id}", user.name)
    return {"id": user.id, "name": user.name, "cached": False}
    

@app.get("/test-redis")
def test_redis():
    try:
        redis_client.set("test_key", "test_value")
        value = redis_client.get("test_key")
        return {"status": "success", "value": value}
    except Exception as e:
        return {"status": "error", "detail": str(e)}
