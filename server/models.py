from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean
from sqlalchemy.sql import func
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    display_name = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)
    interests = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class UserBase(BaseModel):
    username: str
    email: EmailStr
    display_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    interests: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserProfile(BaseModel):
    display_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    interests: Optional[str] = None

class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: str
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class ChatMessage(BaseModel):
    message: str
    timestamp: str

class WebRTCMessage(BaseModel):
    type: str
    to: str
    from_user: Optional[str] = None
    sdp: Optional[str] = None
    candidate: Optional[str] = None
    sdpMid: Optional[str] = None
    sdpMLineIndex: Optional[int] = None
