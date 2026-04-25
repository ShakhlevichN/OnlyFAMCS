from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
import json
import asyncio
import uuid
from datetime import datetime, timedelta
import jwt
import bcrypt

from database import get_db, engine, Base
from models import User, UserCreate, UserLogin, UserProfile
from auth import create_access_token, get_current_user, verify_token

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Video Chat Roulette Server", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}
        self.user_profiles: Dict[str, UserProfile] = {}
        self.waiting_users: List[str] = []
        self.chat_pairs: Dict[str, str] = {}

    async def connect(self, websocket: WebSocket, user_id: str, profile: UserProfile):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        self.user_profiles[user_id] = profile

        await self.send_personal_message({
            "type": "connected",
            "userId": user_id
        }, user_id)

    def disconnect(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

        if user_id in self.waiting_users:
            self.waiting_users.remove(user_id)

        if user_id in self.chat_pairs:
            partner_id = self.chat_pairs[user_id]
            del self.chat_pairs[user_id]
            if partner_id in self.chat_pairs:
                del self.chat_pairs[partner_id]

            asyncio.create_task(self.send_personal_message({
                "type": "partner-disconnected"
            }, partner_id))

        if user_id in self.user_profiles:
            del self.user_profiles[user_id]

    async def send_personal_message(self, message: dict, user_id: str):
        if user_id in self.active_connections:
            try:
                await self.active_connections[user_id].send_text(json.dumps(message))
            except:
                self.disconnect(user_id)

    async def broadcast(self, message: dict):
        for connection in self.active_connections.values():
            try:
                await connection.send_text(json.dumps(message))
            except:
                pass

    async def find_partner(self, user_id: str):
        if user_id in self.waiting_users:
            return
        
        if len(self.waiting_users) > 0:
            partner_id = self.waiting_users.pop(0)
            self.chat_pairs[user_id] = partner_id
            self.chat_pairs[partner_id] = user_id

            user_profile = self.user_profiles[user_id]
            partner_profile = self.user_profiles[partner_id]
            
            await self.send_personal_message({
                "type": "partner-found",
                "partnerId": partner_id,
                "partnerProfile": partner_profile.dict()
            }, user_id)
            
            await self.send_personal_message({
                "type": "partner-found", 
                "partnerId": user_id,
                "partnerProfile": user_profile.dict()
            }, partner_id)
        else:
            self.waiting_users.append(user_id)
            await self.send_personal_message({
                "type": "searching"
            }, user_id)

    async def next_partner(self, user_id: str):
        if user_id in self.chat_pairs:
            partner_id = self.chat_pairs[user_id]
            del self.chat_pairs[user_id]
            if partner_id in self.chat_pairs:
                del self.chat_pairs[partner_id]

            await self.send_personal_message({
                "type": "chat-ended"
            }, user_id)
            await self.send_personal_message({
                "type": "chat-ended"
            }, partner_id)

            if partner_id not in self.waiting_users:
                self.waiting_users.append(partner_id)

        await self.find_partner(user_id)

    async def relay_webrtc_message(self, message: dict, from_user: str):
        to_user = message.get("to")
        if to_user and to_user in self.active_connections:
            message["from"] = from_user
            await self.send_personal_message(message, to_user)

manager = ConnectionManager()

@app.post("/api/register")
async def register(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    existing_username = db.query(User).filter(User.username == user.username).first()
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )

    password_bytes = user.password.encode('utf-8')[:72]
    hashed_password = bcrypt.hashpw(password_bytes, bcrypt.gensalt()).decode('utf-8')
    db_user = User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password,
        display_name=user.display_name or user.username
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    access_token = create_access_token(data={"sub": str(db_user.id)})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": db_user.id,
            "username": db_user.username,
            "email": db_user.email,
            "display_name": db_user.display_name,
            "age": db_user.age,
            "gender": db_user.gender,
            "interests": db_user.interests
        }
    }

@app.post("/api/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    # Find user by email
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not bcrypt.checkpw(user.password.encode('utf-8')[:72], db_user.hashed_password.encode('utf-8')):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(data={"sub": str(db_user.id)})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": db_user.id,
            "username": db_user.username,
            "email": db_user.email,
            "display_name": db_user.display_name,
            "age": db_user.age,
            "gender": db_user.gender,
            "interests": db_user.interests
        }
    }

@app.get("/api/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "display_name": current_user.display_name,
        "age": current_user.age,
        "gender": current_user.gender,
        "interests": current_user.interests
    }

@app.put("/api/profile")
async def update_profile(profile: UserProfile, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    current_user.display_name = profile.display_name
    current_user.age = profile.age
    current_user.gender = profile.gender
    current_user.interests = profile.interests
    db.commit()
    db.refresh(current_user)
    
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "display_name": current_user.display_name,
        "age": current_user.age,
        "gender": current_user.gender,
        "interests": current_user.interests
    }

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket, token: str = None):

    if not token:
        await websocket.close(code=4001, reason="No token provided")
        return
    
    try:
        payload = verify_token(token)
        user_id = payload.get("sub")
        if not user_id:
            await websocket.close(code=4001, reason="Invalid token")
            return
    except:
        await websocket.close(code=4001, reason="Invalid token")
        return

    db = next(get_db())
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        await websocket.close(code=4001, reason="User not found")
        return
    
    profile = UserProfile(
        display_name=user.display_name,
        age=user.age,
        gender=user.gender,
        interests=user.interests
    )

    await manager.connect(websocket, user_id, profile)
    
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            message_type = message.get("type")
            
            if message_type == "search":
                await manager.find_partner(user_id)
                
            elif message_type == "next":
                await manager.next_partner(user_id)
                
            elif message_type in ["offer", "answer", "ice-candidate"]:
                await manager.relay_webrtc_message(message, user_id)
                
            elif message_type == "chat-message":
                if user_id in manager.chat_pairs:
                    partner_id = manager.chat_pairs[user_id]
                    await manager.send_personal_message({
                        "type": "chat-message",
                        "from": user_id,
                        "message": message.get("message")
                    }, partner_id)
                    
    except WebSocketDisconnect:
        manager.disconnect(user_id)

@app.get("/")
async def root():
    return {"message": "Video Chat Roulette Server"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
